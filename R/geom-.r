#' @include legend-draw.r
NULL

.pt <- 1 / 0.352777778
.stroke <- 96 / 25.4


#' @section Geoms:
#'
#' All \code{geom_*} functions (like \code{geom_point}) return a layer that
#' contains a \code{Geom*} object (like \code{GeomPoint}). The \code{Geom*}
#' object is responsible for rendering the data in the plot.
#'
#' Each of the \code{Geom*} objects is a \code{\link{ggproto}} object, descended
#' from the top-level \code{Geom}, and each implements various methods and
#' fields. To create a new type of Geom object, you typically will want to
#' implement one or more of the following:
#'
#' \itemize{
#'   \item \code{draw}: Renders a single group from the data. Should return
#'     a grid grob.
#'   \item \code{draw_groups}: Renders all groups. The method typically calls
#'     \code{draw} for each group.
#'   \item \code{draw_key}: Renders a single legend key.
#'   \item \code{required_aes}: A character vector of aesthetics needed to
#'     render the geom.
#'   \item \code{default_aes}: A list (generated by \code{\link{aes}()} of
#'     default values for aesthetics.
#'   \item \code{reparameterise}: Converts width and height to xmin and xmax,
#'     and ymin and ymax values. It can potentially set other values as well.
#' }
#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
Geom <- ggproto("Geom",
  required_aes = c(),

  default_aes = aes(),

  draw_key = draw_key_point,

  draw = function(...) {},

  draw_groups = function(self, data, scales, coordinates, ...) {
    if (empty(data)) return(zeroGrob())

    groups <- split(data, factor(data$group))
    grobs <- lapply(groups, function(group) self$draw(group, scales, coordinates, ...))

    # String like "bar" or "line"
    objname <- sub("^geom_", "", snake_class(self))

    ggname(paste0(objname, "s"), gTree(
      children = do.call("gList", grobs)
    ))
  },

  reparameterise = function(data, params) data
)

# make_geom("point") returns GeomPoint
make_geom <- function(class) {
  name <- paste0("Geom", camelize(class, first = TRUE))
  if (!exists(name)) {
    stop("No geom called ", name, ".", call. = FALSE)
  }

  obj <- get(name)
  if (!inherits(obj, "Geom")) {
    stop("Found object is not a geom.", call. = FALSE)
  }

  obj
}
