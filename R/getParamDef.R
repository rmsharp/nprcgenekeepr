## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get parameter definitions from tokens found in configuration file
#'
#' @param tokenList list of parameters and their definitions, which are
#' character vectors
#' @param param character vector representing the parameter being defined.
#' @return A character vector of length one with the value (definition) provided
#' in \code{tokenList} for the 'param' parameter represented by \code{param}.
#' @noRd
getParamDef <- function(tokenList, param) {
  if (!any(tolower(tokenList$param) == tolower(param))) {
    stop("Could not find ",
         param,
         " in configuration file. ",
         "Check spelling carefully.\n")
  }
  tokenList$tokenVec[tokenList$param == param][[1L]]
}
