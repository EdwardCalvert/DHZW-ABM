# Load visualization library
library(ggplot2)

# Generate elasticity vector from -0.2 to -1.1 in steps of -0.05
min_val <- -0.2
max_val <- -1.1
elasticity <- seq(min_val, max_val, by = -0.05)

power <- 0.8
mean_val <- 5
# Calculate adjustments
adj_factor_1 <- elasticity * (1 / mean_val)^power
adj_factor_2 <- elasticity
adj_factor_3 <- elasticity * (10 / mean_val)^power

# Construct data frame for plotting
df <- data.frame(
  original = rep(elasticity, 3),
  adjusted = c(adj_factor_1, adj_factor_2, adj_factor_3),
  adjustment = rep(c("Low income adjusted", "Mean income", "High income adjusted"), each = length(elasticity))
)

# Generate plot
ggplot(df, aes(x = original, y = adjusted, color = adjustment)) +
  geom_line() +
  geom_point() +
  # Add solid horizontal lines at specific values
  geom_hline(yintercept = min_val, linetype = "solid", color = "black") +
  geom_hline(yintercept = max_val, linetype = "solid", color = "black") +
  geom_vline(xintercept = min_val, linetype = "solid", color = "black") +
  geom_vline(xintercept = max_val, linetype = "solid", color = "black") +
  labs(
    title = "Elasticity vs. Adjusted Elasticity",
    x = "Original Elasticity Value",
    y = "Adjusted Value"
  ) +
  theme_minimal()
