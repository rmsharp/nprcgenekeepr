## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .orderRootSubtrees() -- the root-subtree ordering pass (Shape A),
## Migration Path Phase 1: standalone, NOT yet wired into
## .positionMatingUnitForest().
## Design: docs/planning/pedigree-diagram-root-subtree-ordering-plan.md (S688).
## The S689 PRE-RED gate ratified the design's two owner choices -- seed =
## reverse Cuthill-McKee (not spectral), calibration = Tier-1 BJL geometry
## only (not the QP-solved pass-1 layout) -- and declined Open Question 5's
## "<4 roots" guard, so Track C's order is expected to change (its full-layout
## positions are identical either way, design Evidence 4).
##
## Contract under test (design Decision 1's interface table + Decisions 2-4):
## .orderRootSubtrees(rootIds, childrenOf, matingUnits, duplicates, minSep,
##                    maxSweeps = 20L)
## returns a permutation of rootIds; identical(out, rootIds) whenever
## length(rootIds) <= 2, or no connector joins two different roots, or no
## candidate strictly beats the incoming order's rigid-block proxy (strict
## -1e-9 acceptance). Pure, no RNG/eigen()/solve.QP(); bitwise reproducible.
##
## Every pinned expectation below was DERIVED BY EXECUTION of the design's
## reference instrument against the unmodified engine (scratchpad/s688_m5.R
## via s688_realize_rcm.R, re-derived with the engine-style per-component
## construction in s689_subset_derive.R -- the two constructions agree
## exactly: rigid-block proxy incoming 3742.375 -> RCM seed 2968.875 ->
## 1 sweep 2112.875 -> converged 1935.875 raw units, 5 sweeps), never
## hand-derived.

## ---- input construction: mirror of .positionMatingUnitForest() :884-983 ---
## Builds exactly the arguments the Phase 2 call site will pass: this
## component's rootIds (ped row order), the childrenOf() closure, and the
## forest tables. Kept as a test-local mirror because Phase 1 tests the pass
## standalone, before any engine wiring exists.
orderPassInputs <- function(ped, forest = .buildMatingUnitForest(ped)) {
  matingUnits <- forest$matingUnits
  childEdges <- forest$childEdges
  ids <- as.character(ped$id)
  sireOf <- stats::setNames(as.character(ped$sire), ids)
  damOf <- stats::setNames(as.character(ped$dam), ids)
  hasParentEdge <- function(id) !is.na(sireOf[[id]]) || !is.na(damOf[[id]])
  directChildrenOf <- function(id) {
    childEdges$to[childEdges$from == id & childEdges$from %in% ids]
  }
  hasOwnDirectChild <- function(id) length(directChildrenOf(id)) > 0L
  anchorOf <- stats::setNames(matingUnits$anchor, matingUnits$id)
  unitChildrenOf <- function(id) {
    myUnits <- matingUnits$id[!is.na(anchorOf) & anchorOf == id]
    if (length(myUnits) == 0L) return(character(0L))
    unlist(lapply(myUnits, function(u) childEdges$to[childEdges$from == u]),
           use.names = FALSE)
  }
  childrenOf <- function(id) c(directChildrenOf(id), unitChildrenOf(id))
  anchoredUnits <- matingUnits[!is.na(matingUnits$anchor), , drop = FALSE]
  everAnchor <- unique(anchoredUnits$anchor)
  neverAnchorIds <- setdiff(unique(c(anchoredUnits$sire, anchoredUnits$dam)),
                            everAnchor)
  b1Ids <- Filter(function(id) {
    id %in% ids && !hasOwnDirectChild(id) && !hasParentEdge(id)
  }, neverAnchorIds)
  founderIds <- Filter(function(id) !hasParentEdge(id), ids)
  orphanUnitIds <- matingUnits$id[is.na(matingUnits$anchor)]
  orphanChildIds <- if (length(orphanUnitIds) > 0L) {
    unique(unlist(lapply(orphanUnitIds, function(u) {
      childEdges$to[childEdges$from == u]
    }), use.names = FALSE))
  } else {
    character(0L)
  }
  rootIds <- union(setdiff(founderIds, b1Ids), orphanChildIds)
  list(rootIds = rootIds, childrenOf = childrenOf,
       matingUnits = matingUnits, duplicates = forest$duplicates)
}

