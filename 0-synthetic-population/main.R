
#Assume the synthetic population ot be correct 
#so simply return them, without doing any processing. 
run_synthetic_population <- function(output_dir,population_source_file){

  
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  
  dest_files <- file.path(output_dir, basename(population_source_file))
  
  
  success <- file.copy(from = population_source_file, to = dest_files, overwrite = TRUE)
  
  if (!all(success)) {
    stop("Failed to copy one or more synth_pop_files")
  }
  
  return(dest_files)
}

