#' Determine if Error List tab should be displayed
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Checks QC results to determine if the Error List tab should be inserted
#' into the application navigation. The tab is shown when there are QC errors.
#'
#' @return Logical. TRUE if errors exist and tab should be shown, FALSE otherwise.
#'
#' @param qcResults list containing QC results with an \code{errors} element.
#'   The errors element should be a data frame where rows indicate errors.
#'
#' @seealso \code{\link{shouldShowChangedColsTab}} for changed columns tab logic
#' @seealso \code{\link{checkErrorLst}} for the original errorLst-based check
#' @export
shouldShowErrorTab <- function(qcResults) {
  if (is.null(qcResults)) {
    return(FALSE)
  }

  if (!is.list(qcResults)) {
    return(FALSE)
  }

  errors <- qcResults$errors

  if (is.null(errors)) {
    return(FALSE)
  }

  if (is.data.frame(errors)) {
    return(nrow(errors) > 0L)
  }

  # Fallback for other structures
  return(length(errors) > 0L)
}
