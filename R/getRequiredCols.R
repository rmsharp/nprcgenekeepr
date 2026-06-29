#' Get required column names for a studbook
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Pedigree curation function
#' @return A character vector of the required columns that can be in a studbook.
#' The required columns are as follows:
#' \itemize{
#' \item \code{id} -- character vector with unique identifier for an individual
#' \item \code{sire} -- character vector with unique identifier for an
#' individual's father (\code{NA} if unknown).
#' \item \code{dam} -- character vector with unique identifier for an
#' individual's mother (\code{NA} if unknown).
#' \item \code{sex} -- factor (levels: "M", "F", "U") Sex specifier for an
#' individual
#' \item \code{birth} -- Date or \code{NA} (optional) with the individual's
#' birth date
#' }
#' @export
#' @examples
#' library(nprcgenekeepr)
#' getRequiredCols()
getRequiredCols <- function() {
  c("id", "sire", "dam", "sex", "birth")
}
