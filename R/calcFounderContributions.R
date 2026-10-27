## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Compute shared founder contributions for calcFE, calcFG, and calcFEFG
#'
#' Part of the Genetic Value Analysis
#'
#' Computes the founder mean-contribution vector \code{p} used by
#' \code{\link{calcFE}}, \code{\link{calcFG}}, and \code{\link{calcFEFG}}.
#' Extracted (NEW-13/NEW-23) so the near-verbatim founder-contribution
#' algorithm and the partial-parentage guard live in a single place instead of
#' being copied across the three functions.
#'
#' The pedigree must have no partial parentage (every animal has both parents
#' known or both unknown); the calling function's name (\code{caller}) is
#' interpolated into the error so each public function keeps its own message.
#'
#' @inheritParams calcFE
#' @param caller name of the public function on whose behalf the contributions
#' are computed; used only to phrase the partial-parentage error.
#' @return A list with \code{p} (named numeric vector of founder mean
#' contributions across the current descendants) and \code{ped} (the input
#' pedigree with id/sire/dam coerced to character, so callers can pass the same
#' character pedigree to \code{calcRetention()}).
#' @noRd
calcFounderContributions <- function(ped, caller = "calcFEFG") {
  ped <- toCharacter(ped, headers = c("id", "sire", "dam"))
  partial <- xor(is.na(ped$sire), is.na(ped$dam))
  if (any(partial)) {
    stop(caller, " requires complete parentage (no partial parentage): ",
         "id(s) with exactly one known parent: ", toString(ped$id[partial]),
         ". Resolve partial parentage upstream ",
         "(e.g., qcStudbook() or addUIds()) before calling ", caller, "().")
  }
  founders <- getFounders(ped)
  descendants <- ped$id[!(ped$id %in% founders)]

  d <- founderContributionMatrix(ped, founders, descendants)

  currentDesc <- ped$id[ped$population & !(ped$id %in% founders)]
  ## drop = FALSE keeps a single living descendant a one-row matrix (S925).
  d <- d[currentDesc, , drop = FALSE]
  p <- colMeans(d)

  list(p = p, ped = ped)
}

#' Fill the founder-contribution matrix, fast
#'
#' Each descendant's row of founder contributions is the mean of its two
#' parents' rows, filled generation by generation from generation 1; the rows
#' of generation 0 stay as \code{initialContributions()} built them. For
#' an ordinary pedigree every row of a generation is filled at once, by
#' position (performance plan Phase 5). Any other pedigree goes through
#' \code{founderContributionMatrixGeneral()}, today's loop by name, unchanged
#' (owner ruling S1058), so it gives today's result, or today's error, by
#' construction.
#'
#' @param ped the pedigree, its id, sire and dam coerced to character.
#' @param founders the founders' ids, from \code{getFounders()}.
#' @param descendants every other id of \code{ped}.
#' @return The founders-plus-descendants by founders matrix of
#' \code{initialContributions()} with the rows of generation 1 and later
#' filled.
#' @noRd
founderContributionMatrix <- function(ped, founders, descendants) {
  plan <- contributionPositions(ped, c(founders, descendants))
  if (is.null(plan)) {
    return(founderContributionMatrixGeneral(ped, founders, descendants))
  }
  ## Built here, where it is filled, so the fill writes into the only copy: a
  ## table passed in while its caller still holds it is copied whole at the
  ## first write (S1075).
  d <- initialContributions(founders, descendants)
  for (rows in plan) {
    ## Mendelian 1/2, as in today's loop: the mean of the parents' rows.
    d[rows$ego, ] <- (d[rows$sire, , drop = FALSE] +
                        d[rows$dam, , drop = FALSE]) / 2L
  }
  d
}

