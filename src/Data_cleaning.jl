# This is code to replicate the outputs from the article "Immigration Restrictions as Active Labor Market Policy:
# Evidence from the Mexican Bracero Exclusion" (2018) by Michael A. Clemens, Ethan G. Lewis, and Hannah M. Postel. 

using StatFiles
using CSV
using DataFrames
using Dates
using Statistics
using ReadStatTables
using ReadStat
using PanelDataTools

include("Functions.jl")

df = CSV.read("data/raw/data_bracero_aer.csv", DataFrame)
sort!(df, [:State, :Year])  # Sort the DataFrame by State and Year columns

# Clean miscoded Cotton_machine values
df[(df.State .== "FL") .& (df.Year .> 1969) .& (df.Cotton_machine .== 0) .& .!ismissing.(df.Cotton_machine), :Cotton_machine] .= missing
df[(df.State .== "VA") .& (df.Year .> 1965) .& (df.Cotton_machine .== 0) .& .!ismissing.(df.Cotton_machine), :Cotton_machine] .= missing

# Generate flags
df[!, :january] .= 0
df[!, :april] .= 0
df[!, :july] .= 0
df[!, :october] .= 0

df[!, :january][df.Month .== 1] .= 1
df[!, :april][df.Month .== 4] .= 1
df[!, :july][df.Month .== 7] .= 1
df[!, :october][df.Month .== 10] .= 1

# Create the 'quarterly_flag' column
df[!, :quarterly_flag] .= [month in [1, 4, 7, 10] for month in df.Month]# True (1) for Jan, Apr, Jul, Oct, else False (0)
# Create the 'quarter' column with default values
df[!, :quarter] .= 1  # Initialize the quarter column to 1
df[!, :quarter][(df.Month .== 4) .| (df.Month .== 5) .| (df.Month .== 6)] .= 2  # For Apr, May, Jun
df[!, :quarter][(df.Month .== 7) .| (df.Month .== 8) .| (df.Month .== 9)] .= 3  # For Jul, Aug, Sep
df[!, :quarter][(df.Month .== 10) .| (df.Month .== 11) .| (df.Month .== 12)] .= 4  # For Oct, Nov, Dec

# Create a Date using the Year, Month, and a fixed day (e.g., 1st of the month)
df[!, :time_m] .= Date.(df.Year, df.Month, 1)

# Quarter dates - numeric
base_date = Date(1960, 1, 1)
df[!, :time_q] .= Date.(df.Year, df.quarter, 1)
df.time_q .= calc_diff(df, :time_m)

df[!, :Mexican] .= df.Mexican_final
df[!, :ln_Mexican] .= (df.Mexican .> 0) .* log.(df.Mexican)

# Drop rows where time_m or State_FIPS are missing
filter!(row -> !ismissing(row.time_m) && !ismissing(row.State_FIPS), df)

# Create the fulldata column based on the given condition
df.fulldata = ((df.Year .>= 1954 .&& df.Month .>= 7) .| (df.Year .>= 1955)) .&& (df.Year .<= 1972)

# Replace missing Mexican values where fulldata is true
df[ismissing.(df.Mexican) .&& df.fulldata .== true, :Mexican] .= 0

df.TotalHiredSeasonal .= df.TotalHiredSeasonal_final
df.NonMexican .= df.TotalHiredSeasonal .- df.Mexican
df.ln_NonMexican .= (df.NonMexican .> 0) .* log.(df.NonMexican)
df.ln_HiredWorkersonFarms .= (df.HiredWorkersonFarms_final .> 0) .* log.(df.HiredWorkersonFarms_final)
df.mex_frac .= (df.TotalHiredSeasonal .> 0) .* (df.Mexican ./ df.TotalHiredSeasonal) # Denominator is hired seasonal farmworkers
df.mex_frac_tot .= df.Mexican ./ (df.Farmworkers_Hired .* 1000)

# Seting up the Panel 
sort!(df, [:State_FIPS, :time_m])
paneldf!(df, :State_FIPS, :time_m)

# Merge dataframes
df1 = CSV.read("Data/raw/data_cpi.csv", DataFrame)
df1.time_m .= Date("1960-01-01") .+ Month.(Int.(df1.time_m))

dfm = leftjoin(df, df1, on = [:State_FIPS, :time_m])

