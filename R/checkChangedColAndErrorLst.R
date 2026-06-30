## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' checkChangedColAndErrorLst examines errorLst for errors and
#' errorLst$changeCols non-empty fields
#'
#' @param errorLst list with fields for each type of changed column and
#' error detectable by \code{qcStudbook}.
#' @return Returns \code{NULL} is all fields are empty
#' else the entire list is returned.
#'
#' @noRd
checkChangedColAndErrorLst <- function(errorLst) {
  if (checkErrorLst(errorLst) ||
    checkChangedColsLst(errorLst$changedCols)) {
    errorLst
  } else {
    NULL
  }
}
