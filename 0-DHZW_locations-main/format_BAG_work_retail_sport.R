library(this.path)
library(sf)
library(dplyr)

# Import BAG of The Netherlands
setwd(this.dir())
setwd('data/raw/')
df <- st_read('verblijfsobjecten')

# Load PC4 of DHZW
setwd(this.path::this.dir())
setwd('../DHZW_shapefiles/data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv",
           sep = ";" ,
           header = F)$V1

add_coordinates <- function(df) {
  # retrieve coordinates from the geometry because the original ones are incomplete
  df$coordinate_y <- st_coordinates(df)[, 2]
  df$coordinate_x <- st_coordinates(df)[, 1]
  return(df)
}

################################################################################

df <- df %>%
  rename(PC6 = a_postcode)  %>% # rename the PC6 coloumn
  mutate(PC4 = gsub('.{2}$', '', PC6)) %>% # extract PC4
  filter(PC4 %in% DHZW_PC4_codes) %>% # filter buildings within DHZW
  filter(status == 'Verblijfsobject in gebruik') # filter buildings existing right now and not in the past

df <- df %>%
  rename(object_ID = objectid,
         address_number = a_huisnum,
         address_letter = a_huislett,
         address = a_straatna,
         building_category = gebrdoel) %>%
    select(object_ID, building_category, address, address_number, address_letter, PC4, PC6)

################################################################################
# filter and save

# set output directory
setwd(this.dir())
setwd('data/output')

# filter work locations
df_work <- df %>%
  filter(building_category == 'kantoorfunctie') %>%
  subset(select = -c(building_category)) # remove coloumn

# add coordinates
df_work <- add_coordinates(df_work)

# remove geometry properties to save it as a CSV
df_work <- data.frame(df_work)
df_work = subset(df_work, select = -c(geometry))

# add location ID

df_work$lid <- paste0('work_', seq.int(nrow(df_work)))

# save
#write.csv(df_work, 'work_DHZW.csv', row.names = FALSE)

#########################
# filter retail locations
df_retail <- df %>%
  filter(building_category == 'winkelfunctie') %>%
  subset(select = -c(building_category)) # remove coloumn

# add coordinates
df_retail <- add_coordinates(df_retail)

# remove geometry properties to save it as a CSV
df_retail <- data.frame(df_retail)
df_retail = subset(df_retail, select = -c(geometry))

# add location ID
df_retail$lid <- paste0('shopping_', seq.int(nrow(df_retail)))

# save
#write.csv(df_retail, 'shopping_DHZW.csv', row.names = FALSE)

#########################
# filter sport locations
df_sport <- df %>%
  filter(building_category == 'sportfunctie') %>%
  subset(select = -c(building_category)) # remove coloumn

# add coordinates
df_sport <- add_coordinates(df_sport)

# remove geometry properties to save it as a CSV
df_sport <- data.frame(df_sport)
df_sport = subset(df_sport, select = -c(geometry))

# add location ID
df_sport$lid <- paste0('sport_', seq.int(nrow(df_sport)))

# save
#write.csv(df_sport, 'sport_DHZW.csv', row.names = FALSE)


