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




# Load ODiNs and OViNs
setwd(this.path::this.dir())
setwd('../../../dhzw_data/odin-ovin')

ODiN2023 <- read_sav("2023_ODiN_EN.sav")



########### Load postcodes
setwd(this.path::this.dir())
setwd('../../0-DHZW_shapefiles-main/data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

#Filter based on postcode.
ODiN2023 <- ODiN2023[ODiN2023$WoPC %in% DHZW_PC4_codes,]

nrow(ODiN2023[ODiN2023$OP==1,])




par(mfrow = c(2, 1))

hist(ODiN2023$HHBestInkG)
hist(ODiN2023$HHGestInkG)
par(mfrow = c(1, 1))

hist(ODiN2023$KHvm)



fuel_labels_2023 <- c( "Petrol", "Diesel","LPG", "Electric","Other", "Unknown", "Not applicable; No passenger car registered to the household")

# Convert to factor
ODiN2023$BrandstofPa1_f <- factor(
  ODiN2023$BrandstofPa1,
  levels = 1:7,
  labels = fuel_labels_2023
)

ODiN2023$Hvm <- factor(
  ODiN2023$Hvm,
  levels = 1:24,
  labels = c("1" = "Passenger car","2" = "Train","3" = "Bus","4" = "Tram","5" = "Metro","6" = "Speed pedelec","7" = "Electric bicycle","8" = "Non-electric bicycle","9" = "On foot","10" = "Coach","11" = "Van","12" = "Lorry","13" = "Camper van","14" = "Taxi/taxi van","15" = "Agricultural vehicle","16" = "Motorcycle","17" = "Moped","18" = "Light moped","19" = "Motorised disabled transport","20" = "Non-motorised disabled transport","21" = "Skates/rollerblades/scooter","22" = "Boat","23" = "Other motorised","24" = "Other non-motorised")
)



ODiN2023$KHvm <- factor(
  ODiN2023$KHvm,
  levels = 1:7,
  labels = c(
             "1"="Passenger car - driver",
             "2"="Passenger car - passenger",
             "3"="Train",
             "4"="Bus/tram/underground",
             "5"="Bicycle",
             "6"="On foot",
             "7"="Other"
  )
)

ODiN2023$Opleiding <- factor(
  ODiN2023$Opleiding,
  levels = 0:7,
  labels = c("0" = "No education completed",
    "1" = "Primary education, lower secondary education",
    "2" = "Lower vocational education", #education or VMBO, VBO, LWOO, VSO, VGLO, MAVO, ULO, MULO ",
    "3" = "Secondary vocational education",# or HAVO, Atheneum, Gymnasium, MMS, HBS",
    "4" = "Higher vocational education, university",
    "5" = "Other education",
    "6" = "Unknown",
    "7" = "Not asked; OP younger than 15 years of age")
)

ODiN2023$HHBestInkG <- factor(
  ODiN2023$HHBestInkG,
  levels = 1:11,
  labels = c("1" = "First 10% group",
              "2" = "Second 10% group",
              "3" = "Third 10% group",
              "4" = "Fourth 10% group",
              "5" = "Fifth 10% group",
              "6" = "Sixth 10% group",
              "7" = "Seventh 10% group",
              "8" = "Eighth 10% group",
              "9" = "Ninth 10% group",
              "10" = "Tenth 10% group",
              "11" = "Income unknown")
)

ODiN2023$HHGestInkG <- factor(
  ODiN2023$HHGestInkG,
  levels = 1:11,
  labels = c("1" = "First 10% group",
             "2" = "Second 10% group",
             "3" = "Third 10% group",
             "4" = "Fourth 10% group",
             "5" = "Fifth 10% group",
             "6" = "Sixth 10% group",
             "7" = "Seventh 10% group",
             "8" = "Eighth 10% group",
             "9" = "Ninth 10% group",
             "10" = "Tenth 10% group",
             "11" = "Income unknown")
)



ODiN2023$Doel <- factor(
  ODiN2023$Doel,
  levels = 1:14,
  labels = c("1" = "Going home",
             "2" = "Working",
             "3" = "Business visit in a work context",
             "4" = "Professional",
             "5" = "Picking up/dropping off people",
             "6" = "Picking up/dropping off goods",
             "7" = "Education/course attendance",
             "8" = "Shopping/grocery shopping",
             "9" = "Visiting/staying overnight",
             "10" = "Touring/walking",
             "11" = "Sport/hobby",
             "12" = "Other leisure activities",
             "13" = "Services/personal care",
             "14" = "Other purpose")
)

par(mar = c(10, 4, 4, 2))
doel_counts <- table(ODiN2023$Doel)
barplot(doel_counts, 
        las = 2, 
        ylim = c(0, max(doel_counts) * 1.2),
        main = "Activity distribution The Hague")
  

par(mar = c(20, 4, 4, 2)) # Adjust margin for labels
opleiding_counts <- table(ODiN2023$Opleiding)
barplot(opleiding_counts, 
        las = 2, 
        ylim = c(0, max(opleiding_counts) * 1.2),
        main = "Activity distribution The Hague")



hvm_counts <- table(ODiN2023$Hvm)
barplot(hvm_counts, 
        las = 2, 
        ylim = c(0, max(hvm_counts) * 1.2),
        main = "Activity distribution The Hague")

khvm_counts <- table(ODiN2023$KHvm)
barplot(khvm_counts, 
        las = 2, 
        ylim = c(0, max(khvm_counts) * 1.2),
        main = "Activity distribution The Hague")

# Calculate absolute counts and percentages
khvm_counts <- table(ODiN2023$KHvm)
khvm_pct <- prop.table(khvm_counts) * 100

# Create barplot and store bar midpoints in 'bp'
bp <- barplot(khvm_pct, 
              las = 2, 
              ylim = c(0, max(khvm_pct) * 1.2),
              ylab = "Percentage (%)",
              main = "Transport Mode Distribution The Hague")

# Add text labels at the top of each bar
# x = bp (bar midpoints)
# y = khvm_pct (height of the bars)
# labels = formatted percentage string
text(x = bp, 
     y = khvm_pct, 
     labels = paste0(round(khvm_pct, 1), "%"), 
     pos = 3, 
     cex = 0.8)



dODiN_proportions <- ODiN2023 %>%
  group_by(KHvm, Opleiding) %>%
  tally() %>%
  ungroup() %>%
  mutate(percent = (n / sum(n)) * 100)



ggplot(ODiN_proportions, aes(x = as.factor(Opleiding), y = as.factor(KHvm), fill = n)) +
  geom_tile() +
  geom_text(aes(label = n), color = "white", size = 3) +
  scale_fill_viridis_c() +
  labs(
    title = "Primary education vs transport mode",
    x = "Fuel Type (Car 1)",
    y = "Main Transport Mode",
    fill = "Observation Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)
  )


ODiN_proportions <- ODiN2023 %>%
  group_by(HHBestInkG, KHvm) %>%
  tally() %>%
  ungroup() %>%
  mutate(percent = (n / sum(n)) * 100)



ggplot(ODiN_proportions, aes(x = as.factor(HHBestInkG), y = as.factor(KHvm), fill = n)) +
  geom_tile() +
  geom_text(aes(label = n), color = "white", size = 3) +
  scale_fill_viridis_c() +
  labs(
    title = "Education level vs disposable household income",
    x = "Fuel Type (Car 1)",
    y = "Main Transport Mode",
    fill = "Observation Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)
  )

#par(mfrow = c(2, 1))
#par(mar = c(10, 4, 4, 2)) # Adjust margin for labels
hhgesting_counts <- table(ODiN2023$HHGestInkG)
barplot(hhgesting_counts, 
        las = 2, 
        ylim = c(0, max(hhgesting_counts) * 1.2),
        main = "Standardised income in the Hauge")


ODiN_proportions <- ODiN2023 %>%
  group_by(HHGestInkG, KHvm) %>%
  tally() %>%
  ungroup() %>%
  mutate(percent = (n / sum(n)) * 100)



ggplot(ODiN_proportions, aes(x = as.factor(HHGestInkG), y = as.factor(KHvm), fill = n)) +
  geom_tile() +
  geom_text(aes(label = n), color = "white", size = 3) +
  scale_fill_viridis_c() +
  labs(
    title = "Standardised income group vs main transport mode",
    x = "Standardised income",
    y = "Main Transport Mode",
    fill = "Observation Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)
  )
#par(mfrow = c(1, 1))

ODiN_proportions <- ODiN2023 %>%
  group_by(HHBestInkG, KVhm) %>%
  tally() %>%
  ungroup() %>%
  mutate(percent = (n / sum(n)) * 100)



ggplot(ODiN_proportions, aes(x = as.factor(Opleiding), y = as.factor(HHBestInkG), fill = n)) +
  geom_tile() +
  geom_text(aes(label = n), color = "white", size = 3) +
  scale_fill_viridis_c() +
  labs(
    title = "Education level vs disposable household income",
    x = "Fuel Type (Car 1)",
    y = "Main Transport Mode",
    fill = "Observation Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)
  )


par(mfrow = c(2, 1))
# Plotting becomes simplified
counts <- table(OViN2010$Brandstof_f[OViN2010$OP == 1])

par(mar = c(10, 4, 4, 2)) # Adjust margin for labels
b <- barplot(counts, 
             ylim = c(0, max(y_max) * 1.2), 
             las = 2, 
             main = "Fuel Type Distribution 2010")
text(x = b, y = counts, labels = counts, pos = 3)

counts <- table(ODiN2023$BrandstofPa1_f[ODiN2023$OP == 1])

par(mar = c(10, 4, 4, 2)) # Adjust margin for labels
b <- barplot(counts, 
             ylim = c(0, max(y_max) * 1.3), 
             las = 2, 
             main = "Fuel Type Distribution 2023")
text(x = b, y = counts, labels = counts, pos = 3)
par(mfrow = c(1, 1))


dev.off()  # But only if there IS a plot


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



ggplot(ODiN_proportions, aes(x = as.factor(BrandstofPa1), y = as.factor(Hvm), fill = n)) +
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
  # + geom_point()


#### Conditional probability

ODiN_proportions <- ODiN2023 %>%
  group_by(BrandstofPa1, Hvm) %>%
  tally() %>%
  group_by(BrandstofPa1) %>%
  mutate(percent = (n / sum(n)) * 100)



ggplot(ODiN_proportions, aes(x = as.factor(BrandstofPa1), y = as.factor(Hvm), fill = percent)) +
  geom_tile() +
  geom_vline(xintercept = seq(1.5, 4.5, by = 1), color = "black", size = 1.2)+
  geom_text(aes(label = round(percent, 1)), color = "white", size = 3) +
  scale_x_discrete(labels = c("1" = "Petrol","2" = "Diesel","3" = "LPG","4" = "Electric","5" = "Other","6" = "Unknown","7" = "Not applicable; No passenger car registered to the household")) +
  scale_y_discrete(labels = c("1" = "Passenger car","2" = "Train","3" = "Bus","4" = "Tram","5" = "Metro","6" = "Speed pedelec","7" = "Electric bicycle","8" = "Non-electric bicycle","9" = "On foot","10" = "Coach","11" = "Van","12" = "Lorry","13" = "Camper van","14" = "Taxi/taxi van","15" = "Agricultural vehicle","16" = "Motorcycle","17" = "Moped","18" = "Light moped","19" = "Motorised disabled transport","20" = "Non-motorised disabled transport","21" = "Skates/rollerblades/scooter","22" = "Boat","23" = "Other motorised","24" = "Other non-motorised")) +
  scale_fill_viridis_c() +
  labs(
    title = "Conditional Heatmap of Primary fuel type of the youngest passenger car registered to the household  vs. Main transport used for a trip (ODiN 2023)",
    x = "Fuel Type (Car 1)",
    y = "Main Transport Mode",
    fill = "Observation Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  


hist(ODiN2022$BrandstofPa1)
hist(ODiN2022$BrandstofPa2)

typeof(ODiN2023$OP)
hist(ODiN2023$BrandstofPa1[ODiN2023$OP == 1])
hist(ODiN2023$BrandstofPa2)
hist(OViN2010$Brandstof[OViN2010$OP == 1])

#plot(ODiN203$HHGestInkG, ODiN2023$)



# Clear packages
detach("package:datasets", unload = TRUE)

# Clear plots
dev.off()  # But only if there IS a plot

# Clear console
cat("\014")  # ctrl+L
