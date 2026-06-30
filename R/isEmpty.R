## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Is vector empty or all NA values.
#'
#' @param x vector of any type.
#' @return \code{TRUE} if x is a zero-length vector else \code{FALSE}.
#'
#' @noRd
isEmpty <- function(x) {
  x <- x[!is.na(x)]
  length(x) == 0L
}
