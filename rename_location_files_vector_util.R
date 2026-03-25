rename_location_files_vector <- function(location_files_vector) {
  return(setNames(
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
  ))
}
