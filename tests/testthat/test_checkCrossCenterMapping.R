## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #149 Slice 1): checkCrossCenterMapping() is the "show every
## problem at once" companion to resolveCrossCenterIds() (D2, plan section 3
## of docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md).
## It shares resolveCrossCenterIds()'s four validation checks (existence,
## uniqueness, collision, conflict) via extracted, non-stop()ing helpers, but
## never stop()s on a domain problem -- those become rows in the returned
## data.frame instead. Structural problems (missing required columns) still
## stop() immediately, exactly like every existing checkXxx() function.
##
## Two-tier gating (D2): tier A (existence, uniqueness) is checked first; if
## either has a hit, ONLY tier A's problems are returned (collision/conflict
## are not even attempted, since a mapped id that doesn't resolve to a real
## row makes those checks meaningless). Tier B (collision, conflict) runs
## only once tier A is clean.
##
## Dragon #2 (plan section 7, item 2): the conflict check's per-pair row
## lookup is only correct AFTER pedB's ids have been rewritten to their
## canonical idA values (the same rewrite resolveCrossCenterIds() itself
## performs). Looking up a merged pair's row by idA against UN-rewritten
## pedB silently returns an all-NA row, not an error -- so a conflict-check
## implementation that forgets the rewrite would silently report zero
## conflicts even when real ones exist. The
## "detects a real parent conflict" test below is the direct proof this
## does not happen.

pedA <- data.frame(
  id   = c("P1", "P2", "T1", "S1"),
  sire = c(NA_character_, NA_character_, "P1", "P1"),
  dam  = c(NA_character_, NA_character_, "P2", "P2"),
  stringsAsFactors = FALSE
)

pedB <- data.frame(
  id   = c("X9", "Q1", "O1"),
  sire = c(NA_character_, NA_character_, "X9"),
  dam  = c(NA_character_, NA_character_, "Q1"),
  stringsAsFactors = FALSE
)

mapping <- data.frame(
  idA = "T1", idB = "X9",
  stringsAsFactors = FALSE
)

test_that("checkCrossCenterMapping returns zero rows for a clean mapping", {
  problems <- checkCrossCenterMapping(pedA, pedB, mapping)

  expect_s3_class(problems, "data.frame")
  expect_identical(names(problems), c("type", "ids", "message"))
  expect_equal(nrow(problems), 0L)
})

test_that("checkCrossCenterMapping stops immediately on a missing pedigree column (structural)", {
  expect_error(
    checkCrossCenterMapping(pedA[, c("id", "sire")], pedB, mapping),
    "dam"
  )
  expect_error(
    checkCrossCenterMapping(pedA, pedB[, c("id", "sire")], mapping),
    "dam"
  )
})

test_that("checkCrossCenterMapping stops immediately on a missing mapping column (structural)", {
  expect_error(
    checkCrossCenterMapping(pedA, pedB, data.frame(idA = "T1")),
    "idB"
  )
})

test_that("checkCrossCenterMapping reports every tier-A problem at once and suppresses tier B even though a real collision exists", {
  ## idB "X9" duplicated (uniqueness) AND idA "NOPE" absent from pedA$id
  ## (existence) -- both tier-A problem types present simultaneously.
  badMapping <- data.frame(
    idA = c("T1", "NOPE"), idB = c("X9", "X9"),
    stringsAsFactors = FALSE
  )
  ## Also inject a real, undeclared id collision (Q1 -> S1) that tier B
  ## would report if it ran -- it must NOT, since tier A is dirty.
  collidingPedB <- pedB
  collidingPedB$id[collidingPedB$id == "Q1"] <- "S1"

  problems <- checkCrossCenterMapping(pedA, collidingPedB, badMapping)

  expect_true(any(problems$type == "uniqueness"))
  expect_true(any(problems$type == "existence"))
  expect_false(any(problems$type == "collision"))
  expect_false(any(problems$type == "conflict"))
})

test_that("checkCrossCenterMapping reports a collision once tier A is clean", {
  collidingPedB <- pedB
  collidingPedB$id[collidingPedB$id == "Q1"] <- "S1" # collides with pedA's S1

  problems <- checkCrossCenterMapping(pedA, collidingPedB, mapping)

  collisionRows <- problems[problems$type == "collision", ]
  expect_equal(nrow(collisionRows), 1L)
  expect_true(grepl("S1", collisionRows$ids))
})

test_that("checkCrossCenterMapping detects a real parent conflict (Dragon #2: proves the pedB id-rewrite runs before the lookup)", {
  conflictPedB <- pedB
  conflictPedB$sire[conflictPedB$id == "X9"] <- "OTHER_SIRE"

  problems <- checkCrossCenterMapping(pedA, conflictPedB, mapping)

  conflictRows <- problems[problems$type == "conflict", ]
  expect_equal(nrow(conflictRows), 1L)
  expect_true(grepl("T1", conflictRows$ids))
})

test_that("checkCrossCenterMapping collects every conflict, not just the first", {
  pedA2 <- data.frame(
    id   = c("P1", "P2", "T1", "T2"),
    sire = c(NA_character_, NA_character_, "P1", "P1"),
    dam  = c(NA_character_, NA_character_, "P2", "P2"),
    stringsAsFactors = FALSE
  )
  pedB2 <- data.frame(
    id   = c("X9", "X10"),
    sire = c("OTHER1", "OTHER2"),
    dam  = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  mapping2 <- data.frame(
    idA = c("T1", "T2"), idB = c("X9", "X10"),
    stringsAsFactors = FALSE
  )

  problems <- checkCrossCenterMapping(pedA2, pedB2, mapping2)

  conflictRows <- problems[problems$type == "conflict", ]
  expect_equal(nrow(conflictRows), 2L)
  expect_setequal(conflictRows$ids, c("T1", "T2"))
})

test_that(".rewriteCrossCenterIds rewrites pedB's own id and any sire/dam pointer to a mapped id", {
  rewritten <- .rewriteCrossCenterIds(pedB, mapping)

  expect_false("X9" %in% rewritten$id)
  expect_true("T1" %in% rewritten$id)
  o1Row <- rewritten[rewritten$id == "O1", ]
  expect_identical(o1Row$sire, "T1")
})

test_that(".pickCrossCenterParent returns value/source/conflict for the A-only, B-only, both-agree, and conflicting cases", {
  aOnly <- .pickCrossCenterParent(
    data.frame(sire = "P1", stringsAsFactors = FALSE),
    data.frame(sire = NA_character_, stringsAsFactors = FALSE),
    "sire"
  )
  expect_equal(aOnly$value, "P1")
  expect_equal(aOnly$source, "A")
  expect_false(aOnly$conflict)

  bOnly <- .pickCrossCenterParent(
    data.frame(sire = NA_character_, stringsAsFactors = FALSE),
    data.frame(sire = "X1", stringsAsFactors = FALSE),
    "sire"
  )
  expect_equal(bOnly$value, "X1")
  expect_equal(bOnly$source, "B")
  expect_false(bOnly$conflict)

  bothAgree <- .pickCrossCenterParent(
    data.frame(sire = "P1", stringsAsFactors = FALSE),
    data.frame(sire = "P1", stringsAsFactors = FALSE),
    "sire"
  )
  expect_equal(bothAgree$value, "P1")
  expect_equal(bothAgree$source, "both")
  expect_false(bothAgree$conflict)

  conflicting <- .pickCrossCenterParent(
    data.frame(sire = "P1", stringsAsFactors = FALSE),
    data.frame(sire = "P2", stringsAsFactors = FALSE),
    "sire"
  )
  expect_true(conflicting$conflict)
})
