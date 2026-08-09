## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read a twin/zygosity relations table from a file
#'
#' Reads a user-supplied twin-relations sidecar table into a data frame for
#' \code{\link{checkTwinRelations}}. The expected form is
#' \code{id1}, \code{id2}, \code{code}, with a header row (see
#' \code{\link{checkTwinRelations}} for the accepted \code{code} values).
#' Excel (\code{.xls}/\code{.xlsx}) and delimited text (\code{.csv}/
#' \code{.txt}) files are both accepted, mirroring
#' \code{\link{readKinshipOverrides}} -- the closest existing precedent for
#' a validated, pairwise sidecar upload (issue #137 D1/D5,
#' \code{docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md}).
#'
#' This reader does not validate structure or domain -- that is
#' \code{\link{checkTwinRelations}}'s job.
#'
#' @param fileName character vector of length one; path to the twin
#' -relations file (typically the temporary \code{datapath} from a Shiny
#' file upload).
#' @param sep column separator for delimited text files (default \code{","}).
#' @return A data frame of the rows read from \code{fileName} (typically with
#' columns \code{id1}, \code{id2}, and \code{code}). Validate it with
#' \code{\link{checkTwinRelations}} before use.
#'
#' @importFrom readxl excel_format
#' @importFrom utils read.table
#' @export
#' @examples
#' \dontrun{
#' twinRelations <- readTwinRelations(fileName = "twin_relations.csv")
#' twinRelations <- checkTwinRelations(ped, twinRelations)
#' }
readTwinRelations <- function(fileName, sep = ",") {
  if (excel_format(fileName) %in% c("xls", "xlsx")) {
    twinRelations <- readExcelPOSIXToCharacter(fileName)
  } else {
    twinRelations <- muffleIncompleteFinalLine(read.table(fileName,
      header = TRUE,
      sep = sep,
      stringsAsFactors = FALSE,
      na.strings = c("", "NA"),
      check.names = FALSE
    ))
  }
  as.data.frame(twinRelations)
}
