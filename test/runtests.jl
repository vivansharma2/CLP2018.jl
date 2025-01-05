using CLP2018
using Test
using DataFrames
using StatFiles
using CSV
using Statistics

stata_df = DataFrame(load("test/testing.dta"))
df = DataFrame(CSV.File("data/clean/data_cleaned.csv"))

@testset "CLP2018.jl" begin
    columns_to_test = [:fallmax_mex_frac, :springmax_mex_frac, :yrmax_Mexican, :yrmax_domestic_seasonal]
    
    for col in columns_to_test
        stata_mean = mean(skipmissing(stata_df[!, col])) 
        julia_mean = mean(skipmissing(df[!, col]))
        @test isapprox(stata_mean, julia_mean, atol=1e-1)
    end 

    col_names_stata = [:yrmax_Local_final, :yrmax_Intrastate_final, :yrmax_Interstate_final]
    col_names_df = [:yrmax_Local_orig, :yrmax_Intrastate_orig, :yrmax_Interstate_orig]

    for (col1, col2) in zip(col_names_stata, col_names_df)
        mean_stata = mean(skipmissing(stata_df[!, col1])) 
        mean_df = mean(skipmissing(df[!, col2]))
        @test isapprox(mean_stata, mean_df, atol=1e-1)
    end 
end