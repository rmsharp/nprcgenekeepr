## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Standalone, pedigree-agnostic Buchheim-Junger-Leipert (BJL) tree-apportioning
## engine -- Pedigree Diagram Walker/BJL redesign, Phase 1a
## (docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md,
## "Phase 1a -- Standalone BJL apportioning engine, genuine trees only").
## Implements firstWalk/apportion/moveSubtree/executeShifts/secondWalk per the
## plan's corrected pseudocode (local-sibling apportion, explicit
## nextLeft/nextRight/commonAncestor), on a generic tree interface (a
## CHILDREN()-style accessor + a node-gap function, both passed in) --
## pedigree-agnostic by design, zero dependency on any nprcgenekeepr pedigree
## structure, zero changes to R/makePedigreeDiagramData.R. Scoped to genuine
## trees only: every edge in every caller's input tree must advance exactly
## one level (Phase 1b's own forest/mixed-gen reconciliation problem is
## separate, future, unscoped work -- see the plan's "Decision" section).
##
## This session found and corrected one real defect in the plan's own
## apportion() pseudocode via the required cross-check against d3-hierarchy's
## actual source (github.com/d3/d3-hierarchy, ISC license -- a correction to
## the plan's own "MIT-licensed" wording, itself equally permissive and
## GPL-avoiding so the plan's licensing rationale is unaffected -- v3.1.2
## src/tree.js): the plan omits `vip_mod += shiftVal; vop_mod += shiftVal`
## immediately after moveSubtree() fires. Real d3-hierarchy's apportion() does
## this (`sip += shift; sop += shift`, tree.js lines ~163-165) -- proved
## mechanically necessary, not cosmetic, by constructing an adversarial
## fixture (2+ compounding shifts within one apportion() call) where the
## corrected and uncorrected versions numerically diverge, then confirming
## only the corrected version matches the real reference exactly. See
## tests/testthat/test_positionTreeApportion.R's own header for the full
## research provenance (primary-source Walker TR89-034 extraction,
## d3-hierarchy cross-checks, exact-value oracles for every fixture).

## ---- generic tree discovery: build a mutable node-per-id environment once --

.newApportionNode <- function(id, parentId, number, children) {
  node <- new.env(parent = emptyenv())
  node$id <- id
  node$parent <- parentId
  node$number <- number       ## 0-based index among its own siblings
  ## character vec, left-to-right; character(0) for a leaf.
  node$children <- children
  node$prelim <- 0L
  node$mod <- 0L
  node$shift <- 0L
  node$change <- 0L
  ## contour bookkeeping pointer; defaults to the node itself.
  node$ancestor <- id
  node$thread <- NULL         ## contour-jump pointer, character(1) or NULL
  node
}

.discoverApportionTree <- function(rootId, childrenOf) {
  nodes <- new.env(parent = emptyenv())
  build <- function(id, parentId, number) {
    kids <- childrenOf(id)
    assign(id, .newApportionNode(id, parentId, number, kids), envir = nodes)
    if (length(kids) > 0L) {
      for (i in seq_along(kids)) build(kids[i], id, i - 1L)
    }
  }
  build(rootId, NULL, 0L)
  nodes
}

## ---- BJL-standard helper accessors (corrected pseudocode, C2-6) ------------

.nextRightApportion <- function(nodes, id) {
  n <- nodes[[id]]
  if (length(n$children) > 0L) return(n$children[[length(n$children)]])
  n$thread
}

.nextLeftApportion <- function(nodes, id) {
  n <- nodes[[id]]
  if (length(n$children) > 0L) return(n$children[[1L]])
  n$thread
}

.leftSiblingApportion <- function(nodes, id) {
  n <- nodes[[id]]
  if (is.null(n$parent) || n$number == 0L) return(NULL)
  ## n$number is 0-based; the sibling one position left is at 1-based index
  ## n$number.
  nodes[[n$parent]]$children[[n$number]]
}

