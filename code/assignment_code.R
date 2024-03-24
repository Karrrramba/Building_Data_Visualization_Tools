library(dplyr)
library(ggplot2)
library(grid)
library(leaflet)
library(magrittr)
library(readr)
library(stringr)
library(tidyr)

library(tidyverse)
library(ggmap)


# Data prep -----

ext_tracks_widths <- c(7, 10, 2, 2, 3, 5, 5, 6, 4, 5, 4, 4, 5, 3, 4, 3, 3, 3,
                       4, 3, 3, 3, 4, 3, 3, 3, 2, 6, 1)
ext_tracks_colnames <- c("Storm_ID", "Storm_Name", "Month", "Day",
                         "Hour", "Year", "Latitude", "Longitude",
                         "Max_Wind", "Min_Pressure", "Rad_Max_Wind",
                         "Eye_Diameter", "Pressure_1", "Pressure_2",
                         paste("Radius_34", c("NE", "SE", "SW", "NW"), sep = "_"),
                         paste("Radius_50", c("NE", "SE", "SW", "NW"), sep = "_"),
                         paste("Radius_64", c("NE", "SE", "SW", "NW"), sep = "_"),
                         "Storm_Type", "Distance_to_Land", "Final")

ext_tracks <- read_fwf("data/ebtrk_atlc_1988_2015.txt", 
                       fwf_widths(ext_tracks_widths, ext_tracks_colnames),
                       na = "-99")

tracks_clean <- ext_tracks %>% 
  mutate(Longitude = round(Longitude - 180, 1),
         Date = ymd_h(paste0(Year, Month, Day, Hour)),
         Storm_ID = paste0(Storm_Name, "-", Year)) %>% 
  select(!c(2:6, 9:14, 27:29)) %>% 
  relocate(Date, .after = Storm_ID) %>% 
  pivot_longer(cols = starts_with("Radius"),
               names_to = c("Wind_Speed", "Quadrant"),
               names_pattern = "Radius_(.*)_(.*)",
               values_to = "Radius",
               ) %>% 
  pivot_wider(names_from = Quadrant,
              values_from = Radius)

# Mapping -----
Ike <- tracks_clean %>% 
  filter(str_starts(Storm_ID, "IKE"))

Ike_map <- get_map(c(left = min(Ike$Longitude), bottom = min(Ike$Latitude), 
          right = max(Ike$Longitude), top = max(Ike$Latitude)), 
        source = "stadia", maptype = "stamen_toner_background", zoom = 6) %>%
  ggmap(extent = "device")

Ike_map +
  geom_circle(data = Ike %>% filter(day(Date) == 01 & hour(Date) == 12), aes(Longitude, Latitude, r_ne = NE, r_nw = NW, r_sw = SW, r_se = SE,
                              ), radius_scale = 1) +
  scale_color_manual(name = "Wind speed (kts)", 
                     values = c("red", "orange", "yellow")) + 
  scale_fill_manual(name = "Wind speed (kts)", 
                    values = c("red", "orange", "yellow"))




