## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Shared founder-contribution computation for calcFE/calcFG/calcFEFG
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
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
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

  d <- matrix(0L, nrow = length(descendants), ncol = length(founders))
  colnames(d) <- founders
  rownames(d) <- descendants

  founderMatrix <- diag(length(founders))
  colnames(founderMatrix) <- rownames(founderMatrix) <- founders

  d <- rbind(founderMatrix, d)
  ## Free the founders-by-founders identity block before the generation loop:
  ## it has been copied into d above and is never referenced again.
  founderMatrix <- NULL
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

  currentDesc <- ped$id[ped$population & !(ped$id %in% founders)]
  d <- d[currentDesc, ]
  p <- colMeans(d)

  list(p = p, ped = ped)
}
