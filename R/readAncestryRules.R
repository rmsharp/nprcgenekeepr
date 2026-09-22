## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read an ancestry compatibility rules table from a file
#'
#' Reads a center-configurable ancestry compatibility rules table from a
#' user-supplied file into a data frame for \code{\link{checkAncestryRules}}
#' (issue #168). Each row is one unordered pair of standardized ancestry
#' levels plus the rule's severity: columns \code{ancestry1},
#' \code{ancestry2}, and \code{severity} (\code{"block"} or \code{"flag"}),
#' with a header row. Excel (\code{.xls}/\code{.xlsx}) and delimited text
#' (\code{.csv}/\code{.txt}) files are both accepted, mirroring
#' \code{\link{readKinshipOverrides}}.
#'
#' This reader does not validate structure or domain -- that is
#' \code{\link{checkAncestryRules}}'s job. An example rules file expressing
#' the rhesus Indian-origin purity case ships as
#' \code{example_ancestry_rules.csv} in the package's
#' \code{extdata/examples} directory.
#'
#' @param fileName character vector of length one; path to the rules file
#' (typically the temporary \code{datapath} from a Shiny file upload).
#' @param sep column separator for delimited text files (default \code{","}).
#' @return A data frame of the rows read from \code{fileName} (typically with
#' columns \code{ancestry1}, \code{ancestry2}, and \code{severity}). Validate
#' it with \code{\link{checkAncestryRules}} before use.
#'
#' @importFrom readxl excel_format
#' @importFrom utils read.table
#' @export
#' @examples
#' rulesFile <- system.file("extdata", "examples",
#'   "example_ancestry_rules.csv",
#'   package = "nprcgenekeepr"
#' )
#' rules <- checkAncestryRules(readAncestryRules(rulesFile))
#' rules
readAncestryRules <- function(fileName, sep = ",") {
  if (excel_format(fileName) %in% c("xls", "xlsx")) {
    rules <- readExcelPOSIXToCharacter(fileName)
  } else {
    rules <- muffleIncompleteFinalLine(read.table(fileName,
      header = TRUE,
      sep = sep,
      stringsAsFactors = FALSE,
      na.strings = c("", "NA"),
      check.names = FALSE
    ))
  }
  as.data.frame(rules)
}
