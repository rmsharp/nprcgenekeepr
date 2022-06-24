#' Creates a empty errorLst object
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr

#' @return An errorLst object with placeholders for error types found in a
#' pedigree file by \code{qcStudbook}.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' getEmptyErrorLst()
#' }
#'
#' @export
getEmptyErrorLst <- function() {
  emptyErrorLst <- list(
    failedDatabaseConnection = character(0),
    missingColumns = character(0),
    invalidDateRows = character(0),
    suspiciousParents = data.frame(),
    femaleSires = character(0),
    maleDams = character(0),
    sireAndDam = character(0),
    duplicateIds = character(0),
    fatalError = character(0),
    changedCols = list(
      caseChange = character(0),
      spaceRemoved = character(0),
      periodRemoved = character(0),
      underScoreRemoved = character(0),
      egoToId = character(0),
      egoidToId = character(0),
      sireIdToSire = character(0),
      damIdToDam =  character(0),
      birthdateToBirth = character(0),
      deathdateToDeath = character(0),
      recordstatusToRecordStatus = character(0),
      fromcenterToFromCenter = character(0),
      geographicoriginToGeographicOrigin = character(0)
    )
  )
  class(emptyErrorLst) <-
    append(class(emptyErrorLst), "nprcgenekeeprErr")
  emptyErrorLst
}
