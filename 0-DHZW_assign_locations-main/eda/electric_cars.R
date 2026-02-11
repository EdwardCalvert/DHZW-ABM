library('haven')
library("dplyr")
library(tibble)
library(tidyr)
library(readr)
library("this.path")
library(datasets)  
library(dplyr)
library(patchwork)
library(ggplot2)
setwd(this.path::this.dir())


### Script to load OViN and ODiN data,

#Creates a CSV with the following attributes
#"agent_ID","age","hh_PC4","day_of_week","car_license","car_hh_ownership",
#"disp_ID","disp_start_PC4","disp_arrival_PC4","disp_activity","disp_start_inside",
#"disp_arrival_inside","disp_modal_choice","distance"


################################################################################
# This script put together the various years of ODiN into a big collection

# Load ODiNs and OViNs
setwd(this.path::this.dir())
setwd('../../../dhzw_data/odin-ovin')

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
ODiN2022 <- read_sav("2022_ODiN.sav")
ODiN2023 <- read_sav("2023_ODiN.sav")



########### Load postcodes
setwd(this.path::this.dir())
setwd('../../0-DHZW_shapefiles-main/data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

#Filter based on postcode.
#ODiN2023 <- ODiN2023[ODiN2023$WoPC %in% DHZW_PC4_codes,]
ODiN2023 <- ODiN2023[ODiN2023$WoGem == 518,]
OViN2010 <- OViN2010[OViN2010$WoGem ==518,] # 's-Gravenhage (methologically incorrect)

#OViN2010 <- OViN2010[OViN2010$WoGem %in% DHZW_PC4_codes,]


############## 2023



hist(ODiN2023$BrandstofPa1[ODiN2023$OP == 1])
hist(ODiN2023$BrandstofPa2[ODiN2023$OP == 1])

plot(ODiN2023$BrandstofPa1,ODiN2023$Hvm)



# Pre-calculate counts for the heatmap
# ODiN_counts <- ODiN2023 %>%
#   group_by(BrandstofPa1, Hvm) %>%
#   tally()

ODiN_proportions <- ODiN2023 %>%
  group_by(BrandstofPa1, Hvm) %>%
  tally() %>%
  ungroup() %>%
  mutate(percent = (n / sum(n)) * 100)

# ggplot(ODiN_counts, aes(x = BrandstofPa1, y = Hvm, fill = n)) +
#   geom_tile() +
#   scale_fill_viridis_c() + # High-contrast color scale
#   labs(fill = "Observations") +
#   theme_minimal()



p1 <- ggplot(ODiN_proportions, aes(x = as.factor(BrandstofPa1), y = as.factor(Hvm), fill = n)) +
  geom_tile() +
  geom_text(aes(label = n), color = "white", size = 3) +
  scale_fill_viridis_c() +
  # Customizing the labels
  scale_x_discrete(labels = c("1" = "Petrol","2" = "Diesel","3" = "LPG","4" = "Electric","5" = "Other","6" = "Unknown","7" = "Not applicable; No passenger car registered to the household")) +
  scale_y_discrete(labels = c("1" = "Passenger car","2" = "Train","3" = "Bus","4" = "Tram","5" = "Metro","6" = "Speed pedelec","7" = "Electric bicycle","8" = "Non-electric bicycle","9" = "On foot","10" = "Coach","11" = "Van","12" = "Lorry","13" = "Camper van","14" = "Taxi/taxi van","15" = "Agricultural vehicle","16" = "Motorcycle","17" = "Moped","18" = "Light moped","19" = "Motorised disabled transport","20" = "Non-motorised disabled transport","21" = "Skates/rollerblades/scooter","22" = "Boat","23" = "Other motorised","24" = "Other non-motorised")) +
  labs(
    title = "Heatmap of Primary fuel type of the youngest passenger car registered to the household  vs. Main transport used for a trip (ODiN 2023)",
    x = "Fuel Type (Car 1)",
    y = "Main Transport Mode",
    fill = "Observation Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Rotates labels if they overlap
  + geom_point()



hist(ODiN2022$BrandstofPa1)
hist(ODiN2022$BrandstofPa2)

typeof(ODiN2023$OP)
hist(ODiN2023$BrandstofPa1[ODiN2023$OP == 1])
hist(ODiN2023$BrandstofPa2)
hist(OViN2010$Brandstof[OViN2010$OP == 1])

#plot(ODiN203$HHGestInkG, ODiN2023$)


####################2010



# # Pre-calculate counts for the heatmap
# ODiN_counts <- OViN2010 %>%
#   group_by(Brandstof, Hvm) %>%
#   tally()

ODiN_proportions <- OViN2010 %>%
  group_by(Brandstof, Hvm) %>%
  tally() %>%
  ungroup() %>%
  mutate(percent = (n / sum(n)) * 100)



ggplot(ODiN_proportions, aes(x = as.factor(Brandstof), y = as.factor(Hvm), fill = percent)) +
  geom_tile() +
  geom_text(aes(label = round(percent, 1)), color = "white", size = 3) +
  scale_x_discrete(labels =c("1" = "Petrol    ","2" = "Diesel    ","3" = "LPG    ","4" = "Other    ","5" = "Unknown    ","6" = "Not asked; OP younger than 18    ","7" = "Not asked; OP does not have a driving licence    ","8" = "Not asked; OP\'s driving licence status unknown    ","9" = "Not asked; OP not the main user of the car    ","10" = "Not asked; OP\'s main use of the car unknown")) + 
  scale_y_discrete(labels =c("1" = "Train","2" = "Coach/bus (private bus transport only)","3" = "Metro","4" = "Tram","5" = "Bus (public transport only)","6" = "Car driver","7" = "Delivery van","8" = "Lorry","9" = "Camper van","10" = "Passenger car","11" = "Taxi","12" = "Motorcycle","13" = "Moped","14" = "Scooter","15" = "Bicycle (electric or non-electric)","16" = "Bicycle as a passenger","17" = "Agricultural vehicle","18" = "Boat (regular service, ferry service)","19" = "Airplane","20" = "Skates/rollerblades/scooter","21" = "Disabled transport","22" = "On foot","23" = "Pram","24" = "Other"))+
  scale_fill_viridis_c() +
  labs(
    title = "Heatmap of Primary fuel type of the youngest passenger car registered to the household  vs. Main transport used for a trip (ODiN 2010)",
    x = "Fuel Type (Car 1)",
    y = "Main Transport Mode",
    fill = "Observation Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  


#### Conditional probability

ODiN_proportions <- OViN2010 %>%
  group_by(Brandstof, Hvm) %>%
  tally() %>%
  group_by(Brandstof) %>% # Re-group by the denominator variable
  mutate(percent = (n / sum(n)) * 100)



ggplot(ODiN_proportions, aes(x = as.factor(Brandstof), y = as.factor(Hvm), fill = percent)) +
  geom_tile() +
  geom_vline(xintercept = seq(1.5, 9.5, by = 1), color = "black", size = 1.2)+
  geom_text(aes(label = round(percent, 1)), color = "white", size = 3) +
  scale_x_discrete(labels =c("1" = "Petrol    ","2" = "Diesel    ","3" = "LPG    ","4" = "Other    ","5" = "Unknown    ","6" = "Not asked; OP younger than 18    ","7" = "Not asked; OP does not have a driving licence    ","8" = "Not asked; OP\'s driving licence status unknown    ","9" = "Not asked; OP not the main user of the car    ","10" = "Not asked; OP\'s main use of the car unknown")) + 
  scale_y_discrete(labels =c("1" = "Train","2" = "Coach/bus (private bus transport only)","3" = "Metro","4" = "Tram","5" = "Bus (public transport only)","6" = "Car driver","7" = "Delivery van","8" = "Lorry","9" = "Camper van","10" = "Passenger car","11" = "Taxi","12" = "Motorcycle","13" = "Moped","14" = "Scooter","15" = "Bicycle (electric or non-electric)","16" = "Bicycle as a passenger","17" = "Agricultural vehicle","18" = "Boat (regular service, ferry service)","19" = "Airplane","20" = "Skates/rollerblades/scooter","21" = "Disabled transport","22" = "On foot","23" = "Pram","24" = "Other"))+
  scale_fill_viridis_c() +
  labs(
    title = "CONDITIONAL Heatmap of Primary fuel type of the youngest passenger car registered to the household  vs. Main transport used for a trip (ODiN 2010)",
    x = "Fuel Type (Car 1)",
    y = "Main Transport Mode",
    fill = "Observation Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  

p1 + p2

#c("1" = "Petrol    ","2" = "Diesel    ","3" = "LPG    ","4" = "Other    ","5" = "Unknown    ","6" = "Not asked; OP younger than 18    ","7" = "Not asked; OP does not have a driving licence    ","8" = "Not asked; OP\'s driving licence status unknown    ","9" = "Not asked; OP not the main user of the car    ","10" = "Not asked; OP\'s main use of the car unknown")
# Clear packages
detach("package:datasets", unload = TRUE)

# Clear plots
dev.off()  # But only if there IS a plot

# Clear console
cat("\014")  # ctrl+L
