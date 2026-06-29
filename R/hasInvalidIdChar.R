#' Detect IDs containing a disallowed character
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Animal IDs (\code{id}, \code{sire}, \code{dam}) must be alphanumeric with no
#' symbols. In particular a period (".") is disallowed. This is the single
#' definition of that rule, reused by \code{qcStudbook} (data input) and
#' \code{geneDrop} (point of use).
#'
#' @param ids character vector of IDs to test.
#' @return logical vector, \code{TRUE} where the corresponding ID contains a
#' disallowed character (currently the period). \code{NA} elements return
#' \code{FALSE}.
#' @noRd
hasInvalidIdChar <- function(ids) {
  !is.na(ids) & grepl(".", ids, fixed = TRUE)
}
