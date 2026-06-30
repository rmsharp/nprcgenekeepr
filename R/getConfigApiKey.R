## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read an optional apiKey from the nprcgenekeepr configuration file
#'
#' Unlike \code{getParamDef}, which stops when a parameter is absent, this
#' performs a soft lookup of the optional \code{apiKey} entry.
#'
#' @param configFile path to the nprcgenekeepr configuration file.
#' @return Character scalar with the configured apiKey, or \code{""} when the
#' configuration file is missing or has no \code{apiKey} entry.
#' @noRd
getConfigApiKey <- function(configFile) {
  if (is.null(configFile) || !file.exists(configFile)) {
    return("")
  }
  lines <- readLines(configFile, skipNul = TRUE)
  tokenList <- getTokenList(lines)
  idx <- tolower(tokenList$param) == "apikey"
  if (!any(idx)) {
    return("")
  }
  tokenList$tokenVec[idx][[1L]][[1L]]
}
