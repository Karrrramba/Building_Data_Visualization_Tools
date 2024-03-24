library(dplyr)
library(grid)
library(ggplot2)
library(magrittr)

StatRadius <- ggplot::ggproto("StatRadius", Stat,
                      required_aes = c("long", "lat", "wind_speed", 
                                       "rad_ne", "rad_nw", "rad_se", "rad_sw"),
                      
                      compute_group = function(data, scales, wind_speed_levels) {
                        projected_points <- lapply(wind_speed_levels, function(speed) {
                          subset_data <- subset(data, wind_speed == speed)
                          
                        })
                           
                      }
)

stat_radius <- function(mapping = NULL, 
                        data = NULL, 
                        geom = "polygon",
                        scale_factor = 1,
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
    scale_factor = scale_factor,
    position = position, 
    show.legend = show.legend, 
    inherit.aes = inherit.aes,
    params = list(outliers = outliers, ...)
  )        
}


GeomHurricane <- ggplot::ggproto("GeomHurricane", Geom,
                         required_aes = c("long", "lat", "rad_ne",
                                          "rad_se", "rad_nw", "rad_sw"), 
                         default_aes = aes(scale_radii = 1), 
                         draw_key = draw_key_polygon,
                         draw_panel = function(data, panel_scales, coord) {
                         
                           )
                         }
)


geom_hurricane <- function(mapping = NULL, 
                           data = NULL, 
                           stat = "hurricane",
                           scale_radii = 1,
                           position = "identity", 
                           na.rm = FALSE,
                           show.legend = NA, 
                           inherit.aes = TRUE, 
                           ...) {
  ggplot2::layer(
    geom = GeomHurricane, 
    mapping = mapping,  
    data = data, 
    stat = stat, 
    position = position, 
    show.legend = show.legend, 
    inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}
