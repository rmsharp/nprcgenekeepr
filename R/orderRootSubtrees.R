## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Root-subtree ordering pass (Shape A), Migration Path Phase 1 --
## docs/planning/pedigree-diagram-root-subtree-ordering-plan.md (S688;
## implemented S689 under the PRE-RED-gate-ratified choices: reverse
## Cuthill-McKee seed, Tier-1 BJL calibration, no "<4 roots" guard).
## Standalone in this phase: nothing calls it yet -- Phase 2 inserts the
## one call between rootIds assembly and .buildForestChildrenOf() in
## .positionMatingUnitForest() (R/makePedigreeDiagramData.R).
##
## Placed beside R/positionTreeApportion.R per the same "standalone engine
## file" precedent: like the BJL engine it is pure, deterministic, and free
## of eigen()/solve.QP()/RNG, so every arithmetic step is plain IEEE double
## (bitwise reproducible across the 3-OS CI matrix -- the design's central
## determinism argument).

#' Reorder a component's root subtrees to shorten duplicate connectors
#'
#' The left-to-right order of a component's founder subtrees is inherited
#' from ped row order -- an arbitrary input property -- and on real colony
#' pedigrees nearly all curved duplicate-connector ink is cross-root-subtree
#' (design \verb{SS}Context: 125 of Real 375's 127 connectors). This pass
#' permutes \code{rootIds} so that subtrees joined by many connectors sit
#' near each other, and returns the incoming order untouched whenever there
#' is nothing to gain.
#'
#' Method (design Decisions 2-4): calibrate block widths and connector
#' endpoints once from a Tier-1 BJL layout of the \emph{incoming} order
#' (\code{\link{.positionTreeApportion}}; a duplicate's endpoint is proxied
#' at its mating unit's anchor); lay blocks left-to-right with a
#' \code{minSep} gap as a rigid-block proxy of the final layout; seed with
#' reverse Cuthill-McKee on the root connector graph; refine by
#' first-improvement swap/move sweeps (at most \code{maxSweeps}); accept
#' only on strict (\code{-1e-9}) proxy improvement over the incoming order.
#' One round -- the pass never recalibrates on its own output (measured to
#' diverge, design \verb{SS}Evidence 3).
#'
#' @param rootIds character vector, the component's root ids in incoming
#'   (ped row) order.
#' @param childrenOf function(id) -> character vector: the engine's
#'   CHILDREN() closure over real individuals and anchored mating units.
#' @param matingUnits this component's forest mating-unit table
#'   (\code{\link{.buildMatingUnitForest}}).
#' @param duplicates this component's forest duplicate table; each row is
#'   one connector (duplicate occurrence to real individual).
#' @param minSep the engine's raw-unit minimum same-row separation (the
#'   inter-block gap in the rigid proxy).
#' @param maxSweeps integer, local-search sweep cap (one sweep = every
#'   pairwise swap, then every single-block move). The search is anytime:
#'   the incumbent at any cutoff is a valid order.
#' @return A permutation of \code{rootIds}; \code{identical()} to it when
#'   \code{length(rootIds) <= 2}, when no connector joins two different
#'   roots, or when no candidate strictly beats the incoming order's proxy.
#' @noRd
.orderRootSubtrees <- function(rootIds, childrenOf, matingUnits, duplicates,
                               minSep, maxSweeps = 20L) {
  if (!(is.character(rootIds) && length(rootIds) > 0L && !anyNA(rootIds))) {
    stop(".orderRootSubtrees() requires 'rootIds' to be a non-empty ",
         "character vector with no NA.")
  }
  k <- length(rootIds)
  ## A 2-block objective is symmetric under swapping, so k <= 2 has
  ## nothing to search (and the five kinship2-verified packing fixtures
  ## stay identity by construction).
  if (k <= 2L) {
    return(rootIds)
  }

  ## ---- root membership (structure only; no layout yet) -------------------
  subtreeIds <- function(id) {
    kids <- childrenOf(id)
    c(id, unlist(lapply(kids, subtreeIds), use.names = FALSE))
  }
  rootMembers <- lapply(rootIds, function(r) unique(subtreeIds(r)))
  names(rootMembers) <- rootIds
  rootOf <- new.env(parent = emptyenv())
  for (r in rootIds) {
    for (m in rootMembers[[r]]) {
      if (is.null(rootOf[[m]])) rootOf[[m]] <- r
    }
  }
  rootOrNa <- function(id) {
    r <- rootOf[[id]]
    if (is.null(r)) NA_character_ else r
  }

  ## One connector per duplicate row; its duplicate endpoint lives at its
  ## mating unit's anchor. A connector at an anchorless (orphan) unit, or
  ## whose endpoint reaches no root, is simply not counted -- never an
  ## error (design failure-mode table).
  anchorOf <- stats::setNames(matingUnits$anchor, matingUnits$id)
  anch <- as.character(unname(anchorOf[duplicates$matingUnitId]))
  rootDup <- vapply(anch, function(a) {
    if (is.na(a)) NA_character_ else rootOrNa(a)
  }, character(1L), USE.NAMES = FALSE)
  rootReal <- vapply(as.character(duplicates$realId), rootOrNa,
                     character(1L), USE.NAMES = FALSE)
  crossRoot <- !is.na(rootDup) & !is.na(rootReal) & rootDup != rootReal
  if (!any(crossRoot)) {
    return(rootIds)
  }

  ## ---- Tier-1 BJL calibration from the INCOMING order (Decision 2) -------
  forestChildrenOf <- .buildForestChildrenOf(rootIds, childrenOf,
                                             superRootId = "__super_root__")
  tier1X <- .positionTreeApportion("__super_root__", forestChildrenOf)
  tier1X <- tier1X[names(tier1X) != "__super_root__"]

  ## Rigid blocks: left/width from the Tier-1 x range of each root's real
  ## members (units/duplicates carry no Tier-1 x of their own; a duplicate's
  ## anchor proxy always lies inside its subtree's span).
  blockRange <- lapply(rootMembers, function(m) {
    m <- m[m %in% names(tier1X)]
    if (length(m) == 0L) c(NA_real_, NA_real_) else range(unname(tier1X[m]))
  })
  blockWidth <- vapply(blockRange, function(r) r[2L] - r[1L], numeric(1L))
  blockLeft <- vapply(blockRange, function(r) r[1L], numeric(1L))
  ## A root with no Tier-1-rendered member contributes no width.
  blockWidth[is.na(blockWidth)] <- 0.0

  ## Connector endpoints as offsets from their block's left edge, so they
  ## ride with the block under reordering; endpoints without a Tier-1 x
  ## (e.g. a B1 free-pass real) drop out of the objective.
  usable <- crossRoot & !is.na(anch) & anch %in% names(tier1X) &
    duplicates$realId %in% names(tier1X)
  if (!any(usable)) {
    return(rootIds)
  }
  connRootDup <- rootDup[usable]
  connRootReal <- rootReal[usable]
  connOffDup <- unname(tier1X[anch[usable]]) - blockLeft[connRootDup]
  connOffReal <- unname(tier1X[as.character(duplicates$realId)[usable]]) -
    blockLeft[connRootReal]

  ## ---- rigid-block proxy objective (Decision 2) ---------------------------
  proxyOf <- function(o) {
    lefts <- cumsum(c(0.0, utils::head(blockWidth[o] + minSep, -1L)))
    names(lefts) <- o
    sum(abs((lefts[connRootDup] + connOffDup) -
              (lefts[connRootReal] + connOffReal)))
  }

  ## ---- reverse Cuthill-McKee seed (Decision 3, integer arithmetic) --------
  w <- matrix(0L, k, k, dimnames = list(rootIds, rootIds))
  for (i in seq_along(connRootDup)) {
    a <- connRootDup[i]
    b <- connRootReal[i]
    w[a, b] <- w[a, b] + 1L
    w[b, a] <- w[b, a] + 1L
  }
  deg <- rowSums(w > 0L)
  visited <- rep(FALSE, k)
  ord <- integer(0L)
  while (length(ord) < k) {
    unvisited <- which(!visited)
    ## min-degree start, ties by current position; an unconnected root
    ## starts its own trivial BFS, so such roots trail in current order.
    start <- unvisited[order(deg[unvisited], unvisited)][1L]
    queue <- start
    visited[start] <- TRUE
    while (length(queue) > 0L) {
      v <- queue[1L]
      queue <- queue[-1L]
      ord <- c(ord, v)
      nb <- which(w[v, ] > 0L & !visited)
      nb <- nb[order(deg[nb], nb)]
      visited[nb] <- TRUE
      queue <- c(queue, nb)
    }
  }
  incumbent <- rootIds[rev(ord)]

  ## ---- first-improvement local search, sweep-capped (Decision 3) ----------
  val <- proxyOf(incumbent)
  sweeps <- 0L
  improved <- TRUE
  while (improved && sweeps < maxSweeps) {
    improved <- FALSE
    sweeps <- sweeps + 1L
    for (i in seq_len(k - 1L)) {
      for (j in (i + 1L):k) {
        cand <- incumbent
        cand[c(i, j)] <- cand[c(j, i)]
        candVal <- proxyOf(cand)
        if (candVal < val - 1e-9) {
          incumbent <- cand
          val <- candVal
          improved <- TRUE
        }
      }
    }
    for (i in seq_len(k)) {
      for (j in seq_len(k)) {
        if (i == j) next
        cand <- append(incumbent[-i], incumbent[i], after = j - 1L)
        candVal <- proxyOf(cand)
        if (candVal < val - 1e-9) {
          incumbent <- cand
          val <- candVal
          improved <- TRUE
        }
      }
    }
  }

  ## ---- strict acceptance: prefer the incoming order (Decision 3) ----------
  if (val < proxyOf(rootIds) - 1e-9) {
    incumbent
  } else {
    rootIds
  }
}
