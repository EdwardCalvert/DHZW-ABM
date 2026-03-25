generate_pc6_centroids <- function(output_dir, DHZW_pc4_codes_csv, pc6_gpkg) {
  # Load PC4 vectorial coordinates and compute their centroids

  df_PC6_NL <- st_read(pc6_gpkg, layer = "cbs_pc6_2021")
  df_PC6_NL <- df_PC6_NL %>%
    rename(PC6 = postcode6)

  ################################################################################
  # Compute centroids
  df_PC6_NL <- st_centroid(df_PC6_NL)

  df_PC6_NL <- st_transform(df_PC6_NL, 4326)

  df_PC6_NL <- subset(df_PC6_NL, select = c("PC6"))

  # coordinates part
  df_PC6_NL_coordinates <- df_PC6_NL

  df_PC6_NL_coordinates$coordinate_y <- st_coordinates(df_PC6_NL_coordinates)[, 2]
  df_PC6_NL_coordinates$coordinate_x <- st_coordinates(df_PC6_NL_coordinates)[, 1]

  df_PC6_NL_coordinates <- data.frame(df_PC6_NL_coordinates)

  df_PC6_NL_coordinates <- subset(df_PC6_NL_coordinates, select = -c(geom))

  ################################################################################
  # Save Netherlands

  centroids_pc6_NL_shp <- file.path(output_dir, "centroids_PC6_NL_shp.shp")
  write_sf(df_PC6_NL, centroids_pc6_NL_shp, overwrite = TRUE)

  centroids_pc6_NL_csv <- file.path(output_dir, "centroids_PC6_NL.csv")
  write.csv(df_PC6_NL_coordinates, centroids_pc6_NL_csv, row.names = FALSE)

  ################################################################################
  # Filter on DHZW
  DHZW_PC4_codes <-
    read.csv(DHZW_pc4_codes_csv, sep = ";", header = F)$V1

  df_PC6_NL$PC4 <- gsub(".{2}$", "", df_PC6_NL$PC6)
  df_PC6_NL_coordinates$PC4 <- gsub(".{2}$", "", df_PC6_NL_coordinates$PC6)

  df_PC6_DHZW <- df_PC6_NL %>%
    filter(PC4 %in% DHZW_PC4_codes)

  df_PC6_DHZW_coordinates <- df_PC6_NL_coordinates %>%
    filter(PC4 %in% DHZW_PC4_codes)

  df_PC6_NL <- subset(df_PC6_NL, select = -c(PC4))
  df_PC6_NL_coordinates <- subset(df_PC6_NL_coordinates, select = -c(PC4))
  df_PC6_DHZW <- subset(df_PC6_DHZW, select = -c(PC4))
  df_PC6_DHZW_coordinates <- subset(df_PC6_DHZW_coordinates, select = -c(PC4))

  ################################################################################
  # Save DHZW

  centroids_PC6_DHZW_shp <- file.path(output_dir, "centroids_PC6_DHZW_shp.shp")
  write_sf(df_PC6_DHZW, centroids_PC6_DHZW_shp, overwrite = TRUE)

  centroids_PC6_DHZW_csv <- file.path(output_dir, "centroids_PC6_DHZW.csv")
  write.csv(df_PC6_DHZW_coordinates, centroids_PC6_DHZW_csv, row.names = FALSE)

  return(c(
    centroids_pc6_NL_shp,
    centroids_pc6_NL_csv,
    centroids_PC6_DHZW_shp,
    centroids_PC6_DHZW_csv
  ))
}
