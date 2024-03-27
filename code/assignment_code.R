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
                               required_aes = c("x", "y", "rad_ne", "rad_se", 
                                                "rad_sw", "rad_nw"),
                               
                               
                               
                               compute_group = function(data, scales) {
                                 
                                 data <- data %>% 
                                   dplyr::mutate(
                                     dplyr::across(
                                       c(rad_NE, rad_SE, rad_SW, rad_NW), ~ .x * 1852
                                     ))
                                 
                                 centre <- c(x, y)
                                 
                                 deg_NE <- 1:90
                                 deg_SE <- 91:180
                                 deg_SW <- 181:270
                                 deg_NW <- 271:360
                                 
                                 quadr_1 <- geosphere::destPoint(centre, b = deg_NE, d = rad_NE)
                                 quadr_2 <- geosphere::destPoint(centre, b = deg_SE, d = rad_SE)
                                 quadr_3 <- geosphere::destPoint(centre, b = deg_SW, d = rad_SW)
                                 quadr_4 <- geosphere::destPoint(centre, b = deg_NW, d = rad_NW)
                                 
                                 point_matrix <- rbind(quadr_1, quadr_2, quadr_3, quadr_4)
                                 point_matrix[ , "lat"] <- point_matrix[ , "lat"] * scale_radii
                                 
                                 point_matrix
                                 
                               }
                               
)

stat_radius <- function(mapping = NULL, 
                        data = NULL, 
                        geom = "polygon",
                        # scale_factor = 1,
                        position = "identity", 
                        show.legend = NA,
                        outliers = TRUE, 
                        inherit.aes = TRUE, 
                        ...) {
  ggplot2::layer(
    stat = StatRadius, 
    data = data, 
    mapping = mapping, 
    geom = geom, 
    # scale_factor = scale_factor,
    position = position, 
    show.legend = show.legend, 
    inherit.aes = inherit.aes,
    params = list(outliers = outliers, ...)
  )        
}


# Mapping -----
Ike <- tracks_clean %>% 
  filter(str_starts(Storm_ID, "IKE"))

Ike_map <- get_map(c(left = min(Ike_34$Longitude), bottom = min(Ike_34$Latitude), 
          right = max(Ike_34$Longitude), top = max(Ike_34$Latitude)), 
        source = "stadia", maptype = "stamen_toner_background", zoom = 6) %>%
  ggmap(extent = "device")

# Ike %>% 
#   filter(day(Date) == 01 & hour(Date) == 12) %>% 
#   mutate(coords = paste(Longitude, Latitude, sep = ", "))

Ike_34 <- tracks_clean %>% 
  filter(str_starts(Storm_ID, "IKE")) %>% 
  filter(day(Date) == 01 & hour(Date) == 12 & Wind_Speed == 34) %>% 
  mutate(across(c(NE, SE, SW, NW), ~ .x * 1852))

StatRadius <- ggplot2::ggproto("StatRadius", Stat,
                               required_aes = c("x", "y", "rad_ne", "rad_se", 
                                                "rad_sw", "rad_nw"),
                               
                               
                               
                               compute_group = function(data, scales) {
                                 
                                 data <- data %>% 
                                   dplyr::mutate(
                                     dplyr::across(
                                       c(rad_NE, rad_SE, rad_SW, rad_NW), ~ .x * 1852
                                     ))
                                 
                                 centre <- c(x, y)
                                 
                                 deg_NE <- 1:90
                                 deg_SE <- 91:180
                                 deg_SW <- 181:270
                                 deg_NW <- 271:360
                                 
                                 quadr_1 <- geosphere::destPoint(centre, b = deg_NE, d = rad_NE)
                                 quadr_2 <- geosphere::destPoint(centre, b = deg_SE, d = rad_SE)
                                 quadr_3 <- geosphere::destPoint(centre, b = deg_SW, d = rad_SW)
                                 quadr_4 <- geosphere::destPoint(centre, b = deg_NW, d = rad_NW)
                                 
                                 point_matrix <- rbind(quadr_1, quadr_2, quadr_3, quadr_4)
                                 point_matrix[ , "lat"] <- point_matrix[ , "lat"] * scale_radii
                                 
                                 point_matrix
                                 
                               }
                               
)

stat_radius <- function(mapping = NULL, 
                        data = NULL, 
                        geom = "polygon",
                        # scale_factor = 1,
                        position = "identity", 
                        show.legend = NA,
                        outliers = TRUE, 
                        inherit.aes = TRUE, 
                        ...) {
  ggplot2::layer(
    stat = StatRadius, 
    data = data, 
    mapping = mapping, 
    geom = geom, 
    # scale_factor = scale_factor,
    position = position, 
    show.legend = show.legend, 
    inherit.aes = inherit.aes,
    params = list(outliers = outliers, ...)
  )        
}

# 
# Ike_map +
#   geom_polygon() +
#   stat_radius(data = Ike_34, aes(long)) +
#   scale_color_manual(name = "Wind speed (kts)", 
#                      values = c("red", "orange", "yellow")) + 
#   scale_fill_manual(name = "Wind speed (kts)", 
#                     values = c("red", "orange", "yellow"))