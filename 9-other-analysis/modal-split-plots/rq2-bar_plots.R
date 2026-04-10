library(tidyverse)
library(ggplot2)
combinded_df <- NULL

average_modal_percent <- function(i) {
  all_dirs <- list.dirs(path = paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), full.names = FALSE, recursive = FALSE)

  sorted_dirs <- sort(all_dirs)
  last_30_dirs <- tail(sorted_dirs, 30)


  file_paths <- file.path(paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), last_30_dirs, "xmode_percent.csv")

  existing_files <- file_paths[file.exists(file_paths)]


  combined_df <- do.call(rbind, lapply(existing_files, function(f) {
    data <- read.csv(f)
    data$source_dir <- i
    return(data)
  }))
  result <- combined_df %>%
    select(mode_choice, simulated.percent) %>%
    group_by(mode_choice) %>%
    summarise(mean_percent = mean(simulated.percent), sd_percent = sd(simulated.percent), rq = i)

  return(result)
}

dir_names <- c("rq1-1", "rq1-2", "rq2-1", "rq2-2")
final_results_list <- lapply(dir_names, average_modal_percent)

final_summary_df <- do.call(rbind, final_results_list)
names(final_summary_df)

base_proportions <- read.csv("9-other-analysis/ODiN-Analysis/DHZW_modal_choice_proporitions.csv") %>%
  select(disp_modal_choice, percentage) %>%
  rename(mode_choice = disp_modal_choice, mean_percent = percentage) %>%
  mutate(sd_percent = 0, rq = "baseline", mode_choice = toupper(mode_choice))

names(base_proportions)
merged <- bind_rows(final_results_list, base_proportions)

unique(base_proportions$mode_choice)

merged <- merged %>%
  mutate(
    mode_choice = factor(
      mode_choice,
      levels = c("WALK", "BIKE", "CAR_DRIVER", "CAR_PASSENGER", "BUS_TRAM", "TRAIN"),
      labels = c("walk", "bike", "car driver", "car passenger", "bus/tram", "train")
    ),
    rq = factor(
      rq,
      levels = c("rq1-1", "rq2-1", "baseline", "rq1-2", "rq2-2"),
      labels = c("STT BasePop (Baseline)", "VOT BasePop", "Ground Truth (ODiN)", "STT GenSynthPop", "VOT GenSynthPop")
    )
  )

rq_colors <- c(
  "Ground Truth (ODiN)" = "#96170F",
  "STT BasePop (Baseline)" = "#B0B0B0",
  "STT GenSynthPop" = "#D3D3D3",
  "VOT BasePop" = "#DC7700",
  "VOT GenSynthPop" = "#7F3DA7"
)
rq_alphas <- c(
  "Ground Truth (ODiN)" = 1.0,
  "STT BasePop (Baseline)" = 1.0,
  "STT GenSynthPop" = 1.0,
  "VOT BasePop" = 1.0,
  "VOT GenSynthPop" = 1.0
)
ggplot(merged, aes(x = mode_choice, y = mean_percent, fill = rq, alpha = rq)) +
  geom_col(position = "dodge") +
  geom_errorbar(
    aes(ymin = mean_percent - sd_percent, ymax = mean_percent + sd_percent),
    position = position_dodge(0.9),
    width = 0.2
  ) +
  labs(
    title = "RQ2:  Introduction of the Value of Time (VOT) utility function",
    subtitle = "Modal choice split from RQ1 is included in grey for convienience",
    x = "Mode Choice",
    y = "Mean Percentage",
    fill = "Population"
  ) +
  scale_fill_manual(values = rq_colors) +
  scale_alpha_manual(values = rq_alphas, guide = "none") +
  theme_minimal() +
  theme(legend.position = "bottom")
