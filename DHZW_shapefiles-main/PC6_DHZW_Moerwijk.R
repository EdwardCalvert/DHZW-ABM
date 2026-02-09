library(this.path)
library(sf)
library(dplyr)

# Load PC4 vectorial coordinates and compute their centroids
setwd(this.dir())
setwd('data/raw/')
df_PC6_NL <- st_read('CBS-PC6-2019-v2')

################################################################################
df_PC6_NL <- st_transform(df_PC6_NL, "+proj=longlat +datum=WGS84")

df_PC6_NL = df_PC6_NL %>%
  select(PC6)

df_PC6_station <- df_PC6_NL %>%
  filter(PC6 %in% c('2532CP', '2521CK', '2521SK', '2524VL'))

################################################################################
# Save DHZW

# Save shapefile
setwd(this.dir())
setwd('data/processed/shapefiles/df_PC6_station_shp/')
write_sf(df_PC6_station, 'df_PC6_station_shp.shp')