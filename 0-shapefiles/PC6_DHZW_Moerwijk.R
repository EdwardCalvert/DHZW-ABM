generate_pc6_DHZW_moerwijk <- function(output_dir, pc6_gpkg) {
  # Load PC4 vectorial coordinates and compute their centroids
  df_PC6_NL <- st_read(pc6_gpkg) %>%
    rename(PC6 = postcode6)


  ################################################################################
  df_PC6_NL <- st_transform(df_PC6_NL, "+proj=longlat +datum=WGS84")

  df_PC6_NL <- df_PC6_NL %>%
    select(PC6)

  df_PC6_station <- df_PC6_NL %>%
    filter(PC6 %in% c("2532CP", "2521CK", "2521SK", "2524VL"))

  ################################################################################
  # Save DHZW

  # Save shapefile
  pc6_moerwijk_station_shp <- file.path(output_dir, "df_PC6_station_shp.shp")
  write_sf(df_PC6_station, pc6_moerwijk_station_shp)
  return(pc6_moerwijk_station_shp)
}
