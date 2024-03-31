#' Draw hurricane radii 
#'
#' This geometry is used to plot a polygon from hurricane wind 
#' radii based on the center coordinates in the four directions NE, SE, SW, NW on a map. 
#' 
#' @section Aesthetics:
#' \code{geom_hurricane} understands the following aesthetics (required aesthetics are in bold).
#' Either \code{fill} or \code{color} are only required if radii of more than one wind speed are plotted.
#' \itemize{
#'   \item \code{**x**}
#'   \item \code{**y**}
#'   \item \code{**rad_ne**}
#'   \item \code{**rad_se**}
#'   \item \code{**rad_sw**}
#'   \item \code{**rad_nw**}
#'   \item \code{**fill**} 
#'   \item \code{**color**}
#'   \item \code{linewidth}
#'   \item \code{linetype}
#'   \item \code{alpha}
#' }
#' 
#' @param x The longitude given in deg. Must have negative values for locations 
#' in the Western hemisphere.
#' @param y The latitude given in deg.
#' @param rad_ne The wind radius for the northeast direction.
#' @param rad_se The wind radius for the southeast direction.
#' @param rad_sw The wind radius for the southwest direction.
#' @param rad_nw The wind radius for the northwest direction.
#' @param scale_radii The scaling factor for the radii. Defaults to 1.
#' @param runit Unit of the wind radii. Either 'nm' for nautical miles or 'm' for meters.
#' Defaults to 'nm'.
#' @param stat The statistical transformation to use. Defaults to "hurricane".
#' @param ... other arguments passed on to \code{\link{layer}}. These are
#'   often aesthetics, used to set an aesthetic to a fixed value, like
#'   \code{color = "red"} or \code{size = 3}. They may also be parameters
#'   to the paired geom/stat
#' @inheritParams ggplot2::geom_polygon
#' @inheritParams ggplot2::ggproto
#' @inheritParams ggplot2::layer
#' 
#' @return A layer for plotting hurricane wind radii.
#' 
#' @section Reprex: 
#' @importFrom ggmap get_map ggmap
#' 
#' @examples /dontrun{
#' library(ggmap)
#' library(ggplot2)
#' 
#' # Create storm data
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
#'   geom_hurricane(data = d, aes(x = Longitude, y = Latitude, rad_ne = NE,
#'                      rad_se = SE, rad_sw = SW, rad_nw = NW,
#'                      fill = Wind_Speed, color = Wind_Speed), nm = TRUE) +
#'   scale_color_manual(name = "Wind speed (kts)",
#'                      values = c("red", "orange", "yellow")) +
#'   scale_fill_manual(name = "Wind speed (kts)",
#'                     values = c("red", "orange", "yellow"))
#' }
#' 
#' @export
geom_hurricane <- function(mapping = NULL, 
                           data = NULL, 
                           stat = "hurricane",
                           position = "identity", 
                           scale_radii = 1,
                           runit = "nm",
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
      runit = runit, 
      ...)
  )
}

#' @rdname geom_hurricane
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


#' @rdname geom_hurricane
#' @export
stat_hurricane <- function(mapping = NULL, 
                        data = NULL, 
                        geom = "polygon",
                        position = "identity", 
                        scale_radii = 1,
                        runit = "nm", 
                        show.legend = NA,
                        inherit.aes = TRUE, 
                        ...) {
  ggplot2::layer(
    stat = StatHurricane, 
    data = data, 
    mapping = mapping, 
    geom = geom, 
    position = position, 
    show.legend = show.legend, 
    inherit.aes = inherit.aes,
    params = list(
      scale_radii = scale_radii, 
      runit = runit, 
      ...)
  )        
}

#' @rdname geom_hurricane
#' @usage NULL
#' @format NULL
#' @importFrom dplyr across mutate
#' @importFrom geosphere destPoint
#' @importFrom magrittr  %>% 
#' @export
StatHurricane <- ggplot2::ggproto(
  "StatHurricane", Stat,
  
  required_aes = c("x", "y", "rad_ne", "rad_se", "rad_sw", "rad_nw"),
  
  compute_group = function(data, scales, rad_ne, rad_se, rad_sw, rad_nw, scale_radii = 1, runit = "nm") {
    
    if (runit == "nm") {
      data <- data %>%
        dplyr::mutate(
          dplyr::across(
            c(rad_ne, rad_se, rad_sw, rad_nw), ~ .x * 1852
          ))
    }
    
    coords <- c(data$x, data$y)
                                 
    deg_ne <- 1:90
    deg_se <- 91:180
    deg_sw <- 181:270
    deg_nw <- 271:360
                                 
    q_1 <- geosphere::destPoint(coords, b = deg_ne, d = data$rad_ne * scale_radii)
    q_2 <- geosphere::destPoint(coords, b = deg_se, d = data$rad_se * scale_radii)
    q_3 <- geosphere::destPoint(coords, b = deg_sw, d = data$rad_sw * scale_radii) 
    q_4 <- geosphere::destPoint(coords, b = deg_nw, d = data$rad_nw * scale_radii) 
                                 
    p <- rbind(q_1, q_2, q_3, q_4)
    p <- rbind(p, p[1, ])
                                 
    df <- data.frame(x = p[, 1], y = p[, 2])
    return(df)
    
    }
)
