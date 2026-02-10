library(this.path)
library(sf)
library(dplyr)

# Load PC4 vectorial coordinates and compute their centroids
setwd(this.dir())
setwd('data/raw/')
df_PC5_NL <- st_read('CBS-PC5-2019-v2')

################################################################################
df_PC5_NL <- st_transform(df_PC5_NL, "+proj=longlat +datum=WGS84")
df_PC5_NL = subset(df_PC5_NL, select = c('PC5'))

# Filter on DHZW
setwd(this.path::this.dir())
setwd('data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

df_PC5_NL$PC4 <- gsub('.{1}$', '', df_PC5_NL$PC5)

df_PC5_DHZW <- df_PC5_NL %>%
  filter (PC4 %in% DHZW_PC4_codes)

df_PC5_NL = subset(df_PC5_NL, select = -c(PC4))
df_PC5_DHZW = subset(df_PC5_DHZW, select = -c(PC4))

################################################################################
# Save DHZW

# Save shapefile
setwd(this.dir())
setwd('data/processed/shapefiles/PC5_DHZW_shp/')
write_sf(df_PC5_DHZW, 'PC5_DHZW_shp.shp')