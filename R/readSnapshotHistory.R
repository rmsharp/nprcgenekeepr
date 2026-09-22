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
#'
#' This reader does not validate structure or domain — that is
#' \code{\link{checkSnapshotHistory}}'s job, matching the reader/validator
#' sibling-pair convention.
#'
#' @param fileName character vector of length one; path to the snapshot
#' history file (typically the temporary \code{datapath} from a Shiny file
#' upload, or a path the user's own scripts maintain).
#' @param sep column separator for delimited text files (default \code{","}).
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
    history <- readExcelPOSIXToCharacter(fileName)
  } else {
    history <- muffleIncompleteFinalLine(read.table(fileName,
      header = TRUE,
      sep = sep,
      stringsAsFactors = FALSE,
      na.strings = c("", "NA"),
      check.names = FALSE
    ))
  }
  as.data.frame(history)
}
