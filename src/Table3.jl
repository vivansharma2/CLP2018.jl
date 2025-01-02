## Reproducing Table 3

using DataFrames
using CSV
using FixedEffectModels
using GLM
using RegressionTables
using HypothesisTests
using Distributions

include("Functions.jl")

df = CSV.read("data/clean/data_cleaned.csv", DataFrame)
df.time_num = vcat([collect(1:size(group, 1)) for group in groupby(df, :State_FIPS)]...)

# Run regressions
model1 = reg(df, @formula(Local_orig~  treatment_frac + fe(State_FIPS) + fe(time_num)), Vcov.cluster(:State_FIPS))
model2 = reg(df, @formula(Intrastate_orig~  treatment_frac + fe(State_FIPS) + fe(time_num)), Vcov.cluster(:State_FIPS))
model3 = reg(df, @formula(Interstate_orig~  treatment_frac + fe(State_FIPS) + fe(time_num)), Vcov.cluster(:State_FIPS))
model4 = reg(df, @formula(ln_local~  treatment_frac + fe(State_FIPS) + fe(time_num)), Vcov.cluster(:State_FIPS))
model5 = reg(df, @formula(ln_intrastate~  treatment_frac + fe(State_FIPS) + fe(time_num)), Vcov.cluster(:State_FIPS))
model6 = reg(df, @formula(ln_interstate~  treatment_frac + fe(State_FIPS) + fe(time_num)), Vcov.cluster(:State_FIPS))

# Create the regression table with all six models
reg_table = regtable(
    model1, model2, model3, model4, model5, model6;  # Models from earlier code
    labels = Dict(
        "Local_orig" => "Local, linear",
        "Intrastate_orig" => "Intrastate, linear",
        "Interstate_orig" => "Interstate, linear",
        "ln_local" => "Local, ln",
        "ln_intrastate" => "Intrastate, ln",
        "ln_interstate" => "Interstate, ln",
    ),
    title = "Effects of Bracero Exclusion on the Three Types of Domestic Seasonal Agricultural Employment",  # Add a title
    notes = ["Clustered standard errors by State_FIPS"]  # Add clustering notes
)
println(reg_table)
write("output/Table3.txt", reg_table)
