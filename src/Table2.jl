## Reproducing Table 2

using DataFrames
using CSV
using FixedEffectModels
using GLM
using RegressionTables
using HypothesisTests
using Distributions

include("Functions.jl")

df = CSV.read("data/clean/data_cleaned.csv", DataFrame)

## TABLE 2
# Generating indicators
df.time_num = vcat([collect(1:size(group, 1)) for group in groupby(df, :State_FIPS)]...)
df.time_num = categorical(df.time_num)
# Set the base category to 0
levels!(df.time_num, unique([0; df.time_num])) 

df_subset = filter(row -> row.Year >= 1960 && row.Year <= 1970, df)
df_filtered = filter(row -> row.none == 0, df)
sort!(df, [:State_FIPS, :time_m])
sort!(df_subset, [:State_FIPS, :time_m])
sort!(df_filtered, [:State_FIPS, :time_m])

model1 = reg(df, @formula(domestic_seasonal~  treatment_frac + time_num + fe(State_FIPS) + fe(time_m)), Vcov.cluster(:State_FIPS))
model2 = reg(df, @formula(ln_domestic_seasonal~  treatment_frac + time_num + fe(State_FIPS) + fe(time_m)), Vcov.cluster(:State_FIPS))
model3 = reg(df_subset, @formula(domestic_seasonal~  treatment_frac + time_num + fe(State_FIPS) + fe(time_m)), Vcov.cluster(:State_FIPS))
model4 = reg(df_subset, @formula(ln_domestic_seasonal~  treatment_frac + time_num + fe(State_FIPS) + fe(time_m)), Vcov.cluster(:State_FIPS))
model5 = reg(df_filtered, @formula(domestic_seasonal~  treatment_frac + time_num + fe(State_FIPS) + fe(time_m)), Vcov.cluster(:State_FIPS))
model6 = reg(df_filtered, @formula(ln_domestic_seasonal~  treatment_frac + time_num + fe(State_FIPS) + fe(time_m)), Vcov.cluster(:State_FIPS))

# Create the regression table with all six models
reg_table = regtable(
    model1, model2, model3, model4, model5, model6;  # Models from earlier code
    labels = Dict(
        "domestic_seasonal" => "Linear",
        "ln_domestic_seasonal" => "ln"
    ),
    title = "Effects of Bracero Exclusion on Domestic Seasonal Agricultural Employment",  # Add a title
    notes = ["Clustered standard errors by State_FIPS"]  # Add clustering notes
)
println(reg_table)
write("output/Table2.txt", reg_table)