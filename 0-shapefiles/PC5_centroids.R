generate_pc5_centroids <- function(
  output_dir,
  DHZW_pc4_codes_csv,
  pc5_gpkg
) {
  # Load PC4 vectorial coordinates and compute their centroids
  df_PC5_NL <- st_read(pc5_gpkg) %>%
    rename(PC5 = postcode)

  ################################################################################
  # Compute centroids
  df_PC5_NL <- st_centroid(df_PC5_NL)

  df_PC5_NL <- st_transform(df_PC5_NL, 4326)

  df_PC5_NL <- subset(df_PC5_NL, select = c("PC5"))

  # coordinates part
  df_PC5_NL_coordinates <- df_PC5_NL

  df_PC5_NL_coordinates$coordinate_y <- st_coordinates(df_PC5_NL_coordinates)[, 2]
  df_PC5_NL_coordinates$coordinate_x <- st_coordinates(df_PC5_NL_coordinates)[, 1]

  df_PC5_NL_coordinates <- data.frame(df_PC5_NL_coordinates)

  df_PC5_NL_coordinates <- subset(df_PC5_NL_coordinates, select = -c(geom))

  ################################################################################
  # Save Netherlands

  # Save shapefile
  centroids_pc5_NL_shp <- file.path(output_dir, "centroids_PC5_NL_shp.shp")
  write_sf(df_PC5_NL, centroids_pc5_NL_shp, overwrite = TRUE)

  # Save CSV
  centroids_pc5_NL_csv <- file.path(output_dir, "centroids_PC5_NL.csv")
  write.csv(df_PC5_NL_coordinates, centroids_pc5_NL_csv, row.names = FALSE)

  ################################################################################
  # Filter on DHZW
  DHZW_PC4_codes <-
    read.csv(DHZW_pc4_codes_csv, sep = ";", header = F)$V1

  df_PC5_NL$PC4 <- gsub(".{1}$", "", df_PC5_NL$PC5)
  df_PC5_NL_coordinates$PC4 <- gsub(".{1}$", "", df_PC5_NL_coordinates$PC5)


  df_PC5_DHZW <- df_PC5_NL %>%
    filter(PC4 %in% DHZW_PC4_codes)
  df_PC5_DHZW <- subset(df_PC5_DHZW, select = c("PC4"))

  df_PC5_DHZW_coordinates <- df_PC5_NL_coordinates %>%
    filter(PC4 %in% DHZW_PC4_codes)

  df_PC5_NL <- subset(df_PC5_NL, select = -c(PC4))
  df_PC5_NL_coordinates <- subset(df_PC5_NL_coordinates, select = -c(PC4))
  df_PC5_DHZW <- subset(df_PC5_DHZW, select = -c(PC4))
  df_PC5_DHZW_coordinates <- subset(df_PC5_DHZW_coordinates, select = -c(PC4))

  ################################################################################
  # Save DHZW

  # Save shapefile
  centroids_pc5_DHZW_shp <- file.path(output_dir, "centroids_PC5_DHZW_shp.shp")
  write_sf(df_PC5_DHZW, centroids_pc5_DHZW_shp, overwrite = TRUE)

  # Save CSV
  centroids_pc5_DHZW_csv <- file.path(output_dir, "centroids_PC5_DHZW.csv")
  write.csv(df_PC5_DHZW_coordinates, centroids_pc5_DHZW_csv, row.names = FALSE)

  return(c(
    centroids_pc5_NL_shp,
    centroids_pc5_NL_csv,
    centroids_pc5_DHZW_shp,
    centroids_pc5_DHZW_csv
  ))
}
