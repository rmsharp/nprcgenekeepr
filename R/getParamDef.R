#' Get parameter definitions from tokens found in configuration file.
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' @param tokenList list of parameters and their definitions, which are
#' character vectors
#' @param param character vector representing the parameter being defined.
#' @noRd
getParamDef <- function(tokenList, param) {
  if (!any(tolower(tokenList$param) == tolower(param))) {
    stop(paste0("Could not find ", param, " in configuration file. ",
                "Check spelling carefully.\n"))
  } else {
    tokenList$tokenVec[tokenList$param == param][[1]]
  }
}
