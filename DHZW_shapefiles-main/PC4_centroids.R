library(this.path)
library(sf)
library(dplyr)

# Load PC4 vectorial coordinates and compute their centroids
setwd(this.dir())
setwd('data/raw/')
df_PC4_NL <- st_read('CBS-PC4-2019-v2')

################################################################################
# Compute centroids

df_PC4_NL <- st_centroid(df_PC4_NL)

df_PC4_NL <- st_transform(df_PC4_NL, 4326)

df_PC4_NL = subset(df_PC4_NL, select = c('PC4'))

# coordinates part
df_PC4_NL_coordinates <- df_PC4_NL

df_PC4_NL_coordinates$coordinate_y <- st_coordinates(df_PC4_NL_coordinates)[, 2]
df_PC4_NL_coordinates$coordinate_x <- st_coordinates(df_PC4_NL_coordinates)[, 1]

df_PC4_NL_coordinates <- data.frame(df_PC4_NL_coordinates)

df_PC4_NL_coordinates = subset(df_PC4_NL_coordinates, select = -c(geometry))

################################################################################
# Save Netherlands

# Save shapefile
setwd(this.dir())
setwd('data/processed/shapefiles/centroids_PC4_NL_shp/')
write_sf(df_PC4_NL, 'centroids_PC4_NL_shp.shp', overwrite=TRUE)

# Save CSV
setwd(this.dir())
setwd('data/processed/csv/')
write.csv(df_PC4_NL_coordinates, 'centroids_PC4_NL.csv', row.names = FALSE)

################################################################################
# Filter on DHZW
setwd(this.path::this.dir())
setwd('data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

df_PC4_DHZW <- df_PC4_NL %>%
  filter (PC4 %in% DHZW_PC4_codes)

df_PC4_DHZW_coordinates <- df_PC4_NL_coordinates %>%
  filter (PC4 %in% DHZW_PC4_codes)
  
################################################################################
# Save DHZW

# Save shapefile
setwd(this.dir())
setwd('data/processed/shapefiles/centroids_PC4_DHZW_shp/')
write_sf(df_PC4_DHZW, 'centroids_PC4_DHZW_shp.shp', overwrite=TRUE)

# Save CSV
setwd(this.dir())
setwd('data/processed/csv/')
write.csv(df_PC4_DHZW_coordinates, 'centroids_PC4_DHZW.csv', row.names = FALSE)