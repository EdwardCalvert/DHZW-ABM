calcuate_euclidian_distance <- function(final_output_dir, OD_symmetric_csv) {
  df <- read.csv(OD_symmetric_csv)

  df$distance_km <- round(distHaversine(
    df[, c("departure_x", "departure_y")],
    df[, c("arrival_x", "arrival_y")]
  ) / 1000, 1)

  df <- df %>%
    select(departure, arrival, distance_km)

  beeline_distance_csv <- file.path(final_output_dir, "beeline_distance.csv")
  write.csv(df, beeline_distance_csv, row.names = FALSE)
  return(beeline_distance_csv)
}
