## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #168 Slice 2 (RED): groupAddAssign() gains an optional
# `ancestryRules = NULL` argument. Block-severity rules merge their
# conflicting pairs into the existing `kin` conflict list ONCE, upstream of
# the current-group conflict filter and of the sampling/exhaustive mode fork
# (never inside the iter loop -- D7/Dragon 1), so candidate selection can
# never co-place a blocked pair in sampling, exhaustive, and sexRatio modes.
# Flag rules never touch the search (D3). D7 pins: `ancestryRules = NULL`
# and flag-only rules are same-seed identical to the pre-change behavior.
#
# HAREM LIMITATION (owner-ratified this session): a harem's sire is sampled
# into the group at initialization (initializeHaremGroups()), and the fill
# loop applies conflict exclusions only for animals the loop itself places
# (fillGroupMembers.R). The existing KINSHIP machinery therefore does not
# exclude the sire's own conflicts either -- ancestry blocking inherits
# exactly that seam: blocks among loop-placed members are enforced; blocks
# against the sampled sire are not. The limitation is pinned by an explicit
# test below and documented in the roxygen for `ancestryRules`.

ancestryPed <- function() {
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

ancestryKmat <- function(ped) {
  kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
}

exampleAncestryRules <- function() {
  checkAncestryRules(readAncestryRules(system.file(
    "extdata", "examples", "example_ancestry_rules.csv",
    package = "nprcgenekeepr"
  )))
}

## Independent hand-rolled violation finder (deliberately NOT the package
## helper, so the property tests do not test the code with itself). Returns
## one "id-id" key per within-group pair matching a rule of the requested
## severity.
violatingPairKeys <- function(groups, ped, rules, severities = "block") {
  rules <- rules[rules$severity %in% severities, , drop = FALSE]
  found <- character(0L)
  for (g in seq_along(groups)) {
    ids <- groups[[g]]
    ids <- ids[!is.na(ids)]
    if (length(ids) < 2L) {
      next
    }
    lev <- toupper(as.character(ped$ancestry[match(ids, ped$id)]))
    cmb <- utils::combn(seq_along(ids), 2L)
    for (k in seq_len(ncol(cmb))) {
      a <- lev[cmb[1L, k]]
      b <- lev[cmb[2L, k]]
      hit <- (rules$ancestry1 == a & rules$ancestry2 == b) |
        (rules$ancestry1 == b & rules$ancestry2 == a)
      if (any(hit)) {
        found <- c(found, paste(
          sort(c(ids[cmb[1L, k]], ids[cmb[2L, k]])),
          collapse = "-"
        ))
      }
    }
  }
  found
}

test_that("groupAddAssign with ancestryRules = NULL is identical to omitting the argument", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  set_seed(42L)
  base <- groupAddAssign(
    candidates = ped$id, kmat = kmat, ped = ped,
    iter = 20L, numGp = 2L
  )
  set_seed(42L)
  withNull <- groupAddAssign(
    candidates = ped$id, kmat = kmat, ped = ped,
    iter = 20L, numGp = 2L, ancestryRules = NULL
  )
  expect_identical(withNull, base)
})

test_that("flag-only rules leave formation same-seed identical to no rules", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  ## names both UNKNOWN and OTHER, so no D6 asymmetry warning
  flagOnly <- data.frame(
    ancestry1 = c("INDIAN", "INDIAN"),
    ancestry2 = c("UNKNOWN", "OTHER"),
    severity = c("flag", "flag"),
    stringsAsFactors = FALSE
  )
  set_seed(7L)
  base <- groupAddAssign(
    candidates = ped$id, kmat = kmat, ped = ped,
    iter = 20L, numGp = 2L
  )
  set_seed(7L)
  flagged <- groupAddAssign(
    candidates = ped$id, kmat = kmat, ped = ped,
    iter = 20L, numGp = 2L, ancestryRules = flagOnly
  )
  expect_identical(flagged, base)
})

test_that("block rules are never violated in sampling mode across seeds", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  rules <- exampleAncestryRules()
  for (s in 1L:5L) {
    set_seed(s)
    res <- groupAddAssign(
      candidates = ped$id, kmat = kmat, ped = ped,
      iter = 10L, numGp = 2L, ancestryRules = rules
    )
    formed <- res$group[seq_len(2L)]
    expect_identical(violatingPairKeys(formed, ped, rules), character(0L))
  }
})

test_that("block rules are never violated in exhaustive mode, in any retained candidate", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  rules <- exampleAncestryRules()
  res <- groupAddAssign(
    candidates = ped$id, kmat = kmat, ped = ped,
    numGp = 1L, exhaustive = TRUE, ancestryRules = rules
  )
  for (cand in res$candidates) {
    formed <- cand$group[1L]
    expect_identical(violatingPairKeys(formed, ped, rules), character(0L))
  }
})

test_that("block rules are never violated in sexRatio mode across seeds", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  rules <- exampleAncestryRules()
  for (s in 1L:3L) {
    set_seed(s)
    res <- groupAddAssign(
      candidates = ped$id, kmat = kmat, ped = ped,
      iter = 10L, numGp = 1L, sexRatio = 1.0, ancestryRules = rules
    )
    formed <- res$group[1L]
    expect_identical(violatingPairKeys(formed, ped, rules), character(0L))
  }
})

