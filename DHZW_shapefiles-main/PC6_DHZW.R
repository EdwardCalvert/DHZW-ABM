library(this.path)
library(sf)
library(dplyr)

# Load PC4 vectorial coordinates and compute their centroids
setwd(this.dir())
setwd('data/raw/')
df_PC6_NL <- st_read('CBS-PC6-2019-v2')

################################################################################
df_PC6_NL <- st_transform(df_PC6_NL, "+proj=longlat +datum=WGS84")
df_PC6_NL = subset(df_PC6_NL, select = c('PC6'))

# Filter on DHZW
setwd(this.path::this.dir())
setwd('data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

df_PC6_NL$PC4 <- gsub('.{2}$', '', df_PC6_NL$PC6)

df_PC6_DHZW <- df_PC6_NL %>%
  filter (PC4 %in% DHZW_PC4_codes)

df_PC6_NL = subset(df_PC6_NL, select = -c(PC4))
df_PC6_DHZW = subset(df_PC6_DHZW, select = -c(PC4))

################################################################################
# Save DHZW

# Save shapefile
setwd(this.dir())
setwd('data/processed/shapefiles/PC6_DHZW_shp/')
write_sf(df_PC6_DHZW, 'PC6_DHZW_shp.shp')