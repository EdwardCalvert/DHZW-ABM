library("haven")
library("dplyr")
library(tibble)
library(tidyr)
library(readr)
library(ggplot2)
library("this.path")
setwd(this.path::this.dir())
source("utils.R")

# setwd(this.path::this.dir())
# source('../0-DHZW_assign_locations-main/src/utils_data_preparation.R')

################################################################################
# This script put together the various years of ODiN and OVin into a big collection

# Load ODiNs and OViNs
setwd(this.path::this.dir())
setwd("../../../dhzw_data/odin-ovin")

OViN2010 <- read_sav("2010_OViN.sav")
OViN2011 <- read_sav("2011_OViN.sav")
OViN2012 <- read_sav("2012_OViN.sav")
OViN2013 <- read_sav("2013_OViN.sav")
OViN2014 <- read_sav("2014_OViN.sav")
OViN2015 <- read_sav("2015_OViN.sav")
OViN2016 <- read_sav("2016_OViN.sav")
OViN2017 <- read_sav("2017_OViN.sav")
ODiN2018 <- read_sav("2018_ODiN.sav")
ODiN2019 <- read_sav("2019_ODiN.sav")
ODiN2023 <- read_sav("2023_ODiN.sav")

OViN2010 <- filter_attributes_OViN(OViN2010)
OViN2011 <- filter_attributes_OViN(OViN2011)
OViN2012 <- filter_attributes_OViN(OViN2012)
OViN2013 <- filter_attributes_OViN(OViN2013)
OViN2014 <- filter_attributes_OViN(OViN2014)
OViN2015 <- filter_attributes_OViN(OViN2015)
OViN2016 <- filter_attributes_OViN(OViN2016)
OViN2017 <- filter_attributes_OViN(OViN2017)
ODiN2018 <- filter_attributes_ODiN(ODiN2018)
ODiN2019 <- filter_attributes_ODiN(ODiN2019)
ODiN2023 <- filter_attributes_ODiN_2023(ODiN2023)

################################################################################
# ODiN


df_ODiN <- rbind(
  ODiN2018,
  ODiN2019,
  ODiN2023
)


df_urbanization_PC4 <-
  read.csv("../../dhzw_data/pc4_2021_vol.csv", sep = ",", header = T)

# Filter individuals that in DHZW

# Read list of all PC4 in the Netherlands
setwd(this.dir())
setwd("../../0-shapefiles/data/codes")
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";", header = F)$V1


PC4_urbanized_like_DHZW <- df_urbanization_PC4[df_urbanization_PC4$STED ==
  1, ]$PC4

# In ODiN, filter only individuals that live in such highly urbanized PC4s
df_ODiN <- df_ODiN[df_ODiN$hh_PC4 %in% PC4_urbanized_like_DHZW, ]

# # In ODiN, filter only individuals that live in DHZW
# df_ODiN <- df_ODiN[df_ODiN$hh_PC4 %in% DHZW_PC4_codes,]


################################################################################
# OViN

df_OViN <- rbind(
  OViN2010,
  OViN2011,
  OViN2012,
  OViN2013,
  OViN2014,
  OViN2015,
  OViN2016,
  OViN2017
)

# Since the residential PC4 is not given, for the individuals that at have least one displacement I retrieve it from the first displacement.
df_OViN <- extract_residential_PC4_from_first_displacement(df_OViN)


# Individuals that stay at home all day.
df_OViN_stay_home <- df_OViN[is.na(df_OViN$disp_counter) & df_OViN$hh_PC4 %in% DHZW_PC4_codes, ]
# plot_modal_distribution(df_OViN_stay_home)


# Individuals with at least a displacement. Filter on the extracted residential PC4 and its urbanization index (like with ODiN).
df_OViN_with_disp <- df_OViN[!is.na(df_OViN$disp_counter), ]
df_OViN_with_disp <- df_OViN[df_OViN$hh_PC4 %in% PC4_urbanized_like_DHZW, ]


# # Individuals with at least a displacement. Filter on the extracted residential PC4 and its urbanization index (like with ODiN).
# df_OViN_with_disp <- df_OViN[!is.na(df_OViN$disp_counter),]
# df_OViN_with_disp <- df_OViN[df_OViN$hh_PC4 %in% DHZW_PC4_codes,]


df_OViN <- rbind(df_OViN_with_disp, df_OViN_stay_home)
# df_OViN <- subset(df_OViN, select=-c(municipality_urbanization))

plot_modal_distribution(df_OViN)


################################################################################

df <- rbind(
  df_OViN,
  df_ODiN
)

