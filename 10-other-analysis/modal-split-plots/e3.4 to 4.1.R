average_modal_percent <- function(i) {
  all_dirs <- list.dirs(path = paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), full.names = FALSE, recursive = FALSE)

  sorted_dirs <- sort(all_dirs)
  last_30_dirs <- tail(sorted_dirs, 30)


  file_paths <- file.path(paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), last_30_dirs, "income_score.txt")

  existing_files <- file_paths[file.exists(file_paths)]


  combined_df <- do.call(rbind, lapply(existing_files, function(f) {
    data <- read.table(f)
    data$source_dir <- i
    return(data)
  }))
  # result <- combined_df %>%
  #   summarise(mean_percent = mean(simulated.percent), sd_percent = sd(simulated.percent), rq = i, .by = c(income_group, mode_choice))

  return(combined_df)
}

dir_names <- c("rq3-4") # NEED TO INCLUDE ,"rq4-5"
final_results_list <- lapply(dir_names, average_modal_percent)
final_summary_df <- do.call(rbind, final_results_list)
mean(final_summary_df$V1)
final_summary_df$V1
