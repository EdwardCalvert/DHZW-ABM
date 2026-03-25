run_trips <- function(output_dir, odin_ovin_dir, urbanisation_pc4_csv, DHZW_pc4_codes_csv) {
  df <- process_ODiN_data(odin_ovin_dir, urbanisation_pc4_csv, DHZW_pc4_codes_csv)

  highly_urbanised_trips_csv <- file.path(output_dir, "df_trips-highly_urbanized.csv")
  write.csv(df, highly_urbanised_trips_csv, row.names = FALSE)
  # # Save dataset
  # setwd(paste0(this.path::this.dir(), "../../../dhzw_data/processed"))
  return(highly_urbanised_trips_csv)
}
