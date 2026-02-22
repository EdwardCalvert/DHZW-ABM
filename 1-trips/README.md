
1.  [`data_preparation.R`](data_preparation.R). The script aggregates the survey years and filters the trips of residents of highly urbanised postcodes. Output: `df_trips-higly_urbanized.csv`


## Dependencies

Internal: none
External: full OViN dataset and partial ODiN dataset from 2018,2019,2023 (years skipped due to covid)

## Output

- df_trips-highly_urbanized.csv


## Analysis

[`analysis/activity_distribution_plots.R`](analysis/activity_distribution_plots.R). The script returns the activity type distribution per week and per weekday. Distributions plotted: observed data (ODiN and OViN) of DHZW and highly urbanised postcodes together with the generated data.

To generate the activity schedule of trips of DHZW residents, it is necessary to modifying the individuals filtering in [`data_preparation.R`](data_preparation.R).