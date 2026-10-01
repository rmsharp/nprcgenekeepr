## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get the superset of report-inclusion columns
#'
#' Part of Genetic Value Functions
#'
#' Replaces INCLUDE.COLUMNS data statement.
#'
#' @return A character vector of the ten columns kept in genetic-value
#' reports (\code{id}, \code{sex}, \code{age}, \code{birth}, \code{exit},
#' \code{population}, \code{condition}, \code{origin}, \code{first_name}
#' and \code{second_name}). It is not the set of columns a pedigree file may
#' contain; that is returned by \code{\link{getPossibleCols}}.
#'
#' @export
#' @examples
#' getIncludeColumns()
getIncludeColumns <- function() {
  .nprcColumnSchema$include
}
