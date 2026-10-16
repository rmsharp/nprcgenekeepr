## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Convert the numeric columns of a table read from Excel to numbers
#'
#' \code{readExcelPOSIXToCharacter()} reads every Excel cell as text. A reader
#' whose table has numeric columns calls this function to give those columns
#' the type a delimited text file gives them. A column is converted only when
#' it holds at least one value and every value that is not \code{NA} is a
#' number. Any other column is left as text, so the checker for the table names
#' it, as it does for a delimited text file.
#'
#' @param df data frame read from an Excel file with every column as text.
#' @param columns character vector of the names of the columns that hold
#' numbers. Names that are not columns of \code{df} are ignored.
#' @return \code{df} with each qualifying column in \code{columns} converted to
#' numeric.
#' @noRd
convertExcelNumericColumns <- function(df, columns) {
  for (column in intersect(columns, names(df))) {
    text <- df[[column]]
    if (!is.character(text) || all(is.na(text))) {
      next
    }
    numbers <- suppressWarnings(as.numeric(text))
    if (!anyNA(numbers[!is.na(text)])) {
      df[[column]] <- numbers
    }
  }
  df
}
