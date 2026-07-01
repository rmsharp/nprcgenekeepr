## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Prepend the date and time to a file name
#'
#' @param filename character vector with name to use in file name
#' @return A character string with a file name prepended with the date and time
#' in YYYY-MM-DD_hh_mm_ss_basename format.
#'
#' @importFrom lubridate now
#' @importFrom stringi stri_c stri_replace_all_fixed
#' @export
#' @examples
#' library(nprcgenekeepr)
#' getDatedFilename("testName")
getDatedFilename <- function(filename) {
  dateStamp <- stri_replace_all_fixed(
    stri_replace_all_fixed(as.character(now()), " ", "_"), ":", "_"
  )
  stri_c(dateStamp, "_", filename)
}
