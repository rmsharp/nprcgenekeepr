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
#' a sire or dam; a real ID of the full shape (\code{"U1234"}) is removed
#' unless the pedigree's \code{placeholder} column (see
#' \code{\link{qcStudbook}}) marks it \code{FALSE}, and a \code{TRUE} mark
#' removes a stand-in whatever its ID looks like. The "four or more" match is
#' a prefix, so an ID such as \code{"U1234abc"} is removed too. Sire and dam
#' entries that are generated IDs are set to \code{NA}.
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
  idIsPlaceholder <- isGeneratedUnknownId(ped$id, ped = ped)
  sireIsPlaceholder <- isGeneratedUnknownId(ped$sire, ped = ped)
  damIsPlaceholder <- isGeneratedUnknownId(ped$dam, ped = ped)
  ped <- ped[!idIsPlaceholder, ]
  ped$sire[sireIsPlaceholder[!idIsPlaceholder]] <- NA
  ped$dam[damIsPlaceholder[!idIsPlaceholder]] <- NA
  ped
}
