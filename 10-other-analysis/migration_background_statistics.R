library(dplyr)
library(ggplot2)
library(scales)
migration_stats <- read.csv("C:\\Users\\ed\\Development\\dhzw_data\\migration_backgrounds.csv", sep = ";")
names(migration_stats)
migration_stats <- dplyr::rename(
  migration_stats,
  region = Regio.s,
  count = Bevolking.op.1.januari..aantal.
)


migration_stats$region <- recode(
  migration_stats$region,
  "Nederland" = "Netherlands",
  "'s-Gravenhage (gemeente)" = "The Hague (municipality)"
)
migration_stats$Migratieachtergrond <- recode(
  migration_stats$Migratieachtergrond,
  "Nederlandse achtergrond" = "Dutch background",
  "Met migratieachtergrond" = "From a migrant background"
)


filtered_ms <- migration_stats[migration_stats$Migratieachtergrond != "Totaal", ]


filtered_ms <- filtered_ms %>%
  group_by(region) %>%
  mutate(
    percentage = (count / sum(count)),
    pos = cumsum(count) - 0.5 * count
  ) %>%
  ungroup()


ggplot(filtered_ms, aes(x = "", y = count, fill = Migratieachtergrond)) +
  facet_wrap(~region, ncol = 2, scale = "free") +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  geom_text(aes(y = pos, label = percent(percentage, accuracy = 0.1)), color = "white") +
  theme_void() +
  labs(title = "Comparison of the migration background between The Netherlands and the Hague, 2022", fill = "Migration Background") +
  theme(legend.position = "bottom", )


filtered_ms <- filtered_ms %>%
  group_by(region) %>%
  arrange(region, desc(Migratieachtergrond)) %>%
  mutate(
    percentage = count / sum(count),
    pos = cumsum(percentage) - (0.5 * percentage)
  ) %>%
  ungroup()

ggplot(filtered_ms, aes(x = "", y = percentage, fill = Migratieachtergrond)) +
  facet_wrap(~region, ncol = 2) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  geom_text(aes(y = pos, label = percent(percentage, accuracy = 0.1)), color = "white") +
  theme_void() +
  labs(title = "Migration Background Comparison, 2022", fill = "Migration Background") +
  theme(legend.position = "bottom")
