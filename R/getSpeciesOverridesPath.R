## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read an optional scalar token from the nprcgenekeepr configuration file
#'
#' Unlike \code{getParamDef}, which stops when a parameter is absent, this
#' performs a soft lookup of an optional configuration entry (the
#' \code{getConfigApiKey} pattern). Used for the optional species-override keys
#' added in issue #73 Part 2, which must not change the fixed-schema
#' \code{getSiteInfo} parser.
#'
#' @param configFile path to the nprcgenekeepr configuration file.
#' @param key character scalar, the parameter name (matched case-insensitively).
#' @return Character scalar with the first configured token for \code{key}, or
#' \code{""} when the file is missing, has no such entry or has an empty one.
#' @noRd
getOptionalConfigToken <- function(configFile, key) {
  if (is.null(configFile) || !file.exists(configFile)) {
    return("")
  }
  lines <- readConfigLines(configFile)
  tokenList <- getTokenList(lines)
  idx <- tolower(tokenList$param) == tolower(key)
  if (!any(idx)) {
    return("")
  }
  value <- tokenList$tokenVec[idx][[1L]]
  if (length(value) == 0L) "" else value[[1L]]
}

#' Read the optional species-overrides CSV path from the configuration file
#'
#' Soft lookup of the optional \code{speciesOverridesPath} entry (issue #73
#' Part 2): the path to a CSV carrying the \code{\link{speciesGestation}}
#' columns.
#'
#' @param configFile path to the nprcgenekeepr configuration file.
#' @return Character scalar with the configured CSV path, or \code{""} when the
#' file is missing or has no \code{speciesOverridesPath} entry.
#' @noRd
getSpeciesOverridesPath <- function(configFile) {
  getOptionalConfigToken(configFile, "speciesOverridesPath")
}
