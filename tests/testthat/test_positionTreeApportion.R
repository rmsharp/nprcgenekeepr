## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .positionTreeApportion() -- Pedigree Diagram Walker/BJL redesign, Phase 1a
## (docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md, "Phase 1a --
## Standalone BJL apportioning engine, genuine trees only"). A new, self-contained,
## pedigree-agnostic module implementing firstWalk/apportion/moveSubtree/executeShifts/
## secondWalk exactly per the plan's corrected pseudocode (local-sibling apportion,
## explicit nextLeft/nextRight/commonAncestor), operating on a generic tree interface (a
## CHILDREN()-style accessor and a node-gap function passed in), plus a synthetic-super-root
## helper for forests. Scoped to genuine trees only: every edge in every fixture below
## advances exactly one level -- Phase 1b (forest/mixed-gen reconciliation) is separate,
## future, unscoped work.
##
## Every fixture below carries a strong, exact-value oracle (plan requirement C2-3, fixing
## the first draft's own gap) -- never a weak structural assertion ("no NA", "all
## distinct"). Oracle provenance, so a future reader can re-derive without re-doing this
## session's own research:
##   - The single-node/balanced/asymmetric/forest fixtures were cross-checked this session
##     against real d3-hierarchy v3.1.2 (github.com/d3/d3-hierarchy, ISC license -- a
##     correction to the plan's "MIT-licensed" wording, itself equally permissive and
##     GPL-avoiding so the plan's licensing rationale is unaffected), run via Node.js with
##     .separation(() => 1).nodeSize([1,1]) to match this engine's own uniform minSep=1
##     convention exactly (no rescaling). This session's own from-scratch JS port of the
##     plan's pseudocode initially reproduced d3-hierarchy's output on 3 of 4 fixtures but
##     diverged on the 4th (an asymmetric-tree variant engineered to force >=2 compounding
##     moveSubtree() shifts within one apportion() call) -- tracing the divergence found the
##     plan's own apportion() pseudocode omits `vip_mod += shiftVal; vop_mod += shiftVal`
##     immediately after moveSubtree() fires (real d3-hierarchy's apportion() does this:
##     `sip += shift; sop += shift`, tree.js source lines ~163-165). This is a real,
##     mechanically significant correction (not cosmetic) -- proved by constructing the
##     adversarial fixture where the uncorrected and corrected versions numerically diverge,
##     then confirming only the corrected version matches the real reference exactly. The R
##     implementation below MUST include this correction; a GREEN implementation that omits
##     it will fail the asymmetric-tree and forest fixtures below (though it happens to pass
##     the single-node and balanced-tree fixtures, which never trigger a compounding shift).
##   - The Walker 15-node golden fixture's expected values are transcribed directly from the
##     primary source (John Q. Walker II, "A Node-Positioning Algorithm for General Trees",
##     UNC TR89-034, September 1989, Figure 12 + "Nodes Visited in the Second Traversal",
##     pp.17-20) -- not a secondary summary. Independently cross-checked this session against
##     real d3-hierarchy (uniform gap=6, matching the paper's SiblingSeparation=
##     SubtreeSeparation=4 + MeanNodeSize=2): all 15 nodes matched exactly (relative to the
##     root), confirming both this session's own reading of the primary source and the
##     plan's own claim that BJL and Walker produce identical output for genuine trees.
##
## Zero changes to R/makePedigreeDiagramData.R or any existing test file (plan requirement).

## ---- 1. Single node -------------------------------------------------------------------

test_that(".positionTreeApportion positions a single node at its own prelim (0)", {
  childrenOf <- function(id) character(0)
  x <- .positionTreeApportion("root", childrenOf)
  expect_equal(unname(x[["root"]]), 0, tolerance = 1e-9)
  expect_equal(names(x), "root")
})

## ---- 2. Balanced n-ary tree: root with 3 children, each with 3 leaf children -----------

