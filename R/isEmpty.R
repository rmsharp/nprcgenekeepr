#' Is vector empty or all NA values.
#'
## Copyright(c) 2017-2023 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return \code{TRUE} if x is a zero-length vector else \code{FALSE}.
#'
#' @param x vector of any type.
isEmpty <- function(x) {
  x <- x[!is.na(x)]
  return(length(x) == 0)
}
