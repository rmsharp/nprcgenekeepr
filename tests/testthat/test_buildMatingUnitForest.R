## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .buildMatingUnitForest() -- Pedigree Diagram Option 2, Slice 1
## (docs/planning/pedigree-diagram-option2-layout-design-plan.md D1/D2).
## A pure, internal function performing the CraneFoot-style mating-unit +
## individual-duplication transformation: one mating-unit node per distinct
## (sire, dam) pair with >=1 recorded child, exactly one deterministically
## -chosen anchor parent per unit (D2), and one duplicate node per
## non-anchor occurrence beyond an individual's own first (free) occurrence
## (D1 step 4 / D3 step 4's own combinatorics -- see design doc S459 §7
## correction). Renders nothing; produces the structural input a future
## positioning function (D3, a separate slice) will consume.

## ---- Input validation -----------------------------------------------

test_that(".buildMatingUnitForest rejects non-data-frame input", {
  expect_error(.buildMatingUnitForest(list(a = 1)), "data frame")
})

test_that(".buildMatingUnitForest rejects a pedigree missing required
           columns", {
  noGen <- data.frame(id = "A", sire = NA, dam = NA, sex = "M",
                       stringsAsFactors = FALSE)
  expect_error(.buildMatingUnitForest(noGen), "gen")
})

test_that(".buildMatingUnitForest fails loudly on a real id colliding with
           the '__union_'/'__dup_' reserved prefixes", {
  bad <- data.frame(
    id = c("__union_1", "F1"),
    sire = NA_character_, dam = NA_character_,
    sex = c("F", "M"), gen = 0L,
    stringsAsFactors = FALSE
  )
  expect_error(.buildMatingUnitForest(bad), "__union_")

  bad2 <- data.frame(
    id = c("__dup_X_1", "F1"),
    sire = NA_character_, dam = NA_character_,
    sex = c("F", "M"), gen = 0L,
    stringsAsFactors = FALSE
  )
  expect_error(.buildMatingUnitForest(bad2), "__dup_")
})

test_that(".buildMatingUnitForest fails loudly on a real id colliding with
           the 3 new '__drop_'/'__bar_'/'__proj_' reserved prefixes added
           for the rectilinear waypoint style (issue #142)", {
  badDrop <- data.frame(
    id = c("__drop_1", "F1"),
    sire = NA_character_, dam = NA_character_,
    sex = c("F", "M"), gen = 0L,
    stringsAsFactors = FALSE
  )
  expect_error(.buildMatingUnitForest(badDrop), "__drop_")

  badBar <- data.frame(
    id = c("__bar_C1", "F1"),
    sire = NA_character_, dam = NA_character_,
    sex = c("F", "M"), gen = 0L,
    stringsAsFactors = FALSE
  )
  expect_error(.buildMatingUnitForest(badBar), "__bar_")

  badProj <- data.frame(
    id = c("__proj_X_1", "F1"),
    sire = NA_character_, dam = NA_character_,
    sex = c("F", "M"), gen = 0L,
    stringsAsFactors = FALSE
  )
  expect_error(.buildMatingUnitForest(badProj), "__proj_")
})

## ---- D5 partial-parentage fallback ------------------------------------

test_that(".buildMatingUnitForest creates no mating unit for a 0-parent
           founder, and no child edge", {
  founder <- data.frame(
    id = "F1", sire = NA_character_, dam = NA_character_,
    sex = "F", gen = 0L, stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(founder)
  expect_equal(nrow(result$matingUnits), 0L)
  expect_equal(nrow(result$duplicates), 0L)
  expect_equal(nrow(result$childEdges), 0L)
})

test_that(".buildMatingUnitForest synthesizes no mating unit for a
           sire-only-known child (D5) -- direct one-edge fallback", {
  ped <- data.frame(
    id = c("S1", "C1"),
    sire = c(NA, "S1"), dam = c(NA, NA),
    sex = c("M", "F"), gen = c(0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)
  expect_equal(nrow(result$matingUnits), 0L)
  expect_equal(nrow(result$childEdges), 1L)
  expect_equal(result$childEdges$from, "S1")
  expect_equal(result$childEdges$to, "C1")
})

