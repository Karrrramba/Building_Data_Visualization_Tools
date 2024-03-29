library(dplyr)
library(geosphere)
library(grid)
library(ggplot2)
library(magrittr)

#' @rdname geom_boxplot
#'
#' Statistic for plotting hurricane wind radii
#'
#' @description This statistic computes the coordinates for plotting hurricane 
#' wind radii based on the provided radii and origin coordinates. Metric scale
#' for the wind radii is required. 
#' 
#' @param data A data frame containing the necessary columns: x, y, rad_ne, 
#' rad_se, rad_sw, rad_nw.
#' @param scales The scales used in the plot.
#' @param rad_ne The wind radius for the northeast direction.
#' @param rad_se The wind radius for the southeast direction.
#' @param rad_sw The wind radius for the southwest direction.
#' @param rad_nw The wind radius for the northwest direction.
#' @param scale_fct The scaling factor for the radii. Defaults to 1.
#' @param nm Boolean indicator whether radii are given as nautic miles. 
#' Defaults to FALSE. If TRUE, radii will be transformed to metric scale.
#' 
#' @importFrom dplyr across mutate
#' @importFrom geosphere destPoint
#' @importFrom ggplot2 aes ggproto
#' @importFrom magrittr  %>% 
#' 
#' @return A data frame with the computed coordinates for plotting hurricane wind radii.
#' 
#' @export
StatRadius <- ggplot2::ggproto("StatRadius", Stat,
                               required_aes = c("long", "lat", "rad_ne", "rad_se", "rad_sw", "rad_nw"),
                               
                               compute_group = function(data, scales, rad_ne, rad_se, rad_sw, rad_nw, scale_fct = 1, nm = FALSE) {
                                 
                                 if (nm == TRUE) {
                                   data <- data %>%
                                     dplyr::mutate(
                                       dplyr::across(
                                         c(rad_ne, rad_se, rad_sw, rad_nw), ~ .x * 1852
                                       ))
                                 }

                                 coords <- c(data$long[1], data$lat[1])
                                 
                                 deg_NE <- 1:90
                                 deg_SE <- 91:180
                                 deg_SW <- 181:270
                                 deg_NW <- 271:360
                                 
                                 q_1 <- geosphere::destPoint(coords, b = deg_NE, d = data$rad_ne * scale_fct)
                                 q_2 <- geosphere::destPoint(coords, b = deg_SE, d = data$rad_se * scale_fct)
                                 q_3 <- geosphere::destPoint(coords, b = deg_SW, d = data$rad_sw * scale_fct) 
                                 q_4 <- geosphere::destPoint(coords, b = deg_NW, d = data$rad_nw * scale_fct) 
                                 
                                 point_matrix <- rbind(q_1, q_2, q_3, q_4)
                                 point_matrix <- rbind(point_matrix, point_matrix[1, ])
                                 
                                 point_df <- data.frame(x = point_matrix[, 1], y = point_matrix[, 2])
                                 return(point_df)
                               }
)


#' stat_radius
#'
#' @title Statistic for plotting hurricane wind radii
#'
#' @description This statistic computes the coordinates for plotting hurricane wind radii based on the provided radii and coordinates.
#' 
#' @param mapping Aesthetic mappings created by ggplot2.
#' @param data A data frame containing the necessary columns for plotting: x, y, rad_ne, rad_se, rad_sw, rad_nw.
#' @param geom Type of geometric object to draw (default is "polygon").
#' @param position Position adjustment to use for overlap (default is "identity").
#' @param scale_radii The scaling factor for the radii. Default is 1.
#' @param show.legend Logical. Should this layer be included in the legends? NA (default) includes if any aesthetics are mapped.
#' @param inherit.aes Should inherit aesthetics from the parent plot?
#' @param ... Additional parameters to be passed to the ggplot2::layer function.
#' 
#' @importFrom ggplot2 layer
#' 
#' @return A layer with the computed coordinates for plotting hurricane wind radii.
#' 
#' @export
stat_radius <- function(mapping = NULL, 
                        data = NULL, 
                        geom = "polygon",
                        position = "identity", 
                        scale_fct = 1,
                        nm = FALSE, 
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
    params = list(
      scale_fct = scale_fct, 
      nm = nm, 
      ...)
  )        
}




#' geom_hurricane
#'
#' @description This geometry is used to plot a polygon from hurricane wind 
#' radii in the four directions NE, SE, SW, NW on a map. 
#' 
#' @param mapping Aesthetic mapping.
#' @param data The dataset to be used for plotting.
#' @param stat The statistical transformation to use. Default is "radius".
#' @param scale_radii The scaling factor for the radii. Default is 1.
#' @param position Position adjustment. Default is "identity".
#' @param na.rm A logical value indicating whether missing values should be removed. Default is FALSE.
#' @param show.legend A flag indicating whether to show legend. Default is NA.
#' @param inherit.aes A flag indicating whether to inherit aesthetics. Default is TRUE.
#' @param ... Other parameters passed to the geom.
#' 
#' @return A layer for plotting hurricane wind radii.
#' 
#' @export
geom_hurricane <- function(mapping = NULL, 
                           data = NULL, 
                           stat = "radius",
                           position = "identity", 
                           scale_fct = 1,
                           nm = FALSE,
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
    params = list(
      na.rm = na.rm, 
      scale_fct = scale_fct,
      nm = nm, 
      ...)
  )
}

#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @rdn
#' @export
GeomHurricane <- ggplot2::ggproto("GeomHurricane", GeomPolygon,
                                  default_aes = ggplot2::aes(color = "yellow", 
                                                             fill = "yellow", 
                                                             scale_radii = 1, 
                                                             linewidth = 0.5,
                                                             alpha = 0.5)
)



get_map(c(left = min(Ike$Longitude) + 20, bottom = min(Ike$Latitude), 
          right = max(Ike$Longitude) + 20, top = max(Ike$Latitude)), 
        source = "stadia", maptype = "stamen_toner_background", zoom = 5) %>%
  ggmap(extent = "device") +
  geom_hurricane(data = Ike_nm, 
               aes(long = Longitude, lat = Latitude, 
                   rad_ne = NE, rad_se = SE, rad_sw = SW, rad_nw = NW, 
                   fill = Wind_Speed, color = Wind_Speed), 
               scale_fct = 2,
               nm = TRUE) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))
