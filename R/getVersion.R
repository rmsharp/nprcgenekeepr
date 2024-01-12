#' getVersion Get the version number of nprcgenekeepr
#'
## Copyright(c) 2017-2023 R. Mark Sharp
## This file is part of nprcgenekeepr
#' @return Current Version
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' getVersion()
#' }
#' @param date A logical value when TRUE (default) a date in YYYYMMDD format
#' within parentheses is appended.
#' @importFrom methods new
#' @export
getVersion <- function(date = TRUE) {
  .Deprecated(
    new,
    package=NULL,
    msg = paste0("`getVersion()` will be removed in the next ",
                 "release of `nprcgenekeepr`. Use ",
                 "`utils::packageVersion(\"nprcgenekeepr\")` ",
                 "and `utils::packageDate(\"nprcgenekeepr\")`."),
    old = as.character(sys.call(sys.parent()))[1L])
  version <- "1.0.6"
  version_date <- "20230115"
  if (date) {
    paste0(version, " (", version_date, ")")
  } else {
    version
  }
}