## Realized Tier-1-level connector span (raw units) for a given root order:
## rebuild the Tier-1 BJL layout under that order and sum |x(dup proxy) -
## x(real)| over every duplicate whose unit has an anchor with a Tier-1 x
## and whose real occurrence has one. Intra-root terms are constant across
## root orders (a subtree's internal BJL geometry does not depend on its
## siblings), so a strict decrease measures cross-root improvement.
tier1ConnectorSpan <- function(rootIds, childrenOf, matingUnits, duplicates) {
  fc <- .buildForestChildrenOf(rootIds, childrenOf,
                               superRootId = "__super_root__")
  t1 <- .positionTreeApportion("__super_root__", fc)
  t1 <- t1[names(t1) != "__super_root__"]
  anchorOf <- stats::setNames(matingUnits$anchor, matingUnits$id)
  anch <- unname(anchorOf[duplicates$matingUnitId])
  ok <- !is.na(anch) & anch %in% names(t1) & duplicates$realId %in% names(t1)
  sum(abs(unname(t1[anch[ok]]) - unname(t1[duplicates$realId[ok]])))
}

## The real 375-animal bundled fixture's 50-root component: the design's
## measured target (design Evidence 6: components 2/1/1/3/50 roots; every
## pinned order below is for this component, incoming = ped row order).
real375BigComponentInputs <- function() {
  ped <- utils::read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE)
  iso <- .findIsolatedIds(ped, NULL)
  ped <- ped[!ped$id %in% iso, , drop = FALSE]
  rownames(ped) <- NULL
  forest <- .buildMatingUnitForest(ped)
  comps <- .forestComponents(ped, forest)
  big <- comps[[which.max(vapply(comps, function(m) {
    sum(m %in% as.character(ped$id))
  }, integer(1L)))]]
  pedBig <- ped[as.character(ped$id) %in% big, , drop = FALSE]
  orderPassInputs(pedBig, .subsetForest(forest, big))
}

## The pinned RCM-searched order (converged, 5 sweeps < maxSweeps default),
## printed by scratchpad/s688_realize_rcm.R and reproduced exactly by the
## engine-style construction (s689_subset_derive.R).
pinnedRcmOrder <- c(
  "YCVRXE", "C1BAND", "C3V2V6", "IYYFP6", "3XP1ZD", "8ZK9LV", "0FKJ81",
  "UYZ1DD", "IP1TGT", "LVP52A", "LWV138", "L2I39Y", "TUILLQ", "A3A34I",
  "8DKELJ", "CBLNYE", "G8EBU9", "Q8MRCZ", "4EEKV7", "6S4HCB", "7U5H8G",
  "5GQC24", "EZ97J5", "R3BBV1", "BM40IX", "1ZERVB", "B948B1", "KWKJXQ",
  "AE08C8", "UUNQ4J", "HDJ52R", "I8ABQE", "ZK6NM2", "C3IFT0", "RXPJPP",
  "C2YD43", "HCY8QM", "IX0KKP", "BD7MNF", "RJHF0G", "P87V3K", "97Y192",
  "FG9RYY", "E2D59U", "RKBTHH", "ESZ6I3", "DPUHBA", "LVS6QV", "WUPTU8",
  "GYQNV5")

## The anytime incumbents under a sweep cap (design Decision 3: one sweep =
## every pairwise swap, then every single-block move, first-improvement).
## maxSweeps = 0 is the RCM seed itself (accepted: its proxy 2968.875 beats
## the incoming 3742.375); maxSweeps = 1 is the cut after one full sweep.
pinnedRcmSeedOrder <- c(
  "8ZK9LV", "L2I39Y", "ESZ6I3", "C3V2V6", "C1BAND", "IYYFP6", "WUPTU8",
  "BM40IX", "UYZ1DD", "AE08C8", "KWKJXQ", "EZ97J5", "IP1TGT", "LVP52A",
  "3XP1ZD", "YCVRXE", "A3A34I", "7U5H8G", "TUILLQ", "4EEKV7", "LWV138",
  "6S4HCB", "5GQC24", "UUNQ4J", "RKBTHH", "HDJ52R", "B948B1", "ZK6NM2",
  "RXPJPP", "0FKJ81", "CBLNYE", "R3BBV1", "C3IFT0", "G8EBU9", "97Y192",
  "1ZERVB", "8DKELJ", "Q8MRCZ", "I8ABQE", "HCY8QM", "RJHF0G", "IX0KKP",
  "C2YD43", "FG9RYY", "E2D59U", "P87V3K", "DPUHBA", "LVS6QV", "BD7MNF",
  "GYQNV5")
