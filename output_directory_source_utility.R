library(here)
library(yaml)

get_output_path <- function() {
  conf <- yaml::read_yaml(here("config.yaml"))
  path <- here("output", conf$experiment_id)
  
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
  return(path)
}