.commonAncestorApportion <- function(nodes, vimId, vId, defaultAncestorId) {
  vim <- nodes[[vimId]]
  ancestorParent <- nodes[[vim$ancestor]]$parent
  if (identical(ancestorParent, nodes[[vId]]$parent)) {
    vim$ancestor
  } else {
    defaultAncestorId
  }
}

## ---- moveSubtree / executeShifts --------------------------------------------

.moveSubtreeApportion <- function(nodes, wLeftId, wRightId, shiftVal) {
  wLeft <- nodes[[wLeftId]]
  wRight <- nodes[[wRightId]]
  n <- wRight$number - wLeft$number
  wRight$change <- wRight$change - shiftVal / n
  wRight$shift <- wRight$shift + shiftVal
  wLeft$change <- wLeft$change + shiftVal / n
  wRight$prelim <- wRight$prelim + shiftVal
  wRight$mod <- wRight$mod + shiftVal
}

.executeShiftsApportion <- function(nodes, vId) {
  kids <- nodes[[vId]]$children
  s <- 0L
  c <- 0L
  for (i in rev(seq_along(kids))) {
    child <- nodes[[kids[[i]]]]
    child$prelim <- child$prelim + s
    child$mod <- child$mod + s
    c <- c + child$change
    s <- s + child$shift + c
  }
}

## ---- apportion: local-sibling comparison-partner sourcing (corrected) ----

.apportionNode <- function(nodes, vId, defaultAncestorId, nodeGap) {
  wId <- .leftSiblingApportion(nodes, vId)
  if (is.null(wId)) return(defaultAncestorId)

  v <- nodes[[vId]]
  siblings <- nodes[[v$parent]]$children
  vipId <- vId
  vopId <- vId
  vimId <- wId
  vomId <- siblings[[1L]]

  vipMod <- nodes[[vipId]]$mod
  vopMod <- nodes[[vopId]]$mod
  vimMod <- nodes[[vimId]]$mod
  vomMod <- nodes[[vomId]]$mod

  repeat {
    nrVim <- .nextRightApportion(nodes, vimId)
    nlVip <- .nextLeftApportion(nodes, vipId)
    if (is.null(nrVim) || is.null(nlVip)) break

    vimId <- nrVim
    vipId <- nlVip
    vomId <- .nextLeftApportion(nodes, vomId)
    vopId <- .nextRightApportion(nodes, vopId)
    nodes[[vopId]]$ancestor <- vId

    vim <- nodes[[vimId]]
    vip <- nodes[[vipId]]
    gap <- nodeGap(vimId, vipId)
    shiftVal <- (vim$prelim + vimMod) - (vip$prelim + vipMod) + gap
    if (shiftVal > 0L) {
      commonAncestorId <- .commonAncestorApportion(nodes, vimId, vId,
                                                     defaultAncestorId)
      .moveSubtreeApportion(nodes, commonAncestorId, vId, shiftVal)
      ## The correction found this session (see file header): without these
      ## two lines, a later loop iteration's shiftVal computation uses stale
      ## modifier sums, diverging from the real BJL/d3-hierarchy reference
      ## whenever a second moveSubtree() fires within one apportion() call.
      vipMod <- vipMod + shiftVal
      vopMod <- vopMod + shiftVal
    }
    vimMod <- vimMod + vim$mod
    vipMod <- vipMod + vip$mod
    vom <- nodes[[vomId]]
    vop <- nodes[[vopId]]
    vomMod <- vomMod + vom$mod
    vopMod <- vopMod + vop$mod
  }

  nrVim <- .nextRightApportion(nodes, vimId)
  if (!is.null(nrVim) && is.null(.nextRightApportion(nodes, vopId))) {
    nodes[[vopId]]$thread <- nrVim
    nodes[[vopId]]$mod <- nodes[[vopId]]$mod + (vimMod - vopMod)
  }
  nlVip <- .nextLeftApportion(nodes, vipId)
  if (!is.null(nlVip) && is.null(.nextLeftApportion(nodes, vomId))) {
    nodes[[vomId]]$thread <- nlVip
    nodes[[vomId]]$mod <- nodes[[vomId]]$mod + (vipMod - vomMod)
    defaultAncestorId <- vId
  }
  defaultAncestorId
}