pinnedRcmOneSweepOrder <- c(
  "C3V2V6", "AE08C8", "IYYFP6", "YCVRXE", "KWKJXQ", "3XP1ZD", "8ZK9LV",
  "LVP52A", "LWV138", "R3BBV1", "IP1TGT", "UYZ1DD", "TUILLQ", "0FKJ81",
  "Q8MRCZ", "A3A34I", "L2I39Y", "CBLNYE", "8DKELJ", "7U5H8G", "6S4HCB",
  "EZ97J5", "1ZERVB", "5GQC24", "B948B1", "4EEKV7", "UUNQ4J", "BM40IX",
  "I8ABQE", "RKBTHH", "HDJ52R", "C1BAND", "ZK6NM2", "RJHF0G", "RXPJPP",
  "C3IFT0", "G8EBU9", "C2YD43", "HCY8QM", "IX0KKP", "BD7MNF", "P87V3K",
  "97Y192", "FG9RYY", "E2D59U", "ESZ6I3", "DPUHBA", "LVS6QV", "WUPTU8",
  "GYQNV5")

## ---- (i)/(vii) identity on the five packing fixtures ----------------------
test_that(".orderRootSubtrees() returns its input order unchanged --
           identical() -- on the five kinship2-verified packing fixtures
           (Track B full, Track B shrunk, D1, D2, D3): none has a
           cross-root duplicate connector, so the no-connector early exit
           fires and the byte-identity invariant is preserved by
           construction", {
  pedB <- data.frame(
    id   = c("P1", "P2", "P3", "P4", "P5", "P6",
             "C1", "C2", "C3", "C4", "C4a",
             "G3", "M1", "L1", "L2", "L3"),
    sire = c(NA, NA, NA, NA, NA, NA,
             "P1", "P1", "P1", "P3", "C4",
             NA, "P1", "M1", "M1", "M1"),
    dam  = c(NA, NA, NA, NA, NA, NA,
             "P2", "P2", "P2", "P4", "P6",
             NA, "P2", "G3", "G3", "G3"),
    sex  = c("M", "F", "M", "F", "F", "F",
             "F", "M", "F", "M", "F",
             "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  pedB$gen <- findGeneration(pedB$id, pedB$sire, pedB$dam)
  genotypedB <- c(P1 = TRUE, P2 = TRUE, P3 = FALSE, P4 = FALSE, P5 = TRUE,
    P6 = TRUE, C1 = TRUE, C2 = FALSE, C3 = TRUE, C4 = TRUE, C4a = TRUE,
    G3 = FALSE, M1 = TRUE, L1 = TRUE, L2 = TRUE, L3 = TRUE)[pedB$id]
  affectedB <- c(P1 = NA, P2 = NA, P3 = NA, P4 = NA, P5 = NA, P6 = NA,
    C1 = FALSE, C2 = NA, C3 = TRUE, C4 = TRUE, C4a = TRUE, G3 = NA,
    M1 = TRUE, L1 = NA, L2 = FALSE, L3 = TRUE)[pedB$id]
  pedBShrunk <- shrinkPedigree(pedB, genotypedB, affected = affectedB,
                               maxBits = 1L)$ped
  pedBShrunk$gen <- findGeneration(pedBShrunk$id, pedBShrunk$sire,
                                   pedBShrunk$dam)
  pedD1 <- data.frame(
    id   = c("F1", "M1", "A1", "S1", "K1", "K2", "K3", "K4",
             "F2", "M2", "B1"),
    sire = c(NA, NA, "F1", NA, "S1", "S1", "S1", "S1", NA, NA, "F2"),
    dam  = c(NA, NA, "M1", NA, "A1", "A1", "A1", "A1", NA, NA, "M2"),
    sex  = c("M", "F", "F", "M", "M", "F", "M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  pedD1$gen <- findGeneration(pedD1$id, pedD1$sire, pedD1$dam)
  pedD2 <- data.frame(
    id   = c("A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"),
    sire = c(NA, NA, "A1", NA, NA, "B1", NA, NA, "C1"),
    dam  = c(NA, NA, "A2", NA, NA, "B2", NA, NA, "C2"),
    sex  = c("M", "F", "F", "M", "F", "M", "M", "F", "F"),
    stringsAsFactors = FALSE
  )
  pedD2$gen <- findGeneration(pedD2$id, pedD2$sire, pedD2$dam)
  pedD3 <- data.frame(
    id   = c("A1", "A2", "A3", "B1", "B2", "B3", "B4", "B5"),
    sire = c(NA, NA, "A1", NA, NA, "B1", "B3", NA),
    dam  = c(NA, NA, "A2", NA, NA, "B2", "B5", NA),
    sex  = c("M", "F", "F", "M", "F", "M", "F", "F"),
    stringsAsFactors = FALSE
  )
  pedD3$gen <- findGeneration(pedD3$id, pedD3$sire, pedD3$dam)

  fixtures <- list("Track B full" = pedB, "Track B shrunk" = pedBShrunk,
                   D1 = pedD1, D2 = pedD2, D3 = pedD3)
  for (nm in names(fixtures)) {
    inp <- orderPassInputs(fixtures[[nm]])
    out <- .orderRootSubtrees(inp$rootIds, inp$childrenOf, inp$matingUnits,
                              inp$duplicates, minSep = 1L)
    expect_identical(out, inp$rootIds, label = nm)
  }
})

## ---- (ii) Track C reorders (the ratified no-guard choice) ------------------
test_that(".orderRootSubtrees() reorders Track C's three roots P1,X,W to
           X,P1,W -- the S688-measured searched order (Tier-1-level span
           600 -> 360 px; the full layout's positions are identical either
           way, design Evidence 4, so no Open-Question-5 guard is
           applied)", {
  pedC <- data.frame(
    id   = c("P1", "P2", "A", "Y", "X", "W", "C1", "C2", "GC"),
    sire = c(NA, NA, "P1", "P1", NA, NA, "A", "Y", "A"),
    dam  = c(NA, NA, "P2", "P2", NA, NA, "X", "W", "Y"),
    sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M"),
    gen  = c(0L, 0L, 1L, 1L, 3L, 1L, 4L, 2L, 2L),
    stringsAsFactors = FALSE
  )
  inp <- orderPassInputs(pedC)
  ## Precondition, derived from the engine's own root assembly: P2 is B1
  ## (never-anchor, childless, parentless), so the roots are P1, X, W in
  ## ped row order.
  expect_identical(inp$rootIds, c("P1", "X", "W"))

  out <- .orderRootSubtrees(inp$rootIds, inp$childrenOf, inp$matingUnits,
                            inp$duplicates, minSep = 1L)
  expect_identical(out, c("X", "P1", "W"))
})

## ---- (iii) Real 375: pinned permutation + strict proxy improvement --------
test_that(".orderRootSubtrees() on Real 375's 50-root component returns
           the pinned RCM-searched permutation of its rootIds and strictly
           reduces the realized Tier-1-level connector span (measured
           3001.25 -> 1604.125 raw units)", {
  inp <- real375BigComponentInputs()
  expect_length(inp$rootIds, 50L)

  out <- .orderRootSubtrees(inp$rootIds, inp$childrenOf, inp$matingUnits,
                            inp$duplicates, minSep = 1L)

  ## a permutation: same elements, same length, not the incoming order
  expect_setequal(out, inp$rootIds)
  expect_length(out, length(inp$rootIds))
  expect_false(identical(out, inp$rootIds))

  ## the exact deterministic result (reference-instrument derived)
  expect_identical(out, pinnedRcmOrder)

  ## the ordering objective it optimizes, observed implementation-
  ## externally: realized Tier-1 connector span strictly improves
  spanBefore <- tier1ConnectorSpan(inp$rootIds, inp$childrenOf,
                                   inp$matingUnits, inp$duplicates)
  spanAfter <- tier1ConnectorSpan(out, inp$childrenOf,
                                  inp$matingUnits, inp$duplicates)
  expect_lt(spanAfter, spanBefore)
})

## ---- (iv) determinism ------------------------------------------------------
test_that(".orderRootSubtrees() is deterministic -- two identical calls on
           Real 375's 50-root component return identical() orders (pure
           function, no RNG, no eigen(), no solve.QP())", {
  inp <- real375BigComponentInputs()
  out1 <- .orderRootSubtrees(inp$rootIds, inp$childrenOf, inp$matingUnits,
                             inp$duplicates, minSep = 1L)
  out2 <- .orderRootSubtrees(inp$rootIds, inp$childrenOf, inp$matingUnits,
                             inp$duplicates, minSep = 1L)
  expect_identical(out1, out2)
})

