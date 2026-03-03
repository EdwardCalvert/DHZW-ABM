run_routing <- function(output_dir,
                        final_output_dir,
                        otp_data_path,
                        otp_java_path,
                        pc6_DHZW_shp,
                        final_activities_locations_csv,
                        centroids_pc5_DHZW_csv) {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  # do some check: (took 13 mintues before.)
  # build_otp_graph(otp_data_path, otp_java_path)

  jdk_17_path <- "C:/Program Files/Java/jdk-17"

  Sys.setenv(JAVA_HOME = jdk_17_path)

  old_path <- Sys.getenv("PATH")
  Sys.setenv(PATH = paste0(file.path(jdk_17_path, "bin"), .Platform$path.sep, old_path))

  message(system2("java", args = "-version", stdout = TRUE, stderr = TRUE))

  OD_results <- run_generate_OD(
    output_dir,
    final_activities_locations_csv,
    centroids_pc5_DHZW_csv
  )
  OD_symmetric_csv <- OD_results[1]
  OD_asymmetric_csv <- OD_results[2]


  otp_setup(otp = otp_java_path, dir = otp_data_path, memory = 10000, port = 8801, securePort = 8802)

  # beeline_distance_csv <- calcuate_euclidian_distance(final_output_dir, OD_symmetric_csv)

  routing_bus_csv <- run_routing_bus(
    output_dir,
    final_output_dir,
    OD_asymmetric_csv,
    pc6_DHZW_shp
  )

  return(1)
}
