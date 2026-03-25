build_otp_graph <- function(otp_data_path, otp_java_path) {
  otp_build_graph(
    otp = otp_java_path,
    dir = otp_data_path,
    memory = 12000
  )
}
