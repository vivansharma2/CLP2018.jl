## Reproducing Figure 3a

using DataFrames
using Statistics 
using Plots

include("Functions.jl")

df = CSV.read("Data/clean/data_cleaned.csv", DataFrame)
sort!(df, [:State_FIPS, :Year])

## Figure 3a
# Generate variables
generate_yrmax(df, :Mexican, :yrmax_Mexican)
generate_yrmax(df, :domestic_seasonal, :yrmax_domestic_seasonal)

yrmax_means!(df, :yrmax_Mexican, :none)
yrmax_means!(df, :yrmax_Mexican, :low)
yrmax_means!(df, :yrmax_Mexican, :high)

yrmax_means!(df, :yrmax_domestic_seasonal, :none)
yrmax_means!(df, :yrmax_domestic_seasonal, :low)
yrmax_means!(df, :yrmax_domestic_seasonal, :high)

# Plot both Mexican and domestic_seasonal
p = plot(df.Year, df.yrmax_Mexican_none, 
     label="No exposure",
     seriestype=:step,   
     linewidth=2,                  
     xlabel="Year",                  
     ylabel="Average mexican workers per state (year peak)",  
     linestyle=:dash,
    )  

plot!(p, df.Year, df.yrmax_Mexican_low, 
     label="Low exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

plot!(p, df.Year, df.yrmax_Mexican_high, 
     label="High exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

vline!([1962, 1965], linecolor=:black, linestyle=:dot, label = "")

m = plot(df.Year, df.yrmax_domestic_seasonal_none, 
     label="No exposure",
     seriestype=:step,   
     linewidth=2,                  
     xlabel="Year",                  
     ylabel="Average domestic workers per state (year peak)",  
     linestyle=:dash,
    )  

plot!(m, df.Year, df.yrmax_domestic_seasonal_low, 
     label="Low exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

plot!(m, df.Year, df.yrmax_domestic_seasonal_high, 
     label="High exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

vline!([1962, 1965], linecolor=:black, linestyle=:dot, label = "")
combined_plot = plot(p, m, layout=(2, 1), size=(1000, 800))
savefig("output/Figure3a.png")

## Figure 3b

generate_yrmax(df, :Local_orig, :yrmax_Local_orig)
generate_yrmax(df, :Intrastate_orig, :yrmax_Intrastate_orig)
generate_yrmax(df, :Interstate_orig, :yrmax_Interstate_orig)

yrmax_means!(df, :yrmax_Local_orig, :none)
yrmax_means!(df, :yrmax_Local_orig, :low)
yrmax_means!(df, :yrmax_Local_orig, :high)

yrmax_means!(df, :yrmax_Intrastate_orig, :none)
yrmax_means!(df, :yrmax_Intrastate_orig, :low)
yrmax_means!(df, :yrmax_Intrastate_orig, :high)

yrmax_means!(df, :yrmax_Interstate_orig, :none)
yrmax_means!(df, :yrmax_Interstate_orig, :low)
yrmax_means!(df, :yrmax_Interstate_orig, :high)

# Plot all three
p1 = plot(df.Year, df.yrmax_Local_orig_none, 
     label="No exposure",
     seriestype=:step,   
     linewidth=2,                  
     xlabel="Year",                  
     ylabel="Average local workers (year peak)",
     ylims=(0, 60000),  
     linestyle=:dash,
    )  

plot!(p1, df.Year, df.yrmax_Local_orig_low,
     label="Low exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

plot!(p1, df.Year, df.yrmax_Local_orig_high, 
     label="High exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

vline!([1962, 1965], linecolor=:black, linestyle=:dot, label = "")

p2 = plot(df.Year, df.yrmax_Intrastate_orig_none, 
     label="No exposure",
     seriestype=:step,   
     linewidth=2,                  
     xlabel="Year",                  
     ylabel="Average intrastate workers (year peak)",  
     ylims=(0, 60000),
     linestyle=:dash,
    )  

plot!(p2, df.Year, df.yrmax_Intrastate_orig_low,
     label="Low exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

plot!(p2, df.Year, df.yrmax_Intrastate_orig_high, 
     label="High exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

vline!([1962, 1965], linecolor=:black, linestyle=:dot, label = "")

p3 = plot(df.Year, df.yrmax_Interstate_orig_none, 
     label="No exposure",
     seriestype=:step,   
     linewidth=2,                  
     xlabel="Year",                  
     ylabel="Average interstate workers (year peak)", 
     ylims=(0, 60000), 
     linestyle=:dash,
     )  

plot!(p3, df.Year, df.yrmax_Interstate_orig_low, 
     label="Low exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

plot!(p3, df.Year, df.yrmax_Interstate_orig_high, 
     label="High exposure", 
     seriestype=:step, 
     linewidth=2, 
     linestyle=:solid)

vline!([1962, 1965], linecolor=:black, linestyle=:dot, label = "")

combined_plot1 = plot(p1, p2, p3, layout=(3, 1), size=(800, 1400))
savefig("output/Figure3b.png")
