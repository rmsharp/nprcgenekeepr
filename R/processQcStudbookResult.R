#' Process qcStudbook Result into UI-Friendly Format
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Converts the errorLst object returned by qcStudbook (when reportErrors=TRUE)
#' into a format suitable for display in the Shiny UI.
#'
#' @param errorLst list object returned by \code{qcStudbook} with
#'   \code{reportErrors = TRUE}, or NULL. Expected to be of class
#'   \code{nprcgenekeeprErr} containing error fields such as femaleSires,
#'   maleDams, sireAndDam, duplicateIds, invalidIdChars, missingColumns,
#'   invalidDateRows, suspiciousParents, failedDatabaseConnection, and
#'   changedCols.
#'
#' @return A list with the following components:
#' \itemize{
#'   \item \code{errors} - data.frame with columns Row, Error, Details
#'   \item \code{warnings} - data.frame with columns Row, Warning, Details
#'   \item \code{changedCols} - list of changed column information
#'   \item \code{hasErrors} - logical indicating if any errors were found
#'   \item \code{hasChangedCols} - logical indicating if columns were renamed
#' }
#'
#' @seealso \code{\link{qcStudbook}} for generating the errorLst input
#' @seealso \code{\link{runQcStudbook}} for a wrapper that uses this function
#' @seealso \code{\link{checkErrorLst}} for checking if errorLst has errors
#' @seealso \code{\link{checkChangedColsLst}} for checking column changes
#'
#' @export
processQcStudbookResult <- function(errorLst) {
  # Helper function to create an error row
  makeErrorRow <- function(error, details) {
    data.frame(
      Row = NA_integer_,
      Error = error,
      Details = details,
      stringsAsFactors = FALSE
    )
  }

  # Helper function to create a warning row
  makeWarningRow <- function(warning, details) {
    data.frame(
      Row = NA_integer_,
      Warning = warning,
      Details = details,
      stringsAsFactors = FALSE
    )
  }

  # Initialize result structure
  result <- list(
    errors = data.frame(
      Row = integer(0L),
      Error = character(0L),
      Details = character(0L),
      stringsAsFactors = FALSE
    ),
    warnings = data.frame(
      Row = integer(0L),
      Warning = character(0L),
      Details = character(0L),
      stringsAsFactors = FALSE
    ),
    changedCols = list(),
    hasErrors = FALSE,
    hasChangedCols = FALSE
  )

  # Handle NULL input
  if (is.null(errorLst)) {
    result$hasErrors <- TRUE
    result$errors <- rbind(
      result$errors,
      makeErrorRow("QC Processing Error",
                   "No result returned from quality control check")
    )
    return(result)
  }

  # Check for missing columns
  if (length(errorLst$missingColumns) > 0L) {
    result$errors <- rbind(
      result$errors,
      makeErrorRow("Missing required columns",
                   toString(errorLst$missingColumns))
    )
  }

  # Check for female sires
  if (length(errorLst$femaleSires) > 0L) {
    for (id in errorLst$femaleSires) {
      result$errors <- rbind(
        result$errors,
        makeErrorRow("Female listed as sire",
                     paste("Animal", id, "is female but listed as a sire"))
      )
    }
  }

  # Check for male dams
  if (length(errorLst$maleDams) > 0L) {
    for (id in errorLst$maleDams) {
      result$errors <- rbind(
        result$errors,
        makeErrorRow("Male listed as dam",
                     paste("Animal", id, "is male but listed as a dam"))
      )
    }
  }

  # Check for animals that are both sire and dam
  if (length(errorLst$sireAndDam) > 0L) {
    for (id in errorLst$sireAndDam) {
      result$errors <- rbind(
        result$errors,
        makeErrorRow("Animal is both sire and dam",
                     paste("Animal", id, "appears as both a sire and a dam"))
      )
    }
  }

  # Check for duplicate IDs
  if (length(errorLst$duplicateIds) > 0L) {
    result$errors <- rbind(
      result$errors,
      makeErrorRow("Duplicate IDs found",
                   toString(errorLst$duplicateIds))
    )
  }

  # Check for IDs containing a disallowed period
  if (length(errorLst$invalidIdChars) > 0L) {
    result$errors <- rbind(
      result$errors,
      makeErrorRow("IDs contain a disallowed period (\".\")",
                   toString(errorLst$invalidIdChars))
    )
  }

  # Check for invalid date rows
  if (length(errorLst$invalidDateRows) > 0L) {
    result$errors <- rbind(
      result$errors,
      makeErrorRow("Invalid date values",
                   toString(errorLst$invalidDateRows))
    )
  }

  # Check for suspicious parents (low age)
  if (!is.null(errorLst$suspiciousParents) &&
      is.data.frame(errorLst$suspiciousParents) &&
      nrow(errorLst$suspiciousParents) > 0L) {
    for (i in seq_len(nrow(errorLst$suspiciousParents))) {
      result$errors <- rbind(
        result$errors,
        makeErrorRow("Parent age too young",
                     "Parent below minimum age at offspring birth")
      )
    }
  }

  # Check for database connection failure
  if (length(errorLst$failedDatabaseConnection) > 0L) {
    result$errors <- rbind(
      result$errors,
      makeErrorRow("Database connection failed",
                   paste(errorLst$failedDatabaseConnection, collapse = "; "))
    )
  }

  # Check for changed columns
  if (!is.null(errorLst$changedCols)) {
    result$changedCols <- errorLst$changedCols
    result$hasChangedCols <- checkChangedColsLst(errorLst$changedCols)

    # Add changed columns as warnings
    if (result$hasChangedCols) {
      if (length(errorLst$changedCols$caseChange) > 0L) {
        result$warnings <- rbind(
          result$warnings,
          makeWarningRow("Column name case changed",
                         toString(errorLst$changedCols$caseChange))
        )
      }
      if (length(errorLst$changedCols$spaceRemoved) > 0L) {
        result$warnings <- rbind(
          result$warnings,
          makeWarningRow("Spaces removed from column names",
                         toString(errorLst$changedCols$spaceRemoved))
        )
      }
    }
  }

  # Set hasErrors flag
  result$hasErrors <- nrow(result$errors) > 0L

  result
}
