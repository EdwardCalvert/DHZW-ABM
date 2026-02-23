
#Because the shapefiles are included in the git repo, I assume them to be correct, 
# so simply return them, without doing any processing. 
run_shapefiles <- function( output_dir,folder_name){
  

  src_dir <- here(folder_name, "data", "codes")
  
  src_files <- c(
    file.path(src_dir,"neighbourhood_codes.csv"),
    file.path(src_dir, "neighbourhoods.csv"),
    file.path(src_dir, "pc4_codes.csv"),
  )
  
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  
  dest_files <- file.path(output_dir, basename(src_files))

  
  success <- file.copy(from = src_files, to = dest_files, overwrite = TRUE)
  
  if (!all(success)) {
    stop("Failed to copy one or more shapefiles.")
  }
  
  return(dest_files)
}