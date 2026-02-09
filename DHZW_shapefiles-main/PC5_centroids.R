library(this.path)
library(sf)
library(dplyr)

# Load PC4 vectorial coordinates and compute their centroids
setwd(this.dir())
setwd('data/raw/')
df_PC5_NL <- st_read('CBS-PC5-2019-v2')

################################################################################
# Compute centroids
df_PC5_NL <- st_centroid(df_PC5_NL)

df_PC5_NL <- st_transform(df_PC5_NL, 4326)

df_PC5_NL = subset(df_PC5_NL, select = c('PC5'))

# coordinates part
df_PC5_NL_coordinates <- df_PC5_NL

df_PC5_NL_coordinates$coordinate_y <- st_coordinates(df_PC5_NL_coordinates)[, 2]
df_PC5_NL_coordinates$coordinate_x <- st_coordinates(df_PC5_NL_coordinates)[, 1]

df_PC5_NL_coordinates <- data.frame(df_PC5_NL_coordinates)

df_PC5_NL_coordinates = subset(df_PC5_NL_coordinates, select = -c(geometry))

################################################################################
# Save Netherlands

# Save shapefile
setwd(this.dir())
setwd('data/processed/shapefiles/centroids_PC5_NL_shp/')
write_sf(df_PC5_NL, 'centroids_PC5_NL_shp.shp', overwrite=TRUE)

# Save CSV
setwd(this.dir())
setwd('data/processed/csv/')
write.csv(df_PC5_NL_coordinates, 'centroids_PC5_NL.csv', row.names = FALSE)

################################################################################
# Filter on DHZW
setwd(this.path::this.dir())
setwd('data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

df_PC5_NL$PC4 <- gsub('.{1}$', '', df_PC5_NL$PC5)
df_PC5_NL_coordinates$PC4 <- gsub('.{1}$', '', df_PC5_NL_coordinates$PC5)


df_PC5_DHZW <- df_PC5_NL %>%
  filter (PC4 %in% DHZW_PC4_codes)
df_PC5_DHZW = subset(df_PC5_DHZW, select = c('PC4'))

df_PC5_DHZW_coordinates <- df_PC5_NL_coordinates %>%
  filter (PC4 %in% DHZW_PC4_codes)

df_PC5_NL = subset(df_PC5_NL, select = -c(PC4))
df_PC5_NL_coordinates = subset(df_PC5_NL_coordinates, select = -c(PC4))
df_PC5_DHZW = subset(df_PC5_DHZW, select = -c(PC4))
df_PC5_DHZW_coordinates = subset(df_PC5_DHZW_coordinates, select = -c(PC4))

################################################################################
# Save DHZW

# Save shapefile
setwd(this.dir())
setwd('data/processed/shapefiles/centroids_PC5_DHZW_shp/')
write_sf(df_PC5_DHZW, 'centroids_PC5_DHZW_shp.shp', overwrite=TRUE)

# Save CSV
setwd(this.dir())
setwd('data/processed/csv/')
write.csv(df_PC5_DHZW_coordinates, 'centroids_PC5_DHZW.csv', row.names = FALSE)