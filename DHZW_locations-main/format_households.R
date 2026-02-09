library(this.path)
library(readr)
library(sf)
library(dplyr)

# Ideally, I would use the BAG dataset to assign a precise home. However, the households generation produced more households than the ones in BAG. Hence, I am using the centroid of the PC6.

# Load household
setwd(this.dir())
setwd('../DHZW_synthetic-population/output/synthetic-population-households/4_car_2022-12-26_15-50')

df_households <- read.csv('df_households_DHZW_2019.csv')

################################################################################
# Add PC6 (representation of the "real" coordinates of the house)

# Load PC6
setwd(this.dir())
setwd('../DHZW_shapefiles/data/processed/csv')
df_PC6 <- read.csv('centroids_PC6_DHZW.csv')

# assign coordinates to households
df_households <- merge(df_households, df_PC6, by = 'PC6')

################################################################################

df_households$lid <- paste0('home_', seq.int(nrow(df_households)))

df_households <- df_households %>%
  mutate(PC4 = gsub('.{2}$', '', PC6))

# Save dataset
setwd(this.dir())
setwd('data/output')

write.csv(df_households, 'df_households_full_info.csv', row.names = FALSE)

df_households <- df_households %>%
  select(hh_ID, lid, PC6, PC4, coordinate_y, coordinate_x)

write.csv(df_households, 'df_households_minimal.csv', row.names = FALSE)