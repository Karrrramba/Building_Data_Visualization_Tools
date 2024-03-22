library(dplyr)
library(grid)
library(ggplot2)
library(magrittr)

StatRadius <- ggproto("StatRadius", Stat, 
                         compute_group = function(data, scales) {
                           probs <- c(0, 0.25, 0.5, 0.75, 1)
                           qq <- quantile(data$y, probs, na.rm = TRUE) 
                           out <- qq %>% as.list %>% data.frame
                           names(out) <- c("ymin", "lower", "middle", 
                                           "upper", "ymax")
                           out$x <- data$x[1]
                           out
                         },
                         required_aes = c("x", "y")
)

stat_radius <- function(mapping = NULL, data = NULL, geom = "hurricane",
                           position = "identity", show.legend = NA, 
                           outliers = TRUE, inherit.aes = TRUE, ...) {
  ggplot2::layer(
    stat = StatRadius, 
    data = data, 
    mapping = mapping, 
    geom = geom, 
    position = position, 
    show.legend = show.legend, 
    inherit.aes = inherit.aes,
    params = list(outliers = outliers, ...)
  )        
}


GeomHurricane <- ggproto("GeomHurricane", Geom,
                         required_aes = c("long", "lat", "rad_ne",
                                          "rad_se", "rad_nw", "rad_sw"), 
                         default_aes = aes(scale_radii = 1), 
                         draw_key = draw_key_point,
                         #a function used to draw the key in the legend. 
                         # specified by a draw_key_* function
                         draw_panel = function(data, panel_scales, coord) {
                           ## Function that returns a grid grob that will 
                           ## be plotted (this is where the real work occurs)
                           coords <- coord$transform(data, panel_scales)
                           
                           str(coords)
                           print(summary(coords))
                           
                           pointsGrob(
                             x = coords$x,
                             y = coords$y,
                             pch = coords$shape
                           )
                         }
)


geom_hurricane <- function(mapping = NULL, data = NULL, stat = "identity",
                          position = "identity", na.rm = FALSE, 
                          show.legend = NA, inherit.aes = TRUE, ...) {
  ggplot2::layer(
    geom = GeomHurricane, mapping = mapping,  
    data = data, stat = stat, position = position, 
    show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}
