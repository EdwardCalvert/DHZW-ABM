library(dplyr)
library(ggplot2)
library(scales)
library(geosphere)
library(sf)


df_pc4_urbanisation <- read.csv("../dhzw_data/pc4_2021_vol.csv")

df_highly_urbanised <- df_pc4_urbanisation[df_pc4_urbanisation$STED == 1, ]$PC4

df_PC4_NL <- st_read("C:\\Users\\ed\\Development\\dhzw_data\\2024-cbs_pc4_2021_vol\\cbs_pc4_2021_vol.gpkg", layer = "cbs_pc4_2021")


average_modal_percent <- function(i) {
  all_dirs <- list.dirs(path = paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), full.names = FALSE, recursive = FALSE)

  sorted_dirs <- sort(all_dirs)
  last_30_dirs <- tail(sorted_dirs, 30)


  file_paths <- file.path(paste0("7-simulation-Sim-2APL/src/main/resources/distance_analysis/", i), last_30_dirs, "OD-Matrix.csv")

  existing_files <- file_paths[file.exists(file_paths)]


  combined_df <- do.call(rbind, lapply(existing_files, function(f) {
    data <- read.csv(f)
    data$source_dir <- i
    return(data)
  }))
  # result <- combined_df %>%
  #   summarise(mean_percent = mean(simulated.percent), sd_percent = sd(simulated.percent), rq = i, .by = c(income_group, mode_choice))

  return(combined_df)
}

df <- average_modal_percent("rq1-1")

df <- df %>%
  group_by(departure, arrival) %>%
  summarise(
    car_driver = sum(car_driver, na.rm = TRUE) / 30,
    car_passenger = sum(car_passenger, na.rm = TRUE) / 30,
    train = sum(train, na.rm = TRUE) / 30,
    bus_tram = sum(bus_tram, na.rm = TRUE) / 30,
    bike = sum(bike, na.rm = TRUE) / 30,
    walk = sum(walk, na.rm = TRUE) / 30,
    .groups = "drop"
  )

# df <- read.csv("9-other-analysis//od-matrix//OD-Matrix.csv", sep = ",")

df_pc4_centroid <- read.csv("C:\\Users\\ed\\Development\\dhzw\\output\\synth_pop\\0-shapefiles\\centroids_PC4_NL.csv", sep = ",")
# df$arrival_x <- df_pc4_centroid[df_pc4_centroid$PC4 == df$arrival, ]


df <- merge(df, df_pc4_centroid[, c("PC4", "coordinate_x", "coordinate_y")],
  by.x = "arrival",
  by.y = "PC4",
  all.x = TRUE
)
names(df)[names(df) == "coordinate_x"] <- "arrival_x"
names(df)[names(df) == "coordinate_y"] <- "arrival_y"

df <- merge(df, df_pc4_centroid[, c("PC4", "coordinate_x", "coordinate_y")],
  by.x = "departure",
  by.y = "PC4",
  all.x = TRUE
)


DHZW_PC4_codes <-
  read.csv("0-shapefiles/data/codes/DHZW_PC4_codes.csv", sep = ";", header = F)$V1


names(df)[names(df) == "coordinate_x"] <- "departure_x"
names(df)[names(df) == "coordinate_y"] <- "departure_y"
names(df)

write.csv(df, paste0("10-other-analysis\\od-matrix\\processed-od.csv"), row.names = FALSE)

df[departures$departure %in% DHZW_PC4_codes, ]



departures <- select(df, c("departure", "car_driver", "car_passenger", "train", "bus_tram", "bike", "walk", "departure_x", "departure_y"))
departures <- departures %>%
  group_by(departure) %>%
  summarize(
    car_driver = sum(car_driver, na.rm = TRUE), # Remove any null values, since dataset will have missing values as route assignment is random
    car_passenger = sum(car_passenger, na.rm = TRUE),
    train = sum(train, na.rm = TRUE),
    bus_tram = sum(bus_tram, na.rm = TRUE),
    bike = sum(bike, na.rm = TRUE),
    walk = sum(walk, na.rm = TRUE),
    departure_x = first(departure_x), departure_y = first(departure_y)
  )
write.csv(departures, "10-other-analysis\\od-matrix\\processed-departures.csv", row.names = FALSE)



departures_in_DHZW <- departures[departures$departure %in% DHZW_PC4_codes, ]

write.csv(departures_in_DHZW, "9-other-analysis\\od-matrix\\processed-departures_IN_DHZW.csv", row.names = FALSE)

departures_not_DHZW <- departures[!departures$departure %in% DHZW_PC4_codes, ]

write.csv(departures_not_DHZW, "9-other-analysis\\od-matrix\\processed-departures_NOT_DHZW.csv", row.names = FALSE)




arrivals <- select(df, c("arrival", "car_driver", "car_passenger", "train", "bus_tram", "bike", "walk", "arrival_x", "arrival_y"))
arrivals <- arrivals %>%
  group_by(arrival) %>%
  summarize(
    car_driver = sum(car_driver, na.rm = TRUE), # Remove any null values, since dataset will have missing values as route assignment is random
    car_passenger = sum(car_passenger, na.rm = TRUE),
    train = sum(train, na.rm = TRUE),
    bus_tram = sum(bus_tram, na.rm = TRUE),
    bike = sum(bike, na.rm = TRUE),
    walk = sum(walk, na.rm = TRUE),
    arrival_x = first(arrival_x), arrival_y = first(arrival_y)
  )
write.csv(departures, "9-other-analysis\\od-matrix\\processed-arrivals.csv", row.names = FALSE)


arrivals_in_DHZW <- arrivals[arrivals$arrival %in% DHZW_PC4_codes, ]

write.csv(arrivals_in_DHZW, "9-other-analysis\\od-matrix\\processed-arrivals_IN_DHZW.csv", row.names = FALSE)

arrivals_not_DHZW <- arrivals[!arrivals$arrival %in% DHZW_PC4_codes, ]

write.csv(arrivals_not_DHZW, "9-other-analysis\\od-matrix\\processed-arrivals_NOT_DHZW.csv", row.names = FALSE)


cars <- select(df, c("departure", "arrival", "car_driver", "arrival_x", "arrival_y", "departure_x", "departure_y"))
cars$count <- cars$car_driver
cars$car_driver <- NULL

cars <- cars[cars$count > 0, ]


cars_destinations <- select(cars, c("departure", "count", "departure_x", "departure_y"))
cars_destinations <- cars_destinations %>%
  group_by(departure) %>%
  summarize(total_count = sum(count, na.rm = TRUE), departure_x = first(departure_x), departure_y = first(departure_y))


write.csv(cars_destinations, "9-other-analysis\\od-matrix\\car-destinations.csv", row.names = FALSE)

cars_arrivals <- select(cars, c("arrival", "count", "arrival_x", "arrival_y"))
cars_arrivals <- cars_arrivals %>%
  group_by(arrival) %>%
  summarize(total_count = sum(count, na.rm = TRUE), arrival_x = first(arrival_x), arrival_y = first(arrival_y))

write.csv(cars_arrivals, "9-other-analysis\\od-matrix\\car-arrivals.csv", row.names = FALSE)

write.csv(cars, "9-other-analysis\\od-matrix\\cars-od.csv", row.names = FALSE)
