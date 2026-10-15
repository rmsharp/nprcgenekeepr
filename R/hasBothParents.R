## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check whether an animal has both parents
#'
#' @param id a single ID to examine for parents. A vector of IDs is not
#' supported: the result is not one value per ID, and a recycling warning
#' appears only when the number of IDs does not divide the number of rows of
#' \code{ped}.
#' @inheritParams reportGV
#' @return TRUE if ID has both sire and dam identified in \code{ped}, FALSE
#' if one or both are unknown, and \code{logical(0)} if \code{id} is not in
#' \code{ped}.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::pedOne
#' names(ped) <- c("id", "sire", "dam", "sex", "birth")
#' hasBothParents("o2", ped)
#' ped$sire[ped$id == "o2"] <- NA
#' hasBothParents("o2", ped)
hasBothParents <- function(id, ped) {
  !is.na(ped$sire[ped$id == id]) & !is.na(ped$dam[ped$id == id])
}
