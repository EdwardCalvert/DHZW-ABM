run_assign_activites <- function(output_dir, highly_urbanised_trips_csv) {
  # Step 1:
  df_activities_all <- get_activites_from_trips(highly_urbanised_trips_csv)

  activity_schedule_csv <- file.path(output_dir, "df_activity_schedule-higly_urbanized.csv")
  write.csv(df_activities_all, activity_schedule_csv, row.names = FALSE)


  # Step 2:
  df_outcome <- match_IDs_synthetic_odin_ovin(highly_urbanised_trips_csv, synthetic_population)

  matched_population_and_odin_ids_csv <- file.path(output_dir, "df_match_synthetic_ODiN_IDs.csv")
  write.csv(df_outcome, matched_population_and_odin_ids_csv, row.names = FALSE)


  # Step 3:
  df <- merge_population_and_odin_schedules(activity_schedule_csv, matched_population_and_odin_ids_csv)

  synthetic_activites_csv <- file.path(output_dir, "df_synthetic_activities.csv")
  write.csv(df, synthetic_activites_csv, row.names = FALSE)
  # c(activity_schedule_csv,matched_population_and_odin_ids_csv,
  return(synthetic_activites_csv)
}
