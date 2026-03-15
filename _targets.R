# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)

# source("output_directory_source_utility.R")
# source("rename_location_files_vector_util.R")

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
    "opentripplanner",
    "geosphere"
  ),
  workspace_on_error = TRUE
)


# Run the R scripts in the R/ folder with your custom functions:
tar_source(c(
  "output_directory_source_utility.R",
  "rename_location_files_vector_util.R",
  "0-shapefiles/PC6_centroids.R",
  "0-shapefiles/PC6_DHZW_Moerwijk.R",
  "0-shapefiles/PC6_DHZW.R",
  "0-shapefiles/PC5_centroids.R",
  "0-shapefiles/PC4_centroids.R",
  "0-synthetic-population/main.R", # Only main, other files not prepared yet
  "0-synthetic-population/src/format-datasets/format-GenSynthPop_to_vanilla.R",
  "1-trips/main.R",
  "1-trips/data_preparation.R",
  "1-trips/utils.R",
  "2-assign-activities",
  "3-locations",
  "4-assign-locations/assign_locations",
  "4-assign-locations/src/",
  "4-assign-locations/main.R",
  "4-assign-locations/data_preparation.R",
  "4-assign-locations/calculate_postcode_activity_distribution.R",
  "5-synthetic-population-to-Sim2APL/merge_locations.R",
  "5-synthetic-population-to-Sim2APL/merge_activities_locations.R",
  # "5-synthetic-population-to-Sim2APL/utils.R",
  "5-synthetic-population-to-Sim2APL/format_to_SIM2APL.R",
  "6-routing/main.R",
  "6-routing/build_graph.R",
  "6-routing/generate_OD.R",
  "6-routing/calculate_euclidean_distance.R",
  "6-routing/utils-otp.R",
  "6-routing/routing_bus.R"
))

