#' checkChangedColsLst examines list for non-empty fields
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return Returns \code{NULL} if all fields are empty
#' else the entire list is returned.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' library(lubridate)
#' pedOne <- data.frame(ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3",
#'                                 "o4"),
#'                     `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
#'                     dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
#'                      sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
#'                      birth_date = mdy(
#'                        paste0(sample(1:12, 8, replace = TRUE), "-",
#'                               sample(1:28, 8, replace = TRUE), "-",
#'                               sample(seq(0, 15, by = 3), 8, replace = TRUE) +
#'                                 2000)),
#'                      stringsAsFactors = FALSE, check.names = FALSE)
#'
#' errorLst <- qcStudbook(pedOne, reportErrors = TRUE, reportChanges = TRUE)
#' checkChangedColsLst(errorLst$changedCols)
#' }
#' @param changedCols list with fields for each type of column change
#' \code{qcStudbook}.
#' @export
checkChangedColsLst <- function(changedCols) {
  if (length(changedCols$caseChange) > 0 |
      length(changedCols$spaceRemoved) > 0 |
      length(changedCols$periodRemoved) > 0 |
      length(changedCols$underScoreRemoved) > 0 |
      length(changedCols$egoToId) > 0 |
      length(changedCols$egoidToId) > 0 |
      length(changedCols$sireIdToSire) > 0 |
      length(changedCols$damIdToDam) > 0 |
      length(changedCols$birthdateToBirth) > 0 |
      length(changedCols$deathdateToDeath) > 0 |
      length(changedCols$recordstatusToRecordStatus) > 0 |
      length(changedCols$fromcenterToFromCenter) > 0) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

