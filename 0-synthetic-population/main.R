
#Assume the synthetic population ot be correct 
#so simply return them, without doing any processing. 
run_synthetic_population <- function(output_dir,folder_name){
  src_dir <- here(folder_name, "output")
  
  src_files <- c(
    file.path(src_dir,"synthetic-population-households","synthetic_population_DHZW_2019"),
  )
  
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  
  dest_files <- file.path(output_dir, basename(src_files))
  
  
  success <- file.copy(from = src_files, to = dest_files, overwrite = TRUE)
  
  if (!all(success)) {
    stop("Failed to copy one or more synth_pop_files")
  }
  
  return(dest_files)
}

