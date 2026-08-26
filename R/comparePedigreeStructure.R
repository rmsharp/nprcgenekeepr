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

#' Extract nprcgenekeepr's parent-child and mate-pair structure
#'
#' Re-derives the same real-individual-level relationship set
#' \code{\link{.extractKinship2Structure}} (Track A) reads from a kinship2
#' \code{pedigree} object, this time from
#' \code{\link{makePedigreeMatingLayout}}'s own \code{"direct"}-style
#' \code{nodes}/\code{edges}/\code{duplicateToReal} return value. This is
#' Track B of a programmatic structural/topological comparison against
#' kinship2; see
#' \code{docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md}
#' sections 3.2/4.2.
#'
#' Callers \strong{must} pass the return value of
#' \code{makePedigreeMatingLayout(ped, edgeStyle = "direct", twinRelations =
#' NULL)} -- this function does not walk \code{"rectilinear"}-style
#' waypoint chains (\code{__drop_}/\code{__bar_}/\code{__proj_}/\code{__jog_}
#' ids); that is the D-2 edgeStyle-invariance property test's own job
#' (\code{tests/testthat/test_comparePedigreeStructure.R}), not this
#' function's runtime responsibility (plan section 3.2).
#'
#' Edge classification mirrors \code{makePedigreeMatingLayout()}'s own
#' construction exactly (re-verified directly against
#' \code{R/makePedigreeDiagramData.R} this session, not assumed from the
#' plan's own illustrative pseudocode): \code{mateEdges$to} is always a
#' \code{__union_} id; a duplicate-node connector is uniquely marked by
#' \code{dashes == TRUE & smooth.type == "curvedCW"}; every other edge is a
#' child edge, whose \code{from} is either a \code{__union_} id (both
#' parents known -- the common case, expanded to 2 rows via the matching
#' mate pair) or a real/duplicate parent id directly (the D5
#' single-known-parent fallback, passed through as one row). Every
#' \code{__dup_} id is resolved to its real individual via
#' \code{duplicateToReal} before being returned.
#'
#' @param layout the return value of \code{makePedigreeMatingLayout(ped,
#'   edgeStyle = "direct", twinRelations = NULL)} -- a list with
#'   \code{nodes}, \code{edges} (\code{from}, \code{to}, \code{dashes},
#'   \code{smooth.type} at minimum), and \code{duplicateToReal}.
#' @return A list with two data frames, in the SAME shape as
#'   \code{\link{.extractKinship2Structure}}'s own return value --
#'   deliberately, so \code{.comparePedigreeStructures()} (Track C) is
#'   agnostic to which side is which: \code{parentChildEdges} (\code{child},
#'   \code{parent}, both real individual ids); \code{matePairs}
#'   (\code{parent1}, \code{parent2}, \code{nChildren} -- one row per
#'   distinct real-individual mate pair with at least one child, counted
#'   from the assembled \code{parentChildEdges}, never left \code{NA}).
#' @noRd
.extractNprcStructure <- function(layout) {
  edges <- layout$edges
  duplicateToReal <- layout$duplicateToReal
  resolveId <- function(id) {
    hit <- match(id, names(duplicateToReal))
    ifelse(is.na(hit), id, unname(duplicateToReal[hit]))
  }

  isMateEdge <- startsWith(edges$to, "__union_")
  isDupEdge <- !isMateEdge & edges$dashes &
    !is.na(edges$smooth.type) & edges$smooth.type == "curvedCW"
  isChildEdge <- !isMateEdge & !isDupEdge

  mateEdges <- edges[isMateEdge, c("from", "to")]
  childEdges <- edges[isChildEdge, c("from", "to")]

  # matePairs: group mate edges by the union id they share (`to`) --
  # exactly 2 per union in this codebase (anchor + non-anchor), but
  # length < 2L is skipped defensively rather than assumed impossible.
  mateEdges$parent <- resolveId(mateEdges$from)
  bySplit <- split(mateEdges$parent, mateEdges$to)
  matePairs <- do.call(rbind, lapply(names(bySplit), function(unionId) {
    parents <- bySplit[[unionId]]
    if (length(parents) < 2L) return(NULL)
    data.frame(parent1 = parents[[1L]], parent2 = parents[[2L]],
               unionId = unionId, stringsAsFactors = FALSE)
  }))
  if (is.null(matePairs)) {
    matePairs <- data.frame(parent1 = character(), parent2 = character(),
                             unionId = character(), stringsAsFactors = FALSE)
  }

  # parentChildEdges: a union-sourced child edge expands to 2 rows (one per
  # resolved mate, looked up by unionId); a D5 real/dup-sourced edge passes
  # through as a single row.
  isUnionSourced <- startsWith(childEdges$from, "__union_")
  unionChild <- childEdges[isUnionSourced, ]
  directChild <- childEdges[!isUnionSourced, ]

  pcFromUnion <- if (nrow(unionChild) > 0L) {
    matchIdx <- match(unionChild$from, matePairs$unionId)
    data.frame(child = rep(resolveId(unionChild$to), 2L),
               parent = c(matePairs$parent1[matchIdx],
                          matePairs$parent2[matchIdx]),
               stringsAsFactors = FALSE)
  } else {
    data.frame(child = character(), parent = character(),
               stringsAsFactors = FALSE)
  }
  pcFromDirect <- if (nrow(directChild) > 0L) {
    data.frame(child = resolveId(directChild$to),
               parent = resolveId(directChild$from),
               stringsAsFactors = FALSE)
  } else {
    data.frame(child = character(), parent = character(),
               stringsAsFactors = FALSE)
  }
  parentChildEdges <- rbind(pcFromUnion, pcFromDirect)

  # nChildren counted from the assembled child edges (plan section 4.2's
  # own hardening note: "should be counted from parentChildEdges after
  # assembly, not left NA") -- one union-sourced child edge per child, so
  # table() on unionChild$from gives exactly nChildren per union.
  nChildrenByUnion <- table(unionChild$from)
  matePairs$nChildren <- as.integer(nChildrenByUnion[matePairs$unionId])
  matePairs$unionId <- NULL

  list(parentChildEdges = parentChildEdges, matePairs = matePairs)
}

