#' Read a list of focal animal Ids from a file
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Internal helper shared by \code{getFocalAnimalPed} and
#' \code{getFocalAnimalPedFromFile}: reads the first column of a file (CSV,
#' delimited text, or Excel) as a character vector of focal animal Ids.
#'
#' @param fileName character path to the focal-animal Id file.
#' @param sep column separator for delimited text files (default \code{","});
#' ignored for Excel files.
#' @return character vector of focal animal Ids (the file's first column).
#' @importFrom readxl excel_format
#' @importFrom utils read.csv
#' @keywords internal
#' @noRd
readFocalAnimalIds <- function(fileName, sep = ",") {
  if (excel_format(fileName) %in% c("xls", "xlsx")) {
    focalAnimals <- readExcelPOSIXToCharacter(fileName)
  } else {
    focalAnimals <- muffleIncompleteFinalLine(read.csv(fileName,
      header = TRUE,
      sep = sep,
      stringsAsFactors = FALSE,
      na.strings = c("", "NA"),
      check.names = FALSE
    ))
  }
  as.character(focalAnimals[, 1L])
}
