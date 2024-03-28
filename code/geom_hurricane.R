library(dplyr)
library(geosphere)
library(grid)
library(ggplot2)
library(magrittr)

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
                                 point_matrix <- rbind(point_matrix, point_matrix[1, ])
                                 
                                 point_df <- data.frame(x = point_matrix[, 1], y = point_matrix[, 2])
                                 return(point_df)
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


GeomHurricane <- ggplot2::ggproto("GeomHurricane", GeomPolygon,
                         default_aes = aes(color = "yellow", 
                                           fill = "yellow", 
                                           scale_radii = 1, 
                                           linewidth = 0.5,
                                           alpha = 0.5)
)


geom_hurricane <- function(mapping = NULL, 
                           data = NULL, 
                           stat = "radius",
                           scale_radii = 1,
                           position = "identity", 
                           na.rm = FALSE,
                           show.legend = NA, 
                           inherit.aes = TRUE, 
                           ...) {
  ggplot2::layer(
    stat = StatRadius,
    geom = GeomHurricane, 
    mapping = mapping,  
    data = data, 
    position = position, 
    show.legend = show.legend, 
    inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}


get_map(c(left = min(Ike$Longitude) + 20, bottom = min(Ike$Latitude), 
          right = max(Ike$Longitude) + 20, top = max(Ike$Latitude)), 
        source = "stadia", maptype = "stamen_toner_background", zoom = 5) %>%
  ggmap(extent = "device") +
  geom_hurricane(data = Ike_34, 
               aes(x = Longitude, y = Latitude, 
                   rad_ne = NE, rad_se = SE, rad_sw = SW, rad_nw = NW, 
                   fill = Wind_Speed, color = Wind_Speed)) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))