test_that(".buildMatingUnitForest synthesizes no mating unit for a
           dam-only-known child (D5) -- direct one-edge fallback", {
  ped <- data.frame(
    id = c("D1", "C1"),
    sire = c(NA, NA), dam = c(NA, "D1"),
    sex = c("F", "F"), gen = c(0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)
  expect_equal(nrow(result$matingUnits), 0L)
  expect_equal(nrow(result$childEdges), 1L)
  expect_equal(result$childEdges$from, "D1")
  expect_equal(result$childEdges$to, "C1")
})

## ---- D1 basic mating-unit identification + D1 step 3 re-parenting -----

test_that(".buildMatingUnitForest creates exactly one mating unit for a
           simple 2-parent/1-child trio, with a single re-parented child
           edge (not two edges to sire and dam)", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(trio)
  expect_equal(nrow(result$matingUnits), 1L)
  expect_true(grepl("^__union_", result$matingUnits$id))
  expect_setequal(c(result$matingUnits$sire, result$matingUnits$dam),
                   c("P1", "P2"))
  expect_equal(nrow(result$childEdges), 1L)
  expect_equal(result$childEdges$from, result$matingUnits$id)
  expect_equal(result$childEdges$to, "C1")
})

test_that(".buildMatingUnitForest's mating-unit gen is max(sire.gen,
           dam.gen) (§1.3's verified compatibility fact)", {
  ped <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)
  expect_equal(result$matingUnits$gen, 2L)
})

test_that(".buildMatingUnitForest picks the non-founder parent as anchor
           over a founder parent (D2 rule 1)", {
  ## P1 has exactly one known parent (GP1) -- a non-founder under D2's
  ## definition (>=1 known parent) without synthesizing a second, extraneous
  ## mating unit for GP1's own pairing (D5 fallback covers that one edge).
  ped <- data.frame(
    id = c("GP1", "P1", "P2", "C1"),
    sire = c(NA, "GP1", NA, "P1"),
    dam = c(NA, NA, NA, "P2"),
    sex = c("M", "M", "F", "M"),
    gen = c(0L, 1L, 0L, 2L),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)
  expect_equal(nrow(result$matingUnits), 1L)
  expect_equal(result$matingUnits$anchor, "P1")
  expect_equal(result$matingUnits$nonAnchor, "P2")
})

## ---- D2 anchor tie-breaks ----------------------------------------------

test_that(".buildMatingUnitForest anchors a 2-mate individual at exactly
           1 duplicate node, created at the correct (later-processed)
           mating unit -- both mates are single-mate founders, so the
           fewer-total-mating-units criterion (D2 rule 2) picks each mate
           over the shared multi-mate parent", {
  ped <- data.frame(
    id = c("X", "Y", "Z", "P", "Q"),
    sire = c(NA, NA, NA, "X", "X"),
    dam = c(NA, NA, NA, "Y", "Z"),
    sex = c("M", "F", "F", "F", "F"),
    gen = c(0L, 0L, 0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)
  expect_equal(nrow(result$matingUnits), 2L)
  ## X (mateCount 2) loses to both Y and Z (mateCount 1 each) -> X anchors
  ## neither of his own units.
  expect_false("X" %in% result$matingUnits$anchor)
  expect_setequal(result$matingUnits$anchor, c("Y", "Z"))
  ## X's FIRST-processed unit (X x Y, row order) is his one free
  ## occurrence; only the second (X x Y -> X x Z) gets a duplicate.
  expect_equal(nrow(result$duplicates), 1L)
  expect_equal(result$duplicates$realId, "X")
  unitXZ <- result$matingUnits$id[result$matingUnits$sire == "X" &
                                     result$matingUnits$dam == "Z"]
  expect_equal(result$duplicates$matingUnitId, unitXZ)
})