# car_driver, car_passenger
df$disp_modal_choice <- ifelse(
  df$disp_modal_choice == "car",
  paste0(df$disp_modal_choice, "_", df$transport_role),
  df$disp_modal_choice
)

df <- df[!is.na(df$disp_modal_choice) & df$disp_modal_choice != "other" & df$disp_modal_choice != "car_other", ]

# For individuals with at least a displacement, filter only the ones that start the  day from one. This is because in the simulation the delibration cycle is at midnight everyday, so the agetns must then start from home everyday.
df <- filter_start_day_from_home(df)

# is no moves (the individual stays at home all day), the counter is 0.
df[is.na(df$disp_counter), ]$disp_counter <- 0

# format the values of the attributes
df <- format_values(df)

################################################################################
# Calculate times

df$disp_start_time <- df$disp_start_hour * 60 + df$disp_start_min
df$disp_arrival_time <-
  df$disp_arrival_hour * 60 + df$disp_arrival_min
df <-
  subset(
    df,
    select = -c(
      disp_start_hour,
      disp_start_min,
      disp_arrival_hour,
      disp_arrival_min
    )
  )

################################################################################
# Data cleaning

# Delete agents that have missing demographic information that are used later for the matching
IDs_to_delete <- df[df$migration_background == "unknown", ]$agent_ID
df <- df[!(df$agent_ID %in% IDs_to_delete), ]


# Delete agents that have missing trip information. NA can be only for people that stay at home all day
IDs_to_delete <- df[(is.na(df$disp_activity) | is.na(df$disp_start_time) | is.na(df$disp_arrival_time)) & df$disp_counter > 0, ]$agent_ID
df <- df[!(df$agent_ID %in% IDs_to_delete), ]


df_dhzw <- df[df$hh_PC4 %in% DHZW_PC4_codes, ]

df_combined <- bind_rows(
  mutate(df, source = "Urbanised like DHZW"),
  mutate(df_dhzw, source = "DHZW Only")
)


# Aggregate data to count occurrences per year per category
df_summary <- df %>%
  group_by(disp_modal_choice, year) %>%
  tally() %>%
  group_by(disp_modal_choice) # %>%

# Create the line plot
ggplot(df_summary, aes(x = year, y = n, color = disp_modal_choice)) +
  geom_line(linewidth = 1) +
  geom_point() +
  scale_x_continuous(breaks = min(df_summary$year):max(df_summary$year)) +
  labs(x = "Year", y = "Count", color = "Modal Choice", title = " Frequency of Modal Choice Over Time DHZW only") +
  theme_minimal()


# Calculate relative proportions per year
df_summary <- df %>%
  group_by(year, disp_modal_choice) %>%
  tally() %>%
  group_by(year) %>%
  mutate(percentage = (n / sum(n)) * 100) %>%
  ungroup()

# Generate the relative line plot
ggplot(df_summary, aes(x = year, y = percentage, color = disp_modal_choice)) +
  geom_line(linewidth = 1) +
  geom_point() +
  scale_x_continuous(breaks = min(df_summary$year):max(df_summary$year)) +
  labs(
    title = "Relative Distribution of Modal Choice Over Time",
    subtitle = "DHZW only",
    x = "Year",
    y = "Percentage (%)",
    color = "Modal Choice"
  ) +
  theme_minimal()


df_combined <- df_combined[!is.na(df_combined$disp_modal_choice), ]
df_summary_combined <- df_combined %>%
  mutate(year = year - 2000) %>%
  group_by(source, year, disp_modal_choice) %>%
  tally() %>%
  group_by(source, year) %>%
  mutate(percentage = (n / sum(n)) * 100) %>%
  ungroup()

