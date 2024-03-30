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
library(geosphere)


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

tr2 <- ext_tracks %>% 
  mutate(Longitude = round(Longitude * -1, 2),
         Date = ymd_h(paste0(Year, Month, Day, Hour)),
         Storm_ID = paste0(Storm_Name, "-", Year)) %>% 
  select(!c(2:6, 9:14, 27:29)) %>% 
  relocate(Date, .after = Storm_ID) %>% 
  pivot_longer(cols = starts_with("Radius"),
               names_to = c("WindSpeed", "Quadrant"),
               names_pattern = "Radius_(.*)_(.*)",
               values_to = "Radius") %>% 
  pivot_wider(names_from = Quadrant,
              values_from = Radius)

Ike <- tr2 %>% 
  filter(str_starts(Storm_ID, "IKE"))


Ike_obs <- tr2 %>% 
  filter(str_starts(Storm_ID, "IKE")) %>% 
  filter(day(Date) == 13 & hour(Date) == 06)


Ike_path <- tr2 %>% 
  filter(str_starts(Storm_ID, "IKE")) %>% 
  filter(WindSpeed == 34) 
  

# Map object
Ike_map <- get_map(c(left = min(Ike$Longitude) - 5, bottom = min(Ike$Latitude) - 3, 
                    right = max(Ike$Longitude) + 3, top = max(Ike$Latitude) + 3), 
                  source = "stadia", maptype = "stamen_toner_background", zoom = 6) %>%
  ggmap(extent = "device")

# Mapping -----

  geom_polygon(data = Ike_34, stat = "radius", 
               aes(x = Longitude, y = Latitude, rad_ne = NE, rad_se = SE,
                   rad_sw = SW, rad_nw = NW, fill = Wind_Speed, color = Wind_Speed)) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))

# Example -----
# Storm data
d <- data.frame(
    Longitude = -94.6,
    Latitude = 29.1,
    Wind_Speed = factor(c(34, 50, 64)),
    NE = c(225, 150, 110),
    SE = c(200, 160, 90),
    SW = c(125, 80, 55),
    NW = c(125, 75, 45)
  )

# Background map
m <- get_map(c(left = d[1, "Longitude"] - 10, bottom = d[1, "Latitude"] - 10, 
          right = d[1, "Longitude"] + 10, top = d[1, "Latitude"] + 10),
 source = "stadia", maptype = "stamen_toner_background", zoom = 5) %>% 
 ggmap(extent = "device")

m +
 geom_hurricane(data = d,
  aes(x = Longitude, y = Latitude, rad_ne = NE,
      rad_se = SE, rad_sw = SW, rad_nw = NW,
      fill = Wind_Speed, color = Wind_Speed), nm = TRUE) +
 scale_color_manual(name = "Wind speed (kts)",
    values = c("red", "orange", "yellow")) +
 scale_fill_manual(name = "Wind speed (kts)",
    values = c("red", "orange", "yellow"))

# storm path
Ike_map +
  geom_point(data = Ike_path, aes(x = Longitude, y = Latitude), color = "red")

# Scale comparison 
f <- m +
  geom_hurricane(data = Ike_obs, 
                 aes(x = Longitude, y = Latitude, 
                     rad_ne = NE, rad_se = SE, rad_sw = SW, rad_nw = NW, 
                     fill = WindSpeed, color = WindSpeed), 
                 scale_radii = 1) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("yellow", "orange", "red")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("yellow", "orange", "red")) +
  ggtitle("Hurrican Ike \n13/09/2008 06:00 \nscale_radii = 0.5")

h <- m +
  geom_hurricane(data = Ike_obs, 
                 aes(x = Longitude, y = Latitude, 
                     rad_ne = NE, rad_se = SE, rad_sw = SW, rad_nw = NW, 
                     fill = WindSpeed, color = WindSpeed), 
                 scale_radii = 0.5) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("yellow", "orange", "red")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("yellow", "orange", "red")) +
  ggtitle("scale_radii = 0.5")

grid.arrange(f, h, ncol = 1)
