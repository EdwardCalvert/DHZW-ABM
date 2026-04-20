library(tibble)
library(tidyverse)
library(ggpubr)
library(rstatix)
library(xtable)
library(emmeans)
# Row-wise construction for readability
df <- tribble(
  ~ID, ~Population, ~ReasoningPolicy, ~UtilityFunction, ~RMSE, ~std,
  "E1.1", "BasePop", "pi_sec", "stt", 7.706912826086915, 0.0011855677234802742,
  "E1.2", "GenSynthPop", "pi_sec", "stt", 0.9533442970049614, 0.0018916929225981218,
  "E2.1", "BasePop", "pi_sec", "vot", 7.755277106879976, 0.0015959902975296516,
  "E2.2", "GenSynthPop", "pi_sec", "vot", 1.0935971968092142, 0.003956972586634427,
  "E3.1", "BasePop", "pi_agg", "stt", 7.636303718175335, 0.0010258093187313333,
  "E3.2", "BasePop", "pi_agg", "vot", 7.730696084795725, 0.0029418759894615,
  "E3.3", "GenSynthPop", "pi_agg", "stt", 0.9783431710759791, 0.009722378147752403,
  "E3.4", "GenSynthPop", "pi_agg", "vot", 1.098746683515709, 1.098746683515709
)

set.seed(123)
data("headache", package = "datarium")
headache %>% sample_n_by(gender, risk, treatment, size = 1)

## Plot results
bxp <- ggboxplot(
  df,
  x = "ReasoningPolicy", y = "RMSE",
  color = "UtilityFunction", palette = "jco", facet.by = "Population"
)
bxp


average_modal_percent <- function(i) {
  all_dirs <- list.dirs(path = paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), full.names = FALSE, recursive = FALSE)

  sorted_dirs <- sort(all_dirs)
  last_30_dirs <- tail(sorted_dirs, 30)


  file_paths <- file.path(paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), last_30_dirs, "percentage_score.txt")

  existing_files <- file_paths[file.exists(file_paths)]


  combined_df <- do.call(rbind, lapply(existing_files, function(f) {
    data <- scan(f, quiet = TRUE)
    data$source_dir <- i
    return(data)
  }))
  # result <- combined_df %>%
  #   select(mode_choice, simulated.percent) %>%
  #   group_by(mode_choice) %>%
  #   summarise(mean_percent = mean(simulated.percent), sd_percent = sd(simulated.percent), rq = i)

  return(combined_df)
}

dir_names <- c("rq1-1", "rq1-2", "rq2-1", "rq2-2", "rq3-1", "rq3-2", "rq3-3", "rq3-4")
final_results_list <- lapply(dir_names, average_modal_percent)
final_summary_df <- do.call(rbind, final_results_list)
final_summary_df <- as.data.frame(final_summary_df)

final_summary_df <- final_summary_df %>%
  mutate(source_dir = as.character(unlist(source_dir)))
colnames(final_summary_df)[1] <- "RMSE"

# Row-wise construction for readability
lookup <- tribble(
  ~ID, ~Population, ~ReasoningPolicy, ~UtilityFunction, ~source_dir,
  "E1.1", "BasePop", "pi_sec", "stt", "rq1-1",
  "E1.2", "GenSynthPop", "pi_sec", "stt", "rq1-2",
  "E2.1", "BasePop", "pi_sec", "vot", "rq2-1",
  "E2.2", "GenSynthPop", "pi_sec", "vot", "rq2-2",
  "E3.1", "BasePop", "pi_agg", "stt", "rq3-1",
  "E3.2", "BasePop", "pi_agg", "vot", "rq3-2",
  "E3.3", "GenSynthPop", "pi_agg", "stt", "rq3-3",
  "E3.4", "GenSynthPop", "pi_agg", "vot", "rq3-4"
)


df_final <- final_summary_df %>%
  left_join(lookup, by = "source_dir")

# Wrangle the data into a useable format, unlist it because it was badly merged. Oops...
df_final <- df_final %>%
  unnest(where(is.list)) %>%
  mutate(
    Population = as.factor(Population),
    ReasoningPolicy = as.factor(ReasoningPolicy),
    UtilityFunction = as.factor(UtilityFunction)
  )

res.aov <- df_final %>% anova_test(RMSE ~ Population * ReasoningPolicy * UtilityFunction)
res.aov
xtable(res.aov, type = "latex")

# Make the model so it can be used by emmeans (anova doesn't save the model for whatever reason)
model <- lm(RMSE ~ Population * ReasoningPolicy * UtilityFunction, data = df_final)



post_hoc <- emmeans(model, ~ Population * ReasoningPolicy * UtilityFunction)


res_means <- as.data.frame(post_hoc)

res_means_sorted <- res_means[order(res_means$emmean), ]
print(res_means_sorted)


xtable(res_means_sorted, type = "latex")


emm <- emmeans(model, ~ Population * ReasoningPolicy * UtilityFunction)
simp <- pairs(emm)
simp
emm
