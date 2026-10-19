## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read an optional apiKey from the nprcgenekeepr configuration file
#'
#' Unlike \code{getParamDef}, which stops when a parameter is absent, this
#' performs a soft lookup of the optional \code{apiKey} entry.
#'
#' @param configFile path to the nprcgenekeepr configuration file.
#' @return Character scalar with the configured apiKey, or \code{""} when the
#' configuration file is missing or has no \code{apiKey} entry or an empty one.
#' @noRd
getConfigApiKey <- function(configFile) {
  getOptionalConfigToken(configFile, "apiKey")
}