test_that(".buildMatingUnitForest breaks a full founder/mate-count tie by
           ascending id sort (D2 rule 3)", {
  ped <- data.frame(
    id = c("B1", "A1", "C1"),
    sire = c(NA, NA, "B1"), dam = c(NA, NA, "A1"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)
  expect_equal(result$matingUnits$anchor, "A1")
})

## ---- D1 step 5 / §9 dragon: reconstructed real loop fixture -----------
## GA204Z / 8LKBV9 -- the exact real individuals issue #134 already used
## for loop-safety, extracted from inst/extdata/examples/
## obfuscated_rhesus_mhc_ped.csv (rows 35, 37, 40, 69, 155, 191, 194, 255).
## 8LKBV9 has 3 mates (G8EBU9, 8P17E3, and his own daughter FJIB3R --
## GA204Z's F = 0.25, confirmed by issue #134). The original 6-node
## half-sib fixture cited in the design doc's §8 was never committed to
## the test suite (S453 was audit-only); this 8-node real-data extraction
## is used instead, matching this project's Learning 442 "check bundled
## data first" convention.

test_that(".buildMatingUnitForest resolves the real GA204Z/8LKBV9 loop:
           8LKBV9 anchors exactly 1 of his 3 mating units and is
           duplicated at exactly the other 2 (§1.4)", {
  ped <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)
  ## 4 mating units total: 8LKBV9's own 3 matings, plus (5A6DFT x 8DKELJ)
  ## -- his OWN parents' pairing that produced him.
  expect_equal(nrow(result$matingUnits), 4L)

  kUnits <- result$matingUnits[
    result$matingUnits$sire == "8LKBV9" | result$matingUnits$dam == "8LKBV9",
  ]
  expect_equal(nrow(kUnits), 3L)
  expect_equal(sum(kUnits$anchor == "8LKBV9"), 1L)

  kDuplicates <- result$duplicates[result$duplicates$realId == "8LKBV9", ]
  expect_equal(nrow(kDuplicates), 2L)
  expect_setequal(kDuplicates$matingUnitId,
                   kUnits$id[kUnits$anchor != "8LKBV9"])

  ## 8LKBV9's own duplicated mate FJIB3R still anchors HER one mating
  ## unit (the GA204Z one) -- she is not herself duplicated.
  gaUnit <- result$matingUnits[result$matingUnits$dam == "FJIB3R", ]
  expect_equal(gaUnit$anchor, "FJIB3R")
  expect_equal(nrow(result$duplicates[result$duplicates$realId ==
                                         "FJIB3R", ]), 0L)

  ## The child edges are all re-parented to a mating-unit id, none direct
  ## -- 1 per mating unit (4 total, including 8LKBV9's own birth).
  expect_equal(nrow(result$childEdges), 4L)
  expect_true(all(grepl("^__union_", result$childEdges$from)))
})

## ---- D1 step 5 / §9 dragon: half-sib-mating convergent-loop fixture ---
## Reconstructed equivalent of the original synthetic 6-node half-sib
## fixture cited in the design doc's §8 (never committed to the test
## suite -- S453 was audit-only, per PROJECT_LEARNINGS.md; CHANGELOG.md's
## own description of that session confirms only kinship(A,B) = 0.125 and
## a 6-real-individual shape, not the literal R fixture). F1 mates with
## F2 -> A; F1 mates with F3 -> B (A, B are half-sibs sharing F1); A mates
## with B -> C, closing the loop (kinship(A,B) = 0.125, matching the
## half-sib coefficient cited in that session).

test_that(".buildMatingUnitForest resolves a half-sib-mating convergent
           loop via the same duplication mechanism, duplicating only the
           doubly-mated founder (F1), not A, B, or C", {
  ped <- data.frame(
    id = c("F1", "F2", "F3", "A", "B", "C"),
    sire = c(NA, NA, NA, "F1", "F1", "A"),
    dam = c(NA, NA, NA, "F2", "F3", "B"),
    sex = c("M", "F", "F", "M", "F", "M"),
    gen = c(0L, 0L, 0L, 1L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)
  expect_equal(nrow(result$matingUnits), 3L)
  expect_equal(nrow(result$duplicates), 1L)
  expect_equal(result$duplicates$realId, "F1")
  expect_equal(nrow(result$childEdges), 3L)
  expect_true(all(grepl("^__union_", result$childEdges$from)))
})