## ---- firstWalk / secondWalk -----------------------------------------------

.firstWalkApportion <- function(nodes, vId, nodeGap) {
  v <- nodes[[vId]]
  kids <- v$children
  if (length(kids) == 0L) {
    wId <- .leftSiblingApportion(nodes, vId)
    v$prelim <- if (is.null(wId)) {
      0L
    } else {
      nodes[[wId]]$prelim + nodeGap(wId, vId)
    }
    return(invisible(NULL))
  }

  defaultAncestorId <- kids[[1L]]
  for (c in kids) {
    .firstWalkApportion(nodes, c, nodeGap)
    defaultAncestorId <- .apportionNode(nodes, c, defaultAncestorId, nodeGap)
  }
  .executeShiftsApportion(nodes, vId)

  firstKid <- nodes[[kids[[1L]]]]
  lastKid <- nodes[[kids[[length(kids)]]]]
  midpoint <- (firstKid$prelim + lastKid$prelim) / 2L

  wId <- .leftSiblingApportion(nodes, vId)
  if (!is.null(wId)) {
    v$prelim <- nodes[[wId]]$prelim + nodeGap(wId, vId)
    v$mod <- v$prelim - midpoint
  } else {
    ## Aesthetic 4, "parent centered over children," by construction.
    v$prelim <- midpoint
  }
  invisible(NULL)
}

.secondWalkApportion <- function(nodes, vId, accumMod, out) {
  v <- nodes[[vId]]
  assign(vId, v$prelim + accumMod, envir = out)
  for (c in v$children) {
    .secondWalkApportion(nodes, c, accumMod + v$mod, out)
  }
  invisible(NULL)
}

## ---- public (internal, non-exported) entry points -------------------------

.positionTreeApportion <- function(rootId, childrenOf,
                                    nodeGap = function(a, b) 1L) {
  if (!(is.character(rootId) && length(rootId) == 1L && !is.na(rootId))) {
    stop(".positionTreeApportion() requires 'rootId' to be a single, ",
         "non-NA character string.")
  }
  if (!is.function(childrenOf)) {
    stop(".positionTreeApportion() requires 'childrenOf' to be a function.")
  }
  if (!is.function(nodeGap)) {
    stop(".positionTreeApportion() requires 'nodeGap' to be a function.")
  }

  nodes <- .discoverApportionTree(rootId, childrenOf)
  .firstWalkApportion(nodes, rootId, nodeGap)

  out <- new.env(parent = emptyenv())
  .secondWalkApportion(nodes, rootId, 0L, out)
  ids <- ls(out, sorted = FALSE)
  unlist(mget(ids, envir = out, inherits = FALSE), use.names = TRUE)
}

.buildForestChildrenOf <- function(rootIds, childrenOf,
                                    superRootId = "__super_root__") {
  if (!(is.character(rootIds) && length(rootIds) > 0L && !anyNA(rootIds))) {
    stop(".buildForestChildrenOf() requires 'rootIds' to be a non-empty ",
         "character vector with no NA.")
  }
  if (!is.function(childrenOf)) {
    stop(".buildForestChildrenOf() requires 'childrenOf' to be a function.")
  }
  if (superRootId %in% rootIds) {
    stop(".buildForestChildrenOf() requires 'superRootId' to not collide ",
         "with any 'rootIds' entry.")
  }
  function(id) {
    if (identical(id, superRootId)) return(rootIds)
    childrenOf(id)
  }
}