# Price adjustment and real wage calculations
dfm.priceadjust .= dfm.cpi ./ 0.1966401  # Divide by the value of the index in January 1965
dfm.realwage_daily .= dfm.DailywoBoard_final ./ dfm.priceadjust
dfm.realwage_daily1 = coalesce.(dfm.realwage_daily, 0)

dfm.realwage_hourly .= dfm.HourlyComposite_final ./ dfm.priceadjust
dfm.realwage_hourly1 = coalesce.(dfm.realwage_hourly, 0)

# Drop columns
select!(dfm, Not([:cpi, :priceadjust]))

# Generate employment data
sort!(dfm, [:State, :time_m])

# Generate the row totals for domestic seasonal workers
# Store original values as separate columns
dfm[!, :Local_orig] .= dfm.Local_final
dfm[!, :Intrastate_orig] .= dfm.Intrastate_final
dfm[!, :Interstate_orig] .= dfm.Interstate_final

# Replace values with 0 if Local_orig is missing
dfm.Local_orig[ismissing.(dfm.Local_orig)] .= 0
dfm.Intrastate_orig[ismissing.(dfm.Local_orig)] .= 0
dfm.Interstate_orig[ismissing.(dfm.Local_orig)] .= 0

# Replace values with missing if Year is outside the valid range or conditions
dfm.Local_orig .= ifelse.((dfm.Year .< 1954) .| (dfm.Year .> 1973) .| ((dfm.Year .== 1973) .& (dfm.Month .> 7)), missing, dfm.Local_orig)
dfm.Intrastate_orig .= ifelse.((dfm.Year .< 1954) .| (dfm.Year .> 1973) .| ((dfm.Year .== 1973) .& (dfm.Month .> 7)), missing, dfm.Intrastate_orig)
dfm.Interstate_orig .= ifelse.((dfm.Year .< 1954) .| (dfm.Year .> 1973) .| ((dfm.Year .== 1973) .& (dfm.Month .> 7)), missing, dfm.Interstate_orig)

# Rowtotals
dfm[!, [:Local_final, :Intrastate_final, :Interstate_final]] .= coalesce.(dfm[:, [:Local_final, :Intrastate_final, :Interstate_final]], 0)
dfm[:, :domestic_seasonal] = sum.(eachrow(dfm[:, [:Local_final, :Intrastate_final, :Interstate_final]])) 

dfm.ln_domestic_seasonal .= (dfm.domestic_seasonal .> 0) .* log.(dfm.domestic_seasonal)
dfm.ln_domestic_seasonal = Union{Missing, Float64}[dfm.ln_domestic_seasonal...]
dfm.ln_domestic_seasonal[dfm.domestic_seasonal .== 0] .= missing

dfm.ln_foreign .= (dfm.TotalForeign_final .> 0) .* log.(dfm.TotalForeign_final)

# Generate fractions
dfm.dom_frac .= dfm.domestic_seasonal ./ dfm.TotalHiredSeasonal_final
dfm.for_frac .= dfm.TotalForeign_final ./ dfm.TotalHiredSeasonal_final

# Generate log for specific categories
dfm.ln_local .= (dfm.Local_final .> 0) .* log.(dfm.Local_final)
dfm.ln_local = Union{Missing, Float64}[dfm.ln_local...]
dfm.ln_local[dfm.Local_final .== 0] .= missing

dfm.ln_intrastate .= (dfm.Intrastate_final .> 0) .* log.(dfm.Intrastate_final)
dfm.ln_intrastate = Union{Missing, Float64}[dfm.ln_intrastate...]
dfm.ln_intrastate[dfm.Intrastate_final .== 0] .= missing

dfm.ln_interstate .= (dfm.Interstate_final .> 0) .* log.(dfm.Interstate_final)
dfm.ln_interstate = Union{Missing, Float64}[dfm.ln_interstate...]
dfm.ln_interstate[dfm.Interstate_final .== 0] .= missing

# Replace values for domestic seasonal workers if year is outside the specified range
dfm.domestic_seasonal .= ifelse.((dfm.Year .< 1954) .| (dfm.Year .> 1973) .| ((dfm.Year .== 1973) .& (dfm.Month .> 7)), missing, dfm.domestic_seasonal)
dfm.ln_domestic_seasonal .= ifelse.((dfm.Year .< 1954) .| (dfm.Year .> 1973) .| ((dfm.Year .== 1973) .& (dfm.Month .> 7)), missing, dfm.ln_domestic_seasonal)

