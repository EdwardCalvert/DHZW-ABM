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
  #for (n in 1:nrow(df_match_IDs)) {
  for (n in 1:100) {
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

##Return "agent_ID","activity_type","start_time","end_time","day_of_week","duration","activity_number"

merge_population_and_odin_schedules_vector <- function(
    activity_schedule_csv, 
    matched_population_and_odin_ids_csv
) {
  
  ##Utilise high-perfomance code, takes a hit on readability, but means
  #this process completes very quickly. 
  # 
  
  # Load data directly into data.table format
  dt_schedule <- fread(activity_schedule_csv)
  dt_match <- fread(matched_population_and_odin_ids_csv)
  
  # Melt the wide mapping table into long format
  # Focuses only on the agent_ID and the 7 ODiN_ID columns
  dt_mapping_long <- melt(
    dt_match, 
    id.vars = "agent_ID", 
    measure.vars = patterns("^ODiN_ID_"),
    value.name = "ODiN_ID"
  )
  
  # Key-based Join
  # Set keys to enable O(log n) binary search joins instead of O(n) scans
  setkey(dt_mapping_long, ODiN_ID)
  setkey(dt_schedule, ODiN_ID)
  
  # Perform the join, drop the original ODiN_ID and 'variable' columns
  dt_final <- dt_schedule[dt_mapping_long, on = "ODiN_ID", allow.cartesian = TRUE]
  
  # Clean up: Replace ODiN_ID with agent_ID and remove helper columns
  #dt_final[, ODiN_ID := agent_ID]
  #setnames(dt_final, "ODiN_ID", "agent_ID")
  dt_final[, variable := NULL]
  
  
  # cols_to_keep <- c("agent_ID", "activity_type", "start_time", "end_time", 
  #                   "day_of_week", "duration", "activity_number")
  # dt_final <- dt_final[, ..cols_to_keep] # Subset to remove extra columns
  # setcolorder(dt_final, cols_to_keep)
  
  df_final <- as.data.frame(dt_final)
  df_final <- df_final %>%
    select(agent_ID, activity_type, start_time, end_time, 
           day_of_week, duration, activity_number)

  
  
  return(df_final)
}