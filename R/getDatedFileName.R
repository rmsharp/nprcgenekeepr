## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Prepend the date and time to a file name
#'
#' @param filename character vector with name to use in file name
#' @return A character string with \code{filename} prepended with the current
#' date and time. The prefix is \code{as.character()} of the current time with
#' spaces and colons replaced by underscores; it can include fractional
#' seconds, for example \code{2026-10-01_15_39_25.959408_testName}.
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
