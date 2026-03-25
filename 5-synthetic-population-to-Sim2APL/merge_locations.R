format_to_sim_merge_locations <- function(output_dir, location_files_vector) {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE) # first in file, no main.R

  location_files_vector <- rename_location_files_vector(location_files_vector)

  # Read locations
  df_homes <- read.csv(location_files_vector["household_locations_full_csv"])
  colnames(df_homes)
  df_homes <- df_homes %>%
    select("PC6", "PC4", "longitude", "latitude", "type", "lid")

  df_work <- read.csv(location_files_vector["work_locations_csv"])
  colnames(df_work)

  df_schools <- as.data.frame(st_read(location_files_vector["school_locations_shp"]))
  df_schools <- df_schools %>%
    select(PC6, PC4, longitude, latitude, type, lid)
  colnames(df_schools)

  df_shoppings <- read.csv(location_files_vector["shopping_locations_csv"])
  colnames(df_shoppings)

  df_sport <- read.csv(location_files_vector["sport_locations_csv"])
  colnames(df_sport)

  df_locations <- rbind(
    df_homes,
    df_work,
    df_schools,
    df_shoppings,
    df_sport
  )


  merged_locations_csv <- file.path(output_dir, "merged_locations.csv")
  write.csv(df_locations, merged_locations_csv, row.names = FALSE)

  return(merged_locations_csv)
}
