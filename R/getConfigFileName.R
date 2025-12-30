#' getConfigFileName returns the configuration file name appropriate for
#' the system.
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of mprcgenekeepr
#'
#' @return Character vector with expected configuration file
#'
#' @param sysInfo object returned by Sys.info()
#' @importFrom stringi stri_detect_fixed
#' @export
#' @examples
#' library(mprcgenekeepr)
#' sysInfo <- Sys.info()
#' config <- getConfigFileName(sysInfo)
getConfigFileName <- function(sysInfo) {
  homeDir <- file.path(Sys.getenv("HOME"))
  if (stri_detect_fixed(toupper(sysInfo[["sysname"]]), "WIND")) {
    configFile <- file.path(homeDir, "_mprcgenekeepr_config")
  } else {
    configFile <- file.path(homeDir, ".mprcgenekeepr_config")
  }
  c(homeDir = homeDir, configFile = configFile)
}
