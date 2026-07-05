## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get the version number of nprcgenekeepr
#'
#' @param date A logical value when TRUE (default) a date in YYYY-MM-DD
#' (ISO) format within parentheses is appended.
#' @return Current Version
#' @importFrom utils packageVersion
#' @importFrom sessioninfo package_info
#' @export
#' @examples
#' library(nprcgenekeepr)
#' getVersion()
getVersion <- function(date = TRUE) {
  version <- packageVersion("nprcgenekeepr")
  if (date) {
    pkg_date <- sessioninfo::package_info("nprcgenekeepr")
    pkg_date <- pkg_date[["date"]][pkg_date[["package"]] == "nprcgenekeepr"]
    paste0(version, " (", pkg_date, ")")
  } else {
    paste0(version)
  }
}
