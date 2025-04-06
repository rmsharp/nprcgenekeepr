#' getConfigFileName returns the configuration file name appropriate for
#' the system.
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return Character vector with expected configuration file
#'
#' @param sysInfo object returned by Sys.info()
#' @importFrom stringi stri_detect_fixed
#' @export
#' @examples
#' library(nprcgenekeepr)
#' sysInfo <- Sys.info()
#' config <- getConfigFileName(sysInfo)
getConfigFileName <- function(sysInfo) {
  if (stri_detect_fixed(toupper(sysInfo[["sysname"]]), "WIND")) {
    homeDir <- paste0(gsub("\\\\", "/", Sys.getenv("HOME"), fixed = TRUE), "/")
    configFile <- paste0(homeDir, "_nprcgenekeepr_config")
  } else {
    homeDir <- paste0("~/")
    configFile <- paste0(homeDir, ".nprcgenekeepr_config")
  }
  c(homeDir = homeDir, configFile = configFile)
}
