#' getVersion Get the version number of nprcgenekeepr
#'
## Copyright(c) 2017-2021 R. Mark Sharp
## This file is part of nprcgenekeepr
#' @return Current Version
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' getVersion()
#' }
#' @param date A logical value when TRUE (default) a date in YYYYMMDD format
#' within parentheses is appended.
#' @importFrom utils packageDate packageVersion
#' @export
getVersion <- function(date = TRUE) {
  version <- packageVersion("nprcgenekeepr")
  if (date) {
    paste0(version, " (", packageDate("nprcgenekeepr"), ")")
  } else {
    version
  }
}
