## Miscellaneous functions
using HypothesisTests

# Function to check dataset columns with missing values
function safe_mean(x)
    if sum(ismissing, x) == length(x)
        missing
    else
        mean(skipmissing(x))
    end
end

# Function to compute the quarter numerically
function calc_diff(dataframe, time_column::Symbol)
    # Base date
    base_date = Date(1960, 1, 1)
    # month to quarter conversion
    month_to_quarter(month) = begin
        if month <= 3
            1
        elseif month <= 6
            2
        elseif month <= 9
            3
        else
            4
        end
    end
    # Calculate the difference 
    quarters_diff = (year.(dataframe[!, time_column]) .- year(base_date)) .* 4 .+
                          (month_to_quarter.(month.(dataframe[!, time_column])) .- 1)
    return quarters_diff
end

# Generating functions for calculating seasonal maxes
### FALLMAX
function generate_fallmax(df::DataFrame, target_var::Symbol, new_var::Symbol)
    # Generate a copy of the variable
    a = df[:, target_var]
    df.b = a
    df.b[df.fall .== 0] .= missing

    df[!, new_var] = similar(df[!, target_var], Union{Float64, Missing})

    # Get unique combinations of `:State_FIPS` and `:Year`
    unique_combos = unique(df[:, [:State_FIPS, :Year]])

    # Loop over each unique combination
    for combo in eachrow(unique_combos)
        # Filter rows matching the current combination
        mask = (df.State_FIPS .== combo.State_FIPS) .& (df.Year .== combo.Year)
        
        # Extract the values of the target variable for the current combination
        values = df[!, :b][mask]
        
        # Find the maximum value, ignoring missing values
        max_val = if all(ismissing, values)
            missing
        else
            maximum(skipmissing(values))
        end

        # Assign the maximum value to all matching rows
        df[!, new_var][mask] .= max_val
    end

    # Set new_var to missing where fall == 0
    df[!, new_var][df.fall .== 0] .= missing
    return df
end

### SPRINGMAX
function generate_springmax(df::DataFrame, target_var::Symbol, new_var::Symbol)
    # Generate a copy of the variable
    a = df[:, target_var]
    df.b = a
    df.b[df.springsummer .== 0] .= missing

    df[!, new_var] = similar(df[!, target_var], Union{Float64, Missing})

    # Get unique combinations of `:State_FIPS` and `:Year`
    unique_combos = unique(df[:, [:State_FIPS, :Year]])

    # Loop over each unique combination
    for combo in eachrow(unique_combos)
        # Filter rows matching the current combination
        mask = (df.State_FIPS .== combo.State_FIPS) .& (df.Year .== combo.Year)
        
        # Extract the values of the target variable for the current combination
        values = df[!, :b][mask]
        
        # Find the maximum value, ignoring missing values
        max_val = if all(ismissing, values)
            missing
        else
            maximum(skipmissing(values))
        end

        # Assign the maximum value to all matching rows
        df[!, new_var][mask] .= max_val
    end

    # Set new_var to missing where fall == 0
    df[!, new_var][df.springsummer .== 0] .= missing
    return df
end

function seamax_means!(df::DataFrame, target_col::Symbol, condition_type::Symbol)
    # Ensure condition_type is one of :none, :low, :high
    if !(condition_type in [:none, :low, :high])
        throw(ArgumentError("condition_type must be one of :none, :low, or :high"))
    end

    # Create the conditional column based on the specified condition_type
    conditional_col = Symbol(target_col, "_", condition_type)
    df[!, conditional_col] = ifelse.(df[!, condition_type] .== 1, df[!, target_col], missing)

    # Get the unique levels of `time_h`
    unique_time_h = unique(df.time_h)
    
    # Initialize a dictionary to store the mean for each `time_h`
    mean_dict = Dict{eltype(df.time_h), Union{Float64, Missing}}()
    
    # Calculate the mean for each `time_h`, skipping missing values
    for t in unique_time_h
        # Filter rows with the current `time_h`
        subset = filter(row -> row.time_h == t, df)
        
        # Calculate the mean of the conditional column
        mean_value = isempty(skipmissing(subset[!, conditional_col])) ? missing : mean(skipmissing(subset[!, conditional_col]))
        
        # Store the result in the dictionary
        mean_dict[t] = mean_value
    end
    
    # Allocate the mean value to each row where the condition is met
    for row in eachrow(df)
        if row[condition_type] == 1
            row[conditional_col] = mean_dict[row.time_h]
        end
    end
    
    # Replace NaN with missing in the conditional column
    replace!(df[!, conditional_col], NaN => missing)
    
    return df
end

# Generating functions for calculating seasonal means
### FALLMEAN
function generate_fallmean(df::DataFrame, target_var::Symbol, new_var::Symbol)
    # Generate a copy of the variable
    a = df[:, target_var]
    df.b = a
    df.b[df.Month .< 7] .= missing

    df[!, new_var] = similar(df[!, target_var], Union{Float64, Missing})

    # Get unique combinations of `:State_FIPS` and `:Year`
    unique_combos = unique(df[:, [:State_FIPS, :Year]])

    # Loop over each unique combination
    for combo in eachrow(unique_combos)
        # Filter rows matching the current combination
        mask = (df.State_FIPS .== combo.State_FIPS) .& (df.Year .== combo.Year)
        
        # Extract the values of the target variable for the current combination
        values = df[!, :b][mask]
        
        # Find the maximum value, ignoring missing values
        mean_val = if all(ismissing, values)
            missing
        else
            mean(skipmissing(values))
        end

        # Assign the maximum value to all matching rows
        df[!, new_var][mask] .= mean_val
    end

    # Set new_var to missing where fall == 0
    df[!, new_var][df.Month .< 7] .= missing
    return df
