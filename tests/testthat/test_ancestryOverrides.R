## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #168 Slice 3 (RED): the override + audit-manifest primitives behind
# the Slice 4 confirm gate (plan sec 5 Slice 3, D4). Internals only -- no
# export. Design pinned at this RED (owner-ratified pre-RED round):
# - .ancestryOverrideWarningText: the ratified gate wording, verbatim.
# - .checkAncestryOverrides(overrides, rules): overrides are a data frame
#   with ancestry1, ancestry2, reason; NULL or zero rows = no overrides;
#   every override needs a non-empty reason, must name a BLOCK rule present
#   in `rules` (unordered match), and may not be duplicated.
# - .effectiveAncestryRules(rules, overrides): the rules groupAddAssign()
#   enforces for the run -- each overridden rule DOWNGRADED to flag (never
#   dropped), so blocking stops while the rule's levels stay named (no
#   spurious D6 UNKNOWN/OTHER warning at formation time).
# - .buildAncestryOverrideManifest(rules, overrides, report, warningText):
#   one row per rule in `rules` (the rule is D4's unit), run-level fields
#   repeated on every row so each row stands alone in the downloaded CSV.

aoPed <- function() {
  raw <- read.csv(
    system.file("extdata", "examples", "example_ancestry_pedigree.csv",
      package = "nprcgenekeepr"
    ),
    stringsAsFactors = FALSE, na.strings = c("", "NA")
  )
  qcStudbook(raw,
    minSireAge = 2, minDamAge = 2, reportChanges = FALSE,
    reportErrors = FALSE
  )
}

aoRules <- function() {
  checkAncestryRules(readAncestryRules(system.file(
    "extdata", "examples", "example_ancestry_rules.csv",
    package = "nprcgenekeepr"
  )))
}

aoReason <- "Founder import approved by the colony veterinarian"

aoOverride <- function(ancestry1 = "INDIAN", ancestry2 = "CHINESE",
                       reason = aoReason) {
  data.frame(
    ancestry1 = ancestry1, ancestry2 = ancestry2, reason = reason,
    stringsAsFactors = FALSE
  )
}

## hand-derived on the fixtures (example rules, in file order: INDIAN x
## CHINESE block, INDIAN x HYBRID block, INDIAN x UNKNOWN flag, INDIAN x
## OTHER flag): group 1 holds I1-C1; group 2 holds I2-C2, I2-H1, I2-U1,
## I2-O1. Census over the 8 grouped animals: CHINESE 2, INDIAN 2, HYBRID 1,
## JAPANESE 1 (named by no rule), OTHER 1, UNKNOWN 1.
aoGroups <- list(c("I1", "C1", "J1"), c("I2", "C2", "H1", "U1", "O1"))

manifestCols <- c(
  "timestamp", "packageVersion", "ancestry1", "ancestry2", "severity",
  "overridden", "reason", "nPairs", "nChinese", "nIndian", "nHybrid",
  "nJapanese", "nOther", "nUnknown", "nUncovered", "overrideSummary",
  "warningText"
)

test_that(".ancestryOverrideWarningText is the ratified gate wording, verbatim", {
  expect_identical(
    .ancestryOverrideWarningText,
    paste(
      "Overriding this ancestry rule lets group formation place animals",
      "together that the rule would otherwise keep apart, for this run",
      "only. The rule stays in your rules file, and every pairing it",
      "matches is still reported, marked \"overridden\". Your stated reason",
      "is saved in the downloadable audit manifest. Confirming that this",
      "override fits your colony's genetic-management and research",
      "commitments is your responsibility, not this tool's."
    )
  )
})

test_that(".checkAncestryOverrides treats NULL and zero rows as no overrides", {
  rules <- aoRules()
  empty <- .checkAncestryOverrides(NULL, rules)
  expect_s3_class(empty, "data.frame")
  expect_identical(names(empty), c("ancestry1", "ancestry2", "reason"))
  expect_identical(nrow(empty), 0L)
  expect_type(empty$ancestry1, "character")
  expect_type(empty$ancestry2, "character")
  expect_type(empty$reason, "character")
  expect_identical(.checkAncestryOverrides(aoOverride()[0L, ], rules), empty)
})

test_that(".checkAncestryOverrides coerces levels and reasons and matches either pair order", {
  rules <- aoRules()
  out <- .checkAncestryOverrides(
    aoOverride(" chinese ", "Indian", "  Approved founder import  "), rules
  )
  expect_identical(names(out), c("ancestry1", "ancestry2", "reason"))
  expect_identical(out$ancestry1, "CHINESE")
  expect_identical(out$ancestry2, "INDIAN")
  expect_identical(out$reason, "Approved founder import")
  asFactors <- data.frame(
    ancestry1 = factor("INDIAN"), ancestry2 = factor("HYBRID"),
    reason = factor("Hybrid cohort approved"), extra = 1L
  )
  outF <- .checkAncestryOverrides(asFactors, rules)
  expect_identical(names(outF), c("ancestry1", "ancestry2", "reason"))
  expect_identical(outF$reason, "Hybrid cohort approved")
})

