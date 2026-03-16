run_routing_walk_bike_car <- function(
  output_dir,
  final_output_dir,
  pc6_DHZW_shp,
  otp_data_path,
  otp_java_path,
  OD_symmetric_csv
) {
  df_symmetric <- read.csv(OD_symmetric_csv)

  df_walk <- df_symmetric
  df_bike <- df_symmetric
  df_car <- df_symmetric


  # Connect to the server
  otpcon <- start_or_connect_otp(otp_java_path, otp_data_path)

  ################################################################################
  # walk
  df_walk <- compute_walk_bike_car(otpcon, df_walk, "WALK")


  write.csv(final_output_dir, "walk_time_distance.csv", row.names = FALSE)

  # bile
  df_bike <- compute_walk_bike_car(otpcon, df_bike, "BICYCLE")
  df_bike <- df_bike %>%
    select(colnames(df_bike_old))
  df_bike <- subset(df_bike, select = -c(combined_id))

  # add old entries
  df_bike <- rbind(df_bike, df_bike_old)

  setwd(this.dir())
  setwd("output")
  write.csv(df_bike, "bike_time_distance.csv", row.names = FALSE)

  # car
  df_car <- compute_walk_bike_car(otpcon, df_car, "CAR")

  df_car <- df_car %>%
    select(colnames(df_car_old))
  df_car <- subset(df_car, select = -c(combined_id))

  # add old entries
  df_car <- rbind(df_car, df_car_old)

  setwd(this.dir())
  setwd("output")
  write.csv(df_car, "car_time_distance.csv", row.names = FALSE)

  otp_stop()
  #
  # nrow(walk_time_distance[walk_time_distance$departure=='2533B' | walk_time_distance$arrival=='2533B' |
  #                           walk_time_distance$departure=='2552' | walk_time_distance$arrival=='2552',])
}
