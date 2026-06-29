#' Get proportion of Low genetic value animals
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return List of the proportion of Low genetic value animals and the
#' dashboard color to be assigned base on that proportion.
#'
#' @param geneticValues character vector of the genetic values. This vector
#' is to have already been filtered to remove animals that should not be
#' included in the calculation. Must contain at least one value; an empty
#' vector is rejected with an error.
#' @importFrom stringi stri_detect_fixed
#' @noRd
getProportionLow <- function(geneticValues) {
  if (length(geneticValues) == 0L) {
    stop("getProportionLow() requires at least one genetic value; ",
         "'geneticValues' is empty.")
  }
  proportion <-
    length(geneticValues[stri_detect_fixed(geneticValues, "Low")]) /
      length(geneticValues)
  if (proportion > 0.5) {
    color <- "red"
    colorIndex <- 1L
  } else if (proportion <= 0.5 && proportion >= 0.3) {
    color <- "yellow"
    colorIndex <- 2L
  } else if (proportion < 0.3) {
    color <- "green"
    colorIndex <- 3L
  }
  list(proportion = proportion, color = color, colorIndex = colorIndex)
}
