get_activites_from_trips <- function(highly_urbanised_trips_csv) {
  ################################################################################
  # This script takes a collection of ODiN and returns activities for each participant (instead of trips)

  ################################################################################
  # Transform ODiN into activities

  df_original <- read_csv(highly_urbanised_trips_csv)

  df_original <- df_original[order(df_original$agent_ID), ]

  df_original <- df_original %>%
    select(agent_ID, disp_activity, disp_start_time, disp_arrival_time, day_of_week)

  # Transform minutes into seconds
  df_original$disp_start_time <- df_original$disp_start_time * 60
  df_original$disp_arrival_time <- df_original$disp_arrival_time * 60

  # For each trip add the start time of the next trip
  df_original <-
    transform(df_original, next_start_time = c(disp_start_time[-1], NA))
  df_original <-
    transform(df_original, nxt_ID = c(as.character(agent_ID[-1]), NA))
  df_original$next_start_time <-
    ifelse(df_original$nxt_ID == df_original$agent_ID,
      df_original$next_start_time,
      86399
    ) # midnight

  # activities where the trips is actually the activity
  list_ODiN_activities <-
    c("collection/delivery of goods", "hiking", "transport is the job")

  datalist <- list()
  ODiN_IDs <- unique(df_original$agent_ID)


  activity_map <- c(
    "to home"                  = "home",
    "to work"                  = "work",
    "visit/stay"               = "visit/stay",
    "shopping"                 = "shopping",
    "other leisure activities" = "leisure",
    "services/personal care"   = "leisure",
    "sports/hobby"             = "sport",
    "pick up / bring people"   = "pick up / bring people",
    "follow education"         = "school",
    "business visit"           = "business visit"
  )

  for (n in 1:length(ODiN_IDs)) {
    ODiN_ID <- ODiN_IDs[n]

    # Pre-allocate with explicit types to prevent coercion errors
    df <- data.frame(
      ODiN_ID = character(),
      activity_type = character(),
      start_time = numeric(),
      end_time = numeric(),
      day_of_week = numeric(),
      stringsAsFactors = FALSE
    )

    df_activities <- df_original[df_original$agent_ID == ODiN_ID, ]
    counter <- 1


    if (is.na(df_activities[1, ]$disp_activity)) {
      # If the agent has no activities defined, agent stays at home
      df[counter, ] <- list(
        ODiN_ID,
        "home",
        0,
        1439,
        df_activities[1, ]$day_of_week
      )
    } else {
      # Go through the activities
      for (i in 1:nrow(df_activities)) {
        # first activity; instatiate a list
        if (counter == 1) {
          df[counter, ] <- list(ODiN_ID, "home", 0, df_activities[1, ]$disp_start_time, df_activities[1, ]$day_of_week)
        }

        counter <- counter + 1
        act_label <- if (df_activities[i, ]$disp_activity %in% list_ODiN_activities) df_activities[i, ]$disp_activity else "trip"
        df[counter, ] <- list(ODiN_ID, act_label, df_activities[i, ]$disp_start_time, df_activities[i, ]$disp_arrival_time, df_activities[i, ]$day_of_week)

        counter <- counter + 1
        # Apply the activity map
        if (df_activities[i, ]$disp_activity %in% list_ODiN_activities) {
          activity <- df[counter - 2, ]$activity_type
        } else {
          activity <- activity_map[df_activities[i, ]$disp_activity]
          if (is.na(activity)) activity <- "other" # Fallback for unmapped types
        }

        df[counter, ] <- list(ODiN_ID, activity, df_activities[i, ]$disp_arrival_time, df_activities[i, ]$next_start_time, df_activities[i, ]$day_of_week)
      }
    }

    # Filtering and cleaning
    df <- df %>% filter(
      activity_type %in% c("home", "work", "shopping", "sport") |
        (activity_type == "school" & !day_of_week %in% c(1, 7))
    )

    # # Check if df is empty before continuing to avoid "replacement has 0 rows" error
    # if (nrow(df) > 0) {
    #   df$remove <- FALSE
    #   for (x in 1:nrow(df)) {
    #     if (x + 1 <= nrow(df)) {
    #       if (df[x, ]$activity_type == df[x + 1, ]$activity_type) {
    #         df[x, ]$remove <- TRUE
    #         df[x + 1, ]$start_time <- df[x, ]$start_time
    #       }
    #     }
    #   }
    # }


    ## Now collapse duplicated activities of the same type to become one activity
    df <- df %>%
      # group_by(agent_ID) %>%
      mutate(
        # Identify if the next activity is the same as the current one
        is_duplicate = activity_type == lead(activity_type),
        # If the PREVIOUS was a duplicate, pull its start_time forward
        # (This handles the 'collapsing' logic)
        start_time = if_else(lag(activity_type, default = "") == activity_type,
          lag(start_time),
          start_time
        )
      ) %>%
      # Filter out the rows marked as duplicates
      filter(!is_duplicate) %>%
      select(-is_duplicate)

    # df <- df[df$remove == FALSE, ]
    # df$remove <- NULL

    # Finalize times and durations
    if (nrow(df) > 0) {
      df[nrow(df), ]$end_time <- 1439 # Set the end_time of the last row to 1439 (errors here if df has no rows)
      df$duration <- df$end_time - df$start_time
      df$activity_number <- 1:nrow(df)

      datalist[[n]] <- df
    }
  }


  df_activities_all <- do.call(rbind, datalist)
  #
  # # Save dataset
  # setwd(paste0(this.path::this.dir(), "/data/processed"))
  # write.csv(df_activities_all, 'df_activity_schedule-higly_urbanized.csv', row.names = FALSE)

  return(df_activities_all)
}


