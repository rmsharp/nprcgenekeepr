#' insertSeparators inserts the character "-" between year and month and
#' between month and day portions of a date string in \%Y\%m\%d format.
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' This function is not exported because it is not general purpose and
#' is missing several defensive programming measures.
#'
#' @return A character vector of potential dates in \%Y-\%m-\%d format.
#'
#' @param dates character vector of potential dates
#' @importFrom stringi stri_detect_regex stri_sub stri_c
insertSeparators <- function(dates) {
  if (!any(stri_detect_regex(dates[!is.na(dates)], pattern = "[-/]"))) {
    if (all(suppressWarnings(as.integer(dates[!is.na(dates)]) &
                             !is.na(as.integer(dates[!is.na(dates)]))))) {
      dates <- vapply(dates, function(x) {
        stri_c(stri_sub(x, from = 1, to = 4), "-",
               stri_sub(x, from = 5, to = 6), "-",
               stri_sub(x, from = 7, to = 8))
      }, character(1))
    }
  }
  dates
}
