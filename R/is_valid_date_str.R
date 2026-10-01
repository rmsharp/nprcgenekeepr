## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Test whether a string is a valid date
#'
#' Taken from github.com/rmsharp/rmsutilityr
#'
#' @param date_str character vector with 0 or more dates
#' @param format character vector of length one. Retained for backward
#' compatibility; the current implementation validates dates with
#' \code{anytime()} and does not use \code{format}.
#' @param optional logical value indicating that NA should be returned
#' instead of \code{FALSE} for strings that are not valid dates.
#' Defaults to FALSE.
#' @return A logical vector with one element per element of \code{date_str}
#' (zero-length input gives a zero-length result) indicating whether or not
#' each string is a valid date. Elements are \code{NA} instead of
#' \code{FALSE} when \code{optional} is \code{TRUE}. Numeric input is never
#' treated as a date and always gives \code{FALSE}.
#'
#' @importFrom anytime anytime
#' @export
#' @examples
#' is_valid_date_str(c(
#'   "13-21-1995", "20-13-98", "5-28-1014",
#'   "1-21-15", "2-13-2098", "25-28-2014"
#' ), format = "%m-%d-%y")
is_valid_date_str <- function(date_str, format = "%d-%m-%Y %H:%M:%S",
                              optional = FALSE) {
  if (!is.character(date_str) && is.numeric(date_str)) {
      return(rep(FALSE, length(date_str)))
  }
  if (optional) {
    result <- !is.na(suppressWarnings(anytime(date_str, useR = TRUE)))
    result[result == FALSE] <- NA # nolint redundant_equals_linter
  } else {
    result <- !is.na(suppressWarnings(anytime(date_str, useR = TRUE)))
  }
  result
}
