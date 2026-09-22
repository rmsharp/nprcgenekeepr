## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #168 Slice 2 (RED): reportAncestryViolations(groups, ped, rules,
# overriddenRules = NULL) is the script-callable flag/inspection API (D3/D4/
# D5), usable on ANY list of formed groups. Shape pinned at this RED (owner-
# ratified gate): it returns list(violations = <data.frame>, coverage =
# <data.frame>) -- the reportMatePairs() two-frame mold, not attributes.
# `violations` has one row per violating within-group pair with columns
# group (integer index into `groups`), id1, id2, ancestry1, ancestry2 (the
# ids' own levels), rule (canonical sorted "LO-HI" string), severity, status
# ("violation" | "overridden" -- an overridden rule's rows are never
# silently absent, D4). `coverage` (D6) always has one row per standardized
# level in checkAncestryRules()'s vocabulary order (CHINESE, INDIAN, HYBRID,
# JAPANESE, OTHER, UNKNOWN), columns ancestry, n (animals in `groups` at
# that level), covered (TRUE when >= 1 rule names the level). Both entry
# points re-validate rules via checkAncestryRules(). The internal helpers
# .ancestryConflictPairs() and .mergeAncestryBlockPairs() are pinned here
# too (Dragon 2: hand-built kin before/after merge, both directions,
# absent and NA entries).

avPed <- function() {
  raw <- read.csv(
    system.file("extdata", "examples", "example_ancestry_pedigree.csv",
      package = "nprcgenekeepr"
    ),
    stringsAsFactors = FALSE, na.strings = c("", "NA")
  )
  qcStudbook(raw,
    minParentAge = 2, reportChanges = FALSE,
    reportErrors = FALSE
  )
}

avRules <- function() {
  checkAncestryRules(readAncestryRules(system.file(
    "extdata", "examples", "example_ancestry_rules.csv",
    package = "nprcgenekeepr"
  )))
}

violationCols <- c(
  "group", "id1", "id2", "ancestry1", "ancestry2", "rule", "severity",
  "status"
)
coverageLevels <- c(
  "CHINESE", "INDIAN", "HYBRID", "JAPANESE", "OTHER", "UNKNOWN"
)

test_that("reportAncestryViolations matches hand-derived violations on the fixtures", {
  ped <- avPed()
  rules <- avRules()
  groups <- list(c("I1", "C1", "J1"), c("I2", "H1", "U1"))
  out <- reportAncestryViolations(groups, ped, rules)
  expect_type(out, "list")
  expect_named(out, c("violations", "coverage"))
  v <- out$violations
  expect_s3_class(v, "data.frame")
  expect_identical(names(v), violationCols)
  expect_type(v$group, "integer")
  expect_identical(nrow(v), 3L)
  ## hand-derived: group 1 has I1-C1 (block INDIAN x CHINESE); group 2 has
  ## I2-H1 (block INDIAN x HYBRID) and I2-U1 (flag INDIAN x UNKNOWN)
  key <- paste(
    v$group, pmin(v$id1, v$id2), pmax(v$id1, v$id2), v$rule, v$severity,
    v$status
  )
  expect_setequal(key, c(
    "1 C1 I1 CHINESE-INDIAN block violation",
    "2 H1 I2 HYBRID-INDIAN block violation",
    "2 I2 U1 INDIAN-UNKNOWN flag violation"
  ))
  ## ancestry1/ancestry2 are id1's/id2's own levels
  expect_identical(
    v$ancestry1,
    toupper(as.character(ped$ancestry[match(v$id1, ped$id)]))
  )
  expect_identical(
    v$ancestry2,
    toupper(as.character(ped$ancestry[match(v$id2, ped$id)]))
  )
})

test_that("the coverage summary counts levels over the group animals (D6)", {
  ped <- avPed()
  rules <- avRules()
  groups <- list(c("I1", "C1", "J1"), c("I2", "H1", "U1"))
  cov <- reportAncestryViolations(groups, ped, rules)$coverage
  expect_s3_class(cov, "data.frame")
  expect_identical(names(cov), c("ancestry", "n", "covered"))
  expect_identical(cov$ancestry, coverageLevels)
  ## I1, I2 INDIAN; C1 CHINESE; J1 JAPANESE; H1 HYBRID; U1 UNKNOWN; no OTHER
  expect_identical(cov$n, c(1L, 2L, 1L, 1L, 0L, 1L))
  ## the example rules name every level except JAPANESE
  expect_identical(cov$covered, c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE))
  ## "animals under no rule" is derivable and hand-checked: J1 alone
  expect_identical(sum(cov$n[!cov$covered]), 1L)
})

