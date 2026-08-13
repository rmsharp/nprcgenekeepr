## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Generate a kinship matrix
#'
#' The function previously had an internal call to the kindepth function in
#' order to provide the parameter pdepth (the generation number). This version
#' requires the generation number to be calculated elsewhere and passed into
#' the function.
#'
#' The rows (cols) of founders are just 0.5 * identity matrix, no further
#'    processing is needed for them.
#' Parents must be processed before their children, and then a child's
#'    kinship is just a sum of the kinship's for his or her parents.
#'
#' @details The code for the kinship function was written by Terry Therneau
#' at the Mayo clinic and taken from his website. This function is part of a
#' package written in S (and later ported to R) for calculating kinship and
#' other statistics.
#'
#' @param id character vector of IDs for a set of animals.
#' @param father.id character vector or NA for the IDs of the sires for the set
#' of animals.
#' @param mother.id character vector or NA for the IDs of the dams for the set
#' of animals.
#' @param pdepth integer vector indicating the generation number for each
#' animal.
#' @param sparse logical flag. If \code{TRUE}, \code{Matrix::Diagnol()} is
#' used to make a unit diagonal matrix. If \code{FALSE}, \code{base::diag()} is
#' used to make a unit square matrix.
#' @param twinRelations \code{NULL} (default, no-op) or a data.frame with
#' columns \code{id1}, \code{id2}, \code{code} declaring twin pairs (see
#' \code{\link{checkTwinRelations}}). Only \code{code == "MZ twin"} rows
#' affect the computed matrix -- \code{"DZ twin"}/\code{"UZ twin"} rows are
#' accepted but get zero special treatment, matching kinship2's own
#' \code{relation} mechanism. A declared MZ-twin pair's coefficient is
#' corrected to equal their shared self-kinship (genetic identity), and the
#' correction is propagated transitively (chained MZ declarations, e.g.
#' A-B and B-C, also correct the undeclared A-C pair) and to every relative
#' computed at a later pedigree depth through either twin -- not just the
#' declared pair's own cell. \code{twinRelations} is trusted as already
#' validated by \code{\link{checkTwinRelations}} (this function has no
#' \code{sex} parameter and so cannot re-run that validator's full rule set
#' itself); only a cheap self-contained check (both ids present in \code{id})
#' is performed here. See
#' \code{docs/planning/twin-relations-kinship-computation-plan.md} for the
#' full design rationale.
#'
#' @return A kinship square matrix
#'
#' @author Terry M. Therneau, Mayo Clinic (mayo.edu), original version
#'
#'
#' All of the code on the original S-Plus kinship function (originally
#' hosted on Terry Therneau's Mayo Clinic software page, offline since at
#' least 2019) was stated to be released under the GNU General Public
#' License (version 2 or later).
#'
#' The R version became the kinship2 package available on CRAN:
#' @references \url{https://cran.r-project.org/package=kinship2}
#'
#' $Id: kinship.s,v 1.5 2003/01/04 19:07:53 therneau Exp $
#'
#' @references Create the kinship matrix, using the algorithm of K Lange,
#'  Mathematical and Statistical Methods for Genetic Analysis,
#'  Springer, 1997, p 71-72.
#'
#' @author as modified by M Raboin, 2014-09-08 14:44:26
#'
#' @import Matrix
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped
#' ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
#' ped
#' kmat
kinship <- function(id, father.id, mother.id, pdepth, sparse = FALSE, # nolint: object_name_linter
                     twinRelations = NULL) {
  # Returns: Matrix (row and col names are 'id')
  n <- length(id)
  if (anyDuplicated(id)) {
    stop("All id values must be unique")
  }
  ## Mendelian 1/2: a non-inbred animal's self-kinship is 1/2, so kmat starts
  ## as one-half of the identity matrix (each founder's self-kinship is 0.5).
  if (sparse) {
    kmat <- Diagonal(n + 1L) / 2L
  } else {
    kmat <- diag(n + 1L) / 2L
  }

  kmat[n + 1L, n + 1L] <- 0L # if A and B both have "unknown" dad, this ensures
  # that they won't end up 'related' in the matrix

  # id number "n + 1" is a placeholder for missing parents
  mrow <- match(mother.id, id, nomatch = n + 1L) # row number of the mother
  drow <- match(father.id, id, nomatch = n + 1L) # row number of the dad

  ## MZ-twin transitive-identity correction (ported from kinship2's own
  ## mzgrp/mzindex mechanism -- see
  ## docs/planning/twin-relations-kinship-computation-plan.md §2.1). Built
  ## once, up front: mzgrp is a union-find grouping of chained MZ
  ## declarations (A-B, B-C => {A,B,C} one group) and mzindex expands each
  ## group to every ordered off-diagonal pair within it -- the matrix cells
  ## the depth loop below must overwrite. Applying this inside the depth
  ## loop (not as a post-hoc pass on the finished matrix) is required for
  ## the correction to propagate to relatives computed at a later depth --
  ## see the plan's §2.2 for the mathematical argument.
  havemz <- FALSE
  if (!is.null(twinRelations)) {
    mzRows <- twinRelations[twinRelations$code == "MZ twin", , drop = FALSE]
    if (nrow(mzRows) > 0L) {
      mzId1 <- match(mzRows$id1, id)
      mzId2 <- match(mzRows$id2, id)
      if (anyNA(c(mzId1, mzId2))) {
        # nolint start: nonportable_path_linter.
        stop("All twinRelations id1/id2 values must be present in id.")
        # nolint end: nonportable_path_linter.
      }
      havemz <- TRUE
      mzmat <- cbind(mzId1, mzId2)
      mzgrp <- seq_len(max(mzmat))
      repeat {
        if (all(mzgrp[mzmat[, 1L]] == mzgrp[mzmat[, 2L]])) {
          break
        }
        for (i in seq_len(nrow(mzmat))) {
          mzgrp[mzmat[i, 1L]] <- mzgrp[mzmat[i, 2L]] <- min(mzgrp[mzmat[i, ]])
        }
      }
      mzindex <- cbind(
        unlist(tapply(mzmat, mzgrp[mzmat], function(x) {
          z <- unique(x)
          rep(z, length(z))
        })),
        unlist(tapply(mzmat, mzgrp[mzmat], function(x) {
          z <- unique(x)
          rep(z, each = length(z))
        }))
      )
      mzindex <- mzindex[mzindex[, 1L] != mzindex[, 2L], , drop = FALSE]
    }
  }

  # Those at depth == 0 don't need to be processed
  # Subjects with depth = i must be processed before those at depth i + 1.
  # Any parent is guarranteed to be at a lower depth than their children
  #  The inner loop on "i" can NOT be replaced with a vectorized expression:
  # sibs' effect on each other is cumulative.
  for (depth in 1L:max(pdepth, na.rm = TRUE)) {
    indx <- (1L:n)[pdepth == depth]
    for (i in indx) {
      mom <- mrow[i]
      dad <- drow[i]
      ## Mendelian 1/2: i's kinship with any j is the average of its two
      ## parents' kinships with j; i's self-kinship is half of one plus its
      ## own inbreeding coefficient (the kinship between its two parents).
      kmat[i, ] <- kmat[, i] <- (kmat[mom, ] + kmat[dad, ]) / 2L
      kmat[i, i] <- (1L + kmat[mom, dad]) / 2L
    }
    if (havemz) {
      kmat[mzindex] <- (diag(kmat))[mzindex[, 1L]]
    }
  }

  kmat <- kmat[1L:n, 1L:n]
  dimnames(kmat) <- list(id, id)
  kmat
}