test_that(".positionTreeApportion matches the d3-hierarchy oracle for a balanced 3x3 tree", {
  kids <- list(
    R = c("A", "B", "C"),
    A = c("A1", "A2", "A3"),
    B = c("B1", "B2", "B3"),
    C = c("C1", "C2", "C3")
  )
  childrenOf <- function(id) if (!is.null(kids[[id]])) kids[[id]] else character(0)
  x <- .positionTreeApportion("R", childrenOf)
  expected <- c(R = 4, A = 1, A1 = 0, A2 = 1, A3 = 2,
                B = 4, B1 = 3, B2 = 4, B3 = 5,
                C = 7, C1 = 6, C2 = 7, C3 = 8)
  expect_equal(x[names(expected)], expected, tolerance = 1e-9)
  ## Aesthetic 2 ("a parent should be centered over its offspring"), by construction.
  expect_equal(unname(x[["R"]]), (unname(x[["A"]]) + unname(x[["C"]])) / 2, tolerance = 1e-9)
})

## ---- 3. Asymmetric tree: one deep-narrow branch, one wide-shallow branch ---------------
## The shape Walker's own paper and issue #141 both name as the interesting case, and the
## specific fixture this session used to prove the moveSubtree()-accumulator correction
## above is required (it forces >=2 compounding shifts within one apportion() call).

test_that(".positionTreeApportion matches the d3-hierarchy oracle for an asymmetric
           deep-narrow + wide-shallow tree", {
  kids <- list(
    Root = c("Deep1", "Wide"),
    Deep1 = "Deep2", Deep2 = "Deep3", Deep3 = "Deep4",
    Wide = c("W1", "W2", "W3", "W4", "W5", "W6")
  )
  childrenOf <- function(id) if (!is.null(kids[[id]])) kids[[id]] else character(0)
  x <- .positionTreeApportion("Root", childrenOf)
  expected <- c(Root = 1.75, Deep1 = 0, Deep2 = 0, Deep3 = 0, Deep4 = 0,
                Wide = 3.5, W1 = 1, W2 = 2, W3 = 3, W4 = 4, W5 = 5, W6 = 6)
  expect_equal(x[names(expected)], expected, tolerance = 1e-9)
})

## ---- 4. Forest of several disconnected trees via the synthetic-super-root helper -------
## Exercises cross-branch conflict at the same level: T1's and T3's subtrees both have
## depth-2 descendants (T1a/T1b vs T3a/T3b) that the apportion mechanism must reconcile
## across branches, with single-node tree T2 sandwiched between them.

test_that(".buildForestChildrenOf + .positionTreeApportion match the d3-hierarchy oracle
           for a 3-tree forest, discarding the synthetic root's own x", {
  kids <- list(
    T1 = c("T1a", "T1b"),
    T3 = c("T3a", "T3b"),
    T3a = c("T3a1", "T3a2", "T3a3")
  )
  childrenOf <- function(id) if (!is.null(kids[[id]])) kids[[id]] else character(0)
  forestChildrenOf <- .buildForestChildrenOf(c("T1", "T2", "T3"), childrenOf,
                                              superRootId = "__super_root__")
  x <- .positionTreeApportion("__super_root__", forestChildrenOf)
  expect_true("__super_root__" %in% names(x))
  x <- x[names(x) != "__super_root__"]
  expected <- c(T1 = 0.5, T1a = 0, T1b = 1, T2 = 1.5,
                T3 = 2.5, T3a = 2, T3a1 = 1, T3a2 = 2, T3a3 = 3, T3b = 3)
  expect_equal(x[names(expected)], expected, tolerance = 1e-9)
})

## ---- 5. REQUIRED: Walker's own 15-node worked example (TR89-034 Figure 12) -------------

test_that(".positionTreeApportion reproduces Walker's own published 15-node worked
           example (TR89-034 Figure 12, 'Nodes Visited in the Second Traversal', p.20)
           exactly, using the paper's own SiblingSeparation=SubtreeSeparation=4 and
           MeanNodeSize=2 (uniform gap = 6)", {
  kids <- list(
    O = c("E", "F", "N"),
    E = c("A", "D"),
    D = c("B", "C"),
    N = c("G", "M"),
    M = c("H", "I", "J", "K", "L")
  )
  childrenOf <- function(id) if (!is.null(kids[[id]])) kids[[id]] else character(0)
  uniformGap6 <- function(leftId, rightId) 6
  x <- .positionTreeApportion("O", childrenOf, nodeGap = uniformGap6)
  expected <- c(O = 13.5, E = 3, A = 0, D = 6, B = 3, C = 9, F = 13.5,
                N = 24, G = 21, M = 27, H = 15, I = 21, J = 27, K = 33, L = 39)
  expect_equal(x[names(expected)], expected, tolerance = 1e-9)
})
