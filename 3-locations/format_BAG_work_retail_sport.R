run_work_retail_sport_location_extraction <- function(
    the_hague_BAG_shp,
    DHZW_pc4_codes_csv
    ){
  
  #EC: ran 22/02/2026
  # Import BAG of The Netherlands
  df <- st_read(the_hague_BAG_shp)
  
  # Load PC4 of DHZW
  DHZW_PC4_codes <-
    read.csv(DHZW_pc4_codes_csv, header = F)$V1
  
  add_coordinates <- function(df) {
    # retrieve coordinates from the geometry because the original ones are incomplete
    df$coordinate_y <- st_coordinates(df)[, 2]
    df$coordinate_x <- st_coordinates(df)[, 1]
    return(df)
  }
  
  process_category <- function(data, category_name, id_prefix){
    data |>
      filter(building_category == category_name) |>
      mutate(lid=paste0(id_prefix, row_number())) |>
      select(-building_category)
  }
  
  ################################################################################
  
  df <- df %>%
    rename(PC6 = postcode)  %>% # rename the PC6 coloumn
    mutate(PC4 = gsub('.{2}$', '', PC6)) %>% # extract PC4
    filter(PC4 %in% DHZW_PC4_codes) #%>% # filter buildings within DHZW
    #Comment code to filter based on building status- not included in current data.  
    #filter(status == 'Verblijfsobject in gebruik') # filter buildings existing right now and not in the past
  
  
  df <- df %>%
    rename(object_ID = objectid,
           address_number = huisnr,
           address_letter = huislt,
           address = ruimtenaam,
           building_category = gebruiksdo) %>%
      select(object_ID, building_category, address, address_number, address_letter, PC4, PC6)
  
  ################################################################################
  # filter and save

  df <- add_coordinates(df)
  df <- data.frame(df)
  df = subset(df, select=-geometry)
  
  
  
  df_work <- process_category(df,'kantoorfunctie','work_')
  df_retail <- process_category(df,'winkelfunctie','shopping_')
  df_sport <- process_category(df,'sportfunctie','sport_')

  return(list(
    work     = df_work,
    retail   = df_retail,
    sport    = df_sport
  ))
}


