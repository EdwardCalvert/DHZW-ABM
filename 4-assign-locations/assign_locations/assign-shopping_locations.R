# Load datasets
assign_shopping_locations <- function(
  df_activities,
  ODiN_shopping_act_prop_csv,
  synthetic_population_csv,
  shopping_locations_csv,
  centroids_pc4_DHZW_shp,
  DHZW_pc4_codes_csv
) {
  print("processing shopping...")
  # Load PC4 proportion destinations
  df_shopping_prop <- read.table(ODiN_shopping_act_prop_csv, check.names = FALSE, sep = ",", header = TRUE)



  # load synthetic population
  df_synth_pop <- read.csv(synthetic_population_csv)
  df_synth_pop$hh_PC4 <- gsub(".{2}$", "", df_synth_pop$PC6)
  df_synth_pop <- df_synth_pop %>%
    select(agent_ID, hh_PC4)
  df_activities <- merge(df_activities, df_synth_pop, by = "agent_ID")

  # load shopping locations
  df_shopping_locations <- read.csv(shopping_locations_csv)

  # Load PC4 vectorial coordinates and compute their centroids
  df_PC4_geometries <- st_read(centroids_pc4_DHZW_shp)

  DHZW_PC4_codes <-
    read.csv(DHZW_pc4_codes_csv, sep = ";", header = F)$V1

  ################################################################################
  # Call function that assigns locations based on the PC4 proportions. For locations in DHZW, the lid contains the locations ID. Otherwise the PC4.

  df_activities <- assign_locations_PC4_proportions(
    df_activities,
    "shopping",
    df_shopping_prop,
    df_synth_pop,
    df_shopping_locations,
    df_PC4_geometries,
    DHZW_PC4_codes
  )

  # check
  #nrow(df_activities[df_activities$activity_type == "shopping" & is.na(df_activities$lid), ])
  print("shopping activity assingment complete.")
  return(df_activities)
}
