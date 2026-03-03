generate_pc6_shp <- function(output_dir, DHZW_pc4_codes_csv, pc6_gpkg) {
  # Load PC4 vectorial coordinates and compute their centroids
  df_PC6_NL <- st_read(pc6_gpkg) %>%
    rename(PC6 = postcode6)

  ################################################################################
  df_PC6_NL <- st_transform(df_PC6_NL, "+proj=longlat +datum=WGS84")
  df_PC6_NL <- subset(df_PC6_NL, select = c("PC6"))

  # Filter on DHZW
  DHZW_PC4_codes <-
    read.csv(DHZW_pc4_codes_csv, sep = ";", header = F)$V1

  df_PC6_NL$PC4 <- gsub(".{2}$", "", df_PC6_NL$PC6)

  df_PC6_DHZW <- df_PC6_NL %>%
    filter(PC4 %in% DHZW_PC4_codes)

  df_PC6_NL <- subset(df_PC6_NL, select = -c(PC4))
  df_PC6_DHZW <- subset(df_PC6_DHZW, select = -c(PC4))

  ################################################################################
  # Save DHZW

  # Save shapefile
  pc6_DHZW_shp <- file.path(output_dir, "PC6_DHZW_shp.shp")
  write_sf(df_PC6_DHZW, pc6_DHZW_shp)
  return(pc6_DHZW_shp)
}
