format_to_sim2apl <- function(
  output_dir,
  final_output_dir,
  synthetic_population_csv,
  location_files_vector,
  activities_locations_csv
) {
  location_files_vector <- rename_location_files_vector(location_files_vector)
  ################################################################################
  # Synthetic population

  df_synthetic_population <- read.csv(synthetic_population_csv)
  df_synthetic_population <- df_synthetic_population %>%
    dplyr::rename(pid = agent_ID)

  df_synthetic_population$pid <- as.numeric(gsub("[^0-9.-]", "", df_synthetic_population$pid))

  ################################################################################
  # Households
  df_households <- read.csv(location_files_vector["household_locations_full_csv"])
  df_households$PC4 <- gsub(".{2}$", "", df_households$PC6)

  ################################################################################
  # Activities
  df_activities <- read.csv(activities_locations_csv)
  df_activities <- df_activities %>%
    dplyr::rename(pid = agent_ID)
  df_activities$pid <- as.numeric(gsub("[^0-9.-]", "", df_activities$pid))

  # Shift Sunday at the end of the week
  df_activities$day_of_week <- recode(
    df_activities$day_of_week,
    "1" = "7",
    "2" = "1",
    "3" = "2",
    "4" = "3",
    "5" = "4",
    "6" = "5",
    "7" = "6"
  )
  df_activities$day_of_week <- as.numeric(df_activities$day_of_week)

  # Remove all the activities that in a day happens the day after (even better to just delete them when generating the activities...)
  df_activities <- df_activities[df_activities$start_time < 86400, ]

  # Calculate time from beginning of the week (required by Sim2APL)
  df_activities$start_time_seconds <- (((df_activities$day_of_week - 1) * 86400) + df_activities$start_time) #* 60
  df_activities$duration_seconds <- df_activities$duration #* 60

  # Modify the activity_number from the beginning of the week till the end of it
  df_activities <- df_activities %>%
    arrange(pid, start_time_seconds) %>%
    group_by(pid) %>%
    mutate(activity_number = row_number(pid))

  # rename column
  df_activities <- df_activities %>%
    rename(start_time_within_day = start_time)

  df_activities$postcode <- NA
  df_activities[df_activities$in_DHZW == 1, ]$postcode <- as.character(df_activities[df_activities$in_DHZW == 1, ]$PC5)
  df_activities[df_activities$in_DHZW == 0, ]$postcode <- as.character(df_activities[df_activities$in_DHZW == 0, ]$PC4)

  df_activities <- df_activities %>%
    select(pid, hh_ID, activity_number, activity_type, day_of_week, start_time_seconds, duration_seconds, in_DHZW, postcode, coordinate_y, coordinate_x)

  ################################################################################
  # Sample

  df_households_sample <- df_households[sample(nrow(df_households), 100), ]
  df_synthetic_population_sample <- df_synthetic_population[df_synthetic_population$hh_ID %in% df_households_sample$hh_ID, ]
  df_activities_sample <- df_activities[df_activities$pid %in% df_synthetic_population_sample$pid, ]

  options(scipen = 999)


  synthentic_population_sample_csv <- file.path(output_dir, "DHZW_synthetic_population_sample.csv")
  write.csv(df_synthetic_population_sample, synthentic_population_sample_csv, row.names = FALSE, quote = FALSE)

  households_sample_csv <- file.path(output_dir, "DHZW_households_sample.csv")
  write.csv(df_households_sample, households_sample_csv, row.names = FALSE, quote = FALSE)

  activities_locations_sample_csv <- file.path(output_dir, "DHZW_activities_locations_sample.csv")
  write.csv(df_activities_sample, activities_locations_sample_csv, row.names = FALSE, quote = FALSE)

  table(df_activities_sample$activity_type)

  ################################################################################

  final_synthetic_population_csv <- file.path(final_output_dir, "DHZW_synthetic_population.csv")
  write.csv(df_synthetic_population, final_synthetic_population_csv, row.names = FALSE, quote = FALSE)

  final_households_csv <- file.path(final_output_dir, "DHZW_households.csv")
  write.csv(df_households, final_households_csv, row.names = FALSE, quote = FALSE)

  final_activities_locations_csv <- file.path(final_output_dir, "DHZW_activities_locations.csv")
  write.csv(df_activities, final_activities_locations_csv, row.names = FALSE, quote = FALSE)

  return(final_activities_locations_csv)
}
