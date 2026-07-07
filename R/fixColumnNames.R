## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Standardize pedigree column names
#'
#' @param orgCols character vector with ordered list of column names
#' found in a pedigree file.
#' @param errorLst list object with places to store the various column
#' name changes.
#' @return A list object with \code{newColNames} and \code{errorLst} with
#' a record of all changes made.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' fixColumnNames(c("Sire_ID", "EGO", "DAM", "Id", "birth_date"),
#'   errorLst = getEmptyErrorLst()
#' )
fixColumnNames <- function(orgCols, errorLst) {
  cols <- tolower(orgCols)
  errorLst$changedCols$caseChange <- colChange(orgCols, cols)
  newCols <- gsub(" ", "", cols, fixed = FALSE) # nolint fixed_regex_linter
  errorLst$changedCols$spaceRemoved <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("\\.", "", cols, fixed = FALSE) # nolint fixed_regex_linter
  errorLst$changedCols$periodRemoved <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("_", "", cols, fixed = FALSE) # nolint fixed_regex_linter

  ## Clean up possible overreach: the underscore strip collapses the
  ## genotype-bearing headers first_name/second_name; restore them on newCols
  ## (the returned vector) so they survive. Issue #117.
  if (any(tolower(newCols) == "firstname")) {
    newCols[tolower(newCols) == "firstname"] <- "first_name"
  }
  if (any(tolower(newCols) == "secondname")) {
    newCols[tolower(newCols) == "secondname"] <- "second_name"
  }

  errorLst$changedCols$underScoreRemoved <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("egoid", "id", cols, fixed = TRUE)
  errorLst$changedCols$egoidToId <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("ego", "id", cols, fixed = TRUE)
  errorLst$changedCols$egoToId <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("sireid", "sire", cols, fixed = TRUE)
  errorLst$changedCols$sireIdToSire <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("damid", "dam", cols, fixed = TRUE)
  errorLst$changedCols$damIdToDam <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("birthdate", "birth", cols, fixed = TRUE)
  errorLst$changedCols$birthdateToBirth <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("deathdate", "death", cols, fixed = TRUE)
  errorLst$changedCols$deathdateToDeath <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("recordstatus", "recordStatus", newCols, fixed = TRUE)
  errorLst$changedCols$recordstatusToRecordStatus <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("fromcenter", "fromCenter", newCols, fixed = TRUE)
  errorLst$changedCols$fromcenterToFromCenter <- colChange(cols, newCols)
  cols <- newCols
  newCols <- gsub("geographicorigin", "geographicOrigin", newCols, fixed = TRUE)
  errorLst$changedCols$geographicoriginToGeographicOrigin <-
    colChange(cols, newCols)
  list(newColNames = newCols, errorLst = errorLst)
}
