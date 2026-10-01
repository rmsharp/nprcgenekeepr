## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check column names for required columns
#'
#' @details When \code{reportErrors = TRUE}, \code{NA} entries in \code{cols}
#' are treated as ordinary non-matching column names when building the list of
#' missing required columns, rather than causing an error. (Earlier versions
#' could error with \code{"missing value where TRUE/FALSE needed"} on such
#' out-of-contract input.)
#'
#' @param cols character vector of column names
#' @param reportErrors logical value with no default. When \code{TRUE} and
#' required columns are missing, a character vector of the names of the missing
#' columns is returned. When \code{FALSE} and required columns are missing, the
#' program stops with the error \code{"Required field(s) missing: ..."}.
#' @return \code{NULL} is returned if all required columns are present. See
#' description of \code{reportErrors} for what happens when required columns
#' are missing.
#'
## ## rmsutilityr str_detect_fixed_all
#' @export
#' @examples
#' library(nprcgenekeepr)
#' requiredCols <- getRequiredCols()
#' cols <- strsplit(
#'   paste0(
#'     "id,sire,siretype,dam,damtype,sex,numberofparentsknown,birth,",
#'     "arrivalatcenter,death,departure,status,ancestry,fromcenter?,",
#'     "origin"
#'   ),
#'   ","
#' )[[1L]]
#' checkRequiredCols(cols, reportErrors = TRUE) # NULL: all required present
#' # A missing required column is returned by name
#' checkRequiredCols(setdiff(cols, "birth"), reportErrors = TRUE)
checkRequiredCols <- function(cols, reportErrors) {
  requiredCols <- getRequiredCols()
  # Checking for the required fields (id, sire, dam, sex, birth)
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
