library(ggplot2)
library(tidyr)
library(dplyr)

# 1. Define Input Table
meta_data <- data.frame(
  category = c("Car costs", "Car Time, ", "Train costs", "Train time", "Bus/Tram costs", "Bus/Tram time"),
  min_val = c(0, -0.15, -0.2, -0.2, -0.3, -0.4),
  max_val = c(-0.3, -0.5, -1.1, -0.8, -0.9, -0.9)
)

mean_val <- 5

# 2. Generate Sequences and Adjustments
# We use an anonymous function to expand the grid for each category
plot_data <- do.call(rbind, lapply(1:nrow(meta_data), function(i) {
  row <- meta_data[i, ]
  elasticity <- seq(row$min_val, row$max_val, by = -0.05)

  data.frame(
    category = row$category,
    original = elasticity,
    min_ref = row$min_val,
    max_ref = row$max_val
  )
}))

# 3. Apply multiple powers (0.5, 0.8, 1.5)
# Using 'crossing' to apply every power to every row
powers <- c(0.5, 0.8, 1.5)
df_final <- plot_data %>%
  crossing(power = powers) %>%
  mutate(
    low_inc  = original / (1 / mean_val)^power,
    mean_inc = original,
    high_inc = original / (10 / mean_val)^power
  ) %>%
  # Pivot to long format for ggplot coloring
  pivot_longer(
    cols = c(low_inc, mean_inc, high_inc),
    names_to = "income_group",
    values_to = "adjusted"
  )

# 4. Visualization with Cropped Coordinate System
ggplot(df_final, aes(x = original, y = adjusted, color = income_group, linetype = as.factor(power))) +
  geom_line() +
  geom_point(size = 0.8) +
  # Use fixed scales to maintain the -1.5 to 0 crop across all facets
  facet_wrap(~category, ncol = 2) +
  # Reference lines
  geom_hline(aes(yintercept = min_ref), linetype = "solid", color = "black", alpha = 0.5) +
  geom_hline(aes(yintercept = max_ref), linetype = "solid", color = "black", alpha = 0.5) +
  geom_vline(aes(xintercept = min_ref), linetype = "solid", color = "black", alpha = 0.5) +
  geom_vline(aes(xintercept = max_ref), linetype = "solid", color = "black", alpha = 0.5) +
  # Define axis breaks with 0.05 increments as requested
  scale_x_continuous(breaks = seq(-1.3, 0, by = 0.05)) +
  scale_y_continuous(breaks = seq(-1.3, 0, by = 0.05)) +
  # Perform the crop (Zoom)
  coord_cartesian(xlim = c(-1.3, 0), ylim = c(-1.3, 0)) +
  labs(
    title = "Multivariate Elasticity Adjustment",
    subtitle = "Cropped View: [-1.5, 0]",
    x = "Original Elasticity",
    y = "Adjusted Value",
    color = "Income Group",
    linetype = "Power (p)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7),
    panel.grid.minor = element_blank()
  )
