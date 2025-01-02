## Reproducing Figure 2a

using Dates
using CSV
using DataFrames
using Statistics 
using Plots

include("Functions.jl")

df = CSV.read("Data/clean/data_cleaned.csv", DataFrame)
sort!(df, [:State_FIPS, :Year])

# Semesters of the Year 
df.semester .=1 
df.semester[df.Month .>= 7] .= 2
df.time_h = Date.(df.Year, (df.semester .- 1) .* 6 .+ 1, 1)

# Seasons of the Year
df.springsummer = in.(df.Month, Ref([3, 4, 5, 6, 7]))
df.fall = in.(df.Month, Ref([8, 9, 10, 11]))

# Get unique combinations of `:State_FIPS` and `:Year`
unique_combos = unique(df[:, [:State_FIPS, :Year]])

# Generate variables
generate_fallmax(df, :mex_frac, :fallmax_mex_frac)
generate_springmax(df, :mex_frac, :springmax_mex_frac)

df.seamax_mex_frac = df.springmax_mex_frac
df[!, :seamax_mex_frac] .= coalesce.(df[!, :seamax_mex_frac], df[!, :fallmax_mex_frac])

seamax_means!(df,:seamax_mex_frac, :none)
seamax_means!(df,:seamax_mex_frac, :low)
seamax_means!(df,:seamax_mex_frac, :high)

# Filter for time period
for row in eachrow(df)
    if row.fulldata == 0
        row.seamax_mex_frac_none = missing
        row.seamax_mex_frac_low = missing
        row.seamax_mex_frac_high = missing
    end
end

# Plot
p = plot(df.Year, df.seamax_mex_frac_none, 
     label="No exposure",
     seriestype=:step,   
     linewidth=2,                  
     xlabel="Year",                  
     ylabel="Average Mexican Fraction (season peak)",  
     linestyle=:dash,
    )  

plot!(p, df.Year, df.seamax_mex_frac_low, 
     label="Low exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

plot!(p, df.Year, df.seamax_mex_frac_high, 
     label="High exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

vline!([1962, 1965], linecolor=:black, linestyle=:dot, label = "")

savefig("output/Figure2a.png")

## Figure 2b

generate_fallmean(df, :realwage_hourly, :fallmean_realwage_hourly)
generate_springmean(df, :realwage_hourly, :springmean_realwage_hourly)

season_means!(df, :realwage_hourly, :none)
season_means!(df, :realwage_hourly, :low)
season_means!(df, :realwage_hourly, :high)

m = plot(df.Year, df.season_realwage_hourly_none,
     label="No exposure",
     seriestype=:step,   
     linewidth=2,                  
     xlabel="Year",                  
     ylabel="Hourly wage, composite (1965 USD /hour)",  
     linestyle=:dash,
    )  

plot!(m, df.Year, df.season_realwage_hourly_low, 
     label="Low exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

plot!(m, df.Year, df.season_realwage_hourly_high, 
     label="High exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)
vline!([1962, 1965], linecolor=:black, linestyle=:dot, label = "")

savefig("output/Figure2b.png")