#' The rows each generation fills, or NULL
#'
#' Filling a generation's rows at once gives today's matrix where today's loop
#' by name reads only rows of earlier generations and finds every name it
#' looks up. So the pedigree must be a dataframe with at least one row,
#' character id, sire and dam, every id present, non-empty and unique,
#' \code{gen} whole numbers of 0 and up with none missing, and every animal of
#' generation 1 or later must have a sire and a dam in the pedigree, each of
#' an earlier generation.
#'
#' @param ped the pedigree \code{founderContributionMatrix()} was given.
#' @param ids the matrix's row names, every id of \code{ped}.
#' @return NULL, or one element per generation from 1 to the last: a list of
#' the matrix rows of that generation's animals (\code{ego}) and of their
#' sires and dams.
#' @noRd
contributionPositions <- function(ped, ids) {
  if (!is.data.frame(ped) || nrow(ped) == 0L ||
        !all(c("id", "sire", "dam", "gen") %in% names(ped)) ||
        !is.character(ped$id) || !is.character(ped$sire) ||
        !is.character(ped$dam)) {
    return(NULL)
  }
  gen <- ped$gen
  if (!is.numeric(gen) || is.object(gen) || anyNA(gen) ||
        !all(is.finite(gen) & gen >= 0L & gen == trunc(gen))) {
    return(NULL)
  }
  if (anyNA(ped$id) || !all(nzchar(ped$id)) || anyDuplicated(ped$id) > 0L) {
    return(NULL)
  }
  later <- gen >= 1L
  sire <- match(ped$sire[later], ped$id)
  dam <- match(ped$dam[later], ped$id)
  if (anyNA(sire) || anyNA(dam) || any(gen[sire] >= gen[later]) ||
        any(gen[dam] >= gen[later])) {
    return(NULL)
  }
  ego <- match(ped$id, ids)
  sireRow <- match(ped$sire, ids)
  damRow <- match(ped$dam, ids)
  lapply(seq_len(max(gen)), function(i) {
    rows <- which(gen == i)
    list(ego = ego[rows], sire = sireRow[rows], dam = damRow[rows])
  })
}

#' Today's founder-contribution fill, for any pedigree
#'
#' \code{calcFounderContributions()}'s generation loop before performance plan
#' Phase 5, word for word: one animal at a time, its row found by name.
#' \code{founderContributionMatrix()} calls it for a pedigree it does not
#' fill by position, which keeps that pedigree's result, error and warnings.
#'
#' @inheritParams founderContributionMatrix
#' @return As \code{founderContributionMatrix()}.
#' @noRd
founderContributionMatrixGeneral <- function(ped, founders, descendants) {
  ## Built here for the reason given in founderContributionMatrix().
  d <- initialContributions(founders, descendants)
  ## Note: skips generation 0.
  ## The references inside matrix d do not work if ped$sire and ped$dam and
  ## thus gen$sire and gen$dam are factors. See test_calcFE.R
  for (i in seq_len(max(ped$gen))) {
    gen <- ped[(ped$gen == i), ]

    for (j in seq_len(nrow(gen))) {
      ego <- gen$id[j]
      sire <- gen$sire[j]
      dam <- gen$dam[j]
      ## Mendelian 1/2: an individual's founder contributions are the mean of
      ## its two parents' (each parent transmits half of its genome).
      d[ego, ] <- (d[sire, ] + d[dam, ]) / 2L
    }
  }
  d
}

#' The founder-contribution matrix before the fill
#'
#' One row per animal, the founders first, and one column per founder: each
#' founder's row is its own column 1 and the rest 0, and every descendant's row
#' is 0. Built directly as one matrix of doubles, the same matrix as the
#' founders' identity block bound above the descendants' zero block.
#'
#' @inheritParams founderContributionMatrix
#' @return The matrix, with the ids as row names and the founders as column
#' names.
#' @noRd
initialContributions <- function(founders, descendants) {
  n <- length(founders)
  d <- matrix(0.0, nrow = n + length(descendants), ncol = n,
              dimnames = list(c(founders, descendants), founders))
  d[cbind(seq_len(n), seq_len(n))] <- 1.0
  d
}