# Normalizing by, respectively, data from the latest Census of Agriculture before 1955 and latest Census of Population before 1955:

dfm.mex_area = dfm.Mexican ./ (dfm.cropland_1954/1000)
dfm.dom_area = dfm.domestic_seasonal ./ (dfm.cropland_1954/1000)
dfm.mex_pop = dfm.Mexican ./ (dfm.pop1950/1000)
dfm.dom_pop = dfm.domestic_seasonal ./ (dfm.pop1950/1000)

dfm.Farmworkers_Hired_pop = (dfm.Farmworkers_Hired * 1000) ./ (dfm.pop1950 / 1000)
dfm.Farmworkers_Hired_area = (dfm.Farmworkers_Hired * 1000) ./ (dfm.cropland_1954 / 1000)

dfm.mex_frac_55 = ifelse.(dfm.Year .== 1955, dfm.Mexican ./ (dfm.Mexican .+ dfm.NonMexican), missing)

# Collapse by State for mex_frac_55
cdf = combine(groupby(dfm, :State), :mex_frac_55 => (x -> mean(skipmissing(x))) => :m_mex_frac_55)
cdf.m_mex_frac_55 .= ifelse.(isnan.(cdf.m_mex_frac_55), missing, cdf.m_mex_frac_55)
sort!(cdf, :State)
CSV.write("Data/clean/merge_util.csv", cdf)  

df2 = CSV.read("Data/clean/merge_util.csv", DataFrame)
dfm_1 = leftjoin(dfm, df2, on=:State)
select!(dfm_1, Not(:mex_frac_55))
rename!(dfm_1, :m_mex_frac_55 => :mex_frac_55)

dfm_1.post = dfm_1.Year .>= 1965                # Create 'post' column
dfm_1.treatment_frac = dfm_1.post .* dfm_1.mex_frac_55 # Create 'treatment_frac' column

dfm_1.post_2 = dfm_1.Year .>= 1962              # Create 'post_2' column
dfm_1.treatment_frac_2 = dfm_1.post_2 .* dfm_1.mex_frac_55  # Create 'treatment_frac_2' column

dfm_1.ln_realwage_hourly .= (dfm_1.realwage_hourly1 .> 0) .* log.(dfm_1.realwage_hourly1)
dfm_1.ln_realwage_hourly = Union{Missing, Float64}[dfm_1.ln_realwage_hourly...]
dfm_1.ln_realwage_hourly[dfm_1.realwage_hourly1 .== 0] .= missing

dfm_1.ln_realwage_daily .= (dfm_1.realwage_daily1 .> 0) .* log.(dfm_1.realwage_daily1)
dfm_1.ln_realwage_daily = Union{Missing, Float64}[dfm_1.ln_realwage_daily...]
dfm_1.ln_realwage_daily[dfm_1.realwage_daily1 .== 0] .= missing

dfm_1.farm_tot_57 = ifelse.(dfm_1.Year .== 1957, dfm_1.Farmworkers_Hired * 1000, missing)

# Collapse by State for farm_tot_57
cdf1 = combine(groupby(dfm_1, :State), :farm_tot_57 => (x -> mean(skipmissing(x))) => :m_farm_tot_57)
cdf1.m_farm_tot_57 .= ifelse.(isnan.(cdf1.m_farm_tot_57), missing, cdf1.m_farm_tot_57)
sort!(cdf1, :State)
CSV.write("Data/clean/merge_util1.csv", cdf1)  

df3 = CSV.read("Data/clean/merge_util1.csv", DataFrame)
dfm_2 = leftjoin(dfm_1, df3, on=:State)
select!(dfm_2, Not(:farm_tot_57))
rename!(dfm_2, :m_farm_tot_57 => :farm_tot_57)

dfm_2.none = (.!ismissing.(dfm_2.mex_frac_55)) .& (dfm_2.mex_frac_55 .== 0)
dfm_2.low = (.!ismissing.(dfm_2.mex_frac_55)) .& (dfm_2.mex_frac_55 .> 0) .& (dfm_2.mex_frac_55 .< 0.2)
dfm_2.high = (.!ismissing.(dfm_2.mex_frac_55)) .& (dfm_2.mex_frac_55 .>= 0.2)

sort!(dfm_2, [:State_FIPS, :time_m])

CSV.write("Data/clean/data_cleaned.csv", dfm_2)
## END ##