#' getVersion Get the version number of mprcgenekeepr
#'
## Copyright(c) 2017-2021 R. Mark Sharp
## This file is part of mprcgenekeepr
#' @return Current Version
#' @param date A logical value when TRUE (default) a date in YYYYMMDD format
#' within parentheses is appended.
#' @importFrom utils packageVersion
#' @importFrom sessioninfo package_info
#' @export
#' @examples
#' library(mprcgenekeepr)
#' getVersion()
getVersion <- function(date = TRUE) {
  version <- packageVersion("mprcgenekeepr")
  if (date) {
    pkg_date <- sessioninfo::package_info("mprcgenekeepr")
    pkg_date <- pkg_date[["date"]][pkg_date[["package"]] == "mprcgenekeepr"]
    paste0(version, " (", pkg_date, ")")
  } else {
    paste0(version)
  }
}
