merge_locations <- function(
  household_locations_full_csv,
  sport_locations_csv,
  work_locations_csv,
  school_locations_csv,
  retail_locations_csv
) {
  df_homes <- read.csv(household_locations_full_csv)
  df_homes <- df_homes %>%
    select(PC6, PC4, coordinate_y, coordinate_x, lid)
  colnames(df_homes)

  df_work <- read.csv(work_locations_csv)
  df_work <- df_work %>%
    select(PC6, PC4, coordinate_y, coordinate_x, lid)
  colnames(df_work)

  df_schools <- read.csv(school_locations_csv)
  df_schools <- df_schools %>%
    select(PC6, PC4, coordinate_y, coordinate_x, lid)
  colnames(df_schools)

  df_shoppings <- read.csv(retail_locations_csv)
  df_shoppings <- df_shoppings %>%
    select(PC6, PC4, coordinate_y, coordinate_x, lid)
  colnames(df_shoppings)

  df_sport <- read.csv(sport_locations_csv)
  df_sport <- df_sport %>%
    select(PC6, PC4, coordinate_y, coordinate_x, lid)
  colnames(df_sport)

  df_locations <- rbind(
    df_homes,
    df_work,
    df_schools,
    df_shoppings,
    df_sport
  )

  df_locations <- df_locations %>%
    select(PC6, PC4, coordinate_y, coordinate_x, lid)

  return(df_locations)
}
