generate_pc4_centroids <- function(output_dir, DHZW_pc4_codes_csv, pc4_gpkg) {
  # Load PC4 vectorial coordinates and compute their centroids
  df_PC4_NL <- st_read(pc4_gpkg, layer = "cbs_pc4_2022") %>%
    rename(PC4 = postcode)

  ################################################################################
  # Compute centroids

  df_PC4_NL <- st_centroid(df_PC4_NL)

  df_PC4_NL <- st_transform(df_PC4_NL, 4326)

  df_PC4_NL <- subset(df_PC4_NL, select = c("PC4"))

  # coordinates part
  df_PC4_NL_coordinates <- df_PC4_NL

  df_PC4_NL_coordinates$coordinate_y <- st_coordinates(df_PC4_NL_coordinates)[, 2]
  df_PC4_NL_coordinates$coordinate_x <- st_coordinates(df_PC4_NL_coordinates)[, 1]

  df_PC4_NL_coordinates <- data.frame(df_PC4_NL_coordinates)

  df_PC4_NL_coordinates <- subset(df_PC4_NL_coordinates, select = -c(geom))

  ################################################################################
  # Save Netherlands

  # Save shapefile
  centroids_pc4_NL_shp <- file.path(output_dir, "centroids_PC4_NL_shp.shp")
  write_sf(df_PC4_NL, centroids_pc4_NL_shp, overwrite = TRUE)

  # Save CSV
  centroids_pc4_NL_csv <- file.path(output_dir, "centroids_PC4_NL.csv")
  write.csv(df_PC4_NL_coordinates, centroids_pc4_NL_csv, row.names = FALSE)

  ################################################################################
  # Filter on DHZW
  DHZW_PC4_codes <-
    read.csv(DHZW_pc4_codes_csv, sep = ";", header = F)$V1

  df_PC4_DHZW <- df_PC4_NL %>%
    filter(PC4 %in% DHZW_PC4_codes)

  df_PC4_DHZW_coordinates <- df_PC4_NL_coordinates %>%
    filter(PC4 %in% DHZW_PC4_codes)

  ################################################################################
  # Save DHZW

  # Save shapefile
  centroids_pc4_DHZW_shp <- file.path(output_dir, "centroids_PC4_DHZW.shp")
  write_sf(df_PC4_DHZW, centroids_pc4_DHZW_shp, overwrite = TRUE)

  # Save CSV
  centroids_pc4_DHZW_csv <- file.path(output_dir, "centroids_PC4_DHZW.csv")
  write.csv(df_PC4_DHZW_coordinates, centroids_pc4_DHZW_csv, row.names = FALSE)
  return(c(
    centroids_pc4_NL_shp,
    centroids_pc4_NL_csv,
    centroids_pc4_DHZW_shp,
    centroids_pc4_DHZW_csv
  ))
}
