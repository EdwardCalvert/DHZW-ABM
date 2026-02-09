library(readr)
library(dplyr)
library(this.path)
library(sf)

# Read locations
setwd(this.dir())
setwd('data/output')
df_homes <- read.csv('df_households_full_info.csv')
df_homes <- df_homes %>%
  select(PC6, PC4, coordinate_y, coordinate_x, lid)
colnames(df_homes)

df_work <- read.csv('work_DHZW.csv')
df_work <- df_work %>%
  select(PC6, PC4, coordinate_y, coordinate_x, lid)
colnames(df_work)

df_schools <- read.csv('school_DHZW.csv')
df_schools <- df_schools %>%
  select(PC6, PC4, coordinate_y, coordinate_x, lid)
colnames(df_schools)

df_shoppings <- read.csv('shopping_DHZW.csv')
df_shoppings <- df_shoppings %>%
  select(PC6, PC4, coordinate_y, coordinate_x, lid)
colnames(df_shoppings)

df_sport <- read.csv('sport_DHZW.csv')
df_sport <- df_sport %>%
  select(PC6, PC4, coordinate_y, coordinate_x, lid)
colnames(df_sport)

df_locations <- rbind(df_homes,
                      df_work,
                      df_schools,
                      df_shoppings,
                      df_sport)

df_locations <- df_locations %>%
  select(PC6, PC4, coordinate_y, coordinate_x, lid)

setwd(this.dir())
setwd('data/output')

write.csv(df_locations, 'locations_merged.csv', row.names = FALSE)