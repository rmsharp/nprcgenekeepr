#' Get Indian-origin status of group
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#' @return \code{ancestry} list of number of Chinese animals (\code{chinese}),
#' number of hybrid (\code{hybrid}),
#' number of borderline hybrid animals (\code{borderline}),
#' number of Indian ancestry animals (\code{indian}),
#' and the dashboard color (\code{color)} to be assigned based on the
#' number of animals of each type counted.
#' @param origin character vector of the animal origins. This vector
#' is to have already been filtered to remove animals that should not be
#' included in the calculation.
#' @importFrom stringi stri_startswith_fixed stri_detect_fixed
getIndianOriginStatus <- function(origin) {
  chinese <- length(origin[stri_detect_fixed(origin, "CHINESE")])
  indian <- length(origin[stri_detect_fixed(origin, "INDIAN")])
  hybrid <- length(origin[stri_startswith_fixed(origin, "HYBRID")])
  borderline <- length(origin[stri_detect_fixed(origin, "BORDERLINE_HYBRID")])
  japanese <- length(origin[stri_detect_fixed(origin, "JAPANESE")])
  unknown <- length(origin[stri_detect_fixed(origin, "UNKNOWN")])
  other <- length(origin[stri_detect_fixed(origin, "OTHER")])

  ancestry <- list(
    chinese = chinese,
    indian = indian,
    hybrid = hybrid,
    borderline = borderline,
    japanese = japanese,
    unknown = unknown,
    other = other
  )
  if ((chinese + hybrid) >= 1) {
    color <- "red"
    colorIndex <- 1
  } else if (borderline >= 1) {
    color <- "yellow"
    colorIndex <- 2
  }else {
    color <- "green"
    colorIndex <- 3
  }
  list(ancestry = ancestry, color = color, colorIndex = colorIndex)
}
