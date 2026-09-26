## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Remove placeholder animals added for unknown parents
#'
#' @inheritParams reportGV
#' @return Pedigree with unknown animals removed. A pedigree without a
#' \code{recordStatus} column has no animals marked as added, so it is
#' returned unchanged.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::smallPed
#' addedPed <- cbind(ped,
#'   recordStatus = rep("original", nrow(ped)),
#'   stringsAsFactors = FALSE
#' )
#' addedPed[1:3, "recordStatus"] <- "added"
#' ped2 <- removeUnknownAnimals(addedPed)
#' nrow(ped)
#' nrow(ped2)
removeUnknownAnimals <- function(ped) {
  if (!("recordStatus" %in% names(ped))) {
    return(ped)
  }
  ## Only "added" rows are removed. An NA status is not "added", and an NA in a
  ## row subscript would return an all-NA phantom row, so guard it explicitly.
  ped[is.na(ped$recordStatus) | ped$recordStatus != "added", ]
}
