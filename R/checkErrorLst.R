#' checkErrorLst examines list for non-empty fields
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return Returns \code{NULL} is all fields are empty
#' else the entire list is returned.
#'
#' @examples
#' \donttest{
#' errorLst <- qcStudbook(nprcgenekeepr::pedFemaleSireMaleDam,
#'                        reportErrors = TRUE)
#' checkErrorLst(errorLst)
#' }
#'
#' @param errorLst list with fields for each type of error detectable by
#' \code{qcStudbook}.
#' @export
checkErrorLst <- function(errorLst) {
  if (is.null(errorLst))
    return(FALSE)
  if (length(errorLst$failedDatabaseConnection) > 0 ||
      length(errorLst$missingColumns) > 0 ||
      length(errorLst$invalidDateRows) > 0 ||
      length(errorLst$sireAndDam) > 0 ||
      length(errorLst$femaleSires) > 0 ||
      length(errorLst$maleDams) > 0 ||
      length(errorLst$duplicateIds) > 0 ||
      nrow(errorLst$suspiciousParents) > 0) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}
