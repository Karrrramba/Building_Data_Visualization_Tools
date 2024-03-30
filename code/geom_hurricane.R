library(dplyr)
library(geosphere)
library(grid)
library(ggplot2)
library(magrittr)

#' geom_hurricane
#'
#' @description This geometry is used to plot a polygon from hurricane wind 
#' radii in the four directions NE, SE, SW, NW on a map. 
#' 
#' @param mapping Aesthetic mapping.
#' @param data The dataset to be used for plotting.
#' @param stat The statistical transformation to use. Default is "radius".
#' @param scale_radii The scaling factor for the radii. Default is 1.
#' @param nm A flag whether radii in the data are given as nautical miles.
#' Defaults to TRUE. If TRUE, nautical miles will be transofromed to metric scale.
#' @param position Position adjustment. Default is "identity".
#' @param show.legend A flag indicating whether to show legend. Default is NA.
#' @param inherit.aes A flag indicating whether to inherit aesthetics. 
#' Defaults to TRUE.
#' @param ... Other parameters passed to the geom.
#' 
#' @return A layer for plotting hurricane wind radii.
#' 
#' @inheritParams ggplot2::layer
#' @inheritParams stat_radius
#' 
#' @importFrom ggmap get_map ggmap
#' 
#' @examples /dontrun{
#' # library(ggmap)
#' 
#' # Storm data
#' d <- data.frame(
#'   Longitude = -94.6,
#'   Latitude = 29.1,
#'   Wind_Speed = factor(c(34, 50, 64)),
#'   NE = c(225, 150, 110),
#'   SE = c(200, 160, 90),
#'   SW = c(125, 80, 55),
#'   NW = c(125, 75, 45)
#' )
#' 
#' # Background map
#' m <- get_map(c(left = d[1, "Longitude"] - 10, bottom = d[1, "Latitude"] - 10, 
#'                right = d[1, "Longitude"] + 10, top = d[1, "Latitude"] + 10),
#'              source = "stadia", maptype = "stamen_toner_background", zoom = 5) %>% 
#'   ggmap(extent = "device")
#' 
#' m +
#'   geom_hurricane(data = d,
#'                  aes(x = Longitude, y = Latitude, rad_ne = NE,
#'                      rad_se = SE, rad_sw = SW, rad_nw = NW,
#'                      fill = Wind_Speed, color = Wind_Speed), nm = TRUE) +
#'   scale_color_manual(name = "Wind speed (kts)",
#'                      values = c("red", "orange", "yellow")) +
#'   scale_fill_manual(name = "Wind speed (kts)",
#'                     values = c("red", "orange", "yellow"))
#' 
#' @export
geom_hurricane <- function(mapping = NULL, 
                           data = NULL, 
                           stat = "radius",
                           position = "identity", 
                           scale_radii = 1,
                           nm = TRUE,
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
      scale_radii = scale_radii,
      nm = nm, 
      ...)
  )
}

#' Geom Hurricane
#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomHurricane <- ggplot2::ggproto("GeomHurricane", GeomPolygon,
                                  default_aes = ggplot2::aes(color = "yellow", 
                                                             fill = "yellow", 
                                                             scale_radii = 1, 
                                                             linewidth = 0.5,
                                                             alpha = 0.5)
)


#' stat_radius
#'
#' @description This statistic computes the coordinates for plotting hurricane 
#' wind radii based on the provided radii and coordinates.
#' 
#' @param mapping Aesthetic mappings created by ggplot2.
#' @param data A data frame containing the coordinates
#' \code{x} (longitude),\code{y} (latitude) and the wind radii for the 
#' directions NE, SE, SW and NW.
#' @param geom Type of geometric object to draw. Defaults to "polygon".
#' @param position Position adjustment to use for overlap . 
#' Defaults to "identity".
#' @param scale_radii The scaling factor for the radii. Default is 1.
#' @param show.legend Logical. Should this layer be included in the legends? 
#' NA (default) includes if any aesthetics are mapped.
#' @param inherit.aes Should inherit aesthetics from the parent plot?
#' @param ... Additional parameters to be passed to the ggplot2::layer function.
#' 
#' @inheritParams ggplot2::layer
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
                        scale_radii = 1,
                        nm = TRUE, 
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
      scale_radii = scale_radii, 
      nm = nm, 
      ...)
  )        
}


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



#' @rdname stat_hurricane
#' @usage NULL
#' @format NULL
#' @export
StatRadius <- ggplot2::ggproto("StatRadius", Stat,
                               required_aes = c("x", "y", "rad_ne", "rad_se", "rad_sw", "rad_nw"),
                               
                               compute_group = function(data, scales, rad_ne, rad_se, rad_sw, rad_nw, scale_radii = 1, nm = TRUE) {
                                 
                                 if (nm == TRUE) {
                                   data <- data %>%
                                     dplyr::mutate(
                                       dplyr::across(
                                         c(rad_ne, rad_se, rad_sw, rad_nw), ~ .x * 1852
                                       ))
                                 }

                                 coords <- c(data$x, data$y)
                                 
                                 deg_NE <- 1:90
                                 deg_SE <- 91:180
                                 deg_SW <- 181:270
                                 deg_NW <- 271:360
                                 
                                 q_1 <- geosphere::destPoint(coords, b = deg_NE, d = data$rad_ne * scale_radii)
                                 q_2 <- geosphere::destPoint(coords, b = deg_SE, d = data$rad_se * scale_radii)
                                 q_3 <- geosphere::destPoint(coords, b = deg_SW, d = data$rad_sw * scale_radii) 
                                 q_4 <- geosphere::destPoint(coords, b = deg_NW, d = data$rad_nw * scale_radii) 
                                 
                                 point_matrix <- rbind(q_1, q_2, q_3, q_4)
                                 point_matrix <- rbind(point_matrix, point_matrix[1, ])
                                 
                                 point_df <- data.frame(x = point_matrix[, 1], y = point_matrix[, 2])
                                 return(point_df)
                               }
)




