#' Read in Excel file and convert POSIX dates to character
#'
## Copyright(c) 2017-2023 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return A pedigree file compatible with others in this package.
#'
#' @param fileName character vector of temporary file path.
#' @importFrom stringi stri_detect_fixed
#' @importFrom readxl read_excel
readExcelPOSIXToCharacter <- function(fileName) {
  pedigree <- as.data.frame(read_excel(path = fileName, na = "NA"),
                            stringsAsFactors = FALSE)
  cols <- vapply(pedigree, function(col) {stri_c(class(col), collapse = "")},
                 character(1))
  cols <- suppressWarnings(names(cols)[stri_detect_fixed(cols, "POSIX")])
  pedigree <- toCharacter(pedigree, headers = cols)
  pedigree
}
