# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)

source("output_directory_source_utility.R")

tar_option_set(
  packages = c(
    "tibble",
    "haven",
    "dplyr",
    "tibble",
    "tidyr",
    "readr",
    "nnet",
    "purrr",
    "this.path",
    "data.table",
    "sf",
    # "plyr", #remove due to namespace masking issues.
    "here",
    "yaml",
    "opentripplanner"
  ),
  workspace_on_error = TRUE
)


# Run the R scripts in the R/ folder with your custom functions:
tar_source(c(
  "0-shapefiles/main.R", # Only main, other files not ready yet
  "0-shapefiles/PC6_centroids.R",
  "0-shapefiles/PC4_centroids.R",
  "0-synthetic-population/main.R", # Only main, other files not prepared yet
  "1-trips/main.R",
  "1-trips/data_preparation.R",
  "1-trips/utils.R",
  "2-assign-activities",
  "3-locations",
  "4-assign-locations/assign_locations",
  "4-assign-locations/src/",
  "4-assign-locations/main.R",
  "4-assign-locations/data_preparation.R",
  "4-assign-locations/calculate_postcode_activity_distribution.R"
))

list(
  tar_target(config_file, "config.yaml", format = "file"),
  tar_target(config, yaml::read_yaml(config_file)),
  tar_target(output_dir, get_output_path(config)),


  ## Shapefiles
  tar_target(
    pc6_gpkg,
    "../dhzw_data/2024-cbs_pc6_2021_vol/cbs_pc6_2021_vol.gpkg",
    format = "file"
  ),
  tar_target(
    pc4_gpkg,
    "../dhzw_data/2025-cbs_pc4_2022_vol/cbs_pc4_2022_vol.gpkg", # 2021 data seemed corrupt
    format = "file"
  ),
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
  # run shapefiles returns :
  # neighbourhood_codes.csv, neighbourhoods.csv, pc4_codes.csv
  tar_target(neighborhood_codes_csv, shapefiles[1], format = "file"),
  tar_target(neighbourhoods_csv, shapefiles[2], format = "file"),
  tar_target(DHZW_pc4_codes_csv, shapefiles[3], format = "file"),
  tar_target(
    centroids_PC6_DHZW_csv,
    generate_pc6_centroids(
      file.path(output_dir, config$modules$shapefiles),
      DHZW_pc4_codes_csv,
      pc6_gpkg
    ),
    format = "file"
  ),
  tar_target(
    centroids_pc4_DHZW_shp,
    generate_pc4_centroids(
      file.path(output_dir, config$modules$shapefiles),
      DHZW_pc4_codes_csv,
      pc4_gpkg
    ),
    format = "file"
  ),

  ## Synthetic population
  # Aware this is pointless to copy, but leave for time being!?
  tar_target(
    synthetic_population_source,
    here(config$modules$synthetic_population, "output", "synthetic-population-households", "synthetic_population_DHZW_2019.csv"),
    format = "file"
  ),
  tar_target(
    synthetic_population_csv,
    run_synthetic_population(
      file.path(output_dir, config$modules$synthetic_population),
      synthetic_population_source
    ),
    format = "file"
  ),
  tar_target(
    df_households_csv,
    here(config$modules$synthetic_population, "output", "synthetic-population-households", "df_households_DHZW_2019.csv"),
    format = "file"
  ),

  ## Trips
  ## NEED TO ENCAPSULATE THESE DIRECTORIES INTO CONFIG FILE!!!!!!
  tar_target(odin_ovin_dir, "../dhzw_data/odin-ovin", format = "file"),
  tar_target(urbanisation_pc4_csv, "../dhzw_data/pc4_2021_vol.csv", format = "file"),
  tar_target(highly_urbanised_trips_csv,
    run_trips(
      file.path(output_dir, config$modules$trips),
      odin_ovin_dir,
      urbanisation_pc4_csv,
      DHZW_pc4_codes_csv
    ),
    format = "file"
  ),

  ## Assign activities
  tar_target(
    synthetic_activities_nonspatial_csv,
    run_assign_activities(
      file.path(output_dir, config$modules$assign_activities),
      highly_urbanised_trips_csv,
      synthetic_population_csv
    ),
    format = "file"
  ),

  ## Locations
  # start by loading neccessary data
  ## NEED TO ENCAPSULATE THESE DIRECTORIES INTO CONFIG FILE!!!!!!
  tar_target(
    the_hague_BAG_shp,
    "../dhzw_data/adressendenhaag/adressendenhaag.shp",
    format = "file"
  ),
  tar_target(
    schools_municipality_shp,
    "../dhzw_data/schoolgebouwen/schoolgebouwen.shp",
    format = "file"
  ),
  tar_target(
    esri_living_atlas_schools_shp,
    "../dhzw_data/DUO_Onderwijslocaties/Onderwijslocaties_adres.shp",
    format = "file"
  ),
  tar_target(
    location_files_vector,
    run_locations(
      file.path(output_dir, config$modules$locations),
      df_households_csv,
      the_hague_BAG_shp,
      schools_municipality_shp,
      esri_living_atlas_schools_shp,
      centroids_PC6_DHZW_csv,
      DHZW_pc4_codes_csv
    ),
    format = "file"
  ),

  ## assign locations
  tar_target(
    synthetic_activities_csv,
    run_assign_locations(
      file.path(
        output_dir, config$modules$assign_locations
      ),
      odin_ovin_dir,
      urbanisation_pc4_csv,
      DHZW_pc4_codes_csv,
      displacements_DHZW_csv,
      synthetic_population_csv,
      synthetic_activities_nonspatial_csv,
      location_files_vector,
      centroids_PC6_DHZW_csv,
      centroids_pc4_DHZW_shp
    ),
    format = "file"
  )
)
