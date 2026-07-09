## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Return a vector of date column names
#'
#' @return Vector of column names in a standardized pedigree object that are
#' dates.
#'
#' @noRd
getDateColNames <- function() {
  c("birth", "death", "departure", "exit")
}
