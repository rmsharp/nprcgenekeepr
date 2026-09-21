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

#' Create one mutable BJL bookkeeping node (internal).
#'
#' Environment-backed so the walks can update \code{prelim}, \code{mod},
#' \code{shift}, \code{change}, \code{ancestor}, and \code{thread} in place.
#'
#' @param id character(1) node id.
#' @param parentId character(1) parent id, or \code{NULL} for the root.
#' @param number 0-based index of this node among its own siblings.
#' @param children character vector of child ids, left-to-right;
#'   \code{character(0)} for a leaf.
#' @return An environment holding the node's BJL walk state.
#' @noRd
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

#' Discover the caller's tree into a node-per-id environment (internal).
#'
#' Depth-first walk from \code{rootId} through the generic \code{childrenOf}
#' accessor; every visited id gets a fresh \code{.newApportionNode()} entry.
#'
#' @param rootId character(1) id of the tree's root.
#' @param childrenOf function(id) returning the ordered character vector of
#'   the node's children (\code{character(0)} for a leaf).
#' @return An environment mapping each node id to its mutable BJL node.
#' @noRd
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

#' Next node down the right contour of a subtree (internal).
#'
#' BJL \code{nextRight()}: the last child when one exists, else the node's
#' \code{thread} pointer (\code{NULL} when the contour ends).
#'
#' @param nodes the node environment from \code{.discoverApportionTree()}.
#' @param id character(1) node id.
#' @return character(1) id of the next right-contour node, or \code{NULL}.
#' @noRd
.nextRightApportion <- function(nodes, id) {
  n <- nodes[[id]]
  if (length(n$children) > 0L) return(n$children[[length(n$children)]])
  n$thread
}

#' Next node down the left contour of a subtree (internal).
#'
#' BJL \code{nextLeft()}: the first child when one exists, else the node's
#' \code{thread} pointer (\code{NULL} when the contour ends).
#'
#' @param nodes the node environment from \code{.discoverApportionTree()}.
#' @param id character(1) node id.
#' @return character(1) id of the next left-contour node, or \code{NULL}.
#' @noRd
.nextLeftApportion <- function(nodes, id) {
  n <- nodes[[id]]
  if (length(n$children) > 0L) return(n$children[[1L]])
  n$thread
}

#' The sibling immediately to the left of a node (internal).
#'
#' @param nodes the node environment from \code{.discoverApportionTree()}.
#' @param id character(1) node id.
#' @return character(1) id of the left sibling, or \code{NULL} when the
#'   node is the root or its parent's leftmost child.
#' @noRd
.leftSiblingApportion <- function(nodes, id) {
  n <- nodes[[id]]
  if (is.null(n$parent) || n$number == 0L) return(NULL)
  ## n$number is 0-based; the sibling one position left is at 1-based index
  ## n$number.
  nodes[[n$parent]]$children[[n$number]]
}

#' Pick the shift partner for a contour overlap (internal).
#'
#' BJL \code{ancestor()}: \code{vim}'s recorded \code{ancestor} when that
#' ancestor is still a sibling of \code{v} (their parents match), else the
#' running \code{defaultAncestorId}.
#'
#' @param nodes the node environment from \code{.discoverApportionTree()}.
#' @param vimId character(1) id of the left-contour comparison node.
#' @param vId character(1) id of the node being apportioned.
#' @param defaultAncestorId character(1) current default ancestor id.
#' @return character(1) id of the ancestor sibling to shift against.
#' @noRd
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

#' Shift a subtree right to resolve a contour overlap (internal).
#'
#' BJL \code{moveSubtree()}: moves the subtree rooted at \code{wRightId}
#' right by \code{shiftVal}, recording per-node \code{shift} and
#' \code{change} amounts so \code{.executeShiftsApportion()} can spread the
#' spacing adjustment evenly across the intermediate siblings.
#'
#' @param nodes the node environment from \code{.discoverApportionTree()}.
#' @param wLeftId character(1) id of the left (ancestor) sibling.
#' @param wRightId character(1) id of the sibling subtree being moved.
#' @param shiftVal numeric(1) distance to move right.
#' @return Called for its side effects on \code{nodes}.
#' @noRd
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

#' Apply accumulated shift/change amounts to a node's children (internal).
#'
#' BJL \code{executeShifts()}: one right-to-left pass over \code{vId}'s
#' children folding the aggregated \code{shift} and \code{change}
#' bookkeeping into each child's \code{prelim} and \code{mod}.
#'
#' @param nodes the node environment from \code{.discoverApportionTree()}.
#' @param vId character(1) id of the parent whose children are adjusted.
#' @return Called for its side effects on \code{nodes}.
#' @noRd
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

