# library(here)
# library(yaml)

get_output_path <- function(config) {
  path <- here("output", config$experiment_id)

  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }

  # Iterate through all module subdirectories defined in YAML
  # We use walk/lapply for side effects (creating directories)
  lapply(config$modules, function(module_dir) {
    full_module_path <- file.path(path, module_dir)
    if (!dir.exists(full_module_path)) {
      dir.create(full_module_path, recursive = TRUE)
    }
  })
  return(path)
}

get_final_output_path <- function(config) {
  path <- here("output", config$experiment_id, "final_output")

  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
  return(path)
}
