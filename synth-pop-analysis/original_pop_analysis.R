synthetic_population <- "C:\\Users\\ed\\Development\\dhzw\\0-synthetic-population\\output\\synthetic-population\\synthetic_population_DHZW_2019.csv"

synth_pop <- read_csv(synthetic_population)


synth_pop$income_group

synthetic_population_DHZW_2019 <- read_csv("C:/Users/ed/Development/dhzw/output/effect-of-rush-hour/0-synthetic-population/synthetic_population_DHZW_2019.csv")


df <- synthetic_population_DHZW_2019 %>%
  mutate(income_group = fct_recode(income_group,
    "Bottom 10%" = "income_1_10",
    "10-20%"     = "income_2_10",
    "20-30%"     = "income_3_10",
    "30-40%"     = "income_4_10",
    "40-50%"     = "income_5_10",
    "50-60%"     = "income_6_10",
    "60-70%"     = "income_7_10",
    "70-80%"     = "income_8_10",
    "Top 10%"    = "income_9_10"
  ))
df <- df %>%
  mutate(income_index = as.numeric(as.factor(income_group)))

# Calculate Statistics
stats <- df %>%
  summarise(
    mean_val = mean(income_index, na.rm = TRUE),
    median_val = median(income_index, na.rm = TRUE)
  )
unique(df$income_index)


# Plotting
ggplot(df, aes(x = income_group)) +
  geom_bar(fill = "steelblue") +
  geom_text(
    aes(label = sprintf("%.1f%%", after_stat(count) / sum(after_stat(count)) * 100)),
    stat = "count",
    vjust = -0.5,
    size = 3.5
  ) +
  # Adding vertical lines for mean/median based on the index
  geom_vline(aes(xintercept = stats$mean_val, color = "Mean"), linewidth = 1.2) +
  geom_vline(aes(xintercept = stats$median_val, color = "Median"), linewidth = 1.2, linetype = "dashed") +
  scale_color_manual(name = "Statistics", values = c("Mean" = "red", "Median" = "orange")) +
  labs(
    title = "Distribution of Income Groups in the Synthetic Population",
    x = "Income Group",
    y = "Frequency"
  ) +
  theme_minimal()
