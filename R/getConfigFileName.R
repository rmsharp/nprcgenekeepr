## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get the configuration file name for the system
#'
#' @param sysInfo object returned by Sys.info()
#' @return A named character vector of length two: \code{homeDir} is the
#' user's home directory and \code{configFile} is the expected configuration
#' file path. Only \code{sysInfo[["sysname"]]} is used, to choose the file
#' name (\code{_nprcgenekeepr_config} on Windows, otherwise
#' \code{.nprcgenekeepr_config}).
#'
#' @importFrom stringi stri_detect_fixed
#' @export
#' @examples
#' library(nprcgenekeepr)
#' sysInfo <- Sys.info()
#' config <- getConfigFileName(sysInfo)
getConfigFileName <- function(sysInfo) {
  homeDir <- file.path(Sys.getenv("HOME"))
  if (stri_detect_fixed(toupper(sysInfo[["sysname"]]), "WIND")) {
    configFile <- file.path(homeDir, "_nprcgenekeepr_config")
  } else {
    configFile <- file.path(homeDir, ".nprcgenekeepr_config")
  }
  c(homeDir = homeDir, configFile = configFile)
}
