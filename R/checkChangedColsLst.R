## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check a changed-columns list for non-empty fields
#'
#' @param changedCols list with fields for each type of column change
#' made by \code{qcStudbook}.
#' @return Returns \code{TRUE} if any changed-columns field is
#' non-empty, otherwise \code{FALSE}.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' library(lubridate)
#' pedOne <- data.frame(
#'   ego_id = c(
#'     "s1", "d1", "s2", "d2", "o1", "o2", "o3",
#'     "o4"
#'   ),
#'   `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
#'   dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
#'   sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
#'   birth_date = mdy(
#'     paste0(
#'       sample(1:12, 8, replace = TRUE), "-",
#'       sample(1:28, 8, replace = TRUE), "-",
#'       sample(seq(0, 15, by = 3), 8, replace = TRUE) +
#'         2000
#'     )
#'   ),
#'   stringsAsFactors = FALSE, check.names = FALSE
#' )
#'
#' errorLst <- qcStudbook(pedOne, reportErrors = TRUE, reportChanges = TRUE)
#' checkChangedColsLst(errorLst$changedCols)
checkChangedColsLst <- function(changedCols) {
  any(lengths(changedCols) > 0L)
}
