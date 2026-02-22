library(this.path)
library(sf)
library(dplyr)

# Load PC4 vectorial coordinates and compute their centroids
setwd(this.dir())
setwd('data/raw/')
df_PC6_NL <- st_read('CBS-PC6-2019-v2')

################################################################################
# Compute centroids
df_PC6_NL <- st_centroid(df_PC6_NL)

df_PC6_NL <- st_transform(df_PC6_NL, 4326)

df_PC6_NL = subset(df_PC6_NL, select = c('PC6'))

# coordinates part
df_PC6_NL_coordinates <- df_PC6_NL

df_PC6_NL_coordinates$coordinate_y <- st_coordinates(df_PC6_NL_coordinates)[, 2]
df_PC6_NL_coordinates$coordinate_x <- st_coordinates(df_PC6_NL_coordinates)[, 1]

df_PC6_NL_coordinates <- data.frame(df_PC6_NL_coordinates)

df_PC6_NL_coordinates = subset(df_PC6_NL_coordinates, select = -c(geometry))

################################################################################
# Save Netherlands

# Save shapefile
setwd(this.dir())
setwd('data/processed/shapefiles/centroids_PC6_NL_shp/')
write_sf(df_PC6_NL, 'centroids_PC6_NL_shp.shp', overwrite=TRUE)

# Save CSV
setwd(this.dir())
setwd('data/processed/csv/')
write.csv(df_PC6_NL_coordinates, 'centroids_PC6_NL.csv', row.names = FALSE)

################################################################################
# Filter on DHZW
setwd(this.path::this.dir())
setwd('data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

df_PC6_NL$PC4 <- gsub('.{2}$', '', df_PC6_NL$PC6)
df_PC6_NL_coordinates$PC4 <- gsub('.{2}$', '', df_PC6_NL_coordinates$PC6)

df_PC6_DHZW <- df_PC6_NL %>%
  filter (PC4 %in% DHZW_PC4_codes)

df_PC6_DHZW_coordinates <- df_PC6_NL_coordinates %>%
  filter (PC4 %in% DHZW_PC4_codes)

df_PC6_NL = subset(df_PC6_NL, select = -c(PC4))
df_PC6_NL_coordinates = subset(df_PC6_NL_coordinates, select = -c(PC4))
df_PC6_DHZW = subset(df_PC6_DHZW, select = -c(PC4))
df_PC6_DHZW_coordinates = subset(df_PC6_DHZW_coordinates, select = -c(PC4))

################################################################################
# Save DHZW

# Save shapefile
setwd(this.dir())
setwd('data/processed/shapefiles/centroids_PC6_DHZW_shp/')
write_sf(df_PC6_DHZW, 'centroids_PC6_DHZW_shp.shp', overwrite=TRUE)

# Save CSV
setwd(this.dir())
setwd('data/processed/csv/')
write.csv(df_PC6_DHZW_coordinates, 'centroids_PC6_DHZW.csv', row.names = FALSE)