get_activities_from_trips_attempt_vector <- function(highly_urbanised_trips_csv) {
  df_trips <- read_csv(highly_urbanised_trips_csv)

  activity_map <- c(
    "to home"                  = "home",
    "to work"                  = "work",
    "visit/stay"               = "visit/stay",
    "shopping"                 = "shopping",
    "other leisure activities" = "leisure",
    "services/personal care"   = "leisure",
    "sports/hobby"             = "sport",
    "pick up / bring people"   = "pick up / bring people",
    "follow education"         = "school",
    "business visit"           = "business visit"
  )
  # travel_centric_tasks <- c(
  #   "collection/delivery of goods",
  #   "hiking",
  #   "transport is the job"
  # )

  ##MAY NEED TO include blank (i.e sitting at home all day) activity schedule 
  # for some agents so IDs are contiguous

  df_activites <- df_trips |>
    arrange(agent_ID, disp_start_time) |>
    mutate(
      start_min = disp_start_time * 60, # transform minutes into seconds
      arr_min = disp_arrival_time * 60,
      mapped_activity = recode(
        disp_activity, 
        !!!activity_map, 
        .default = "other"
      )
    ) |>
    #slice(1:1000)|> #DEV: TAKE FIRST 1000 rows for quick processing.
    group_by(agent_ID) |> 
    reframe(
      activity_type =  mapped_activity,
      start_time = start_min,
      end_time = lead(start_min, default = 86399), # number of seconds in a day
      day_of_week   = day_of_week
    ) |>
    group_by(agent_ID) |> #regroup reframed tibble
    group_modify(~ {
      ## Make sure each agent starts at home.
      first_start <- .x$start_time[1]
      add_row(
        .x,
        activity_type = "home",
        start_time = 0,
        end_time = first_start,
        day_of_week = .x$day_of_week[1],
        .before = 1
      )
    }) |>
    filter(
      (activity_type %in% c("home", "work", "shopping", "sport")) |
        (activity_type == "school" & !day_of_week %in% c(1, 7))
    ) |>
    mutate(
      is_duplicate = (activity_type == lead(activity_type, default = "END")),
      # Pull start_time from first in a chain of duplicates
      start_time = if_else(lag(activity_type, default = "START") == activity_type,
        lag(start_time),
        start_time
      )
    ) |>
    filter(!is_duplicate) |>
    mutate(
      end_time = if_else(row_number() == n(), 86399, end_time),
      duration = end_time - start_time,
      activity_number = row_number()
    ) |>
    # filter(duration > 0 ) |>
    select(ODiN_ID = agent_ID, activity_type, start_time, end_time, day_of_week, duration, activity_number) |>
    ungroup()
  return(df_activites)
}

