assign_home_locations <- function(
    df_activities,
    synthetic_population,
    household_locations_minimal_csv){
  # Load datasets
  print("assinging home locations")

  
  # load synthetic population
  df_synth_pop <- read.csv(synthetic_population)
  
  # load home locations
  df_homes <- read.csv(household_locations_minimal_csv)
  df_homes <- df_homes %>%
    select(hh_ID, lid)
  
  ################################################################################
  # Merge
  
  df_synth_pop <- df_synth_pop %>%
    select(agent_ID, hh_ID)
  
  df_activities <- merge(df_activities, df_synth_pop, by = 'agent_ID')
  df_activities <- merge(df_activities, df_homes, by = 'hh_ID')
  
  df_activities$in_DHZW = NA
  df_activities[df_activities$activity_type == 'home',]$in_DHZW = 1
  df_activities[!(df_activities$activity_type == 'home'),]$lid = NA
  
  print("assigning home locations complete.")
  # save 
  return(df_activities)
}