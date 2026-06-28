#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr

#' Identify one-unknown focals whose missing side an override informs
#'
#' Issue #95 option C, Slice 1. Returns the subset of \code{candidateIds} that
#' are missing exactly one parent (one-unknown, detected with
#' \code{isGeneratedUnknownId} / \code{NA} on \code{ped$sire}, \code{ped$dam})
#' AND are named by a non-blank \code{missingSideFor} cell in \code{overrides}
#' -- the focal animals whose MISSING-side relatedness an override stands in for
#' (case a). These are the ids whose \code{+ sexMean / 2} prior \code{reportGV}
#' suppresses under option C. A blank / NA \code{missingSideFor} (known-side,
#' case b), an absent \code{missingSideFor} column, a named id that is not
#' one-unknown, and a \code{NULL} / zero-row frame all contribute nothing.
#'
#' @param overrides validated kinship-overrides frame (see
#' \code{\link{checkKinshipOverrides}}); may carry an optional
#' \code{missingSideFor} column.
#' @param ped pedigree data.frame with at least \code{id}, \code{sire},
#' \code{dam}.
#' @param candidateIds character vector of ids to consider (the analysis
#' probands).
#' @return character vector (possibly empty) of the missing-side focal ids.
#' @noRd
classifyOverrideMissingSide <- function(overrides, ped, candidateIds) {
  if (is.null(overrides) || nrow(overrides) == 0L ||
    !("missingSideFor" %in% names(overrides))) {
    return(character(0L))
  }
  side <- as.character(overrides$missingSideFor)
  side[is.na(side)] <- ""
  claimed <- unique(side[nzchar(side)])
  if (length(claimed) == 0L) {
    return(character(0L))
  }
  ped <- as.data.frame(ped, stringsAsFactors = FALSE)
  rownames(ped) <- as.character(ped$id)
  cand <- ped[as.character(candidateIds), , drop = FALSE]
  isU <- function(x) is.na(x) | isGeneratedUnknownId(x)
  oneU <- xor(isU(cand$sire), isU(cand$dam))
  oneUids <- as.character(cand$id[oneU])
  intersect(claimed, oneUids)
}
