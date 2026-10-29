## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read a colony snapshot-history table from a file
#'
#' Reads a user-maintained longitudinal colony snapshot history (issue #167)
#' from a file into a data frame for \code{\link{checkSnapshotHistory}}. The
#' history is the single CSV a colony manager keeps between analyses: one row
#' per recorded snapshot in the 27-column version-1 schema (see
#' \code{\link{checkSnapshotHistory}} for the column groups). Excel
#' (\code{.xls}/\code{.xlsx}) and delimited text (\code{.csv}/\code{.txt})
#' files are both accepted, mirroring \code{\link{readKinshipOverrides}}.
#' Excel files are read with every column as text and then the numeric columns
#' (e.g. \code{schemaVersion}) are converted to numbers, so an Excel file and a
#' delimited text file of the same table give the same result. A numeric column
#' that holds a value that is not a number is left as text and
#' \code{\link{checkSnapshotHistory}} stops, naming it.
#'
#' This reader does not validate structure or domain — that is
#' \code{\link{checkSnapshotHistory}}'s job, matching the reader/validator
#' sibling-pair convention.
#'
#' @param fileName character vector of length one; path to the snapshot
#' history file (typically the temporary \code{datapath} from a Shiny file
#' upload, or a path the user's own scripts maintain).
#' @param sep column separator for delimited text files (default \code{","}).
#' Ignored for Excel files.
#' @return A data frame of the rows read from \code{fileName}. Validate it
#' with \code{\link{checkSnapshotHistory}} before use.
#'
#' @importFrom readxl excel_format
#' @importFrom utils read.table
#' @export
#' @examples
#' history <- readSnapshotHistory(system.file("extdata", "examples",
#'   "example_snapshot_history.csv",
#'   package = "nprcgenekeepr"
#' ))
#' history <- checkSnapshotHistory(history)
readSnapshotHistory <- function(fileName, sep = ",") {
  if (excel_format(fileName) %in% c("xls", "xlsx")) {
    history <- convertExcelNumericColumns(
      readExcelPOSIXToCharacter(fileName), snapshotSchemaNumericColumns
    )
  } else {
    history <- readDelimitedFile(fileName, sep)
  }
  as.data.frame(history)
}
