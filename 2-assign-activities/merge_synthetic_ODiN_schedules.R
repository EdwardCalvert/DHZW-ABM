merge_population_and_odin_schedules <- function(
    activity_schedule_csv,
    matched_population_and_odin_ids_csv
    ){
  ################################################################################
  # This script merges together the schedule for each day for each synthetic participant
  
  # read the activity schedule for the ODiN participants
  df_schedule_ODiN <- read.csv(activity_schedule_csv)
  
  # read the ID mapping between synthetic agents and ODiN participants
  df_match_IDs <- read.csv(matched_population_and_odin_ids_csv)
  
  # prepare an empty dataset
  datalist = list()
  
  # for each synthetic agent
  for (n in 1:nrow(df_match_IDs)) {
    agent_ID <- df_match_IDs[n,]$agent_ID
    
    # get Monday
    df_i <- df_schedule_ODiN[df_schedule_ODiN$ODiN_ID == df_match_IDs[df_match_IDs$agent_ID == agent_ID,]$ODiN_ID_1,]
    
    # add the other days
    for (i in c(2:7)){
      df_i <- rbind(df_i, df_schedule_ODiN[df_schedule_ODiN$ODiN_ID == df_match_IDs[df_match_IDs$agent_ID == agent_ID, paste0('ODiN_ID_', i)],])
    }
  
    # change column names
    df_i <- df_i %>%
      rename('agent_ID' = 'ODiN_ID')
    df_i$agent_ID <- agent_ID
    
    datalist[[n]] <- df_i
  }
  
  df = do.call(rbind, datalist)
  
  # save dataset
  return(df)
}