## ---- (v) maxSweeps respected ----------------------------------------------
test_that(".orderRootSubtrees() respects maxSweeps as an anytime cutoff on
           Real 375's 50-root component: 0 returns the accepted RCM seed
           itself, 1 returns the incumbent after exactly one
           swap-then-move sweep, both valid permutations distinct from the
           converged order (which needs 5 sweeps); the default (20) equals
           an explicit maxSweeps = 20L", {
  inp <- real375BigComponentInputs()

  outDefault <- .orderRootSubtrees(inp$rootIds, inp$childrenOf,
                                   inp$matingUnits, inp$duplicates,
                                   minSep = 1L)
  out20 <- .orderRootSubtrees(inp$rootIds, inp$childrenOf, inp$matingUnits,
                              inp$duplicates, minSep = 1L, maxSweeps = 20L)
  expect_identical(outDefault, out20)

  out0 <- .orderRootSubtrees(inp$rootIds, inp$childrenOf, inp$matingUnits,
                             inp$duplicates, minSep = 1L, maxSweeps = 0L)
  out1 <- .orderRootSubtrees(inp$rootIds, inp$childrenOf, inp$matingUnits,
                             inp$duplicates, minSep = 1L, maxSweeps = 1L)

  expect_setequal(out0, inp$rootIds)
  expect_setequal(out1, inp$rootIds)
  expect_identical(out0, pinnedRcmSeedOrder)
  expect_identical(out1, pinnedRcmOneSweepOrder)
  expect_false(identical(out0, outDefault))
  expect_false(identical(out1, outDefault))
})

