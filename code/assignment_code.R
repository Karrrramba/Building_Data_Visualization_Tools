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

tracks_clean <- ext_tracks %>% 
  mutate(Longitude = round(Longitude - 180, 2),
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

# Stat/geom

StatRadius <- ggplot2::ggproto("StatRadius", Stat,
                               required_aes = c("x", "y", "rad_ne", "rad_se", "rad_sw", "rad_nw"),
                               
                               # default_aes = ggplot2::aes(scale_radii = 1),
                               
                               compute_group = function(data, scales, rad_ne, rad_se, rad_sw, rad_nw, scale_radii) {
                                 
                                 # data <- data %>% 
                                 #   dplyr::mutate(
                                 #     dplyr::across(
                                 #       c(rad_ne, rad_se, rad_sw, rad_nw), ~ .x * 1852
                                 #     ))
                                 
                                 coords <- c(data$x[1], data$y[1])
                                 
                                 deg_NE <- 1:90
                                 deg_SE <- 91:180
                                 deg_SW <- 181:270
                                 deg_NW <- 271:360
                                 
                                 q_1 <- geosphere::destPoint(coords, b = deg_NE, d = data$rad_ne)
                                 q_2 <- geosphere::destPoint(coords, b = deg_SE, d = data$rad_se)
                                 q_3 <- geosphere::destPoint(coords, b = deg_SW, d = data$rad_sw)
                                 q_4 <- geosphere::destPoint(coords, b = deg_NW, d = data$rad_nw)
                                 
                                 point_matrix <- rbind(q_1, q_2, q_3, q_4)
                                 # point_matrix[ , "lat"] <- point_matrix[ , "lat"] * scale_radii
                                 
                                 return(point_matrix)
                               }
                               
)

stat_radius <- function(mapping = NULL, 
                        data = NULL, 
                        geom = "polygon",
                        position = "identity", 
                        scale_radii = 1,
                        show.legend = NA,
                        inherit.aes = TRUE, 
                        ...) {
  ggplot2::layer(
    stat = StatRadius, 
    data = data, 
    mapping = mapping, 
    geom = geom, 
    position = position, 
    show.legend = show.legend, 
    inherit.aes = inherit.aes,
    params = list(scale_radii = scale_radii, ...)
  )        
}

get_map(c(left = min(Ike$Longitude), bottom = min(Ike$Latitude), 
          right = max(Ike$Longitude), top = max(Ike$Latitude)), 
        source = "stadia", maptype = "stamen_toner_background", zoom = 6) %>%
  ggmap(extent = "device") +
  geom_polygon(data = Ike_34, stat = "radius", 
               aes(x = Longitude, y = Latitude, rad_ne = NE, rad_se = SE,
                   rad_sw = SW, rad_nw = NW))

# Mapping -----
Ike <- tracks_clean %>% 
  filter(str_starts(Storm_ID, "IKE"))

Ike_map <- get_map(c(left = min(Ike$Longitude), bottom = min(Ike$Latitude), 
          right = max(Ike$Longitude), top = max(Ike$Latitude)), 
        source = "stadia", maptype = "stamen_toner_background", zoom = 6) %>%
  ggmap(extent = "device")

Ike_34 <- tracks_clean %>% 
  filter(str_starts(Storm_ID, "IKE")) %>% 
  filter(day(Date) == 01 & hour(Date) == 12 & Wind_Speed == 34) %>% 
  mutate(across(c(NE, SE, SW, NW), ~ .x * 1852))

# 
# Ike_map +
#   geom_polygon() +
#   stat_radius(data = Ike_34, aes(long)) +
#   scale_color_manual(name = "Wind speed (kts)", 
#                      values = c("red", "orange", "yellow")) + 
#   scale_fill_manual(name = "Wind speed (kts)", 
#                     values = c("red", "orange", "yellow"))