## ---- §9 dragon: anchor-collision fallback + full real-fixture check ---

test_that(".buildMatingUnitForest resolves the real anchor-collision case
           (both parents already anchoring a different, earlier unit) by
           letting the individual anchor a second unit -- D3 step 2's own
           'rare case' allowance -- rather than erroring, and the totals
           match this session's corrected §7 figures", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)

  expect_equal(nrow(result$matingUnits), 237L)
  expect_equal(nrow(result$duplicates), 128L)

  ## Every mating unit has exactly one anchor, chosen from its own two
  ## parents (the invariant that always holds unconditionally by
  ## construction -- §9's "explicit assertion" requirement).
  expect_true(all(
    result$matingUnits$anchor == result$matingUnits$sire |
      result$matingUnits$anchor == result$matingUnits$dam
  ))
  expect_false(any(is.na(result$matingUnits$anchor)))

  ## The 2 individuals this session found DO anchor more than one unit
  ## (the rare collision case), verified explicitly rather than assumed.
  anchorCounts <- table(result$matingUnits$anchor)
  multiAnchor <- names(anchorCounts[anchorCounts > 1])
  expect_setequal(multiAnchor, c("KUENM8", "IM1B5T"))
  expect_equal(as.integer(anchorCounts[["KUENM8"]]), 2L)
  expect_equal(as.integer(anchorCounts[["IM1B5T"]]), 2L)
})

## ---- dangling parent references (Slice 3 live-verification finding,
## S461): a sire/dam value with NO OWN ROW in 'ped' -- e.g. a
## focal-animal-trimmed pedigree (R/modPedigree.R's own
## trimPedigree(..., addBackParents = FALSE)) that keeps a blood
## relative's row but not that relative's own mate's row. --------------

test_that(".buildMatingUnitForest does not error when a mating unit's
           non-anchor parent has no own row in 'ped' (a dangling
           reference), and that parent is not chosen as anchor", {
  ped <- data.frame(
    id = c("GRANDSIRE", "SIRE", "CHILD"),
    sire = c(NA, "GRANDSIRE", "SIRE"),
    dam = c(NA, NA, "DANGLING_DAM"),
    sex = c("M", "M", "F"),
    gen = c(0L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  result <- expect_error(.buildMatingUnitForest(ped), NA)
  expect_equal(nrow(result$matingUnits), 1L)
  ## SIRE has known parents (non-founder) and a real row; DANGLING_DAM has
  ## no row at all here -- SIRE must anchor, not the dangling reference.
  expect_equal(result$matingUnits$anchor, "SIRE")
  expect_equal(result$matingUnits$nonAnchor, "DANGLING_DAM")
})

test_that(".buildMatingUnitForest assigns a duplicate node (not a crash)
           when a dangling parent reference appears at more than one
           mating unit", {
  ped <- data.frame(
    id = c("SIRE1", "SIRE2", "CHILD1", "CHILD2"),
    sire = c(NA, NA, "SIRE1", "SIRE2"),
    dam = c(NA, NA, "DANGLING_DAM", "DANGLING_DAM"),
    sex = c("M", "M", "F", "M"),
    gen = c(0L, 0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  result <- expect_error(.buildMatingUnitForest(ped), NA)
  expect_equal(nrow(result$matingUnits), 2L)
  expect_equal(nrow(result$duplicates), 1L)
  expect_equal(result$duplicates$realId, "DANGLING_DAM")
})

test_that(".buildMatingUnitForest's dangling-reference handling does not
           change anchor assignment for any fully self-contained pedigree
           (every sire/dam also has its own row) -- confirmed against the
           full real 375-individual fixture's already-verified figures", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  result <- .buildMatingUnitForest(ped)
  expect_equal(nrow(result$matingUnits), 237L)
  expect_equal(nrow(result$duplicates), 128L)
})