## ---- (vi) the stop() contract ---------------------------------------------
test_that(".orderRootSubtrees() stop()s on a non-character, NA-containing,
           or empty rootIds, matching .buildForestChildrenOf()'s own guard
           wording style; the other arguments are never reached", {
  emptyUnits <- data.frame(id = character(), sire = character(),
                           dam = character(), anchor = character(),
                           nonAnchor = character(), gen = integer(),
                           stringsAsFactors = FALSE)
  emptyDups <- data.frame(id = character(), realId = character(),
                          matingUnitId = character(),
                          stringsAsFactors = FALSE)
  noKids <- function(id) character(0L)

  expect_error(
    .orderRootSubtrees(1:3, noKids, emptyUnits, emptyDups, minSep = 1L),
    "requires 'rootIds' to be a non-empty character vector with no NA")
  expect_error(
    .orderRootSubtrees(c("R1", NA), noKids, emptyUnits, emptyDups,
                       minSep = 1L),
    "requires 'rootIds' to be a non-empty character vector with no NA")
  expect_error(
    .orderRootSubtrees(character(0L), noKids, emptyUnits, emptyDups,
                       minSep = 1L),
    "requires 'rootIds' to be a non-empty character vector with no NA")
})

## ---- (vii) early exits and dropped connectors ------------------------------
test_that(".orderRootSubtrees() early-exits to identity when k <= 2 even
           with a cross-root connector present, and drops intra-root and
           anchorless-unit connectors from the objective (identity, no
           error) -- design Decision 1's contract and failure-mode table",
          {
  ## k = 2 with a genuine cross-root connector: identity purely by the
  ## k <= 2 exit (a 2-block ordering objective is symmetric -- |a - b|
  ## is unchanged by swapping two blocks -- so searching is pointless).
  kids2 <- function(id) {
    switch(id, R1 = "A", R2 = "B", character(0L))
  }
  units2 <- data.frame(id = "__union_1", sire = "B", dam = "Zd",
                       anchor = "B", nonAnchor = "Zd", gen = 1L,
                       stringsAsFactors = FALSE)
  dups2 <- data.frame(id = "__dup_A_1", realId = "A",
                      matingUnitId = "__union_1",
                      stringsAsFactors = FALSE)
  out2 <- .orderRootSubtrees(c("R1", "R2"), kids2, units2, dups2,
                             minSep = 1L)
  expect_identical(out2, c("R1", "R2"))

  ## k = 3, connectors present but none joins two DIFFERENT roots: one
  ## intra-root connector (both endpoints under R1) and one at an
  ## anchorless (orphan, issue #154) unit -- both dropped, identity, and
  ## never an error (design failure-mode table: such connectors are
  ## "simply not counted").
  kids3 <- function(id) {
    switch(id, R1 = c("A", "B"), character(0L))
  }
  units3 <- data.frame(id = c("__union_1", "__union_2"),
                       sire = c("A", "Zs"), dam = c("Zd", "Zd2"),
                       anchor = c("A", NA), nonAnchor = c("Zd", NA),
                       gen = c(1L, 1L),
                       stringsAsFactors = FALSE)
  dups3 <- data.frame(id = c("__dup_B_1", "__dup_C_1"),
                      realId = c("B", "C"),
                      matingUnitId = c("__union_1", "__union_2"),
                      stringsAsFactors = FALSE)
  out3 <- .orderRootSubtrees(c("R1", "R2", "R3"), kids3, units3, dups3,
                             minSep = 1L)
  expect_identical(out3, c("R1", "R2", "R3"))
})
