#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr

#' Prepare outside-information kinship overrides for a genetic-value path
#'
#' Issue #95 option C, Slice 2. The shared override-preparation step that
#' \code{reportGV} and \code{gvaConvergence} both use so their override
#' handling cannot drift. Given the proband-filtered kinship matrix, the raw
#' user override frame (or \code{NULL}), the pedigree, and the candidate
#' (proband) ids, it validates the frame (\code{\link{checkKinshipOverrides}}),
#' \code{warning()}s and drops rows naming ids outside \code{rownames(kmat)} so
#' the strict leaf never aborts a run (D5), applies the survivors to the matrix
#' (\code{\link{applyKinshipOverrides}}), and computes the set of one-unknown
#' ids whose \code{+ sexMean / 2} prior the issue-#9 correction should
#' suppress: the missing-side focals named by a non-blank \code{missingSideFor}
#' cell (option C, case a) when that column is present, otherwise the full
#' overridden set (blanket supersession, D11; byte-identical with no override /
#' no column, D10).
#'
#' @param kmat dense, symmetric, id-named proband kinship matrix.
#' @param kinshipOverrides raw user override data.frame (\code{id1}, \code{id2},
#' \code{kinship}, optional \code{missingSideFor}), or \code{NULL}.
#' @param ped pedigree data.frame with \code{id}, \code{sire}, \code{dam}.
#' @param candidateIds character vector of candidate (proband) ids.
#' @return list with \code{kmat} (the patched matrix) and \code{suppressIds}
#' (the one-unknown ids whose \code{+ sexMean / 2} prior to suppress).
#' @noRd
prepareKinshipOverrides <- function(kmat, kinshipOverrides, ped, candidateIds) {
  suppressIds <- character(0L)
  if (is.null(kinshipOverrides) || nrow(kinshipOverrides) == 0L) {
    return(list(kmat = kmat, suppressIds = suppressIds))
  }
  overrides <- checkKinshipOverrides(kinshipOverrides)
  inMatrix <- overrides$id1 %in% rownames(kmat) &
    overrides$id2 %in% rownames(kmat)
  if (!all(inMatrix)) {
    dropped <- setdiff(
      unique(c(overrides$id1[!inMatrix], overrides$id2[!inMatrix])),
      rownames(kmat)
    )
    warning(sprintf(
      paste0("Dropping %d kinship override row(s) referencing id(s) not in ",
        "the analysis set: %s."),
      sum(!inMatrix), toString(dropped)
    ))
    overrides <- overrides[inMatrix, , drop = FALSE]
  }
  if (nrow(overrides) > 0L) {
    kmat <- applyKinshipOverrides(kmat, overrides)
    overriddenIds <- unique(c(overrides$id1, overrides$id2))
    suppressIds <- if ("missingSideFor" %in% names(overrides)) {
      classifyOverrideMissingSide(overrides, ped, candidateIds)
    } else {
      overriddenIds
    }
  }
  list(kmat = kmat, suppressIds = suppressIds)
}