test_that("overridden rules mark their rows overridden, never absent (D4)", {
  ped <- avPed()
  rules <- avRules()
  groups <- list(c("I1", "C1", "J1"), c("I2", "H1", "U1"))
  ## reversed order and lowercase pin unordered, case-coerced matching
  overridden <- data.frame(
    ancestry1 = "chinese", ancestry2 = "indian", stringsAsFactors = FALSE
  )
  v <- reportAncestryViolations(
    groups, ped, rules,
    overriddenRules = overridden
  )$violations
  expect_identical(nrow(v), 3L)
  expect_identical(v$status[v$rule == "CHINESE-INDIAN"], "overridden")
  expect_setequal(v$status[v$rule != "CHINESE-INDIAN"], "violation")
})

test_that("an overriddenRules row matching no rule stops (typo safety)", {
  ped <- avPed()
  rules <- avRules()
  groups <- list(c("I1", "C1"))
  badOverride <- data.frame(
    ancestry1 = "JAPANESE", ancestry2 = "CHINESE", stringsAsFactors = FALSE
  )
  expect_error(
    reportAncestryViolations(
      groups, ped, rules,
      overriddenRules = badOverride
    ),
    "not present in rules"
  )
  expect_error(
    reportAncestryViolations(
      groups, ped, rules,
      overriddenRules = badOverride
    ),
    "CHINESE-JAPANESE"
  )
})

test_that("no violations returns a zero-row frame with the full column shape", {
  ped <- avPed()
  rules <- avRules()
  out <- reportAncestryViolations(list(c("J1", "J2")), ped, rules)
  expect_identical(nrow(out$violations), 0L)
  expect_identical(names(out$violations), violationCols)
  cov <- out$coverage
  expect_identical(cov$n[cov$ancestry == "JAPANESE"], 2L)
  expect_identical(sum(cov$n), 2L)
})

test_that("an empty rules table is valid: no violations, nothing covered", {
  ped <- avPed()
  emptyRules <- data.frame(
    ancestry1 = character(0L), ancestry2 = character(0L),
    severity = character(0L), stringsAsFactors = FALSE
  )
  out <- reportAncestryViolations(list(c("I1", "C1")), ped, emptyRules)
  expect_identical(nrow(out$violations), 0L)
  expect_identical(out$coverage$covered, rep(FALSE, 6L))
  expect_identical(sum(out$coverage$n), 2L)
})

test_that("a self-pair rule flags two same-level animals; a minimal ped suffices", {
  ## ped needs only id + ancestry columns for reporting
  pedH <- data.frame(
    id = c("X1", "X2", "X3"),
    ancestry = c("HYBRID", "HYBRID", "INDIAN"),
    stringsAsFactors = FALSE
  )
  selfRule <- data.frame(
    ancestry1 = "HYBRID", ancestry2 = "HYBRID", severity = "block",
    stringsAsFactors = FALSE
  )
  v <- reportAncestryViolations(
    list(c("X1", "X2", "X3")), pedH, selfRule
  )$violations
  expect_identical(nrow(v), 1L)
  expect_setequal(c(v$id1, v$id2), c("X1", "X2"))
  expect_identical(v$rule, "HYBRID-HYBRID")
  expect_identical(v$severity, "block")
})

test_that("lowercase ancestry values in ped still match (coerced like the rules)", {
  pedLower <- data.frame(
    id = c("Y1", "Y2"), ancestry = c("indian", "chinese"),
    stringsAsFactors = FALSE
  )
  v <- reportAncestryViolations(
    list(c("Y1", "Y2")), pedLower, avRules()
  )$violations
  expect_identical(nrow(v), 1L)
  expect_identical(v$rule, "CHINESE-INDIAN")
  expect_identical(v$ancestry1, "INDIAN")
  expect_identical(v$ancestry2, "CHINESE")
})

