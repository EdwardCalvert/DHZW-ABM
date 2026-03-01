
# Ideally, I would use the BAG dataset to assign a precise home. 
# However, the households generation produced more households than the ones in BAG. 
# Hence, I am using the centroid of the PC6.


format_households <- function(df_households_csv, centroids_PC6_DHZW_csv){
  
  # Load household
  df_households <- read.csv(df_households_csv)
  
  ################################################################################
  # Add PC6 (representation of the "real" coordinates of the house)
  
  # Load PC6
  df_PC6 <- read.csv(centroids_PC6_DHZW_csv)
  
  # assign coordinates to households
  df_households <- merge(df_households, df_PC6, by = 'PC6')
  
  ################################################################################
  
  df_households$lid <- paste0('home_', seq.int(nrow(df_households)))
  
  df_households <- df_households %>%
    mutate(PC4 = gsub('.{2}$', '', PC6))
  
  
  df_households_minimal <- df_households %>%
    dplyr::select(hh_ID, lid, PC6, PC4, coordinate_y, coordinate_x)
  
  return(list(
    df_households_full = df_households,
    df_households_minimal = df_households_minimal
  ))
}