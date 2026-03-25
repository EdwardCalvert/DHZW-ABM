run_routing <- function(output_dir,
                        final_output_dir,
                        otp_data_path,
                        otp_java_path,
                        pc6_DHZW_shp,
                        final_activities_locations_csv,
                        centroids_pc5_DHZW_csv) {
  # do some check: (took 13 mintues before.), I believe only needs to be run
  # once for the map input (not dependent on the simulation?)
  # build_otp_graph(otp_data_path, otp_java_path)


  # OD_results <- run_generate_OD(
  #   output_dir,
  #   final_activities_locations_csv,
  #   centroids_pc5_DHZW_csv
  # )
  # OD_symmetric_csv <- OD_results[1]
  # OD_asymmetric_csv <- OD_results[2]


  # otp_setup(otp = otp_java_path, dir = otp_data_path, memory = 10000, port = 8801, securePort = 8802)

  # beeline_distance_csv <- calcuate_euclidian_distance(final_output_dir, OD_symmetric_csv)

  routing_bus_csv <- run_routing_bus(
    output_dir,
    final_output_dir,
    OD_asymmetric_csv,
    pc6_DHZW_shp
  )

  return(1)
}

start_or_connect_otp <- function(otp_java_path, otp_data_path) {
  jdk_17_path <- "C:/Program Files/Java/jdk-17"

  Sys.setenv(JAVA_HOME = jdk_17_path)

  old_path <- Sys.getenv("PATH")
  Sys.setenv(PATH = paste0(file.path(jdk_17_path, "bin"), .Platform$path.sep, old_path)) # use java 17

  message(system2("java", args = "-version", stdout = TRUE, stderr = TRUE))
  # Simple socket check or try to connect
  con <- tryCatch(
    {
      otp_connect(port = 8801)
    },
    error = function(e) {
      message("Starting new OTP instance...")
      otp_setup(otp = otp_java_path, dir = otp_data_path, memory = 15000, port = 8801)
      # Wait for server to initialize if necessary, then connect
      Sys.sleep(10)
      otp_connect(port = 8801)
    }
  )
  return(con)
}