test_that(".checkAncestryOverrides stops when a required column is missing", {
  expect_error(
    .checkAncestryOverrides(
      aoOverride()[, c("ancestry1", "ancestry2")], aoRules()
    ),
    "overrides must have columns"
  )
})

test_that(".checkAncestryOverrides requires a non-empty reason for every override (D4)", {
  rules <- aoRules()
  expect_error(
    .checkAncestryOverrides(aoOverride(reason = ""), rules),
    "non-empty reason"
  )
  expect_error(
    .checkAncestryOverrides(aoOverride(reason = "   "), rules),
    "non-empty reason"
  )
  expect_error(
    .checkAncestryOverrides(aoOverride(reason = NA_character_), rules),
    "non-empty reason"
  )
})

test_that(".checkAncestryOverrides stops on an override naming no rule in rules", {
  expect_error(
    .checkAncestryOverrides(aoOverride("JAPANESE", "CHINESE"), aoRules()),
    "not present in rules"
  )
})

test_that(".checkAncestryOverrides stops on an override naming a flag rule", {
  expect_error(
    .checkAncestryOverrides(aoOverride("INDIAN", "UNKNOWN"), aoRules()),
    "only block rules can be overridden"
  )
})

test_that(".checkAncestryOverrides stops on a duplicated (unordered) override", {
  dup <- rbind(
    aoOverride("INDIAN", "CHINESE", "first reason"),
    aoOverride("CHINESE", "INDIAN", "second reason")
  )
  expect_error(.checkAncestryOverrides(dup, aoRules()), "duplicated")
})

test_that(".effectiveAncestryRules downgrades each overridden rule to flag and changes nothing else", {
  rules <- aoRules()
  eff <- .effectiveAncestryRules(rules, aoOverride())
  expect_identical(names(eff), names(rules))
  expect_identical(eff$ancestry1, rules$ancestry1)
  expect_identical(eff$ancestry2, rules$ancestry2)
  expect_identical(eff$severity, c("flag", "block", "flag", "flag"))
  expect_identical(.effectiveAncestryRules(rules, NULL), rules)
  expect_identical(.effectiveAncestryRules(rules, aoOverride()[0L, ]), rules)
})

test_that(".effectiveAncestryRules keeps overridden levels named, so no D6 warning appears", {
  rules <- data.frame(
    ancestry1 = c("INDIAN", "INDIAN"), ancestry2 = c("UNKNOWN", "OTHER"),
    severity = c("block", "block"), stringsAsFactors = FALSE
  )
  expect_no_warning(
    eff <- .effectiveAncestryRules(rules, aoOverride("INDIAN", "OTHER"))
  )
  expect_identical(eff$severity, c("block", "flag"))
  expect_no_warning(checkAncestryRules(eff))
})

test_that(".buildAncestryOverrideManifest returns one row per rule with the ratified columns and types", {
  ped <- aoPed()
  rules <- aoRules()
  report <- reportAncestryViolations(aoGroups, ped, rules,
    overriddenRules = aoOverride()
  )
  m <- .buildAncestryOverrideManifest(
    rules, aoOverride(), report, .ancestryOverrideWarningText
  )
  expect_s3_class(m, "data.frame")
  expect_identical(nrow(m), nrow(rules))
  expect_identical(names(m), manifestCols)
  expect_identical(m$ancestry1, rules$ancestry1)
  expect_identical(m$ancestry2, rules$ancestry2)
  expect_identical(m$severity, rules$severity)
  for (col in c(
    "timestamp", "packageVersion", "reason", "overrideSummary",
    "warningText"
  )) {
    expect_type(m[[col]], "character")
  }
  expect_type(m$overridden, "logical")
  for (col in c(
    "nPairs", "nChinese", "nIndian", "nHybrid", "nJapanese", "nOther",
    "nUnknown", "nUncovered"
  )) {
    expect_type(m[[col]], "integer")
  }
})

