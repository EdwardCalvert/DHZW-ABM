################################################################################
# This script filters the municipality school dataset (source) and prepare it for the simulation

################################################################################
# Load and filter DHZW

# https://livingatlas-dcdev.opendata.arcgis.com/datasets/esrinl-content::onderwijslocaties-adres/explore?filters=eyJQUk9WSU5DSUUiOlsiWnVpZC1Ib2xsYW5kIl0sIkdFTUVFTlRFTkFBTSI6WyJTIEdSQVZFTkhBR0UiXX0%3D&location=52.053199%2C4.316303%2C14.58

format_schools <- function(
  schools_municipality_shp,
  esri_living_atlas_schools_shp,
  DHZW_pc4_codes_csv
) {
  # Load PC4 DHZW
  DHZW_PC4_codes <-
    read.csv(DHZW_pc4_codes_csv,
      sep = ";",
      header = F
    )$V1


  # setwd(this.path::this.dir())
  # setwd('../../dhzw_data/DUO_Onderwijslocaties')
  # df_schools_esri <- st_read('DUO_Onderwijslocaties.shp')
  # df_schools_municipality <- st_read('schoolgebouwen')

  # Load municipality schools
  df_schools_esri <- st_read(esri_living_atlas_schools_shp)
  df_schools_municipality <- st_read(schools_municipality_shp)

  df_schools_esri <- df_schools_esri %>%
    select(
      ONDERWIJS,
      INSTELLING,
      POSTCODE
    ) %>%
    rename(
      level = ONDERWIJS,
      name = INSTELLING,
      PC6 = POSTCODE
    ) %>%
    mutate(PC6 = gsub(" ", "", PC6)) %>%
    mutate(PC4 = gsub(".{2}$", "", PC6)) %>%
    filter(PC4 %in% DHZW_PC4_codes)

  # Transform into WGS84
  df_schools_esri <- st_transform(df_schools_esri, 4326)

  df_schools_municipality <- df_schools_municipality %>%
    select(
      bestemming,
      school,
      postcode
    ) %>%
    rename(
      level = bestemming,
      name = school,
      PC6 = postcode
    ) %>%
    mutate(PC6 = gsub(" ", "", PC6)) %>%
    mutate(PC4 = gsub(".{2}$", "", PC6)) %>%
    filter(PC4 %in% DHZW_PC4_codes)

  # Transform into WGS84
  df_schools_municipality <- st_transform(df_schools_municipality, 4326)

  ################################################################################
  # Filter and sssign categories

  # Use the municipality dataset for daycare
  df_schools_municipality <- df_schools_municipality[df_schools_municipality$level == "BO-Voorschool", ]

  # Use the ESRI living atlas for primary and highschool
  df_schools_esri <- df_schools_esri[df_schools_esri$level == "BO" | df_schools_esri$level == "VBO/MAVO", ]

  
  df_schools_municipality <- df_schools_municipality %>%
    st_zm() %>%
    st_cast("POINT")
  
  df_schools_esri <- df_schools_esri %>%
    st_zm() %>%
    st_cast("POINT")
  
  # Put dataset together and reformat school labels
  df_schools <- rbind(df_schools_municipality, df_schools_esri)
  df_schools$category <- NA
  df_schools[df_schools$level == "BO-Voorschool", ]$category <- "daycare"
  df_schools[df_schools$level == "BO", ]$category <- "primary_school"
  df_schools[df_schools$level == "VBO/MAVO", ]$category <- "highschool"

  df_schools <- df_schools %>%
    subset(select = -c(level))

  df_schools$lid <- paste0("school_", seq.int(nrow(df_schools)))

  ################################################################################
  # retrieve coordinates from the geometry

  df_schools$coordinate_y <- st_coordinates(df_schools)[, 2]
  df_schools$coordinate_x <- st_coordinates(df_schools)[, 1]

  plot(df_schools$geometry)

  ################################################################################

  
  return(df_schools)
}