#' Diff two pedigree structural extractions
#'
#' Compares two \code{list(parentChildEdges, matePairs)} structures in the
#' shared output shape of \code{\link{.extractKinship2Structure}} (Track A)
#' and \code{\link{.extractNprcStructure}} (Track B) -- deliberately agnostic
#' to which side is kinship2 vs. nprcgenekeepr (either argument order gives
#' the same \code{identical} verdict, with A/B swapped in the "only in"
#' fields). This is Track C of a programmatic structural/topological
#' comparison against kinship2; see
#' \code{docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md}
#' sections 3.3/4.3.
#'
#' Canonicalizes each side before comparing (plan section 1.3's fifth fact:
#' neither package treats sire/dam left-right order as meaningful, so a
#' comparator must never assert positional/x-order equivalence) -- for
#' \code{matePairs}, \code{parent1}/\code{parent2} are sorted alphabetically
#' per row so \code{(A, B)} and \code{(B, A)} compare equal; rows in both
#' tables are then compared as unordered sets (a row present in A but not B,
#' or vice versa), never via positional \code{identical()}.
#'
#' @param a,b each a list with \code{parentChildEdges} (\code{child},
#'   \code{parent}) and \code{matePairs} (\code{parent1}, \code{parent2},
#'   \code{nChildren}) data frames, in \code{\link{.extractKinship2Structure}}/
#'   \code{\link{.extractNprcStructure}}'s shared output shape.
#' @return A list: \code{parentChildOnlyInA}, \code{parentChildOnlyInB},
#'   \code{matePairsOnlyInA}, \code{matePairsOnlyInB} (each a data frame, in
#'   the same shape as the corresponding input table, of rows found on only
#'   one side); \code{identical} (\code{TRUE} iff all 4 of the above are
#'   zero-row).
#' @noRd
.comparePedigreeStructures <- function(a, b) {
  canonicalizeParentChild <- function(pc) {
    pc <- pc[order(pc$child, pc$parent), c("child", "parent")]
    rownames(pc) <- NULL
    pc
  }
  canonicalizeMatePairs <- function(mp) {
    lo <- pmin(mp$parent1, mp$parent2)
    hi <- pmax(mp$parent1, mp$parent2)
    out <- data.frame(parent1 = lo, parent2 = hi, nChildren = mp$nChildren,
                       stringsAsFactors = FALSE)
    out <- out[order(out$parent1, out$parent2), ]
    rownames(out) <- NULL
    out
  }
  pcKey <- function(pc) paste(pc$child, pc$parent, sep = "|")
  mateKey <- function(mp) {
    paste(mp$parent1, mp$parent2, mp$nChildren, sep = "|")
  }

  pcA <- canonicalizeParentChild(a$parentChildEdges)
  pcB <- canonicalizeParentChild(b$parentChildEdges)
  mpA <- canonicalizeMatePairs(a$matePairs)
  mpB <- canonicalizeMatePairs(b$matePairs)

  pcOnlyA <- pcA[!pcKey(pcA) %in% pcKey(pcB), , drop = FALSE]
  pcOnlyB <- pcB[!pcKey(pcB) %in% pcKey(pcA), , drop = FALSE]
  mpOnlyA <- mpA[!mateKey(mpA) %in% mateKey(mpB), , drop = FALSE]
  mpOnlyB <- mpB[!mateKey(mpB) %in% mateKey(mpA), , drop = FALSE]

  list(
    parentChildOnlyInA = pcOnlyA,
    parentChildOnlyInB = pcOnlyB,
    matePairsOnlyInA = mpOnlyA,
    matePairsOnlyInB = mpOnlyB,
    identical = nrow(pcOnlyA) == 0L && nrow(pcOnlyB) == 0L &&
      nrow(mpOnlyA) == 0L && nrow(mpOnlyB) == 0L
  )
}
