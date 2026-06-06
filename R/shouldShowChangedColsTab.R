#' Determine if Changed Columns tab should be displayed
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Checks the changedCols list to determine if the Changed Columns tab should
#' be inserted into the application navigation. The tab is shown when column
#' names were modified during QC processing.
#'
#' @return Logical. TRUE if columns were changed and tab should be shown,
#'   FALSE otherwise.
#'
#' @param changedCols list containing information about changed column names.
#'   Expected fields include: \code{caseChange}, \code{spaceRemoved},
#'   \code{periodRemoved}, \code{underScoreRemoved}, \code{egoToId},
#'   \code{egoidToId}, \code{sireIdToSire}, \code{damIdToDam},
#'   \code{birthdateToBirth}, \code{deathdateToDeath},
#'   \code{recordstatusToRecordStatus}, \code{fromcenterToFromCenter}.
#'
#' @seealso \code{\link{checkChangedColsLst}} for the original implementation
#' @export
shouldShowChangedColsTab <- function(changedCols) {
  if (is.null(changedCols)) {
    return(FALSE)
  }

  if (!is.list(changedCols)) {
    return(FALSE)
  }

  if (length(changedCols) == 0L) {
    return(FALSE)
  }

  # Check each possible changed column field
  fields <- c(
    "caseChange", "spaceRemoved", "periodRemoved", "underScoreRemoved",
    "egoToId", "egoidToId", "sireIdToSire", "damIdToDam",
    "birthdateToBirth", "deathdateToDeath",
    "recordstatusToRecordStatus", "fromcenterToFromCenter"
  )

  for (field in fields) {
    if (field %in% names(changedCols)) {
      if (length(changedCols[[field]]) > 0L) {
        return(TRUE)
      }
    }
  }

  FALSE
}
