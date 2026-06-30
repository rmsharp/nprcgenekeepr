## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Apply outside-information kinship overrides to a kinship matrix
#'
#' Writes pairwise kinship coefficients from outside information
#' into a computed kinship matrix, replacing the
#' pedigree-derived value for the named pairs. Each
#' \code{(id1, id2, kinship)} row sets both \code{kmat[id1, id2]} and its
#' symmetric twin \code{kmat[id2, id1]}; all other cells are unchanged.
#' This is a direct cell replacement -- it does not propagate to descendant
#' rows.
#'
#' \code{kmat} must be a dense, symmetric, id-named base R matrix (the object
#' \code{\link{kinship}} returns); a sparse \code{Matrix} object is out of
#' contract. The function is strict: it \code{stop()}s on an id absent from the
#' matrix and on a value above the exact positive-semi-definiteness bound
#' \code{sqrt(kmat[id1, id1] * kmat[id2, id2])}. Soft, run-preserving
#' handling of ids outside the analysis set is the caller's responsibility
#' -- \code{\link{reportGV}} warn-drops non-member ids before calling this.
#' \code{kinship()} itself is never modified (it has several callers, including
#' two simulations that must not take current-kinship overrides).
#'
#' @param kmat a dense, symmetric, id-named numeric kinship matrix.
#' @param overrides data.frame of overrides (\code{id1}, \code{id2},
#' \code{kinship}); \code{NULL} or a zero-row frame is a no-op returning
#' \code{kmat} unchanged. Validated with \code{\link{checkKinshipOverrides}}.
#' @return \code{kmat} with the override cells replaced (symmetric).
#' @export
#' @examples
#' ped <- nprcgenekeepr::qcPed
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
#' overrides <- data.frame(
#'   id1 = ped$id[1], id2 = ped$id[2], kinship = 0.25,
#'   stringsAsFactors = FALSE
#' )
#' kmat <- applyKinshipOverrides(kmat, overrides)
applyKinshipOverrides <- function(kmat, overrides) {
  if (is.null(overrides) || nrow(overrides) == 0L) {
    return(kmat)
  }
  overrides <- checkKinshipOverrides(overrides)

  ids <- rownames(kmat)
  unknown <- setdiff(unique(c(overrides$id1, overrides$id2)), ids)
  if (length(unknown) > 0L) {
    stop("Kinship override id(s) not found in the matrix: ",
      toString(unknown), ".")
  }

  for (i in seq_len(nrow(overrides))) {
    id1 <- overrides$id1[i]
    id2 <- overrides$id2[i]
    value <- overrides$kinship[i]
    bound <- sqrt(kmat[id1, id1] * kmat[id2, id2])
    if (value > bound) {
      stop(sprintf(
        paste0("Kinship override for (%s, %s) is %g, above the maximum ",
          "%g = sqrt(self-kinship product) for that pair."),
        id1, id2, value, bound
      ))
    }
    kmat[id1, id2] <- value
    kmat[id2, id1] <- value
  }
  message(sprintf("%d kinship override(s) applied.", nrow(overrides)))
  kmat
}
