## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Assert that the population of interest holds at least two animals
#'
#' The internal check that stops \code{reportGV()} and
#' \code{gvaConvergence()} before any calculation when the population of
#' interest has fewer than 2 animals. A genetic value ranking compares animals
#' with one another, so one animal (or none) has nothing to be ranked against.
#' Mirrors \code{assertRequiredColsPresent()}.
#'
#' @param n integer(1) number of animals in the population of interest.
#' @param where character(1) label identifying the call site, named in the
#' error message (e.g. \code{"reportGV(ped)"}).
#' @return \code{invisible(NULL)} if \code{n} is at least 2.
#' @noRd
assertPopulationSize <- function(n, where) {
  if (n < 2L) {
    stop("nprcgenekeepr: ", where, " needs at least 2 animals in the ",
         "population; the population has ", n, ".", call. = FALSE)
  }
  invisible(NULL)
}
