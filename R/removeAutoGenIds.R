## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Remove automatically generated IDs from pedigree
#'
#' Identifies automatically generated IDs via \code{isGeneratedUnknownId()},
#' the shared detection predicate derived from the configurable auto-ID format
#' (see \code{\link{getAutoIdFormat}}). With the default \code{"U\%04d"}, an
#' automatically generated ID is a capital "U" followed by at least four
#' capital letters or digits (\code{"U0001"}, or \code{"U05X3C"} after
#' de-identification). A real animal whose ID merely starts with "U"
#' (\code{"U1"}, \code{"U123"}, \code{"Uma"}) is kept, and so is its place as
#' a sire or dam; a real ID of the full shape (\code{"U1234"}) is removed.
#' @inheritParams getDescendantPedigree
#'
#' @return A pedigree with automatically generated IDs removed.
#' @export
#'
#' @examples
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' length(examplePedigree$id)
#' ped <- removeAutoGenIds(examplePedigree)
#' length(ped$id)
#'
removeAutoGenIds <- function(ped) {
  ped <- ped[!isGeneratedUnknownId(ped$id), ]
  ped$sire[isGeneratedUnknownId(ped$sire)] <- NA
  ped$dam[isGeneratedUnknownId(ped$dam)] <- NA
  ped
}
