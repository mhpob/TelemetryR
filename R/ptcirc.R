#' Draw circles around a Lat/Long point
#'
#' \code{ptcirc} creates a data frame of points forming a circle around a point.
#'
#' The function was adopted from an answer on R-Help, 20061107, by Arien Lam
#' \url{https://stat.ethz.ch/pipermail/r-help/2006-November/116851.html}.
#' Each point is the place where you end up if you travel a certain distance
#' along a great circle, which is uniquely defined by a point (your
#' starting point) and an angle with the meridian at that point (your
#' direction).
#'
#' @param lonlatpoint Numeric vector. A set of longitude and latitude pairs
#'    (decimal degrees), in that order. Can be a data frame or matrix, but the
#'    first column must be the longitude and the second must be latitude.
#' @param radius Numeric. Radius of desired circle, in m.
#' @return Output is a data frame with longitude, latitude, and "circle"
#'    columns. The circle column demarcates circles belonging to different
#'    Lon/Lat pairs.
#' @seealso \code{\link{GEcircle}}
#' @export
#' @examples
#' ptcirc(c(-75, 37), 1609)
#' ptcirc(data.frame(lon = c(-76, -80), lat = c(34, 37)), 2000)

ptcirc <- function(lonlatpoint, radius) {
     Rearth <- 6372795 #"ellipsoidal quadratic mean radius of the earth", in m.
     magnitude <- radius / Rearth

     if(!is.data.frame(lonlatpoint)){
       lonlatpoint <- data.frame(matrix(lonlatpoint, ncol = 2))
     }

     lonlatpoint <- unique(lonlatpoint)
     size <- nrow(lonlatpoint)
     lonlatpoint$circ <-  paste0('C', seq_len(size))
     lonlatpoint <- lonlatpoint[rep(seq_len(size),
                                    each = length(radius)),]
     lonlatpoint$circ <- paste0(lonlatpoint$circ, '_', radius/1000, 'km')

     lonlatpoint[, 1:2] <- lonlatpoint[, 1:2] * (pi / 180)

     size <- nrow(lonlatpoint)
     direction <- seq(0, 2 * pi, by = 2 * pi / 100)
     direction <- rep(direction, times = size)
     magnitude <- rep(magnitude, each = 101)
     lonlatpoint <- lonlatpoint[rep(1:size, each = 101),]


     latb <- asin(cos(direction) * cos(lonlatpoint[, 2]) * sin(magnitude) +
                    sin(lonlatpoint[, 2]) * cos(magnitude))
     dlon <- atan2(cos(magnitude) - sin(lonlatpoint[, 2]) * sin(latb),
                   sin(direction) * sin(magnitude) * cos(lonlatpoint[, 2]))
     lonb <- lonlatpoint[, 1] - dlon + pi / 2

     lonb[lonb >  pi] <- lonb[lonb >  pi] - 2 * pi
     lonb[lonb < -pi] <- lonb[lonb < -pi] + 2 * pi

     latb <- latb * (180 / pi)
     lonb <- lonb * (180 / pi)

     data.frame(long = lonb, lat = latb, circle = lonlatpoint$circ)
}