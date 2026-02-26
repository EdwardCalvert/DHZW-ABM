
#Because the shapefiles are included in the git repo, I assume them to be correct, 
# so simply return them, without doing any processing. 
run_shapefiles <- function(output_dir, src_files) {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  dest_files <- file.path(output_dir, basename(src_files))
  success <- file.copy(from = src_files, to = dest_files, overwrite = TRUE)
  
  if (!all(success)) {
    stop("Failed to copy one or more shapefiles. Check if source paths exist.")
  }
  
  return(dest_files)
}