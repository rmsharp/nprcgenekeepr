## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read a list of focal animal Ids from a file
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
#' @noRd
readFocalAnimalIds <- function(fileName, sep = ",") {
  if (excel_format(fileName) %in% c("xls", "xlsx")) {
    focalAnimals <- readExcelPOSIXToCharacter(fileName)
  } else {
    focalAnimals <- muffleCannotOpenFile(
      muffleIncompleteFinalLine(read.csv(fileName,
        header = TRUE,
        sep = sep,
        stringsAsFactors = FALSE,
        na.strings = c("", "NA"),
        check.names = FALSE
      ))
    )
  }
  as.character(focalAnimals[, 1L])
}

#' Evaluate an expression, muffling the "cannot open file" warning.
#'
#' Runs \code{expr} and suppresses only the \code{"cannot open file '...'"}
#' warning that \code{\link[utils]{read.csv}} (via \code{\link[base]{file}})
#' emits when the path is missing or unreadable. The accompanying error is left
#' to propagate, so the caller's \code{tryCatch} still sees the failure; only
#' the benign console warning is removed. All other warnings propagate to the
#' caller.
#'
#' @param expr expression to evaluate, typically a \code{read.csv} call.
#' @return The value of \code{expr}.
#' @noRd
muffleCannotOpenFile <- function(expr) {
  withCallingHandlers(
    expr,
    warning = function(w) {
      if (grepl("cannot open file", conditionMessage(w), fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )
}
