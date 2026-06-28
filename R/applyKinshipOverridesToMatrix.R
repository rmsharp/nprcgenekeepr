#' Apply kinship overrides to a recomputed matrix, soft-dropping absent ids
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Internal helper for the Shiny module fallback recompute paths (issue #13
#' Slice 3). The breeding-group and summary-stats modules recompute a fresh
#' kinship matrix when no Genetic Value output is available; this applies any
#' outside-information kinship overrides to that matrix the same way
#' \code{\link{reportGV}} does on its own path. It intersects the override
#' id-set with \code{rownames(kmat)}, \code{warning()}s and drops rows
#' referencing ids absent from the matrix (so the strict leaf never aborts a
#' module -- D5), then applies the survivors via
#' \code{\link{applyKinshipOverrides}}. A \code{NULL} or zero-row
#' \code{overrides} is a no-op returning \code{kmat} unchanged.
#'
#' @param kmat a dense, symmetric, id-named numeric kinship matrix.
#' @param overrides validated overrides data.frame (\code{id1}, \code{id2},
#'   \code{kinship}), or \code{NULL}.
#' @return \code{kmat} with the in-matrix override cells replaced (symmetric).
#' @noRd
applyKinshipOverridesToMatrix <- function(kmat, overrides) {
  if (is.null(overrides) || nrow(overrides) == 0L) {
    return(kmat)
  }
  inMatrix <- overrides$id1 %in% rownames(kmat) &
    overrides$id2 %in% rownames(kmat)
  if (any(!inMatrix)) {
    dropped <- setdiff(
      unique(c(overrides$id1[!inMatrix], overrides$id2[!inMatrix])),
      rownames(kmat)
    )
    warning(sprintf(
      paste0("Dropping %d kinship override row(s) referencing id(s) not in ",
        "the analysis set: %s."),
      sum(!inMatrix), paste(dropped, collapse = ", ")
    ))
    overrides <- overrides[inMatrix, , drop = FALSE]
  }
  if (nrow(overrides) == 0L) {
    return(kmat)
  }
  applyKinshipOverrides(kmat, overrides)
}
