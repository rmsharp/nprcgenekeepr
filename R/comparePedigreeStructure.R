## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Extract kinship2's parent-child and mate-pair structure
#'
#' Re-derives the parent-child edge set and mate-pair list a kinship2
#' \code{pedigree} object implies, from its plain \code{id}/\code{findex}/
#' \code{mindex} vectors alone (\code{findex}/\code{mindex} are 1-based
#' positions into \code{id}, or \code{0} for an unknown parent). This is
#' Track A of a programmatic structural/topological comparison against
#' \code{\link{makePedigreeMatingLayout}}'s own output (Track B); see
#' \code{docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md}
#' sections 3.1/4.1.
#'
#' Deliberately typed to this minimal plain-list shape rather than the
#' \code{kinship2::pedigree} S3 class -- dispatching on that class would pull
#' a \code{kinship2} dependency into package code for no benefit, since only
#' these fields are ever read. A real \code{kinship2::pedigree()} object
#' satisfies this contract structurally, with no special-casing.
#'
#' The mate-pair derivation re-implements, verbatim, the unexported
#' \code{spouselist} logic inside kinship2's own \code{align.pedigree()}
#' (\code{any(findex > 0 & mindex > 0)}, deduplicated by
#' \code{(findex, mindex)} pair) -- not invented logic.
#'
#' @param pedLike a plain list with \code{id} (vector, any type coercible to
#'   character), \code{findex} (integer vector, same length as \code{id}),
#'   and \code{mindex} (integer vector, same length as \code{id}).
#' @return A list with two data frames: \code{parentChildEdges} (\code{child},
#'   \code{parent}, \code{role} -- \code{role} is \code{"father"} or
#'   \code{"mother"}); \code{matePairs} (\code{parent1}, \code{parent2},
#'   \code{nChildren} -- one row per distinct \code{(findex, mindex)} pair
#'   with at least one child, deduplicated so multiple shared children never
#'   inflate the row count).
#' @noRd
.extractKinship2Structure <- function(pedLike) {
  hasFather <- pedLike$findex > 0L
  hasMother <- pedLike$mindex > 0L
  parentChildEdges <- rbind(
    data.frame(child = pedLike$id[hasFather],
               parent = pedLike$id[pedLike$findex[hasFather]],
               role = rep("father", sum(hasFather)),
               stringsAsFactors = FALSE),
    data.frame(child = pedLike$id[hasMother],
               parent = pedLike$id[pedLike$mindex[hasMother]],
               role = rep("mother", sum(hasMother)),
               stringsAsFactors = FALSE)
  )

  hasBoth <- hasFather & hasMother
  pairKey <- paste(pedLike$findex[hasBoth], pedLike$mindex[hasBoth],
                    sep = "_")
  keep <- !duplicated(pairKey)
  matePairs <- data.frame(
    parent1 = pedLike$id[pedLike$findex[hasBoth][keep]],
    parent2 = pedLike$id[pedLike$mindex[hasBoth][keep]],
    nChildren = as.integer(table(pairKey)[pairKey[keep]]),
    stringsAsFactors = FALSE
  )

  list(parentChildEdges = parentChildEdges, matePairs = matePairs)
}