#' Apportion one node against its left-sibling subtrees (internal).
#'
#' The BJL core: walks the contours of \code{vId}'s subtree and its left
#' siblings' subtrees in lock-step and, wherever the left contour of
#' \code{vId}'s subtree overlaps a left sibling's right contour, fires
#' \code{.moveSubtreeApportion()} with the separating shift. Includes the
#' post-\code{moveSubtree} modifier correction (the \code{vipMod} and
#' \code{vopMod} increments) documented in this file's header -- required to
#' match the real d3-hierarchy reference when two shifts compound within one
#' call.
#'
#' @param nodes the node environment from \code{.discoverApportionTree()}.
#' @param vId character(1) id of the node being apportioned.
#' @param defaultAncestorId character(1) current default ancestor id.
#' @param nodeGap function(leftId, rightId) returning the minimum horizontal
#'   gap between the two nodes.
#' @return character(1) the (possibly updated) default ancestor id.
#' @noRd
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

#' Bottom-up first walk: compute preliminary x and modifiers (internal).
#'
#' BJL \code{firstWalk()}: post-order recursion assigning each node a
#' \code{prelim} x (leaves packed left-to-right; parents centered over
#' their children -- Aesthetic 4) and a \code{mod} carried down to its
#' descendants, apportioning each child against its left siblings as the
#' recursion returns.
#'
#' @param nodes the node environment from \code{.discoverApportionTree()}.
#' @param vId character(1) id of the subtree root to walk.
#' @param nodeGap function(leftId, rightId) returning the minimum horizontal
#'   gap between the two nodes.
#' @return \code{invisible(NULL)}; works by side effect on \code{nodes}.
#' @noRd
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

#' Top-down second walk: write final x positions (internal).
#'
#' BJL \code{secondWalk()}: pre-order recursion writing each node's final
#' x -- its \code{prelim} plus the accumulated ancestor modifiers -- into
#' \code{out}.
#'
#' @param nodes the node environment from \code{.discoverApportionTree()}.
#' @param vId character(1) id of the subtree root to walk.
#' @param accumMod numeric(1) sum of the ancestor \code{mod} values above
#'   \code{vId}.
#' @param out environment collecting id to final-x assignments.
#' @return \code{invisible(NULL)}; works by side effect on \code{out}.
#' @noRd
.secondWalkApportion <- function(nodes, vId, accumMod, out) {
  v <- nodes[[vId]]
  assign(vId, v$prelim + accumMod, envir = out)
  for (c in v$children) {
    .secondWalkApportion(nodes, c, accumMod + v$mod, out)
  }
  invisible(NULL)
}

## ---- public (internal, non-exported) entry points -------------------------

#' Position a genuine tree with the BJL apportioning algorithm (internal
#' entry point).
#'
#' Validates its arguments, discovers the tree through the generic
#' \code{childrenOf} accessor, then runs the bottom-up first walk and the
#' top-down second walk. Pedigree-agnostic by design; scoped to genuine
#' trees whose every edge advances exactly one level (see the file header).
#'
#' @param rootId character(1) id of the tree's root.
#' @param childrenOf function(id) returning the ordered character vector of
#'   the node's children (\code{character(0)} for a leaf).
#' @param nodeGap function(leftId, rightId) returning the minimum horizontal
#'   gap between the two nodes; defaults to a constant gap of 1.
#' @return A named numeric vector of final x positions, one element per
#'   discovered node id.
#' @noRd
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

#' Wrap a childrenOf accessor so a forest hangs under one synthetic
#' super-root (internal).
#'
#' Lets \code{.positionTreeApportion()} lay out a multi-root forest as a
#' single tree: the returned accessor reports \code{rootIds} as the
#' children of \code{superRootId} and otherwise delegates to
#' \code{childrenOf}.
#'
#' @param rootIds non-empty character vector of the forest's root ids
#'   (no NA).
#' @param childrenOf function(id) returning the ordered character vector of
#'   the node's children (\code{character(0)} for a leaf).
#' @param superRootId character(1) id for the synthetic super-root; must
#'   not collide with any \code{rootIds} entry.
#' @return A \code{function(id)} suitable as the \code{childrenOf} argument
#'   of \code{.positionTreeApportion()}.
#' @noRd
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
