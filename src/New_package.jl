module New_package

using Test, HypothesisTests, Statistics, Plots, StatFiles, CSV, DataFrames, Dates, ReadStatTables, ReadStat, PanelDataTools, FixedEffectModels, GLM, RegressionTables, Distributions, PrettyTables, CategoricalArrays

function run()
    include("src/Functions.jl")
    include("src/Data_cleaning.jl")
    include("src/Table1.jl")
    include("src/Table2.jl")
    include("src/Table3.jl")
    include("src/Figure2.jl")
    include("src/Figure3.jl")
end 

export run
end