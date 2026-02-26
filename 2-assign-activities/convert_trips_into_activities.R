
## Take the urbanised trips, and convert them into activities, with a defined 
#start and end time. Filters only to activity types of home, work, school,
# shopping and work. Likely needs future efforts. 


#May need to check wether date processing needs to occur
#i.e. is an ODiN agent ID restricted to reporting activities only on one
# given day????
# EC 


get_activites_from_trips_vector <- function(highly_urbanised_trips_csv) {
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
  
  #Was included in original script, so feel the need to include!
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
