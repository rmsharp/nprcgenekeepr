## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #169 Slice 3a RED: the pure pieces behind the Mate Pair override gate
## and audit manifest (plan docs/planning/mate-pair-ancestry-guardrails-plan.md
## section 5 Slice 3, decisions D6b and D8). Internals only -- no export.
## Design pinned at this RED (owner-ratified S776 gates):
##  * .matePairAncestryOverrideWarningText: the Mate Pair confirm-gate wording,
##    verbatim (the plan's D8a proposal, ratified as written at the S776 gate).
##    A sibling of .ancestryOverrideWarningText, which stays as it is.
##  * .matePairAncestryReport(result): the `report` adapter (D8b). It turns a
##    reportMatePairs(ancestryRules =) result into the list
##    .buildAncestryOverrideManifest() reads:
##      list(violations = <data.frame with a `rule` column: one row per
##                          ancestry-matched pair, from pairs UNION excluded>,
##           coverage   = <the result's ancestryCoverage, passed through>)
##    An overridden block pair sits in `pairs` and is counted; a blocked pair
##    sits in `excluded` and is counted; a flag pair is counted. A result made
##    without ancestryRules (no ancestryCoverage) is an error -- there is
##    nothing to record.
##
## Fixture: the shipped inst/extdata/examples/example_ancestry_{pedigree,
## rules}.csv (the same ten animals as test_reportMatePairsAncestry.R and
## test_modMatePair_ancestry.R). Hand-derived there and re-measured at S776:
## 25 male x female pairs; the rules (INDIAN-CHINESE block, INDIAN-HYBRID
## block, INDIAN-UNKNOWN flag, INDIAN-OTHER flag) match
##   CHINESE-INDIAN  3  (C1xI2, I1xC2, A1xC2)   -- block
##   HYBRID-INDIAN   2  (I1xH1, A1xH1)          -- block
##   INDIAN-UNKNOWN  2  (I1xU1, A1xU1)          -- flag
##   INDIAN-OTHER    1  (O1xI2)                 -- flag
## = 8 matches, whether or not CHINESE-INDIAN is overridden. Census over the
## ten animals: CHINESE 2, INDIAN 3, HYBRID 1, JAPANESE 2, OTHER 1, UNKNOWN 1;
## JAPANESE is named by no rule, so nUncovered = 2. HYBRID has one animal (a
## dam), so the self-pair rule HYBRID-HYBRID matches nothing.

mmPed <- local({
  raw <- read.csv(
    system.file("extdata", "examples", "example_ancestry_pedigree.csv",
      package = "nprcgenekeepr"
    ),
    stringsAsFactors = FALSE, na.strings = c("", "NA")
  )
  p <- qcStudbook(raw,
    minSireAge = 2, minDamAge = 2, reportChanges = FALSE,
    reportErrors = FALSE
  )
  p$gen <- findGeneration(p$id, p$sire, p$dam)
  p
})
mmKmat <- kinship(mmPed$id, mmPed$sire, mmPed$dam, mmPed$gen)
mmRules <- checkAncestryRules(readAncestryRules(system.file(
  "extdata", "examples", "example_ancestry_rules.csv",
  package = "nprcgenekeepr"
)))
mmNoMatchRules <- checkAncestryRules(data.frame(
  ancestry1 = "HYBRID", ancestry2 = "HYBRID", severity = "block",
  stringsAsFactors = FALSE
))

mmReason <- "Founder import approved by the colony veterinarian"
mmOverride <- data.frame(
  ancestry1 = "INDIAN", ancestry2 = "CHINESE", reason = mmReason,
  stringsAsFactors = FALSE
)
mmRuleKeys <- c(
  "CHINESE-INDIAN", "HYBRID-INDIAN", "INDIAN-OTHER", "INDIAN-UNKNOWN"
)
mmRuleCounts <- c(3L, 2L, 1L, 2L)

mmGateText <- paste(
  "Overriding this ancestry rule lets the Mate Pair Analysis list pairs the",
  "rule would otherwise exclude, for this run only. The rule stays in your",
  "rules file, and every pair it matches is still reported, marked",
  "\"overridden\". Your stated reason is saved in the downloadable audit",
  "manifest. Confirming that this override fits your colony's",
  "genetic-management and research commitments is your responsibility, not",
  "this tool's."
)

## What the module's "allAlive" click hands the kernel.
mmRun <- function(rules = mmRules, ov = NULL) {
  reportMatePairs(
    mmPed, mmKmat,
    markerKmat = NULL, geneticValues = NULL, minAge = 1,
    populationIds = mmPed$id[is.na(mmPed$exit)], exclude = character(0L),
    ancestryRules = rules, overriddenRules = ov
  )
}

mmRuleCount <- function(report) {
  tab <- table(report$violations$rule)
  as.integer(tab[mmRuleKeys])
}

# =============================================================================
# The confirm-gate wording (D8a)
# =============================================================================

test_that(paste(
  ".matePairAncestryOverrideWarningText is the ratified Mate Pair wording,",
  "verbatim, and is not the group-formation wording"
), {
  txt <- .matePairAncestryOverrideWarningText
  expect_type(txt, "character")
  expect_length(txt, 1L)
  expect_identical(txt, mmGateText)
  expect_false(identical(txt, .ancestryOverrideWarningText))
  expect_true(grepl("Mate Pair Analysis", txt, fixed = TRUE))
  expect_false(grepl("group formation", txt, fixed = TRUE))
})

# =============================================================================
# The report adapter (D8b)
# =============================================================================

