## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Examines column names, \code{cols} for required column names
#'
#' @details When \code{reportErrors = TRUE}, \code{NA} entries in \code{cols}
#' are treated as ordinary non-matching column names when building the list of
#' missing required columns, rather than causing an error. (Earlier versions
#' could error with \code{"missing value where TRUE/FALSE needed"} on such
#' out-of-contract input.)
#'
#' @return NULL is returned if all required columns are present. See description
#' of \code{reportErrors} for return values when required columns are missing.
#'
#' @param cols character vector of column names
#' @param reportErrors logical value when \code{TRUE} and missing columns are
#' found
#' the \code{errorLst} object is updated with the names of the missing
#' columns and returned and when \code{FALSE} and missing columns are found
#' the program is stopped.
## ## rmsutilityr str_detect_fixed_all
#' @export
#' @examples
#' library(nprcgenekeepr)
#' requiredCols <- getRequiredCols()
#' cols <-
#'   paste0(
#'     "id,sire,siretype,dam,damtype,sex,numberofparentsknown,birth,",
#'     "arrivalatcenter,death,departure,status,ancestry,fromcenter?,",
#'     "origin"
#'   )
#' all(requiredCols %in% checkRequiredCols(cols, reportErrors = TRUE))
checkRequiredCols <- function(cols, reportErrors) {
  requiredCols <- getRequiredCols()
  # Checking for the required fields (id, sire, dam, sex)
  if (!all(str_detect_fixed_all(cols, requiredCols)) ||
    length(cols) < length(requiredCols)) {
    if (reportErrors) {
      missingColumns <- requiredCols[!requiredCols %in% cols]
      if (length(missingColumns) > 0L) {
        return(missingColumns)
      }
    } else {
      stop(
        "Required field(s) missing: ",
        toString(
          requiredCols[!str_detect_fixed_all(cols, requiredCols,
            ignore_na = TRUE
          )]), "."
      )
    }
  }
  NULL
}
