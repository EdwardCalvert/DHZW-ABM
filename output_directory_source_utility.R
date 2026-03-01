# library(here)
# library(yaml)

get_output_path <- function(config) {
  path <- here("output", config$experiment_id)
  
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
  return(path)
}