ggplot(df_summary_combined, aes(x = year, y = percentage, fill = disp_modal_choice)) +
  geom_area(alpha = 0.8, stat = "identity", color = "white", linewidth = 0.2) +
  facet_wrap(~source) +
  scale_x_continuous(breaks = unique(df_summary_combined$year)) +
  labs(
    title = "Relative proportions of reported mode choices in OViN and ODiN datasets from 2010 to 2019, and 2023",
    x = "Year (20--)",
    y = "Percentage (%)",
    fill = "Mode Choice"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggplot(df_summary_combined, aes(x = year, y = percentage, color = disp_modal_choice)) +
  geom_line(linewidth = 1) +
  geom_point() +
  facet_wrap(~source) +
  labs(
    title = "Comparison of Modal Choice Trends",
    y = "Percentage (%)",
    color = "Choice",
    linetype = "Dataset"
  ) +
  theme_minimal()


df_combined$hh_income_group <- recode(df_combined$hh_income_group,
  "income_1_10" = "low",
  "income_2_10" = "low",
  "income_3_10" = "low",
  "income_4_10" = "average",
  "income_5_10" = "average",
  "income_6_10" = "average",
  "income_7_10" = "average",
  "income_8_10" = "high",
  "income_9_10" = "high",
  "income_10_10" = "high",
  "unknown" = "unknown"
)

df_income_grouped <- df_combined %>%
  mutate(year = year - 2000) %>%
  filter(hh_income_group != "unknown") %>%
  mutate(hh_income_group = factor(hh_income_group,
    levels = c("low", "average", "high", "unknown")
  )) %>%
  group_by(source, hh_income_group, disp_modal_choice) %>%
  tally() %>%
  group_by(source, hh_income_group) %>%
  mutate(percentage = (n / sum(n)) * 100) %>%
  ungroup()

setwd(this.path::this.dir())
write.csv(df_income_grouped, "both_areas_income_grouped.csv", row.names = FALSE)

df_dhzw_income <- df_income_grouped[df_income_grouped$source == "DHZW Only", ]
df_dhzw_income$source <- NULL
write.csv(df_dhzw_income, "DHZW_income_group_proportions.csv", row.names = FALSE)

ggplot(df_income_grouped, aes(x = hh_income_group, y = n, fill = disp_modal_choice)) +
  geom_col(position = position_dodge2(width = 1, padding = 0), alpha = 0.8, color = "white", linewidth = 0.2) +
  geom_vline(xintercept = c(1.5, 2.5), linetype = "dashed", color = "gray80") +
  geom_text(
    aes(label = n),
    position = position_dodge2(width = 0.8),
    vjust = -0.5,
    size = 2
  ) +
  facet_wrap(~source, scale = "free") +
  labs(
    title = "Count of Mode Choice by Income Group",
    x = "Household Income Group",
    y = "Count",
    fill = "Mode Choice"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom", panel.spacing.x = unit(3, "lines"))


df_percentage_summary <- df_combined %>%
  mutate(year = year - 2000) %>%
  filter(hh_income_group != "unknown") %>%
  mutate(hh_income_group = factor(hh_income_group,
    levels = c("low", "average", "high", "unknown")
  )) %>%
  group_by(source, disp_modal_choice) %>%
  tally() %>%
  group_by(source) %>%
  mutate(percentage = (n / sum(n)) * 100) %>%
  ungroup()

write.csv(df_percentage_summary, "both_area_proportions.csv", row.names = FALSE)

df_dhzw_percentage <- df_percentage_summary[df_percentage_summary$source == "DHZW Only", ]
df_dhzw_percentage$source <- NULL
write.csv(df_dhzw_percentage, "DHZW_modal_choice_proporitions.csv", row.names = FALSE)

ggplot(df_percentage_summary, aes(y = percentage, x = disp_modal_choice, fill = disp_modal_choice)) +
  geom_col(position = position_dodge2(width = 1, padding = 0), alpha = 0.8, color = "white", linewidth = 0.2) +
  geom_text(
    aes(label = round(percentage, 1)),
    position = position_dodge2(width = 0.8),
    vjust = -0.5,
    size = 3
  ) +
  facet_wrap(~source, scale = "free") +
  labs(
    title = "Reported mode choices in percent from the OViN and ODiN datasets from 2010-19, and 2023 ",
    x = "Mode choice",
    y = "Percentage (%)",
    fill = "Mode Choice"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom", panel.spacing.x = unit(3, "lines"), axis.text.x = element_text(angle = 45, vjust = 0.5, hjust = 0.5))

# Prepare relative data
df_summary <- df %>%
  group_by(year, disp_modal_choice) %>%
  tally() %>%
  group_by(year) %>%
  mutate(percentage = (n / sum(n)) * 100) %>%
  ungroup()

# Generate stacked area plot
ggplot(df_summary, aes(x = year, y = percentage, fill = disp_modal_choice)) +
  geom_area(alpha = 0.8, color = "white", linewidth = 0.2) +
  scale_x_continuous(breaks = min(df_summary$year):max(df_summary$year)) +
  labs(
    title = "Market Share of Modal Choice (Stacked)",
    x = "Year",
    y = "Percentage of Total (%)",
    fill = "Modal Choice"
  ) +
  theme_minimal()

plot_modal_distribution(df, subtitle = "(DHZW only, 2010-2019 + 2023)")
# Clear packages
detach("package:datasets", unload = TRUE)

# Clear plots
dev.off() # But only if there IS a plot

# Clear console
cat("\014") # ctrl+L
