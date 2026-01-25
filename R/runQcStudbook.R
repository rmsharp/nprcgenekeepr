#' Run Quality Control on Studbook with UI-Friendly Results
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Wrapper function that runs \code{qcStudbook} and processes results into a
#' format suitable for Shiny UI display. This function performs two passes:
#' first to check for errors, then to get the cleaned data if no errors exist.
#'
#' @param ped data.frame containing pedigree data with columns including
#'   id, sire, dam, sex, and optionally birth, death, departure, etc.
#' @param minParentAge numeric minimum age in years for parents (default 2.0).
#'   Parents younger than this at the time of offspring birth are flagged.
#' @param reportChanges logical whether to report column name changes in the
#'   result (default FALSE). When TRUE, warnings about renamed columns are
#'   included in the qcResult.
#'
#' @return A list with the following components:
#' \itemize{
#'   \item \code{cleaned} - The cleaned pedigree data.frame with standardized
#'     column names, added generation numbers, etc. NULL if errors were found.
#'   \item \code{qcResult} - Result from \code{processQcStudbookResult}
#'     containing errors, warnings, changedCols, hasErrors, and hasChangedCols.
#' }
#'
#' @seealso \code{\link{qcStudbook}} for the underlying QC function
#' @seealso \code{\link{processQcStudbookResult}} for result processing
#' @seealso \code{\link{modInputServer}} for Shiny module integration
#'
#' @examples
#' \dontrun{
#' data("pedGood", package = "nprcgenekeepr")
#' result <- runQcStudbook(pedGood, minParentAge = 2.0)
#' if (!result$qcResult$hasErrors) {
#'   cleanedPed <- result$cleaned
#' }
#' }
#'
#' @export
runQcStudbook <- function(ped, minParentAge = 2.0, reportChanges = FALSE) {
  # Helper to create empty qcResult structure
  getEmptyQcResult <- function() {
    list(
      errors = data.frame(
        Row = integer(0),
        Error = character(0),
        Details = character(0),
        stringsAsFactors = FALSE
      ),
      warnings = data.frame(
        Row = integer(0),
        Warning = character(0),
        Details = character(0),
        stringsAsFactors = FALSE
      ),
      changedCols = list(),
      hasErrors = FALSE,
      hasChangedCols = FALSE
    )
  }

  # Validate input
  if (is.null(ped)) {
    stop("Pedigree data cannot be NULL")
  }

  # Handle empty pedigree - return as-is with no errors
  if (nrow(ped) == 0L) {
    return(list(
      cleaned = ped,
      qcResult = getEmptyQcResult()
    ))
  }

  # First pass: check for errors
  # Always use reportChanges=TRUE internally to avoid NULL return from qcStudbook
  errorLst <- tryCatch(
    qcStudbook(
      ped,
      minParentAge = minParentAge,
      reportChanges = TRUE,
      reportErrors = TRUE
    ),
    warning = function(cond) getEmptyErrorLst(),
    error = function(cond) getEmptyErrorLst()
  )

  # Safety check: handle NULL (shouldn't happen with reportChanges=TRUE)
  if (is.null(errorLst)) {
    errorLst <- getEmptyErrorLst()
  }

  # Process the error list into UI-friendly format
  qcResult <- processQcStudbookResult(errorLst)

  # If caller doesn't want change reports, clear them from result
  if (!reportChanges) {
    qcResult$changedCols <- list()
    qcResult$hasChangedCols <- FALSE
    qcResult$warnings <- data.frame(
      Row = integer(0),
      Warning = character(0),
      Details = character(0),
      stringsAsFactors = FALSE
    )
  }

  # If there are errors, return NULL for cleaned data
  if (qcResult$hasErrors) {
    return(list(
      cleaned = NULL,
      qcResult = qcResult
    ))
  }

  # Second pass: get the cleaned data (no error reporting needed)
  cleanedPed <- tryCatch(
    qcStudbook(
      ped,
      minParentAge = minParentAge,
      reportChanges = FALSE,
      reportErrors = FALSE
    ),
    warning = function(cond) NULL,
    error = function(cond) NULL
  )

  list(
    cleaned = cleanedPed,
    qcResult = qcResult
  )
}
