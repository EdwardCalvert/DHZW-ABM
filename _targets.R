# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

source("output_directory_source_utility.R")
# Set target options:
tar_option_set(
  packages = c("tibble", "haven", "dplyr", "tibble", "tidyr", "readr") 
)


output_dir <-get_output_path()
config <- yaml::read_yaml(here("config.yaml"))

# Run the R scripts in the R/ folder with your custom functions:
tar_source(c(
  "0-shapefiles",
  "0-synthetic-population",
  "1-trips",
  "2-assign_activities"
))
# tar_source("other_functions.R") # Source other scripts as needed.

shapefile_folder <- config$modules$shapefiles
synthetic_population_folder <- config$modules$synthetic-population
# Replace the target list below with your own:
list(
  ## Shapefiles
  tar_target(
    shapefiles, 
    run_shapefiles(file.path(output_dir,shapefile_folder)), 
    format="file",
  ),
  #run shapefiles returns :
  # neighbourhood_codes.csv, neighbourhoods.csv, pc4_codes.csv
  tar_target(neighborhood_codes_csv, shapefiles[0], format="file"),
  tar_target(neighbourhoods_csv, shapefiles[1], format="file"),
  tar_target(pc4_codes_csv, shapefiles[2], format="file"),
  
  ##Synthetic population
  tar_target(
    synthetic_populations, 
    run_synthetic_population(file.path(output_dir,synthetic_population_folder )),
    format="file"
  )
  
)
