run_locations <- function(
  output_dir,
  df_households_csv,
  the_hague_BAG_shp,
  schools_municipality_shp,
  esri_living_atlas_schools_shp,
  centroids_PC6_DHZW_csv,
  DHZW_pc4_codes_csv
) {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  results <- run_work_retail_sport_location_extraction(
    the_hague_BAG_shp,
    DHZW_pc4_codes_csv
  )

  work_locations_csv <- file.path(output_dir, "work_DHZW.csv")

  write.csv(
    results$work,
    work_locations_csv,
    row.names = FALSE
  )

  sport_locations_csv <- file.path(output_dir, "sport_DHZW.csv")
  write.csv(
    results$sport,
    sport_locations_csv,
    row.names = FALSE
  )

  shopping_locations_csv <- file.path(output_dir, "retail_DHZW.csv")
  write.csv(
    results$retail,
    shopping_locations_csv,
    row.names = FALSE
  )

  # Households

  household_results <- format_households(df_households_csv, centroids_PC6_DHZW_csv)

  household_locations_full_csv <- file.path(
    output_dir,
    "df_households_full_info.csv"
  )
  write.csv(
    household_results$df_households_full,
    household_locations_full_csv,
    row.names = FALSE
  )

  household_locations_minimal_csv <- file.path(
    output_dir,
    "df_households_minimal.csv"
  )
  write.csv(
    household_results$df_households_minimal,
    household_locations_minimal_csv,
    row.names = FALSE
  )


  # Schools

  df_schools <- format_schools(
    schools_municipality_shp,
    esri_living_atlas_schools_shp,
    DHZW_pc4_codes_csv
  )

  school_locations_shp <- file.path(output_dir, "schools_DHZW.shp")
  st_write(df_schools, school_locations_shp, delete_layer = TRUE)

  df_schools <- data.frame(df_schools)
  df_schools <- subset(df_schools, select = -c(geometry))

  school_locations_csv <- file.path(output_dir, "school_DHZW.csv")
  write.csv(df_schools, school_locations_csv, row.names = FALSE)


  df_merged_locations <- merge_locations(
    household_locations_full_csv,
    sport_locations_csv,
    work_locations_csv,
    school_locations_csv,
    shopping_locations_csv
  )

  merged_locations_csv <- file.path(output_dir, "locations_merged.csv")
  write.csv(df_merged_locations, merged_locations_csv, row.names = FALSE)

  return(

      c(
        work_locations_csv,
        sport_locations_csv,
        shopping_locations_csv,
        household_locations_full_csv,
        household_locations_minimal_csv,
        school_locations_shp,
        school_locations_csv,
        merged_locations_csv
      )
      
    )
}