test_that("reportAncestryViolations stop() paths name the defect", {
  ped <- avPed()
  rules <- avRules()
  pedNoAncestry <- ped[, setdiff(names(ped), "ancestry")]
  expect_error(
    reportAncestryViolations(list("I1"), pedNoAncestry, rules),
    "no 'ancestry' column"
  )
  expect_error(
    reportAncestryViolations(list(c("I1", "NOPE")), ped, rules),
    "NOPE"
  )
  badSeverity <- data.frame(
    ancestry1 = "INDIAN", ancestry2 = "CHINESE", severity = "warn",
    stringsAsFactors = FALSE
  )
  expect_error(
    reportAncestryViolations(list(c("I1", "C1")), ped, badSeverity),
    "severity"
  )
})

test_that("groups formed under block rules report zero block violations", {
  ped <- avPed()
  rules <- avRules()
  kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
  set_seed(5L)
  res <- groupAddAssign(
    candidates = ped$id, kmat = kmat, ped = ped,
    iter = 10L, numGp = 2L, ancestryRules = rules
  )
  v <- reportAncestryViolations(res$group[1L:2L], ped, rules)$violations
  expect_identical(nrow(v[v$severity == "block", , drop = FALSE]), 0L)
})

test_that(".ancestryConflictPairs finds every pair of the requested severity exactly once", {
  ped <- avPed()
  rules <- avRules()
  blockPairs <- nprcgenekeepr:::.ancestryConflictPairs(
    ped$id, ped, rules,
    severity = "block"
  )
  expect_s3_class(blockPairs, "data.frame")
  expect_true(all(c("id1", "id2") %in% names(blockPairs)))
  key <- paste(
    pmin(blockPairs$id1, blockPairs$id2),
    pmax(blockPairs$id1, blockPairs$id2),
    sep = "-"
  )
  ## INDIAN (I1, I2, A1) x CHINESE (C1, C2): 6 pairs;
  ## INDIAN x HYBRID (H1): 3 pairs
  expect_identical(sort(key), sort(c(
    "C1-I1", "C2-I1", "C1-I2", "C2-I2", "A1-C1", "A1-C2",
    "H1-I1", "H1-I2", "A1-H1"
  )))
  expect_identical(anyDuplicated(key), 0L)
  flagPairs <- nprcgenekeepr:::.ancestryConflictPairs(
    ped$id, ped, rules,
    severity = "flag"
  )
  ## INDIAN x UNKNOWN (U1): 3; INDIAN x OTHER (O1): 3
  expect_identical(nrow(flagPairs), 6L)
})

test_that(".ancestryConflictPairs respects the ids subset", {
  ped <- avPed()
  rules <- avRules()
  pairs <- nprcgenekeepr:::.ancestryConflictPairs(
    c("I1", "C1", "J1"), ped, rules,
    severity = "block"
  )
  expect_identical(nrow(pairs), 1L)
  expect_setequal(c(pairs$id1, pairs$id2), c("I1", "C1"))
})

test_that(".mergeAncestryBlockPairs adds both directions and creates absent entries", {
  kin <- list(A = "B", B = "A")
  pairs <- data.frame(
    id1 = c("A", "C"), id2 = c("C", "D"), stringsAsFactors = FALSE
  )
  merged <- nprcgenekeepr:::.mergeAncestryBlockPairs(kin, pairs)
  expect_setequal(merged[["A"]], c("B", "C"))
  expect_identical(merged[["B"]], "A")
  expect_setequal(merged[["C"]], c("A", "D"))
  expect_identical(merged[["D"]], "C")
})

test_that(".mergeAncestryBlockPairs tolerates NA placeholder entries and empty pairs", {
  kin <- list(A = NA)
  pairs <- data.frame(id1 = "A", id2 = "B", stringsAsFactors = FALSE)
  merged <- nprcgenekeepr:::.mergeAncestryBlockPairs(kin, pairs)
  expect_true("B" %in% merged[["A"]])
  expect_true("A" %in% merged[["B"]])
  ## the merged entry still works at the fillGroupMembers seam
  expect_identical(setdiff(c("B", "Z"), merged[["A"]]), "Z")
  noPairs <- data.frame(
    id1 = character(0L), id2 = character(0L), stringsAsFactors = FALSE
  )
  expect_identical(
    nprcgenekeepr:::.mergeAncestryBlockPairs(kin, noPairs), kin
  )
})
