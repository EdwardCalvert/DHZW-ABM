assign_sport_locations <- function(
    df_activities,
    ODiN_sport_act_prop_csv,
    synthetic_population_csv,
    sport_locations_csv,
    centroids_pc4_DHZW_shp,
    DHZW_pc4_codes_csv
    )
{
  print("processing sport")
  # Load datasets
  
  # Load PC4 proportion destinations
  df_sport_prop <- read.table(ODiN_sport_act_prop_csv, check.names=FALSE, sep = ',', header = TRUE)
  

  
  # load synthetic population
  df_synth_pop <- read.csv(synthetic_population_csv)
  df_synth_pop$hh_PC4 = gsub('.{2}$', '', df_synth_pop$PC6)
  df_synth_pop <- df_synth_pop %>%
    select(agent_ID, hh_PC4)
  df_activities <- merge(df_activities, df_synth_pop, by = 'agent_ID')
  
  # load sport locations
  df_sport_locations <- read.csv(sport_locations_csv)
  
  # Load PC4 vectorial coordinates and compute their centroids
  df_PC4_geometries <- st_read(centroids_pc4_DHZW_shp)
  
  DHZW_PC4_codes <- read.csv(DHZW_pc4_codes_csv, sep = ";" , header = F)$V1
  
  ################################################################################
  # Call function that assigns locations based on the PC4 proportions
  
  df_activities <- assign_locations_PC4_proportions(df_activities, 'sport', df_sport_prop, df_synth_pop, df_sport_locations, df_PC4_geometries, DHZW_PC4_codes)
  
  # check
  # nrow(df_activities[df_activities$activity_type=='sport' & is.na(df_activities$lid),])
  # nrow(df_activities[df_activities$activity_type=='home' & is.na(df_activities$lid),])
  # nrow(df_activities[df_activities$activity_type=='work' & is.na(df_activities$lid),])
  # nrow(df_activities[df_activities$activity_type=='school' & is.na(df_activities$lid),])
  
  ################################################################################
  # save
  print("sport activity assignment complete.")
  return(df_activities)
}