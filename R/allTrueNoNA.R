#' Returns \code{TRUE} if every member of the vector is \code{TRUE}.
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Part of Relations
#'
#' Considers NA values the same as false
#' @param v logical vector
allTrueNoNA <- function(v) {
  # v <- all(v)
  # v <- if (is.na(v)) FALSE else v
  # return(v)
  # The following is equivalent and should be a bit faster
  return(all(c(v, all(!is.na(v))), na.rm = TRUE))
}
