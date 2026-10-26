## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Kinship of some animals, computed from them and their ancestors only
#'
#' Internal helper for the app's tabs (performance and memory campaign Phase
#' 9; design docs/planning/app-kinship-memory-design.md section 6.1, D5 ruled
#' (c) S1062). A tab asks for the kinship of the animals it uses when the user
#' asks, instead of the app keeping one matrix of every animal for the whole
#' session. A pair's kinship depends only on the two animals' ancestors, so
#' the result is identical to the same cells of the whole pedigree's matrix
#' with the twins and overrides applied (\code{R/appServer.R}).
#'
#' Three rules keep it identical (design section 4.3; owner ruling S1063):
#' \itemize{
#'   \item the pedigree is trimmed with \code{\link{getProbandPedigree}} to
#'     the animals asked for, the animals the overrides name, and their
#'     ancestors, in the pedigree's own row order;
#'   \item MZ twins are grouped on the whole declaration list first (A-B and
#'     B-C make one group), and each group's members in the trimmed pedigree
#'     are declared as a chain; DZ and UZ rows change no value and are kept
#'     when both animals are in the trimmed pedigree;
#'   \item every override is applied as on the whole matrix, so its messages,
#'     warnings and errors are today's; then the matrix is cut to the animals
#'     asked for.
#' }
#'
#' @param ped pedigree data frame with \code{id}, \code{sire} and \code{dam},
#'   and optionally \code{gen}.
#' @param ids character vector of the animals whose kinship is wanted;
#'   \code{NULL} (the default) means every animal. Ids the pedigree does not
#'   hold are left out, as \code{\link{filterKinMatrix}} leaves them out.
#' @param twinRelations validated twin table (\code{id1}, \code{id2},
#'   \code{code}), or \code{NULL}.
#' @param overrides validated kinship-override table (\code{id1}, \code{id2},
#'   \code{kinship}), or \code{NULL}.
#' @return A base numeric matrix of the animals asked for that the pedigree
#'   holds, rows and columns in the pedigree's order and named by id.
#' @noRd
kinshipForAnimals <- function(ped, ids = NULL, twinRelations = NULL,
                              overrides = NULL) {
  if (!is.null(ids)) {
    pedIds <- ped$id
    ped <- getProbandPedigree(union(ids, c(overrides$id1, overrides$id2)),
                              ped)
    twinRelations <- twinRelationsForSet(twinRelations, ped$id, pedIds)
  }
  if (!is.null(ids) && nrow(ped) == 0L) {
    kmat <- matrix(numeric(0L), 0L, 0L,
                   dimnames = list(character(0L), character(0L)))
  } else {
    if (!"gen" %in% names(ped)) {
      ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
    }
    kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen,
                    twinRelations = twinRelations)
  }
  kmat <- applyKinshipOverridesToMatrix(kmat, overrides)
  if (is.null(ids)) kmat else filterKinMatrix(ids, kmat)
}

#' The twin declarations kinship() needs for a trimmed pedigree
#'
#' MZ declarations are grouped on the whole list first, as kinship() groups
#' them (\code{R/kinship.R}): A-B and B-C make A, B and C one group. Each
#' group's members that \code{held} contains are then declared as a chain, so
#' a group whose middle member is not held keeps its correction. DZ and UZ
#' rows are kept when both animals are held.
#'
#' @param twinRelations validated twin table, or \code{NULL}.
#' @param held ids of the trimmed pedigree.
#' @param pedIds ids of the whole pedigree: an MZ declaration naming an id it
#'   does not hold stops with kinship()'s own error, as the whole matrix would.
#' @return A twin table (\code{id1}, \code{id2}, \code{code}), or \code{NULL}
#'   when no row remains.
#' @noRd
twinRelationsForSet <- function(twinRelations, held, pedIds) {
  if (is.null(twinRelations) || nrow(twinRelations) == 0L) {
    return(NULL)
  }
  isMz <- twinRelations$code == "MZ twin"
  mz <- twinRelations[isMz, , drop = FALSE]
  if (!all(c(mz$id1, mz$id2) %in% pedIds)) {
    stop(mzTwinIdsAbsentMessage)
  }
  members <- unique(c(mz$id1, mz$id2))
  group <- mzTwinGroups(match(mz$id1, members), match(mz$id2, members),
                        length(members))
  chains <- lapply(unique(group), function(g) {
    kept <- members[group == g & members %in% held]
    data.frame(id1 = kept[-length(kept)], id2 = kept[-1L],
               code = rep("MZ twin", max(length(kept) - 1L, 0L)),
               stringsAsFactors = FALSE)
  })
  other <- twinRelations[!isMz & twinRelations$id1 %in% held &
                           twinRelations$id2 %in% held,
                         c("id1", "id2", "code"), drop = FALSE]
  rows <- do.call(rbind, c(chains, list(other)))
  if (nrow(rows) == 0L) NULL else rows
}
