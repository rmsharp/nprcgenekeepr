## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get genotypes from file
#'
#' @param fileName character vector of length one: the path of a delimited
#' text file or an Excel (\code{xls}/\code{xlsx}) file.
#' @param sep column separator in a delimited text file; ignored for an Excel
#' file.
#' @return The file's contents as an unchecked dataframe (column names are
#' not changed). In a delimited text file an empty string and \code{"NA"} are
#' read as \code{NA}. Pass the result to \code{\link{checkGenotypeFile}}
#' to make it compatible with the other functions in this package.
#'
#' @importFrom futile.logger flog.debug
#' @importFrom readxl excel_format
#' @importFrom utils read.table
#' @export
#' @examples
#' library(nprcgenekeepr)
#' pedCsv <- getGenotypes(fileName = system.file("testdata", "qcPed.csv",
#'   package = "nprcgenekeepr"
#' ))
getGenotypes <- function(fileName, sep = ",") {
  flog.debug(paste0("in getGenotypes\n"),
    name = "nprcgenekeepr"
  )
  if (excel_format(fileName) %in% c("xls", "xlsx")) {
    genotypes <- readExcelPOSIXToCharacter(fileName)
    flog.debug(paste0(
      "in getGenotypes after readxl, nrow(genotypes) = ",
      nrow(genotypes), "\n"
    ), name = "nprcgenekeepr")
  } else {
    genotypes <- muffleIncompleteFinalLine(read.table(fileName,
      header = TRUE,
      sep = sep,
      stringsAsFactors = FALSE,
      na.strings = c("", "NA"),
      check.names = FALSE
    ))
    flog.debug(paste0(
      "in getGenotypes after read.csv, nrow(genotypes) = ",
      nrow(genotypes), "\n"
    ), name = "nprcgenekeepr")
  }
  genotypes
}
