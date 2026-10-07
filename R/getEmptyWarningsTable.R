## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' The QC warnings table with no rows
#'
#' The shape of the \code{warnings} table that \code{processQcStudbookResult()}
#' and \code{runQcStudbook()} return: the columns \code{Row}, \code{Warning}
#' and \code{Details}, with no rows.
#'
#' @return A data frame with zero rows and the columns \code{Row} (integer),
#' \code{Warning} (character) and \code{Details} (character).
#' @noRd
getEmptyWarningsTable <- function() {
  data.frame(
    Row = integer(0L),
    Warning = character(0L),
    Details = character(0L),
    stringsAsFactors = FALSE
  )
}
