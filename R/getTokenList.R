#' Gets tokens from character vector of lines
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return First right and left space trimmed token from first character vector
#' element.
#'
#' @examples
#' \donttest{
#' lines <- c("center = \"SNPRC\"",
#'            " baseUrl = \"https://boomer.txbiomed.local:8080/labkey\"",
#'            " schemaName = \"study\"", " folderPath = \"/SNPRC\"",
#'            " queryName = \"demographics\"",
#'            "lkPedColumns = (\"Id\", \"gender\", \"birth\", \"death\",",
#'            "              \"lastDayAtCenter\", \"dam\", \"sire\")",
#'            "mapPedColumns = (\"id\", \"sex\", \"birth\", \"death\", ",
#'            "  \"exit\", \"dam\", \"sire\")")
#' lkVec <- c("Id", "gender", "birth", "death",
#'            "lastDayAtCenter", "dam", "sire")
#' mapVec <- c("id", "sex", "birth", "death", "exit", "dam", "sire")
#' tokenList <- getTokenList(lines)
#' params <- tokenList$param
#' tokenVectors <- tokenList$tokenVec
#' }
#'
#' @param lines character vector with text from configuration file
#' @importFrom stringi stri_replace_all_fixed stri_replace_all_regex
#' @importFrom stringi stri_trim_both stri_split_regex
#' @export
getTokenList <- function(lines) {
  tokens <- character(0)
  line <- paste0(lines, collapse = " ")
  line <- stri_replace_all_fixed(stri_trim_both(line), pattern = "\"",
                               replacement = "")
  line <- stri_replace_all_fixed(line, pattern = "=",
                                 replacement = " = ")
  tokens <- c(tokens, stri_split_regex(
    line, pattern = "[[\\p{WHITE_SPACE},]]+")[[1]])
  tokens <- tokens[!tokens == ""]
  parLocations <- seq_along(tokens)[tokens == "="] - 1
  param <- tokens[parLocations]
  start <- parLocations + 2
  end <- parLocations - 1
  end <- c(end[-1], length(tokens))
  tokens <- stri_replace_all_regex(tokens, "[()]+", "")
  tokenVec <- list()
  for (i in seq_along(start)) {
    tokenVec[[i]] <- tokens[seq(from = start[i], to = end[i])]
  }
  list(param = param, tokenVec = tokenVec)
}