test_that(".buildAncestryOverrideManifest field values match the hand-derived run", {
  ped <- aoPed()
  rules <- aoRules()
  report <- reportAncestryViolations(aoGroups, ped, rules,
    overriddenRules = aoOverride()
  )
  m <- .buildAncestryOverrideManifest(
    rules, aoOverride(), report, .ancestryOverrideWarningText
  )
  expect_true(all(nzchar(m$timestamp)))
  expect_length(unique(m$timestamp), 1L)
  expect_false(is.na(as.POSIXct(m$timestamp[1L])))
  expect_identical(m$packageVersion, rep(getVersion(date = FALSE), 4L))
  expect_identical(m$overridden, c(TRUE, FALSE, FALSE, FALSE))
  expect_identical(m$reason, c(aoReason, NA, NA, NA))
  expect_identical(m$nPairs, c(2L, 1L, 1L, 1L))
  expect_identical(m$nChinese, rep(2L, 4L))
  expect_identical(m$nIndian, rep(2L, 4L))
  expect_identical(m$nHybrid, rep(1L, 4L))
  expect_identical(m$nJapanese, rep(1L, 4L))
  expect_identical(m$nOther, rep(1L, 4L))
  expect_identical(m$nUnknown, rep(1L, 4L))
  expect_identical(m$nUncovered, rep(1L, 4L))
  expect_identical(
    m$overrideSummary, rep("1 of 4 rules overridden for this run.", 4L)
  )
  expect_identical(m$warningText, rep(.ancestryOverrideWarningText, 4L))
})

test_that("a manifest from a run with no overrides says so explicitly", {
  ped <- aoPed()
  rules <- aoRules()
  report <- reportAncestryViolations(aoGroups, ped, rules)
  for (ov in list(NULL, aoOverride()[0L, ])) {
    m <- .buildAncestryOverrideManifest(rules, ov, report, "gate text")
    expect_identical(m$overridden, rep(FALSE, 4L))
    expect_identical(m$reason, rep(NA_character_, 4L))
    expect_identical(
      m$overrideSummary, rep("No rules were overridden for this run.", 4L)
    )
    expect_identical(m$warningText, rep("gate text", 4L))
    expect_identical(m$nPairs, c(2L, 1L, 1L, 1L))
  }
})

test_that("an overridden rule with no matched pairs is still recorded, never silently absent", {
  ped <- aoPed()
  rules <- aoRules()
  ov <- aoOverride("INDIAN", "HYBRID", "Hybrid breeders approved")
  report <- reportAncestryViolations(list(c("I1", "C1")), ped, rules,
    overriddenRules = ov
  )
  m <- .buildAncestryOverrideManifest(rules, ov, report, "gate text")
  row <- m[m$ancestry1 == "INDIAN" & m$ancestry2 == "HYBRID", ]
  expect_identical(nrow(row), 1L)
  expect_true(row$overridden)
  expect_identical(row$reason, "Hybrid breeders approved")
  expect_identical(row$nPairs, 0L)
  expect_identical(
    m$overrideSummary[1L], "1 of 4 rules overridden for this run."
  )
})

test_that(".buildAncestryOverrideManifest stops on zero rules, a reasonless override, a malformed report, or empty warning text", {
  ped <- aoPed()
  rules <- aoRules()
  report <- reportAncestryViolations(list(c("I1", "C1")), ped, rules)
  expect_error(
    .buildAncestryOverrideManifest(rules[0L, ], NULL, report, "gate text"),
    "no rules"
  )
  expect_error(
    .buildAncestryOverrideManifest(
      rules, aoOverride(reason = ""), report, "gate text"
    ),
    "non-empty reason"
  )
  expect_error(
    .buildAncestryOverrideManifest(
      rules, NULL, list(violations = report$violations), "gate text"
    ),
    "reportAncestryViolations"
  )
  expect_error(
    .buildAncestryOverrideManifest(rules, NULL, report, ""),
    "warningText"
  )
})

test_that("override -> enforcement -> report -> manifest works end to end without the app", {
  ped <- aoPed()
  rules <- aoRules()
  kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
  ov <- .checkAncestryOverrides(aoOverride(), rules)
  eff <- .effectiveAncestryRules(rules, ov)
  for (s in 1:5) {
    set_seed(s)
    blocked <- groupAddAssign(
      candidates = c("I1", "C1"), kmat = kmat, ped = ped,
      iter = 5L, numGp = 1L, ancestryRules = rules
    )
    expect_length(blocked$group[[1L]], 1L)
    set_seed(s)
    allowed <- groupAddAssign(
      candidates = c("I1", "C1"), kmat = kmat, ped = ped,
      iter = 5L, numGp = 1L, ancestryRules = eff
    )
    expect_setequal(allowed$group[[1L]], c("I1", "C1"))
  }
  report <- reportAncestryViolations(allowed$group[1L], ped, rules,
    overriddenRules = ov
  )
  v <- report$violations
  expect_identical(nrow(v), 1L)
  expect_identical(v$rule, "CHINESE-INDIAN")
  expect_identical(v$severity, "block")
  expect_identical(v$status, "overridden")
  m <- .buildAncestryOverrideManifest(
    rules, ov, report, .ancestryOverrideWarningText
  )
  row <- m[m$ancestry1 == "INDIAN" & m$ancestry2 == "CHINESE", ]
  expect_true(row$overridden)
  expect_identical(row$reason, aoReason)
  expect_identical(row$nPairs, 1L)
  expect_identical(m$warningText[1L], .ancestryOverrideWarningText)
})
