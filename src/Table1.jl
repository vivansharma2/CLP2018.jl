## Reproducing Table 1

using DataFrames
using CSV
using FixedEffectModels
using GLM
using RegressionTables
using HypothesisTests
using Distributions
using PrettyTables
using CategoricalArrays

include("Functions.jl")

df = CSV.read("Data/clean/data_cleaned.csv", DataFrame)

## TABLE 1
## PART 1
df1 = filter(:quarterly_flag => identity, df) # Quarterly data only

df1.time_q_plus = df1[!, :time_q] .+ 100
df1.time_q_plus = categorical(df1.time_q_plus)

model1 = reg(df1, @formula(realwage_hourly ~  treatment_frac + fe(State_FIPS) + fe(time_q_plus)), Vcov.cluster(:State_FIPS))
model2 = reg(df1, @formula(realwage_daily ~  treatment_frac + fe(State_FIPS) + fe(time_q_plus)), Vcov.cluster(:State_FIPS))

# Filter data for the years 1960–1970
df2 = filter(row -> row.Year >= 1960 && row.Year <= 1970, df1)

model3 = reg(df2, @formula(realwage_hourly ~  treatment_frac + fe(State_FIPS) + fe(time_q_plus)), Vcov.cluster(:State_FIPS))
model4 = reg(df2, @formula(realwage_daily ~  treatment_frac + fe(State_FIPS) + fe(time_q_plus)), Vcov.cluster(:State_FIPS))

# Create the regression table with all four models
reg_table = regtable(
    model1, model2, model3, model4;  # Models from earlier code
    labels = Dict(
        "realwage_hourly" => "Hourly Composite",
        "realwage_daily" => "Daily w/o Board"
    ),
    title = "Effects of Bracero Exclusion on Real Wages",  # Add a title
    notes = ["Clustered standard errors by State_FIPS"]  # Add clustering notes
)
println(reg_table)

## PART 2 - Semi-elasticities

# Define models and their formulas
formulas = [
    @formula(ln_realwage_hourly ~ treatment_frac + fe(State_FIPS) + fe(time_q_plus)),
    @formula(ln_realwage_daily ~ treatment_frac + fe(State_FIPS) + fe(time_q_plus))
]

# Initialize storage for results (empty DataFrame)
results = DataFrame(
    model = Int[],
    coef = Float64[],
    se = Float64[],
    fstat = Float64[],
    p_value = Float64[]
)

# Define dataframes
dataframes = [df1, df2]
null = 0.1

for (i, formula) in enumerate(formulas)  # Use enumerate to get the model index
    for df in dataframes
        # Declare variables as local to avoid scope ambiguity
        local model
        local df_numerator
        local df_denominator
        # Run regression
        model = reg(df, formula, Vcov.cluster(:State_FIPS))
        
        # Extract coefficient and standard error for treatment_frac
        coef_val = coef(model)[1]
        se_val = stderror(model)[1]
        
        # Calculate F-statistic
        fstat_val = (coef_val - null)^2 / (se_val^2)
        
        # Degrees of freedom
        df_numerator = 1
        df_denominator = model.dof_residual
        
        # Compute p-value
        p_val = 1 - Distributions.cdf(FDist(df_numerator, df_denominator), fstat_val)
        
        # Store results with the model index (i) instead of formula and no need to store df
        push!(results, (i, coef_val, se_val, fstat_val, p_val))
    end
end

## Here is part two of table 1: the first two rows correspond to the "Hourly Composite" columns in the paper, and the last two correspond to the "Daily w/0 Board"
table1_b = pretty_table(results)

write("output/Table1_a.txt", reg_table)