# library('haven')
# library("dplyr")
# library(tibble)
# library(tidyr)
# library(readr)
# library("this.path")
# setwd(this.path::this.dir())
# #source(utils.R')

process_ODiN_data <- function(odin_ovin_path, urbanisation_pc4_csv, pc4_codes_csv){
  
  df_OViN <- lapply(c(2010:2017), function(y) {
    read_sav(file.path(odin_ovin_path, paste0(y, "_OViN.sav")))%>% 
      filter_attributes_OViN()
  }) %>% bind_rows()
  
  df_ODiN <- lapply(c(2018, 2019), function(y) {
    read_sav(file.path(odin_ovin_path, paste0(y, "_ODiN.sav"))) %>% 
      filter_attributes_ODiN()
  }) %>% bind_rows()
  
  # Filter individuals that live in a PC4 with the same DHZW urbanization index.
  
  # Find PC4 in The Netherlands with the same urbanization index of DHZW. STED is the index and 1 is the highest
  # Extracted from: https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische-data/gegevens-per-postcode
  df_urbanization_PC4 <-
    read.csv(urbanisation_pc4_csv, sep = "," , header = T)
  
  # Read list of all PC4 in the Netherlands and their urbanization indexes.
  DHZW_PC4_codes <-
    read.csv(pc4_codes_csv, sep = ";" , header = F)$V1
  
  # Find all the PC4s in The Netherlands that have such STED index equals to 1 "Very highly urban" (environmental address density of 2500 or more addresses/km2)
  PC4_urbanized_like_DHZW = df_urbanization_PC4[df_urbanization_PC4$STED ==
                                                  1,]$PC4
  
  # In ODiN, filter only individuals that live in such highly urbanized PC4s
  df_ODiN <- df_ODiN[df_ODiN$hh_PC4 %in% PC4_urbanized_like_DHZW,]
  
  ################################################################################
  # OViN
  
  # Since the residential PC4 is not given, for the individuals that at have least one displacement I retrieve it from the first displacement.
  df_OViN <- extract_residential_PC4_from_first_displacement(df_OViN)
  
  # Individuals that stay at home all day. Filter based on the given municipality urbanization index
  df_OViN_stay_home <- df_OViN[is.na(df_OViN$disp_counter) & df_OViN$municipality_urbanization==1,]
  
  
  # Individuals with at least a displacement. Filter on the extracted residential PC4 and its urbanization index (like with ODiN).
  df_OViN_with_disp <- df_OViN[!is.na(df_OViN$disp_counter),]
  df_OViN_with_disp <- df_OViN[df_OViN$hh_PC4 %in% PC4_urbanized_like_DHZW,]
  
  plot_modal_distribution(df_OViN_with_disp)
  
  df_OViN <- rbind(df_OViN_with_disp, df_OViN_stay_home)
  df_OViN <- subset(df_OViN, select=-c(municipality_urbanization))
  
  ################################################################################
  
  df <- rbind(df_OViN,
              df_ODiN)
  
  
  # For individuals with at least a displacement, filter only the ones that start the  day from one. This is because in the simulation the delibration cycle is at midnight everyday, so the agetns must then start from home everyday.
  df <- filter_start_day_from_home(df)
  
  # is no moves (the individual stays at home all day), the counter is 0.
  df[is.na(df$disp_counter),]$disp_counter <- 0
  
  # format the values of the attributes
  df <- format_values(df)
  
  ################################################################################
  # Calculate times
  
  df$disp_start_time <- df$disp_start_hour * 60 + df$disp_start_min
  df$disp_arrival_time <-
    df$disp_arrival_hour * 60 + df$disp_arrival_min
  df <-
    subset(
      df,
      select = -c(
        year,
        disp_start_hour,
        disp_start_min,
        disp_arrival_hour,
        disp_arrival_min
      )
    )
  
  ################################################################################
  # Data cleaning
  
  # Delete agents that have missing demographic information that are used later for the matching
  IDs_to_delete = df[df$migration_background == 'unknown', ]$agent_ID
  df <- df[!(df$agent_ID %in% IDs_to_delete),]
  
  
  # Delete agents that have missing trip information. NA can be only for people that stay at home all day
  IDs_to_delete = df[(is.na(df$disp_activity) | is.na(df$disp_start_time) | is.na(df$disp_arrival_time)) & df$disp_counter > 0,]$agent_ID
  df <- df[!(df$agent_ID %in% IDs_to_delete),]
  

  return (df)
  #plot_modal_distribution(df,subtitle = "(urbanised like DHZW, 2010-2019,2023)")

}