list(
  tar_target(config_file, "config.yaml", format = "file"),
  tar_target(config, yaml::read_yaml(config_file)),
  tar_target(output_dir, get_output_path(config)),
  tar_target(final_output_dir, get_final_output_path(config)),
  tar_target(experiment_id, config$experiment_id),

  # Open trip planner depdenencies
  tar_target(otp_data_path, "../dhzw_data/otp"),
  tar_target(otp_java_path, file.path(otp_data_path, "otp-2.2.0-shaded.jar")),


  ## Shapefiles
  tar_target(
    pc6_gpkg,
    "../dhzw_data/2024-cbs_pc6_2021_vol/cbs_pc6_2021_vol.gpkg",
    format = "file"
  ),
  tar_target(
    pc5_gpkg,
    "../dhzw_data/2024-cbs_pc5_2021_vol/cbs_pc5_2021_vol.gpkg",
    format = "file"
  ),
  tar_target(
    pc4_gpkg,
    "../dhzw_data/2025-cbs_pc4_2022_vol/cbs_pc4_2022_vol.gpkg", # 2021 data seemed corrupt
    format = "file"
  ),
  # run shapefiles returns :
  # neighbourhood_codes.csv, neighbourhoods.csv, pc4_codes.csv
  tar_target(neighborhood_codes_csv, here(config$modules$shapefiles, "data", "codes", "DHZW_neighbourhoods_codes.csv"), format = "file"),
  tar_target(neighbourhoods_csv, here(config$modules$shapefiles, "data", "codes", "DHZW_neighbourhoods.csv"), format = "file"),
  tar_target(DHZW_pc4_codes_csv, here(config$modules$shapefiles, "data", "codes", "DHZW_pc4_codes.csv"), format = "file"),

  # PC6
  tar_target(
    centroids_PC6_results,
    generate_pc6_centroids(
      file.path(output_dir, config$modules$shapefiles),
      DHZW_pc4_codes_csv,
      pc6_gpkg
    ),
    format = "file"
  ),
  tar_target(centroids_pc6_NL_shp, centroids_PC6_results[1], format = "file"),
  tar_target(centroids_pc6_NL_csv, centroids_PC6_results[2], format = "file"),
  tar_target(centroids_PC6_DHZW_shp, centroids_PC6_results[3], format = "file"),
  tar_target(centroids_PC6_DHZW_csv, centroids_PC6_results[4], format = "file"),
  tar_target(
    pc6_moerwijk_station_shp,
    generate_pc6_DHZW_moerwijk(
      file.path(output_dir, config$modules$shapefiles),
      pc6_gpkg
    ),
    format = "file"
  ),
  tar_target(
    pc6_DHZW_shp,
    generate_pc6_shp(
      file.path(output_dir, config$modules$shapefiles),
      DHZW_pc4_codes_csv,
      pc6_gpkg
    )
  ),

  # PC5
  tar_target(
    centroids_pc5_results,
    generate_pc5_centroids(
      file.path(output_dir, config$modules$shapefiles),
      DHZW_pc4_codes_csv,
      pc5_gpkg
    )
  ),
  tar_target(centroids_pc5_NL_shp, centroids_pc5_results[1], format = "file"),
  tar_target(centroids_pc5_NL_csv, centroids_pc5_results[2], format = "file"),
  tar_target(centroids_pc5_DHZW_shp, centroids_pc5_results[3], format = "file"),
  tar_target(centroids_pc5_DHZW_csv, centroids_pc5_results[4], format = "file"),

  # PC4
  tar_target(
    centroids_pc4_results,
    generate_pc4_centroids(
      file.path(output_dir, config$modules$shapefiles),
      DHZW_pc4_codes_csv,
      pc4_gpkg
    ),
    format = "file"
  ),
  tar_target(centroids_pc4_NL_shp, centroids_pc4_results[1], format = "file"),
  tar_target(centroids_pc4_NL_csv, centroids_pc4_results[2], format = "file"),
  tar_target(centroids_pc4_DHZW_shp, centroids_pc4_results[3], format = "file"),
  tar_target(centroids_pc4_DHZW_csv, centroids_pc4_results[4], format = "file"),

  ## Synthetic population
  tar_target(
    synthetic_population_source,
    here(config$configuration[[experiment_id]]$module_dir, config$configuration[[experiment_id]]$population),
    format = "file"
  ),
  tar_target(
    synthetic_household_source,
    here(config$configuration[[experiment_id]]$module_dir, config$configuration[[experiment_id]]$households),
    format = "file"
  ),
  tar_target(
    synthetic_population_csv,
    run_synthetic_population(
      file.path(output_dir, config$modules$synthetic_population),
      synthetic_population_source,
      experiment_id,
      synthetic_household_source,
      DHZW_pc4_codes_csv
    ),
    format = "file"
  ),
  tar_target(
    df_households_csv,
    run_synthetic_households(
      file.path(output_dir, config$modules$synthetic_population),
      synthetic_population_csv,
      experiment_id,
      synthetic_household_source,
      DHZW_pc4_codes_csv
    ),
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
  ),

  ## merge_locations
  # merge_activities_locations
  # format_to_SIM2APL.
  # tar_target(
  #   merged_locations_csv,
  #   merge_locations(
  #     file.path(
  #       output_dir, config$modules$synthetic_population_to_sim
  #     ),
  #     location_files_vector
  #   ),
  #   format = "file"
  # ),
  tar_target(
    format_to_sim_activities_locations_csv,
    format_to_sim_merge_locations(
      file.path(output_dir, config$modules$synthetic_population_to_sim),
      synthetic_activities_csv,
      location_files_vector,
      centroids_pc4_NL_csv,
      centroids_pc5_NL_csv,
      centroids_pc6_NL_csv
    ),
    format = "file"
  ),
  tar_target(
    final_activities_locations_csv,
    format_to_sim2apl(
      file.path(output_dir, config$modules$synthetic_population_to_sim),
      final_output_dir,
      synthetic_population_csv,
      location_files_vector,
      format_to_sim_activities_locations_csv
    ),
    format = "file"
  )
  # ,
  # tar_target(
  #   status,
  #   run_routing(
  #     file.path(output_dir, config$modules$routing),
  #     final_output_dir,
  #     otp_data_path,
  #     otp_java_path,
  #     pc6_DHZW_shp,
  #     final_activities_locations_csv,
  #     centroids_pc5_DHZW_csv
  #   ),
  # )
)