test_that(paste(
  ".matePairAncestryReport counts every ancestry-matched pair from pairs and",
  "excluded together and passes the coverage through"
), {
  res <- mmRun()
  expect_identical(nrow(res$pairs), 20L)
  expect_identical(nrow(res$excluded), 5L)

  rep <- .matePairAncestryReport(res)
  expect_identical(names(rep), c("violations", "coverage"))
  expect_s3_class(rep$violations, "data.frame")
  expect_true("rule" %in% names(rep$violations))
  expect_type(rep$violations$rule, "character")
  expect_identical(nrow(rep$violations), 8L)
  expect_identical(mmRuleCount(rep), mmRuleCounts)
  expect_identical(rep$coverage, res$ancestryCoverage)
})

test_that(paste(
  ".matePairAncestryReport still counts an overridden block rule's pairs (they",
  "move to pairs, marked overridden, never disappear)"
), {
  res <- mmRun(ov = mmOverride)
  expect_identical(nrow(res$pairs), 23L)
  expect_identical(nrow(res$excluded), 2L)

  rep <- .matePairAncestryReport(res)
  expect_identical(nrow(rep$violations), 8L)
  expect_identical(mmRuleCount(rep), mmRuleCounts)
  expect_identical(rep$coverage, res$ancestryCoverage)
})

test_that(paste(
  ".matePairAncestryReport returns a zero-row violations table (character",
  "`rule`) when no pair matches any rule"
), {
  res <- mmRun(rules = mmNoMatchRules)
  expect_identical(nrow(res$pairs), 25L)
  expect_identical(nrow(res$excluded), 0L)

  rep <- .matePairAncestryReport(res)
  expect_identical(nrow(rep$violations), 0L)
  expect_type(rep$violations$rule, "character")
  expect_identical(rep$coverage, res$ancestryCoverage)
})

test_that(paste(
  ".matePairAncestryReport refuses a result made without ancestryRules and",
  "anything that is not a reportMatePairs() result"
), {
  noRules <- reportMatePairs(
    mmPed, mmKmat,
    markerKmat = NULL, geneticValues = NULL, minAge = 1,
    populationIds = mmPed$id[is.na(mmPed$exit)], exclude = character(0L)
  )
  expect_error(.matePairAncestryReport(noRules), "ancestryRules")
  expect_error(
    .matePairAncestryReport(list(pairs = data.frame(), excluded = data.frame())),
    "ancestryRules"
  )
  expect_error(.matePairAncestryReport(NULL), "reportMatePairs")
  expect_error(.matePairAncestryReport("not a result"), "reportMatePairs")
})

# =============================================================================
# Adapter -> manifest, end to end (D6b, D8)
# =============================================================================

test_that(paste(
  "adapter -> .buildAncestryOverrideManifest: with no override the manifest",
  "has one row per rule, the pair counts, the census and the Mate Pair gate",
  "text"
), {
  res <- mmRun()
  m <- .buildAncestryOverrideManifest(
    mmRules, NULL, .matePairAncestryReport(res),
    .matePairAncestryOverrideWarningText
  )
  expect_identical(nrow(m), 4L)
  key <- .ancestryPairKey(m$ancestry1, m$ancestry2)
  expect_identical(m$nPairs[match(mmRuleKeys, key)], mmRuleCounts)
  expect_false(any(m$overridden))
  expect_true(all(is.na(m$reason)))
  expect_identical(
    unique(m$overrideSummary), "No rules were overridden for this run."
  )
  expect_identical(unique(m$warningText), mmGateText)
  ## census over the ten animals the report considered (all 25 pairs are in
  ## pairs UNION excluded)
  expect_identical(unique(m$nChinese), 2L)
  expect_identical(unique(m$nIndian), 3L)
  expect_identical(unique(m$nHybrid), 1L)
  expect_identical(unique(m$nJapanese), 2L)
  expect_identical(unique(m$nOther), 1L)
  expect_identical(unique(m$nUnknown), 1L)
  expect_identical(unique(m$nUncovered), 2L)
})

test_that(paste(
  "adapter -> .buildAncestryOverrideManifest: an override is recorded with",
  "its reason on exactly its rule's row, pair counts unchanged"
), {
  res <- mmRun(ov = mmOverride)
  m <- .buildAncestryOverrideManifest(
    mmRules, mmOverride, .matePairAncestryReport(res),
    .matePairAncestryOverrideWarningText
  )
  expect_identical(nrow(m), 4L)
  key <- .ancestryPairKey(m$ancestry1, m$ancestry2)
  expect_identical(m$nPairs[match(mmRuleKeys, key)], mmRuleCounts)
  expect_identical(m$overridden[match(mmRuleKeys, key)],
    c(TRUE, FALSE, FALSE, FALSE)
  )
  expect_identical(m$reason[key == "CHINESE-INDIAN"], mmReason)
  expect_true(all(is.na(m$reason[key != "CHINESE-INDIAN"])))
  expect_identical(
    unique(m$overrideSummary), "1 of 4 rules overridden for this run."
  )
  expect_identical(unique(m$warningText), mmGateText)
  expect_identical(unique(m$nUncovered), 2L)
})

test_that(paste(
  "adapter -> .buildAncestryOverrideManifest: a rule that matched no pair is",
  "recorded with nPairs 0"
), {
  res <- mmRun(rules = mmNoMatchRules)
  m <- .buildAncestryOverrideManifest(
    mmNoMatchRules, NULL, .matePairAncestryReport(res),
    .matePairAncestryOverrideWarningText
  )
  expect_identical(nrow(m), 1L)
  expect_identical(m$nPairs, 0L)
  expect_false(m$overridden)
  ## the census is still the ten animals; every level but HYBRID is uncovered
  expect_identical(m$nHybrid, 1L)
  expect_identical(m$nUncovered, 9L)
})
