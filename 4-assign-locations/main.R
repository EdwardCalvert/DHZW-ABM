run_assign_locations <- function(
  output_dir,
  odin_ovin_dir,
  urbanisation_pc4_csv,
  DHZW_pc4_codes_csv,
  displacements_DHZW_csv,
  synthetic_population_csv,
  synthetic_activities_nonspatial_csv,
  location_files_vector,
  centroids_PC6_DHZW_csv,
  centroids_pc4_DHZW_shp
) {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  # Set names here due to some issue with the targets framework.
  location_files_vector <- setNames(
    location_files_vector,
    c(
      "work_locations_csv",
      "sport_locations_csv",
      "shopping_locations_csv",
      "household_locations_full_csv",
      "household_locations_minimal_csv",
      "school_locations_shp",
      "school_locations_csv",
      "merged_locations_csv"
    )
  )

  displacements_DHZW_csv <- calculate_ODiN_displacements(
    output_dir,
    odin_ovin_dir,
    urbanisation_pc4_csv,
    DHZW_pc4_codes_csv
  )

  ODiN_activity_distributions_vector <- calculate_postcode_activity_distribution(
    output_dir,
    DHZW_pc4_codes_csv,
    displacements_DHZW_csv
  )

  df_activities <- read.csv(synthetic_activities_nonspatial_csv)

  df_assigned_activity <- df_activities |>
    assign_home_locations(
      synthetic_population_csv,
      location_files_vector["household_locations_minimal_csv"]
    ) |>
    assign_school_locations(
      location_files_vector["school_locations_csv"],
      synthetic_population_csv,
      centroids_PC6_DHZW_csv,
      DHZW_pc4_codes_csv,
      ODiN_activity_distributions_vector$ODiN_school_daycare_act_prop_csv,
      ODiN_activity_distributions_vector$ODiN_school_primary_act_prop_csv,
      ODiN_activity_distributions_vector$ODiN_school_highschool_act_prop_csv,
      ODiN_activity_distributions_vector$ODiN_univeristy_act_prop_csv
    ) |>
    assign_shopping_locations(
      ODiN_activity_distributions_vector$ODiN_shopping_act_prop_csv,
      synthetic_population_csv,
      location_files_vector["shopping_locations_csv"],
      centroids_pc4_DHZW_shp,
      DHZW_pc4_codes_csv
    ) |>
    assign_sport_locations(
      ODiN_activity_distributions_vector$ODiN_sport_act_prop_csv,
      synthetic_population_csv,
      location_files_vector["sport_locations_csv"],
      centroids_pc4_DHZW_shp,
      DHZW_pc4_codes_csv
    ) |>
    assign_work_locations(
      ODiN_activity_distributions_vector$ODiN_work_act_prop_csv,
      synthetic_population_csv,
      location_files_vector["work_locations_csv"],
      centroids_pc4_DHZW_shp,
      DHZW_pc4_codes_csv
    )

  print("summary:")
  print(nrow(df_activities[df_activities$activity_type == "sport" & is.na(df_activities$lid), ]))
  nrow(df_activities[df_activities$activity_type == "home" & is.na(df_activities$lid), ])
  nrow(df_activities[df_activities$activity_type == "work" & is.na(df_activities$lid), ])
  nrow(df_activities[df_activities$activity_type == "school" & is.na(df_activities$lid), ])

  synthetic_activities_csv <- file.path(output_dir, "synthetic_activites.csv")
  write.csv(df_assigned_activity, synthetic_activities_csv, row.names = FALSE)

  return(synthetic_activities_csv)
}
