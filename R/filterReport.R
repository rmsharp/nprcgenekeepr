## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Filter a genetic value report to selected animals
#'
#' @inheritParams getParents
#' @param rpt a dataframe with the required colname \code{id}, such as the
#' data.frame of results from a genetic value analysis. Only \code{id} is
#' used; all other columns are returned unchanged.
#' @return A copy of report specific to the specified animals.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' rpt <- nprcgenekeepr::pedWithGenotypeReport$report
#' rpt1 <- filterReport(c("GHH9LB", "BD41WW"), rpt)
filterReport <- function(ids, rpt) {
  rpt[rpt$id %in% ids, ]
}