get_activites_from_trips_attempt_vector <- function(highly_urbanised_trips_csv) {
  df_original <- read_csv(highly_urbanised_trips_csv)

  # 1. Pre-processing: Map activities and handle constants
  activity_map <- c(
    "to home"                  = "home",
    "to work"                  = "work",
    "visit/stay"               = "visit/stay",
    "shopping"                 = "shopping",
    "other leisure activities" = "leisure",
    "services/personal care"   = "leisure",
    "sports/hobby"             = "sport",
    "pick up / bring people"   = "pick up / bring people",
    "follow education"         = "school",
    "business visit"           = "business visit"
  )

  list_ODiN_activities <- c("collection/delivery of goods", "hiking", "transport is the job")
  #
  # # 2. Main Vectorized Transformation
  # df_processed <- df_original %>%
  #   arrange(agent_ID, disp_start_time) %>%
  #   mutate(
  #     # Standardize times to minutes (0-1439)
  #     start_min = disp_start_time, # Assuming input is already in minutes based on previous context
  #     arr_min   = disp_arrival_time,
  #     # Map activity types
  #     mapped_act = recode(disp_activity, !!!activity_map, .default = "other")
  #   ) %>%
  #   group_by(agent_ID) %>%
  #   # Create three segments per trip record:
  #   # A: Initial Home (only for first trip), B: The Trip itself, C: The Activity after the trip
  #   reframe(
  #     activity_type = c("home", "trip", mapped_act),
  #     start_time    = c(0, start_min, arr_min),
  #     end_time      = c(start_min, arr_min, lead(start_min, default = 1439)),
  #     day_of_week   = first(day_of_week)
  #   ) %>%
  #   # 3. Apply ODiN Specific Logic (where trip IS the activity)
  #   mutate(
  #     activity_type = if_else(activity_type == "trip" & lag(activity_type) %in% list_ODiN_activities,
  #                             lag(activity_type),
  #                             activity_type)
  #   ) %>%

  df_processed <- df_original %>%
    arrange(agent_ID, disp_start_time) %>%
    mutate(
      start_min = disp_start_time,
      arr_min = disp_arrival_time,
      mapped_act = recode(disp_activity, !!!activity_map, .default = "other")
    ) %>%
    group_by(agent_ID) %>%
    # Logic: For every trip, we generate two rows: the trip itself and the activity following it.
    reframe(
      activity_type = c("trip", mapped_act),
      start_time    = c(start_min, arr_min),
      end_time      = c(arr_min, lead(start_min, default = 1439)),
      day_of_week   = first(day_of_week)
    ) %>%
    # Now prepend the "Initial Home" activity for every agent
    group_by(agent_ID) %>%
    group_modify(~ {
      first_start <- .x$start_time[1]
      add_row(.x,
        activity_type = "home",
        start_time = 0,
        end_time = first_start,
        day_of_week = .x$day_of_week[1],
        .before = 1
      )
    }) %>%
    # 4. Filtering criteria
    filter(
      activity_type %in% c("home", "work", "shopping", "sport") |
        (activity_type == "school" & !day_of_week %in% c(1, 7))
    ) %>%
    # 5. Collapse Duplicates (Vectorized)
    mutate(
      is_duplicate = (activity_type == lead(activity_type, default = "END")),
      # Pull start_time from first in a chain of duplicates
      start_time = if_else(lag(activity_type, default = "START") == activity_type,
        lag(start_time),
        start_time
      )
    ) %>%
    filter(!is_duplicate) %>%
    # 6. Finalize durations and indices
    mutate(
      end_time = if_else(row_number() == n(), 1439, end_time),
      duration = end_time - start_time,
      activity_number = row_number()
    ) %>%
    filter(duration > 0) %>% # Clean up any 0-length activities from collapsing
    select(ODiN_ID = agent_ID, activity_type, start_time, end_time, day_of_week, duration, activity_number) %>%
    ungroup()

  return(df_processed)
}


get_activites_from_trips_attempt_vector2 <- function(highly_urbanised_trips_csv) {
  df_original <- read_csv(highly_urbanised_trips_csv)

  activity_map <- c(
    "to home"                  = "home",
    "to work"                  = "work",
    "visit/stay"               = "visit/stay",
    "shopping"                 = "shopping",
    "other leisure activities" = "leisure",
    "services/personal care"   = "leisure",
    "sports/hobby"             = "sport",
    "pick up / bring people"   = "pick up / bring people",
    "follow education"         = "school",
    "business visit"           = "business visit"
  )

  df_processed <- df_original %>%
    arrange(agent_ID, disp_start_time) %>%
    mutate(
      mapped_act = recode(disp_activity, !!!activity_map, .default = "other"),
      # Define the end of the activity as the start of the next trip
      act_end_time = lead(disp_start_time, default = 1439)
    ) %>%
    group_by(agent_ID) %>%
    # Create paired columns for pivoting
    mutate(
      type_1 = "trip",        start_1 = disp_start_time,    end_1 = disp_arrival_time,
      type_2 = mapped_act,    start_2 = disp_arrival_time,  end_2 = act_end_time
    ) %>%
    # Pivot to interleave Trip and Activity rows
    pivot_longer(
      cols = matches("^(type|start|end)_"),
      names_to = c(".value", "pair_id"),
      names_pattern = "(.*)_(.*)"
    ) %>%
    # Prepend the initial Home activity
    group_modify(~ {
      add_row(.x,
        type = "home",
        start = 0,
        end = .x$start[1],
        day_of_week = .x$day_of_week[1],
        .before = 1
      )
    }) %>%
    filter(
      type %in% c("home", "work", "shopping", "sport") |
        (type == "school" & !day_of_week %in% c(1, 7))
    ) %>%
    # Collapse sequential identical activities
    mutate(
      is_duplicate = (type == lead(type, default = "END"))
    ) %>%
    filter(!is_duplicate) %>%
    mutate(
      duration = end - start,
      activity_number = row_number()
    ) %>%
    filter(duration > 0) %>%
    select(
      ODiN_ID = agent_ID, activity_type = type, start_time = start,
      end_time = end, day_of_week, duration, activity_number
    ) %>%
    ungroup()

  return(df_processed)
}
