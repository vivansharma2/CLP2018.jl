using .New_package
using Test
using DataFrames

# Test: generate_fallmax function
@testset "generate_fallmax" begin
    # Create a sample DataFrame
    df = DataFrame(
        State_FIPS = [1, 1, 1, 2, 2, 2],
        Year = [2020, 2020, 2021, 2020, 2021, 2021],
        fall = [1, 1, 0, 1, 0, 1],
        target_var = [10, 20, 30, 40, 50, 60],
        Month = [10, 11, 12, 1, 2, 3]
    )
    
    # Apply the function
    df = generate_fallmax(df, :target_var, :fallmax)

    # Check that the new column 'fallmax' has been created and contains the correct values
    @test !:fallmax in names(df)  # Check if the column was added
    @test df.fallmax[1] == 20  # For State_FIPS=1, Year=2020, max of target_var when fall=1 should be 20
    @test df.fallmax[2] == 20  # For State_FIPS=1, Year=2020, max of target_var when fall=1 should be 20
    @test df.fallmax[3] == missing  # For State_FIPS=1, Year=2021, fall=0 should be missing
    @test df.fallmax[4] == 40  # For State_FIPS=2, Year=2020, max of target_var when fall=1 should be 40
    @test df.fallmax[5] == missing  # For State_FIPS=2, Year=2021, fall=0 should be missing
    @test df.fallmax[6] == 60  # For State_FIPS=2, Year=2021, max of target_var when fall=1 should be 60
end