## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Detect IDs containing a disallowed character
#'
#' Animal IDs (\code{id}, \code{sire}, \code{dam}) must not contain a period
#' ("."); no other character is rejected. This is the single
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
