## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Find date errors and convert dates in a pedigree
#'
#' Finds date errors in columns defined in
#' \code{convertDate} as dates and converts date strings to \code{Date} objects.
#'
#' Every date column is checked on its own and each invalid date is listed by
#' row; the invalid dates become \code{NA} in the converted pedigree, and exit
#' dates are calculated and added, unless every original record has an invalid
#' date, in which case the pedigree is returned unchanged.
#'
#' @param sb A dataframe containing a table of pedigree and demographic
#' information.
#' @param errorLst object with placeholders for error types found in a pedigree
#' file by \code{qcStudbook} through the functions it calls.
#' @return A list with the pedigree, \code{sb}, and the \code{errorLst} with
#' invalid date rows (\code{errorLst$invalidDateRows}), a character vector of
#' row numbers (\code{character(0)} when all dates are valid). When the dates
#' are converted, \code{sb} also gains an \code{exit} column.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::pedInvalidDates
#' ped
#' errorLst <- getEmptyErrorLst()
#' colNamesAndErrors <- fixColumnNames(names(ped), errorLst)
#' names(ped) <- colNamesAndErrors$newColNames
#' pedAndErrors <- getDateErrorsAndConvertDatesInPed(ped, errorLst)
#' pedAndErrors$sb
#' pedAndErrors$errorLst
getDateErrorsAndConvertDatesInPed <- function(sb, errorLst) { # nolint: object_length_linter
  invalidDateRows <- convertDate(sb,
    timeOrigin = as.Date("1970-01-01"),
    reportErrors = TRUE
  )
  if (!is.null(invalidDateRows)) {
    errorLst$invalidDateRows <- invalidDateRows
    invalidAndAdded <- c(
      as.integer(invalidDateRows),
      getRecordStatusIndex(sb, "added")
    )
    if (nrow(sb[-invalidAndAdded, ]) > 0L) {
      ## Blank each date column's own invalid cells, so the conversion below
      ## never meets one (it stops on the first).
      for (dateCol in intersect(names(sb), getDateColNames())) {
        badRows <- as.integer(convertDate(
          sb[, intersect(names(sb), c(dateCol, "recordStatus")), drop = FALSE],
          timeOrigin = as.Date("1970-01-01"),
          reportErrors = TRUE
        ))
        sb[badRows, dateCol] <- NA
      }
      sb <- convertDate(sb,
        timeOrigin = as.Date("1970-01-01"),
        reportErrors = FALSE
      )
      sb <- setExit(sb, timeOrigin = as.Date("1970-01-01"))
    }
  } else {
    sb <- convertDate(sb,
      timeOrigin = as.Date("1970-01-01"),
      reportErrors = FALSE
    )
    sb <- setExit(sb, timeOrigin = as.Date("1970-01-01"))
  }
  list(sb = sb, errorLst = errorLst)
}
