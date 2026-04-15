library(tidyverse)
library(ggplot2)
library(latex2exp)

average_modal_percent <- function(i) {
  all_dirs <- list.dirs(path = paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), full.names = FALSE, recursive = FALSE)

  sorted_dirs <- sort(all_dirs)
  last_30_dirs <- tail(sorted_dirs, 30)


  file_paths <- file.path(paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), last_30_dirs, "income_mode_percent.csv")

  existing_files <- file_paths[file.exists(file_paths)]


  combined_df <- do.call(rbind, lapply(existing_files, function(f) {
    data <- read.csv(f)
    data$source_dir <- i
    return(data)
  }))
  result <- combined_df %>%
    summarise(mean_percent = mean(simulated.percent), sd_percent = sd(simulated.percent), rq = i, .by = c(income_group, mode_choice))

  return(result)
}

dir_names <- c("rq4-1", "rq4-3", "rq4-5", "rq4-6") # NEED TO INCLUDE ,"rq4-5"
final_results_list <- lapply(dir_names, average_modal_percent)

final_summary_df <- do.call(rbind, final_results_list)
names(final_summary_df)

base_proportions <- read.csv("9-other-analysis/ODiN-Analysis/DHZW_income_group_proportions.csv") %>%
  select(hh_income_group, disp_modal_choice, percentage) %>%
  rename(income_group = hh_income_group, mode_choice = disp_modal_choice, mean_percent = percentage) %>%
  mutate(sd_percent = 0, rq = "baseline", mode_choice = toupper(mode_choice), income_group = toupper(income_group))

names(base_proportions)
merged <- bind_rows(final_results_list, base_proportions)

unique(base_proportions$mode_choice)



rq_colors <- c(
  "Ground Truth (ODiN)" = "#96170F",
  "VOT (baseline, K, E4.1)" = "#ebebeb",
  "VOT (K)" = "#5c1477",
  "STT (Baseline, P, E4.3)" = "#b7b7b7",
  "STT (P)" = "#31688E",
  "STT (Baseline, P, E4.5)" = "#777777",
  "STT (K)" = "#35B779",
  "STT * (P)" = "#FDE725"
)

unique(base_proportions$income_group)

merged <- merged %>%
  mutate(
    mode_choice = factor(
      mode_choice,
      levels = c("WALK", "BIKE", "CAR_DRIVER", "CAR_PASSENGER", "BUS_TRAM", "TRAIN"),
      labels = c("walk", "bike", "car driver", "car passenger", "bus/tram", "train")
    ),
    rq = factor(
      rq,
      levels = c("baseline", "rq4-1", "rq3-4", "rq4-3", "rq4-2", "rq4-5", "rq4-4", "rq4-6"),
      labels = c("Ground Truth (ODiN)", "VOT (K)", "VOT (baseline, K, E4.1)", "STT (P)", "STT (Baseline, P, E4.3)", "STT (K)", "STT (Baseline, P, E4.5)", "STT * (P)"),
    ),
    income_group = factor(
      income_group,
      levels = c("LOW", "AVERAGE", "HIGH"),
      labels = c("Bottom 30% Income", "Middle 40%", "Top 30% Income")
    )
  )

ggplot(merged, aes(x = mode_choice, y = mean_percent, fill = rq)) +
  geom_col(position = "dodge", color = "black") +
  geom_errorbar(
    aes(ymin = mean_percent - sd_percent, ymax = mean_percent + sd_percent),
    position = position_dodge(0.9),
    width = 0.2
  ) +
  facet_wrap(~income_group, nrow = 3, ncol = 1) +
  labs(
    title = "RQ4: Modal choice split by income declies",
    x = "Mode Choice",
    y = "Mean Percentage",
    fill = "Population"
  ) +
  scale_fill_manual(
    values = rq_colors,
  ) +
  geom_text(
    aes(label = round(mean_percent, 1)),
    position = position_dodge2(width = 0.9),
    vjust = -1,
    hjust = +0.5,
    size = 2.5
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE))
