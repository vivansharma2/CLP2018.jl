# Replication exercise for Computational Economics
Authors: Guillaume POUSSE, Morgane SOUFFLET, Vivan SHARMA

## Overview and Data Availability
This is the ReadMe for a replication of Clemens, Lews & Postel, "Immigration Restrictions as Active Labor Market Policy: Evidence from the Mexican Bracero Exclusion." (2018). The citation can be found below. 
The original code was in STATA, and can be found [here](https://www.openicpsr.org/openicpsr/project/113187/version/V1/view) alongside the data used.

*Clemens, Michael A., Ethan G. Lewis, and Hannah M. Postel. 2018. "Immigration Restrictions as Active Labor Market Policy: Evidence from the Mexican Bracero Exclusion." American Economic Review, 108 (6): 1468–87.*

## Computational Requirements
- Julia (produced using version 1.11.2)
- The following packages: 
    - Test
    - HypothesisTests
    - Statistics
    - Plots
    - StatFiles
    - CSV
    - DataFrames
    - Dates
    - ReadStatTables
    - ReadStat
    - PanelDataTools
    - FixedEffectModels
    - GLM
    - RegressionTables
    - Distributions
    - PrettyTables
    - CategoricalArrays

## Scripts
The files are named after their respective purposes. *Data_cleaning.jl* cleans the raw data and exports the cleaned csv.'s to the output folder. *Table1.jl, Table2.jl, Table3.jl* all produce regression tables by the same number as in the paper. Similarly, *Figure2.jl, Figure3.jl* do the same for the graphs. *Functions.jl* is a script wherein intermediate functions are defined. These functions are used in several of the other scripts. Lastly, *CLP2018.jl* is the main file of interest - it defines the package.

## Instructions for replication
1. Go to your computer's terminal and open Julia's package manager.
2. Enter: `add "https://github.com/vivansharma2/CLP2018.jl"`
3. Return to the Julia REPL.
4. Enter: `using CLP2018`
5. Make sure that you are in the correct directory. If not, use `cd("path/to/your/data/CLP2018")` to get to the relevant envrionment. The code uses relative filepaths for this particular environment.
6. Enter: `CLP2018.run()`
7. This should run all of the code and produce all of the output.

## Notes on replication
For the most part, we were able to fully replicate the main findings of the paper. We had discrepancies in Table 2, most probably originating from how we dealt with missing values. We observed that the authors of the paper generated a variable *domestic_seasonal* as the rowtotal of three other variables. They defined it such that it took the value 0 if all three inputs were missing and added whatever values were available, even if one or two of the others were missing. They converted all observations outside of a certain time frame to missings. We believe that this is a problematic approach, and can bias the estimates from the regression. While there will be a loss in explanatory power, the regression results could change significantly if we turned the zeros summed from missing inputs into missing values. Perhaps this could warrant further discussion into the matter.



