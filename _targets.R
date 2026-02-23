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



# Run the R scripts in the R/ folder with your custom functions:
tar_source(c(
  "0-shapefiles/main.R", #Only main, other files not ready yet
  "0-synthetic-population/main.R", #Only main, other files not prepared yet
  "1-trips/main.R",
  "1-trips/data_preparation.R",
  "1-trips/utils.R"
  #"2-assign_activities"
))

list(
  tar_target(config_file, "config.yaml", format = "file"),
  tar_target(config, yaml::read_yaml(config_file)),
  tar_target(output_dir,get_output_path(config)),
  
  
  ## Shapefiles
  tar_target(
    shapefile_sources,
    c(
      here(config$modules$shapefiles, "data", "codes", "DHZW_neighbourhoods_codes.csv"),
      here(config$modules$shapefiles, "data", "codes", "DHZW_neighbourhoods.csv"),
      here(config$modules$shapefiles, "data", "codes", "DHZW_pc4_codes.csv")
    ),
    format = "file"
  ),
  
  tar_target(
    shapefiles,
    run_shapefiles(file.path(output_dir, config$modules$shapefiles), shapefile_sources),
    format = "file"
  ),
  #run shapefiles returns :
  # neighbourhood_codes.csv, neighbourhoods.csv, pc4_codes.csv
  tar_target(neighborhood_codes_csv, shapefiles[1], format="file"),
  tar_target(neighbourhoods_csv, shapefiles[2], format="file"),
  tar_target(pc4_codes_csv, shapefiles[3], format="file"),
  
  ## Synthetic population
  #Aware this is pointless to copy, but leave for time being!?
  tar_target(
    synthetic_population_source,
    here(config$modules$synthetic_population,"output", "synthetic-population-households","synthetic_population_DHZW_2019.csv"),
    format="file"
  ),
  tar_target(
    synthetic_populations, 
    run_synthetic_population(file.path(output_dir,config$modules$synthetic_population ),synthetic_population_source),
    format="file"
  ),
  
  
  ## NEED TO ENCAPSULATE THESE DIRECTORIES INTO CONFIG FILE!!!!!!
  ## Trips
  tar_target(odin_ovin_dir, "../dhzw_data/odin-ovin", format = "file"),
  tar_target(urbanisation_pc4_csv, "../dhzw_data/pc4_2021_vol.csv", format = "file"),
  
  tar_target(highly_urbanised_trips_csv,
    run_trips(
      file.path(output_dir,config$modules$trips),
      odin_ovin_dir, 
      urbanisation_pc4_csv, 
      pc4_codes_csv
    ),
    format = "file"
  )
  
)
