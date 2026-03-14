process_ODiN_data <- function(odin_ovin_dir, urbanisation_pc4_csv, DHZW_pc4_codes_csv) {
  df_OViN <- lapply(c(2010:2017), function(y) {
    read_sav(file.path(odin_ovin_dir, paste0(y, "_OViN.sav"))) %>%
      filter_attributes_OViN()
  }) %>% bind_rows()

  df_ODiN <- lapply(c(2018, 2019), function(y) {
    read_sav(file.path(odin_ovin_dir, paste0(y, "_ODiN.sav"))) %>%
      filter_attributes_ODiN()
  }) %>% bind_rows()

  # Filter individuals that live in a PC4 with the same DHZW urbanization index.

  # Find PC4 in The Netherlands with the same urbanization index of DHZW. STED is the index and 1 is the highest
  # Extracted from: https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische-data/gegevens-per-postcode
  df_urbanization_PC4 <-
    read.csv(urbanisation_pc4_csv, sep = ",", header = T)

  # Read list of all PC4 in the Netherlands and their urbanization indexes.
  DHZW_PC4_codes <-
    read.csv(DHZW_pc4_codes_csv, sep = ";", header = F)$V1

  # Find all the PC4s in The Netherlands that have such STED index equals to 1 "Very highly urban" (environmental address density of 2500 or more addresses/km2)
  PC4_urbanized_like_DHZW <- df_urbanization_PC4[df_urbanization_PC4$STED ==
    1, ]$PC4

  # In ODiN, filter only individuals that live in such highly urbanized PC4s
  df_ODiN <- df_ODiN[df_ODiN$hh_PC4 %in% PC4_urbanized_like_DHZW, ]

  ################################################################################
  # OViN

  # Since the residential PC4 is not given, for the individuals that at have least one displacement I retrieve it from the first displacement.
  df_OViN <- extract_residential_PC4_from_first_displacement(df_OViN)

  # Individuals that stay at home all day. Filter based on the given municipality urbanization index
  df_OViN_stay_home <- df_OViN[is.na(df_OViN$disp_counter) & df_OViN$municipality_urbanization == 1, ]


  # Individuals with at least a displacement. Filter on the extracted residential PC4 and its urbanization index (like with ODiN).
  df_OViN_with_disp <- df_OViN[!is.na(df_OViN$disp_counter), ]
  df_OViN_with_disp <- df_OViN[df_OViN$hh_PC4 %in% PC4_urbanized_like_DHZW, ]

  # plot_modal_distribution(df_OViN_with_disp)

  df_OViN <- rbind(df_OViN_with_disp, df_OViN_stay_home)
  df_OViN <- subset(df_OViN, select = -c(municipality_urbanization))

  ################################################################################

  df <- rbind(
    df_OViN,
    df_ODiN
  )

  # # is no moves (the individual stays at home all day), the counter is 0.
  # # EC removed 28/02/2026 since filter start_day_from home removes this property
  # df[is.na(df$disp_counter),]$disp_counter <- 0

  # For individuals with at least a displacement, filter only the ones that
  # start the  day from one. This is because in the simulation the delibration
  # cycle is at midnight everyday, so the agetns must then start from home
  # everyday.
  df <- filter_start_day_from_home(df)


  # format the values of the attributes
  df <- format_values(df)

  ################################################################################

  df$disp_start_time <- (df$disp_start_hour * 60 + df$disp_start_min) * 60 # start_time_in seconds
  df$disp_arrival_time <-
    (df$disp_arrival_hour * 60 + df$disp_arrival_min) * 60


  day_labels <- c(
    "1" = "Sunday", "2" = "Monday", "3" = "Tuesday",
    "4" = "Wednesday", "5" = "Thursday", "6" = "Friday", "7" = "Saturday"
  )

  unique(df$disp_modal_choice)


  df_car <- df[
    !is.na(df$disp_start_time) &
      !is.na(df$day_of_week),
  ]

  df_car$day_of_week <- factor(df_car$day_of_week,
    levels = c(2, 3, 4, 5, 6, 7, 1),
    labels = c(
      "Monday", "Tuesday", "Wednesday", "Thursday",
      "Friday", "Saturday", "Sunday"
    )
  )
  df_car$start_hour <- df_car$disp_start_time / 3600

  df_car <- df_car[!is.na(df_car$start_hour), ]

  df_age <- df_car[!is.na(df_car$age) & !is.na(df_car$disp_modal_choice), ]


  ggplot(df_age, aes(x = age, fill = disp_modal_choice)) +
    geom_bar(position = "stack", width = 1) +
    # facet_wrap(~day_of_week, scales = "fixed", ncol = 2, drop = FALSE) +
    scale_x_continuous(breaks = seq(0, 100, 10)) +
    scale_fill_viridis_d(aesthetics = "fill", option = "virdis", direction = -1) +
    theme_minimal() +
    theme(legend.position = "bottom") +
    labs(
      fill = "Activity",
      title = "Age against modal choice",
      x = "Age",
      y = "Count"
    )


  df_car <- df_car[df_car$disp_modal_choice == "car", ]
  df_dhzw <- df_car[df_car$hh_PC4 %in% DHZW_PC4_codes, ]


  df_combined <- bind_rows(
    mutate(df_car, source = "Urbanised like DHZW"),
    mutate(df_dhzw, source = "DHZW Only")
  )


  df_combined <- df_combined %>%
    mutate(disp_activity = fct_recode(as.factor(disp_activity),
      # "Business visit in a work context" = "business visit",
      # "Picking up/dropping off goods"    = "collection/delivery of goods",
      "Education/course attendance"      = "follow education",
      # "Touring/walking"                  = "hiking",
      # "Other purpose"                    = "other",
      # "Other leisure activities"         = "other leisure activities",
      # "Picking up/dropping off people"   = "pick up / bring people",
      # "Services/personal care"           = "services/personal care",
      "Shopping/grocery shopping"        = "shopping",
      "Sport/hobby"                      = "sports/hobby",
      "Going home"                       = "to home",
      "Working"                          = "to work",
      # "Professional"                     = "transport is the job",
      # "Visiting/staying overnight"       = "visit/stay"
    )) %>%
    mutate(disp_activity = fct_relevel(
      disp_activity,
      # "Business visit in a work context",
      # "Picking up/dropping off goods",
      "Education/course attendance",
      # "Touring/walking",
      # "Other purpose",
      # "Other leisure activities",
      # "Picking up/dropping off people",
      # "Services/personal care",
      "Shopping/grocery shopping",
      "Sport/hobby",
      "Going home",
      "Working",
      # "Professional",
      # "Visiting/staying overnight"
    ))

  df_combined <- df_combined[df_combined$disp_activity %in% c(
    "Education/course attendance",
    "Shopping/grocery shopping",
    "Sport/hobby",
    "Going home",
    "Working"
  ), ]

  # ggplot(df_combined, aes(x = start_hour, fill = disp_activity)) +
  #   geom_bar(position = "stack", width = 0.5) +
  #   facet_wrap(
  #     day_of_week ~ source,
  #     scales = "free_y",
  #     ncol = 2,
  #     labeller = label_context(sep = " | ") # Customizes the join string
  #     ) +
  #   scale_x_continuous(breaks = seq(0, 24, 4)) +
  #   labs(fill = "Activity", title = "Temporal Distribution of Car Trips by Activity and Weekday") +
  #   scale_fill_viridis_d(aesthetics  = "cividis") +
  #   theme_minimal() +
  #   theme(
  #     legend.position = "bottom",
  #     strip.text = element_text(size = 9) # Adjust size if the single line gets too long
  #   )

  df_combined %>%
    mutate(facet_label = fct_inorder(paste(day_of_week, source, sep = " - "))) %>%
    ggplot(aes(x = start_hour, fill = disp_activity)) +
    geom_bar(position = "stack", width = 0.5) +
    facet_wrap(~facet_label, scales = "free_y", ncol = 2) +
    scale_x_continuous(breaks = seq(0, 24, 2)) +
    theme_minimal() +
    theme(
      legend.position = "bottom"
    ) +
    labs(
      fill = "Activity",
      title = "Temporal Distribution of Trips made on Foot by Activity and Weekday",
      x = "Hour of day",
      y = "Count"
    )


  days <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
  sources <- unique(df_combined$source)

  grid_levels <- paste(rep(days, each = length(sources)), sources, sep = " - ")

  df_plot <- df_combined %>%
    mutate(
      facet_label_str = paste(day_of_week, source, sep = " - "),
      facet_label = factor(facet_label_str, levels = grid_levels)
    )


  ggplot(df_plot, aes(x = start_hour, fill = disp_activity)) +
    geom_bar(position = "stack", width = 0.5) +
    facet_wrap(~facet_label, scales = "free_y", ncol = 2, drop = FALSE) +
    scale_x_continuous(breaks = seq(0, 24, 2)) +
    scale_fill_viridis_d(aesthetics = "cividis") +
    theme_minimal() +
    theme(legend.position = "bottom") +
    labs(
      fill = "Activity",
      title = "Temporal Distribution of Car Trips by Activity and Weekday",
      x = "Hour of day",
      y = "Count"
    )


  ########################################################################################
  # Data cleaning

  # Delete agents that have missing demographic information that are used later for the matching
  IDs_to_delete <- df[df$migration_background == "unknown", ]$agent_ID
  df <- df[!(df$agent_ID %in% IDs_to_delete), ]


  # Delete agents that have missing trip information. NA can be only for people that stay at home all day
  IDs_to_delete <- df[(is.na(df$disp_activity) | is.na(df$disp_start_time) | is.na(df$disp_arrival_time)) & df$disp_counter > 0, ]$agent_ID
  df <- df[!(df$agent_ID %in% IDs_to_delete), ]


  return(df)
  # plot_modal_distribution(df,subtitle = "(urbanised like DHZW, 2010-2019,2023)")
}
