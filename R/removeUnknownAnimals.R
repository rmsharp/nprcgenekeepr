## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Remove placeholder animals added for unknown parents
#'
#' @inheritParams reportGV
#' @return Pedigree with unknown animals removed
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
  ped[getRecordStatusIndex(ped, status = "original"), ]
}
