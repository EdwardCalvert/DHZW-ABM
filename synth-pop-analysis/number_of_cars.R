synthetic_population <- "C:\\Users\\ed\\Development\\dhzw\\output\\synth_pop\\final_output\\DHZW_synthetic_population.csv"

synth_pop <- read_csv(synthetic_population)

synth_pop_car_licences <- synth_pop[synth_pop$car_license, ]
synth_pop_cars <- synth_pop[synth_pop$car_ownership, ]

synth_pop_car_users <- synth_pop[synth_pop$car_license & synth_pop$car_ownership, ]


vanilla_pop <- "C:\\Users\\ed\\Development\\dhzw\\output\\vanilla\\final_output\\DHZW_synthetic_population.csv"
vanilla <- read_csv(vanilla_pop)

vanilla_car_licences <- vanilla[vanilla$car_license, ]
vanilla_cars <- vanilla[vanilla$car_ownership, ]

vanilla_car_users <- vanilla[vanilla$car_license & vanilla$car_ownership, ]