end

### SPRINGMEAN
function generate_springmean(df::DataFrame, target_var::Symbol, new_var::Symbol)
    # Generate a copy of the variable
    a = df[:, target_var]
    df.b = a
    df.b[df.Month .> 6] .= missing

    df[!, new_var] = similar(df[!, target_var], Union{Float64, Missing})

    # Get unique combinations of `:State_FIPS` and `:Year`
    unique_combos = unique(df[:, [:State_FIPS, :Year]])

    # Loop over each unique combination
    for combo in eachrow(unique_combos)
        # Filter rows matching the current combination
        mask = (df.State_FIPS .== combo.State_FIPS) .& (df.Year .== combo.Year)
        
        # Extract the values of the target variable for the current combination
        values = df[!, :b][mask]
        
        # Find the maximum value, ignoring missing values
        mean_val = if all(ismissing, values)
            missing
        else
            mean(skipmissing(values))
        end

        # Assign the maximum value to all matching rows
        df[!, new_var][mask] .= mean_val
    end

    # Set new_var to missing where spring == 0
    df[!, new_var][df.Month .> 6] .= missing
    return df
end

function season_means!(df::DataFrame, target_col::Symbol, condition_type::Symbol)
    # Ensure condition_type is one of :none, :low, :high
    if !(condition_type in [:none, :low, :high])
        throw(ArgumentError("condition_type must be one of :none, :low, or :high"))
    end

    # Create the conditional column based on the specified condition_type
    conditional_col = Symbol("season_", target_col, "_", condition_type)
    df[!, conditional_col] = ifelse.(df[!, condition_type] .== 1, df[!, target_col], missing)

    # Get the unique levels of `time_h`
    unique_time_h = unique(df.time_h)
    
    # Initialize a dictionary to store the mean for each `time_h`
    mean_dict = Dict{eltype(df.time_h), Union{Float64, Missing}}()
    
    # Calculate the mean for each `time_h`, skipping missing values
    for t in unique_time_h
        # Filter rows with the current `time_h`
        subset = filter(row -> row.time_h == t, df)
        
        # Calculate the mean of the conditional column
        mean_value = isempty(skipmissing(subset[!, conditional_col])) ? missing : mean(skipmissing(subset[!, conditional_col]))
        
        # Store the result in the dictionary
        mean_dict[t] = mean_value
    end
    
    # Allocate the mean value to each row where the condition is met
    for row in eachrow(df)
        if row[condition_type] == 1
            row[conditional_col] = mean_dict[row.time_h]
        end
    end
    
    # Replace NaN with missing in the conditional column
    replace!(df[!, conditional_col], NaN => missing)
    
    return df
end

# Generating function for calculating yearly maxes
function generate_yrmax(df::DataFrame, target_var::Symbol, new_var::Symbol)
    # Generate a copy of the variable
    a = df[:, target_var]
    df.b = a

    df[!, new_var] = similar(df[!, target_var], Union{Float64, Missing})

    # Get unique combinations of `:State_FIPS` and `:Year`
    unique_combos = unique(df[:, [:State_FIPS, :Year]])

    # Loop over each unique combination
    for combo in eachrow(unique_combos)
        # Filter rows matching the current combination
        mask = (df.State_FIPS .== combo.State_FIPS) .& (df.Year .== combo.Year)
        
        # Extract the values of the target variable for the current combination
        values = df[!, :b][mask]
        
        # Find the maximum value, ignoring missing values
        max_val = if all(ismissing, values)
            missing
        else
            maximum(skipmissing(values))
        end

        # Assign the maximum value to all matching rows
        df[!, new_var][mask] .= max_val
    end
    return df
end

function yrmax_means!(df::DataFrame, target_col::Symbol, condition_type::Symbol)
    # Ensure condition_type is one of :none, :low, :high
    if !(condition_type in [:none, :low, :high])
        throw(ArgumentError("condition_type must be one of :none, :low, or :high"))
    end

    # Create the conditional column based on the specified condition_type
    conditional_col = Symbol(target_col, "_", condition_type)
    df[!, conditional_col] = ifelse.(df[!, condition_type] .== 1, df[!, target_col], missing)

    # Get the unique levels of `time_h`
    unique_year = unique(df.Year)
    
    # Initialize a dictionary to store the mean for each `time_h`
    mean_dict = Dict{eltype(df.Year), Union{Float64, Missing}}()
    
    # Calculate the mean for each `time_h`, skipping missing values
    for t in unique_year
        # Filter rows with the current `time_h`
        subset = filter(row -> row.Year == t, df)
        
        # Calculate the mean of the conditional column
        mean_value = isempty(skipmissing(subset[!, conditional_col])) ? missing : mean(skipmissing(subset[!, conditional_col]))
        
        # Store the result in the dictionary
        mean_dict[t] = mean_value
    end
    
    # Allocate the mean value to each row where the condition is met
    for row in eachrow(df)
        if row[condition_type] == 1
            row[conditional_col] = mean_dict[row.Year]
        end
    end
    
    # Replace NaN with missing in the conditional column
    replace!(df[!, conditional_col], NaN => missing)
    
    return df
end