test_that("block rules bind harem members placed by the fill loop", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  rules <- exampleAncestryRules()
  for (s in 1L:3L) {
    set_seed(s)
    res <- groupAddAssign(
      candidates = ped$id, kmat = kmat, ped = ped,
      iter = 10L, numGp = 1L, harem = TRUE, ancestryRules = rules
    )
    ## the sire is seeded first; the loop-placed remainder must be block-free
    loopPlaced <- res$group[[1L]][-1L]
    expect_identical(
      violatingPairKeys(list(loopPlaced), ped, rules),
      character(0L)
    )
  }
})

test_that("harem sire seeding bypasses ancestry blocking (documented limitation)", {
  ## The only possible sire (I1, INDIAN) plus the only fillable female
  ## (C2, CHINESE) match a block rule, yet ARE co-placed: the sampled sire's
  ## conflicts are never applied to the fill loop's available list -- the
  ## same seam the kinship machinery has. Pinned deliberately; a change in
  ## this behavior must be its own gated decision.
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  rules <- exampleAncestryRules()
  set_seed(1L)
  res <- groupAddAssign(
    candidates = c("I1", "C2"), kmat = kmat, ped = ped,
    iter = 5L, numGp = 1L, harem = TRUE, ancestryRules = rules
  )
  expect_setequal(res$group[[1L]], c("I1", "C2"))
})

test_that("candidates ancestry-blocked against a current group member are never placed", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  rules <- exampleAncestryRules()
  for (s in 1L:3L) {
    set_seed(s)
    res <- groupAddAssign(
      candidates = setdiff(ped$id, "I1"), kmat = kmat, ped = ped,
      currentGroups = list("I1"),
      iter = 10L, numGp = 1L, ancestryRules = rules
    )
    ## I1 is INDIAN: CHINESE (C1, C2) and HYBRID (H1) candidates are blocked
    expect_false(any(c("C1", "C2", "H1") %in% res$group[[1L]]))
    expect_identical(
      violatingPairKeys(res$group[1L], ped, rules),
      character(0L)
    )
  }
})

test_that("an F-F pair matching a block rule is excluded while F-F kinship stays ignored", {
  ## I2 (INDIAN, F) and H1 (HYBRID, F) are mother and daughter (kinship
  ## 0.25), exempted by the default ignore = list(c("F", "F")); INDIAN x
  ## HYBRID is a block rule in the example rules file. Ancestry enforcement
  ## is sex-blind (D3), so the same pair that kinship ignores is blocked.
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  rules <- exampleAncestryRules()
  set_seed(3L)
  noRules <- groupAddAssign(
    candidates = c("I2", "H1"), kmat = kmat, ped = ped,
    iter = 5L, numGp = 1L
  )
  expect_setequal(noRules$group[[1L]], c("I2", "H1"))
  set_seed(3L)
  withRules <- groupAddAssign(
    candidates = c("I2", "H1"), kmat = kmat, ped = ped,
    iter = 5L, numGp = 1L, ancestryRules = rules
  )
  expect_length(withRules$group[[1L]], 1L)
})

test_that("groupAddAssign stops when rules are supplied but ped has no ancestry column", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  rules <- exampleAncestryRules()
  pedNoAncestry <- ped[, setdiff(names(ped), "ancestry")]
  expect_error(
    groupAddAssign(
      candidates = ped$id, kmat = kmat, ped = pedNoAncestry,
      iter = 5L, numGp = 1L, ancestryRules = rules
    ),
    "no 'ancestry' column"
  )
})

test_that("groupAddAssign stops on malformed ancestry rules", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  badSeverity <- data.frame(
    ancestry1 = "INDIAN", ancestry2 = "CHINESE", severity = "warn",
    stringsAsFactors = FALSE
  )
  expect_error(
    groupAddAssign(
      candidates = ped$id, kmat = kmat, ped = ped,
      iter = 5L, numGp = 1L, ancestryRules = badSeverity
    ),
    "severity"
  )
  expect_error(
    groupAddAssign(
      candidates = ped$id, kmat = kmat, ped = ped,
      iter = 5L, numGp = 1L,
      ancestryRules = data.frame(wrong = 1L)
    ),
    "missing"
  )
})

test_that("active block rules leave the return shape unchanged", {
  ped <- ancestryPed()
  kmat <- ancestryKmat(ped)
  rules <- exampleAncestryRules()
  set_seed(2L)
  res <- groupAddAssign(
    candidates = ped$id, kmat = kmat, ped = ped,
    iter = 5L, numGp = 1L, ancestryRules = rules
  )
  expect_true(all(c("group", "score", "candidates") %in% names(res)))
  ## no new top-level fields ride the argument (violations are reported by
  ## reportAncestryViolations(), never by the former itself -- D3)
  expect_false(any(c("violations", "coverage", "ancestry") %in% names(res)))
})
