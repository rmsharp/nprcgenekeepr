## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Prepare outside-information kinship overrides for a genetic-value path
#'
#' Issue #13 / issue #95 keep-all revert. The shared override-preparation step
#' that \code{reportGV} and \code{gvaConvergence} both use so their override
#' handling cannot drift. Given the proband-filtered kinship matrix and the raw
#' user override frame (or \code{NULL}), it validates the frame
#' (\code{\link{checkKinshipOverrides}}), \code{warning()}s and drops rows
#' naming ids outside \code{rownames(kmat)} so the strict leaf never aborts a
#' run (D5), and applies the survivors to the matrix
#' (\code{\link{applyKinshipOverrides}}). The override REFINES the named kinship
#' cells; it never suppresses the issue-#9 \code{+ sexMean / 2} unknown-parent
#' prior, which is kept for every one-unknown animal (issue #95 keep-all
#' revert). With no override / an empty frame the result is byte-identical to
#' no override (D10).
#'
#' @param kmat dense, symmetric, id-named proband kinship matrix.
#' @param kinshipOverrides raw user override data.frame (\code{id1}, \code{id2},
#' \code{kinship}), or \code{NULL}.
#' @return list with \code{kmat} (the patched matrix).
#' @noRd
prepareKinshipOverrides <- function(kmat, kinshipOverrides) {
  if (is.null(kinshipOverrides) || nrow(kinshipOverrides) == 0L) {
    return(list(kmat = kmat))
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
  }
  list(kmat = kmat)
}
