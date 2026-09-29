## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Classify how much of each animal's parentage is known
#'
#' Labels each animal by how many of its parents are unknown, treating both a
#' missing parent (\code{NA}) and an auto-generated unknown-parent placeholder
#' id (see \code{\link{isGeneratedUnknownId}}) as unknown. Used by the genetic
#' value report (issue #9 Slice 3) to flag both-unknown founders so the
#' displayed rank can demote them, and to surface a parentage column for the
#' user.
#'
#' @param sire character vector of sire ids (\code{NA} or a U-id when unknown).
#' @param dam character vector of dam ids (\code{NA} or a U-id when unknown),
#' the same length as \code{sire}.
#' @param ped optional pedigree (the whole one, not the animals being
#' classified). Where it has a \code{placeholder} column (written by
#' \code{\link{qcStudbook}}), a parent id with a mark there is unknown exactly
#' when the mark says so; any other id is read by its shape (see
#' \code{\link{isGeneratedUnknownId}}).
#' @return a character vector the length of \code{sire}: \code{"known"} when
#' both parents are known, \code{"one unknown parent"} when exactly one is
#' unknown, and \code{"both unknown"} when neither parent is known.
#' @noRd
classifyParentage <- function(sire, dam, ped = NULL) {
  isU <- function(x) is.na(x) | isGeneratedUnknownId(x, ped = ped)
  sireUnknown <- isU(sire)
  damUnknown <- isU(dam)
  out <- rep("known", length(sireUnknown))
  out[sireUnknown | damUnknown] <- "one unknown parent"
  out[sireUnknown & damUnknown] <- "both unknown"
  out
}
