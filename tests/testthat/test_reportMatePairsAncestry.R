## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #169 Slice 1 RED: reportMatePairs(..., ancestryRules = NULL,
## overriddenRules = NULL) is the script-callable kernel that applies the
## shipped issue #168 ancestry rules to individual mate pairs. Contract:
## docs/planning/mate-pair-ancestry-guardrails-plan.md, decisions D1-D6 and
## section 5 Slice 1 (done-when items 1-7).
##
## Shape pinned at this RED (owner-ratified gates):
##  * NULL rules => identical() to today's list(pairs, excluded) (D4-1).
##  * Any non-NULL rules (even a valid zero-rule table) => `pairs` gains
##    ancestryRule / ancestrySeverity / ancestryStatus AFTER damGu, `excluded`
##    gains ancestryRule, and the list gains `ancestryCoverage` (D4-4/D6c),
##    on EVERY path including the three empty ones.
##  * block => the pair leaves `pairs` and enters `excluded` with reason
##    "ancestry rule" (D2); flag => stays in `pairs`, status "violation";
##    an overridden block rule's pairs stay in `pairs`, status "overridden".
##  * overriddenRules: ancestry1/ancestry2 columns like
##    reportAncestryViolations(); an optional `reason` column is accepted and
##    ignored; an override naming no real rule, a FLAG rule, a duplicated
##    rule, or given without ancestryRules is an error (owner answer, S774).
##  * The ancestry screen runs LAST (D5): a pair that fails the age or the
##    user-exclude screen keeps that reason and is not an ancestry match.
##  * ancestryCoverage mirrors reportAncestryViolations()'s coverage (six
##    fixed level rows: ancestry, n, covered); its universe is the distinct
##    animals in pairs + excluded; an NA-level animal matches nothing and is
##    counted in no row (refines D1's looser "counted as uncovered").
##
## Fixture: the shipped inst/extdata/examples/example_ancestry_{pedigree,
## rules}.csv (10 animals, no new fixture file needed -- plan 1.3). Hand-
## derived: 25 male x female pairs; 5 block (C1xI2, I1xC2, A1xC2, I1xH1,
## A1xH1), 3 flag (I1xU1, A1xU1, O1xI2), 17 unmatched; census CHINESE 2,
## INDIAN 3, HYBRID 1, JAPANESE 2, OTHER 1, UNKNOWN 1.

mpaLevels <- c("CHINESE", "INDIAN", "HYBRID", "JAPANESE", "OTHER", "UNKNOWN")
baseCols <- c(
  "sireId", "damId", "kinship", "markerKinship", "sireIndivMeanKin",
  "sireGu", "damIndivMeanKin", "damGu"
)
ancCols <- c("ancestryRule", "ancestrySeverity", "ancestryStatus")
blockKeys <- c("C1|I2", "I1|C2", "A1|C2", "I1|H1", "A1|H1")
flagKeys <- c("I1|U1", "A1|U1", "O1|I2")

mpaPed <- local({
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
mpaKmat <- kinship(mpaPed$id, mpaPed$sire, mpaPed$dam, mpaPed$gen)
mpaRules <- checkAncestryRules(readAncestryRules(system.file(
  "extdata", "examples", "example_ancestry_rules.csv",
  package = "nprcgenekeepr"
)))

mpaKey <- function(d) paste(d$sireId, d$damId, sep = "|")
noRn <- function(d) {
  rownames(d) <- NULL
  d
}
mpaOv <- function(a1, a2, ...) {
  data.frame(ancestry1 = a1, ancestry2 = a2, ..., stringsAsFactors = FALSE)
}
mpaRun <- function(..., minAge = 1, ped = mpaPed) {
  reportMatePairs(ped, mpaKmat, minAge = minAge, ...)
}

test_that("fixture premise: the shipped ancestry fixtures give 25 pairs, 0 excluded, the hand-derived census (plan 1.3)", {
  base <- mpaRun()
  expect_identical(nrow(base$pairs), 25L)
  expect_identical(nrow(base$excluded), 0L)
  expect_true(all(c(blockKeys, flagKeys) %in% mpaKey(base$pairs)))
  expect_identical(
    unname(table(factor(as.character(mpaPed$ancestry), levels = mpaLevels))),
    unname(table(factor(rep(mpaLevels, c(2, 3, 1, 2, 1, 1)),
      levels = mpaLevels
    )))
  )
})

test_that("D4-1: NULL rules are identical() to today's result, argument omitted or explicit -- even without an ancestry column", {
  base <- mpaRun()
  expect_named(base, c("pairs", "excluded"))
  expect_identical(names(base$pairs), baseCols)
  expect_identical(names(base$excluded), c("sireId", "damId", "reason"))
  expect_identical(mpaRun(ancestryRules = NULL), base)
  expect_identical(mpaRun(ancestryRules = NULL, overriddenRules = NULL), base)
  ## zero-row overrides are "no overrides", not an error, with NULL rules
  expect_identical(
    mpaRun(ancestryRules = NULL, overriddenRules = mpaOv(character(0), character(0))),
    base
  )
  ## a pedigree with no ancestry column runs exactly as today without rules
  noAnc <- mpaPed[, setdiff(names(mpaPed), "ancestry")]
  expect_identical(mpaRun(ancestryRules = NULL, ped = noAnc), base)
})

test_that("hand-derived counts: 25 pairs -> 20 eligible (3 flagged) / 5 ancestry-excluded, both rule orientations", {
  res <- mpaRun(ancestryRules = mpaRules)
  expect_named(res, c("pairs", "excluded", "ancestryCoverage"))
  expect_identical(names(res$pairs), c(baseCols, ancCols))
  expect_identical(
    names(res$excluded), c("sireId", "damId", "reason", "ancestryRule")
  )
  expect_identical(nrow(res$pairs), 20L)
  expect_identical(nrow(res$excluded), 5L)

  ## block: C1xI2 is CHINESE male x INDIAN female, I1xC2 the reverse
  expect_setequal(mpaKey(res$excluded), blockKeys)
  expect_true(all(res$excluded$reason == "ancestry rule"))
  ex <- res$excluded
  expect_identical(
    ex$ancestryRule[match(c("C1|I2", "I1|C2", "A1|C2"), mpaKey(ex))],
    rep("CHINESE-INDIAN", 3L)
  )
  expect_identical(
    ex$ancestryRule[match(c("I1|H1", "A1|H1"), mpaKey(ex))],
    rep("HYBRID-INDIAN", 2L)
  )

  ## flag: kept in pairs, annotated
  fl <- res$pairs[!is.na(res$pairs$ancestryRule), ]
  expect_setequal(mpaKey(fl), flagKeys)
  expect_true(all(fl$ancestrySeverity == "flag"))
  expect_true(all(fl$ancestryStatus == "violation"))
  expect_identical(
    fl$ancestryRule[match(c("I1|U1", "A1|U1", "O1|I2"), mpaKey(fl))],
    c("INDIAN-UNKNOWN", "INDIAN-UNKNOWN", "INDIAN-OTHER")
  )

  ## unmatched: NA in all three annotation columns
  un <- res$pairs[is.na(res$pairs$ancestryRule), ]
  expect_identical(nrow(un), 17L)
  expect_true(all(is.na(un$ancestrySeverity)))
  expect_true(all(is.na(un$ancestryStatus)))
  expect_type(res$pairs$ancestryRule, "character")
  expect_type(res$pairs$ancestrySeverity, "character")
  expect_type(res$pairs$ancestryStatus, "character")
  expect_type(res$excluded$ancestryRule, "character")
})

test_that("D4-2/D4-3/D5: rules never change age/user exclusions and never drop or invent a pair; a pair failing an earlier screen keeps that reason", {
  ## minAge 25 age-excludes A1 and H1 (21.3); "C2" is user-excluded. A1xC2
  ## matches a block rule but fails the age screen first; I1xC2 matches too
  ## but is user-excluded; C1xI2 is the only remaining block match.
  base <- mpaRun(minAge = 25, exclude = "C2")
  res <- mpaRun(minAge = 25, exclude = "C2", ancestryRules = mpaRules)

  earlier <- res$excluded[res$excluded$reason != "ancestry rule", ]
  expect_identical(
    noRn(earlier[, c("sireId", "damId", "reason")]), noRn(base$excluded)
  )
  expect_true(all(is.na(earlier$ancestryRule)))
  expect_identical(
    earlier$reason[match("A1|C2", mpaKey(earlier))], "under minimum age"
  )
  expect_identical(
    earlier$reason[match("I1|C2", mpaKey(earlier))], "user-excluded"
  )

  ## conservation: the same pair set with and without rules, no duplicates
  allBase <- c(mpaKey(base$pairs), mpaKey(base$excluded))
  allRules <- c(mpaKey(res$pairs), mpaKey(res$excluded))
  expect_identical(anyDuplicated(allRules), 0L)
  expect_setequal(allRules, allBase)
  expect_identical(length(allRules), length(allBase))

  ## only the otherwise-eligible C1xI2 became an ancestry exclusion
  anc <- res$excluded[res$excluded$reason == "ancestry rule", ]
  expect_identical(mpaKey(anc), "C1|I2")
  expect_true(all(mpaKey(anc) %in% mpaKey(base$pairs)))

  ## survivors keep their relative order and their first eight columns
  keep <- mpaKey(base$pairs) %in% mpaKey(res$pairs)
  expect_identical(mpaKey(res$pairs), mpaKey(base$pairs)[keep])
  expect_identical(noRn(res$pairs[, baseCols]), noRn(base$pairs[keep, ]))

  ## D5: animals that only appear in `excluded` are still in the census
  expect_identical(res$ancestryCoverage$n, c(2L, 3L, 1L, 2L, 1L, 1L))
})

test_that("overriding CHINESE x INDIAN: 23 eligible (3 overridden) / 2 excluded -- any orientation, any case, reason ignored", {
  overrides <- list(
    mpaOv("CHINESE", "INDIAN"),
    mpaOv("indian", " Chinese "),
    mpaOv("CHINESE", "INDIAN", reason = "founder rotation")
  )
  for (ov in overrides) {
    res <- mpaRun(ancestryRules = mpaRules, overriddenRules = ov)
    expect_identical(nrow(res$pairs), 23L)
    expect_identical(nrow(res$excluded), 2L)
    expect_setequal(mpaKey(res$excluded), c("I1|H1", "A1|H1"))
    expect_true(all(res$excluded$reason == "ancestry rule"))
    ovr <- res$pairs[which(res$pairs$ancestryStatus == "overridden"), ]
    expect_setequal(mpaKey(ovr), c("C1|I2", "I1|C2", "A1|C2"))
    expect_true(all(ovr$ancestrySeverity == "block"))
    expect_true(all(ovr$ancestryRule == "CHINESE-INDIAN"))
    expect_identical(sum(res$pairs$ancestryStatus == "violation", na.rm = TRUE), 3L)
  }
})

test_that("overrides: every block rule overridden keeps all 25 listed; a valid override matching no pair changes nothing; zero-row overrides are none", {
  both <- mpaRun(
    ancestryRules = mpaRules,
    overriddenRules = mpaOv(c("CHINESE", "HYBRID"), c("INDIAN", "INDIAN"))
  )
  expect_identical(nrow(both$pairs), 25L)
  expect_identical(nrow(both$excluded), 0L)
  expect_identical(sum(both$pairs$ancestryStatus == "overridden", na.rm = TRUE), 5L)

  ## HYBRID-HYBRID is a real block rule that no pair in this pedigree matches
  rules2 <- rbind(
    mpaRules,
    data.frame(ancestry1 = "HYBRID", ancestry2 = "HYBRID", severity = "block")
  )
  noMatch <- mpaRun(
    ancestryRules = rules2, overriddenRules = mpaOv("HYBRID", "HYBRID")
  )
  expect_identical(nrow(noMatch$excluded), 5L)
  expect_identical(nrow(noMatch$pairs), 20L)

  none <- mpaRun(
    ancestryRules = mpaRules,
    overriddenRules = mpaOv(character(0), character(0))
  )
  expect_identical(none, mpaRun(ancestryRules = mpaRules))
})

test_that("D4-4: a valid zero-rule table yields the ancestry columns and coverage with nothing moved", {
  zero <- data.frame(
    ancestry1 = character(0), ancestry2 = character(0),
    severity = character(0), stringsAsFactors = FALSE
  )
  base <- mpaRun()
  res <- mpaRun(ancestryRules = zero)
  expect_named(res, c("pairs", "excluded", "ancestryCoverage"))
  expect_identical(names(res$pairs), c(baseCols, ancCols))
  expect_identical(noRn(res$pairs[, baseCols]), base$pairs)
  for (col in ancCols) expect_true(all(is.na(res$pairs[[col]])))
  expect_identical(nrow(res$excluded), 0L)
  expect_identical(
    names(res$excluded), c("sireId", "damId", "reason", "ancestryRule")
  )
  expect_identical(res$ancestryCoverage$n, c(2L, 3L, 1L, 2L, 1L, 1L))
  expect_false(any(res$ancestryCoverage$covered))
})

test_that("flag-only rules annotate but never move a pair", {
  flagOnly <- mpaRules[mpaRules$severity == "flag", ]
  res <- mpaRun(ancestryRules = flagOnly)
  expect_identical(nrow(res$pairs), 25L)
  expect_identical(nrow(res$excluded), 0L)
  expect_setequal(mpaKey(res$pairs[!is.na(res$pairs$ancestryRule), ]), flagKeys)
})

test_that("a self-pair rule (INDIAN-INDIAN) matches same-level pairs", {
  rules <- data.frame(
    ancestry1 = "INDIAN", ancestry2 = "INDIAN", severity = "block"
  )
  res <- mpaRun(ancestryRules = rules)
  expect_setequal(mpaKey(res$excluded), c("I1|I2", "A1|I2"))
  expect_true(all(res$excluded$ancestryRule == "INDIAN-INDIAN"))
  expect_identical(nrow(res$pairs), 23L)
})

test_that("ancestryCoverage: six fixed level rows, hand-derived census, JAPANESE the only uncovered level, equal to the group reporter's", {
  cov <- mpaRun(ancestryRules = mpaRules)$ancestryCoverage
  expect_s3_class(cov, "data.frame")
  expect_named(cov, c("ancestry", "n", "covered"))
  expect_identical(cov$ancestry, mpaLevels)
  expect_identical(cov$n, c(2L, 3L, 1L, 2L, 1L, 1L))
  expect_identical(cov$covered, c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE))
  ref <- reportAncestryViolations(list(mpaPed$id), mpaPed, mpaRules)$coverage
  expect_identical(cov, ref)
})

test_that("coverage universe is the animals the report considered, not the whole pedigree", {
  res <- mpaRun(
    populationIds = c("C1", "I2", "J1"), ancestryRules = mpaRules
  )
  expect_identical(mpaKey(res$excluded), "C1|I2")
  expect_identical(mpaKey(res$pairs), "J1|I2")
  expect_identical(res$ancestryCoverage$n, c(1L, 1L, 0L, 1L, 0L, 0L))
})

test_that("D4-4: the shape depends on the argument, never the data, on every empty path", {
  wantPairs <- c(baseCols, ancCols)
  wantExcl <- c("sireId", "damId", "reason", "ancestryRule")
  covered <- c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE)

  ## (a) scoped to nobody; (b) scoped to two same-sex animals
  for (ids in list(character(0), c("C1", "J1"))) {
    res <- mpaRun(populationIds = ids, ancestryRules = mpaRules)
    expect_named(res, c("pairs", "excluded", "ancestryCoverage"))
    expect_identical(nrow(res$pairs), 0L)
    expect_identical(names(res$pairs), wantPairs)
    expect_identical(nrow(res$excluded), 0L)
    expect_identical(names(res$excluded), wantExcl)
    expect_type(res$pairs$ancestryRule, "character")
    expect_identical(res$ancestryCoverage$ancestry, mpaLevels)
    expect_identical(res$ancestryCoverage$n, rep(0L, 6L))
    expect_identical(res$ancestryCoverage$covered, covered)
  }

  ## (c) every candidate pair fails the age screen: zero rows in `pairs`
  ## after the screens, and the census still counts the excluded animals
  allAge <- mpaRun(minAge = 100, ancestryRules = mpaRules)
  expect_identical(nrow(allAge$pairs), 0L)
  expect_identical(names(allAge$pairs), wantPairs)
  expect_identical(nrow(allAge$excluded), 25L)
  expect_true(all(allAge$excluded$reason == "under minimum age"))
  expect_true(all(is.na(allAge$excluded$ancestryRule)))
  expect_identical(allAge$ancestryCoverage$n, c(2L, 3L, 1L, 2L, 1L, 1L))

  ## without rules the same paths keep today's two-element shape
  expect_named(
    mpaRun(populationIds = character(0)), c("pairs", "excluded")
  )
})

test_that("stop paths: rules on a pedigree with no ancestry column fail loudly -- before any early return", {
  ## message parity with reportAncestryViolations() (plan D1); the phrase is
  ## specific on purpose -- a bare "ancestry" also matches R's own
  ## "unused argument (ancestryRules = ...)" error
  noAnc <- mpaPed[, setdiff(names(mpaPed), "ancestry")]
  expect_error(
    mpaRun(ancestryRules = mpaRules, ped = noAnc), "has no 'ancestry' column"
  )
  expect_error(
    mpaRun(populationIds = character(0), ancestryRules = mpaRules, ped = noAnc),
    "has no 'ancestry' column"
  )
})

test_that("stop paths: malformed rules fail loudly through checkAncestryRules(), before any early return", {
  noSeverity <- mpaRules[, c("ancestry1", "ancestry2")]
  badLevel <- mpaRules
  badLevel$ancestry1[1L] <- "MARTIAN"
  badSeverity <- mpaRules
  badSeverity$severity[1L] <- "veto"
  dupRule <- rbind(mpaRules, mpaRules[1L, ])
  expect_error(mpaRun(ancestryRules = noSeverity), "Ancestry rules must have columns")
  expect_error(mpaRun(ancestryRules = badLevel), "outside the standardized")
  expect_error(mpaRun(ancestryRules = badSeverity), "'severity' values must be")
  expect_error(mpaRun(ancestryRules = dupRule), "duplicated \\(unordered\\) pair")
  expect_error(
    mpaRun(populationIds = character(0), ancestryRules = badLevel),
    "outside the standardized"
  )
})

test_that("stop paths: an override that names nothing real, a flag rule, a duplicate, lacks columns, or has no rules fails loudly", {
  ## phrases mirror reportAncestryViolations()'s own overriddenRules errors
  ## (and are specific enough that R's "unused argument" text cannot match)
  run <- function(ov) mpaRun(ancestryRules = mpaRules, overriddenRules = ov)
  expect_error(
    run(mpaOv("INDIAN", "JAPANESE")), "overriddenRules contains rule\\(s\\) not present in rules"
  )
  expect_error(
    run(mpaOv("INDIAN", "UNKNOWN")), "only block rules can be overridden"
  )
  expect_error(
    run(mpaOv(c("CHINESE", "INDIAN"), c("INDIAN", "CHINESE"))),
    "overriddenRules contains duplicated"
  )
  expect_error(
    run(data.frame(ancestry1 = "CHINESE")), "overriddenRules must have columns"
  )
  expect_error(
    mpaRun(overriddenRules = mpaOv("CHINESE", "INDIAN")),
    "overriddenRules given without ancestryRules"
  )
})

test_that("the validator's UNKNOWN-without-OTHER warning is inherited and fires exactly once, with or without overrides", {
  countWarnings <- function(expr) {
    n <- 0L
    withCallingHandlers(
      expr,
      warning = function(w) {
        n <<- n + 1L
        invokeRestart("muffleWarning")
      }
    )
    n
  }
  unkOnly <- data.frame(
    ancestry1 = "INDIAN", ancestry2 = "UNKNOWN", severity = "flag"
  )
  expect_identical(countWarnings(mpaRun(ancestryRules = unkOnly)), 1L)
  unkBlock <- data.frame(
    ancestry1 = "INDIAN", ancestry2 = "UNKNOWN", severity = "block"
  )
  expect_identical(
    countWarnings(mpaRun(
      ancestryRules = unkBlock, overriddenRules = mpaOv("INDIAN", "UNKNOWN")
    )),
    1L
  )
})

test_that("levels are normalised like the group reporter: case, whitespace, factor, and NA (Dragon 3)", {
  mk <- function(anc) {
    data.frame(
      id = c("M1", "M2", "F1", "F2"), sire = NA_character_,
      dam = NA_character_, sex = c("M", "M", "F", "F"), age = 5,
      ancestry = anc, stringsAsFactors = FALSE
    )
  }
  founderK <- function(p) {
    k <- diag(0.5, nrow(p))
    dimnames(k) <- list(p$id, p$id)
    k
  }
  rules <- data.frame(
    ancestry1 = c("INDIAN", "INDIAN", "OTHER"),
    ancestry2 = c("CHINESE", "UNKNOWN", "UNKNOWN"),
    severity = c("block", "flag", "flag"), stringsAsFactors = FALSE
  )
  variants <- list(
    mk(c(" indian ", NA, "Chinese", "UNKNOWN")),
    mk(factor(c("INDIAN", NA, "CHINESE", "UNKNOWN"), levels = mpaLevels))
  )
  for (p in variants) {
    res <- reportMatePairs(p, founderK(p), minAge = 1, ancestryRules = rules)
    expect_identical(mpaKey(res$excluded), "M1|F1")
    expect_identical(res$excluded$ancestryRule, "CHINESE-INDIAN")
    flagged <- res$pairs[!is.na(res$pairs$ancestryRule), ]
    expect_identical(mpaKey(flagged), "M1|F2")
    expect_identical(flagged$ancestryRule, "INDIAN-UNKNOWN")
    ## M2 has an NA level: matches nothing, and is counted in no row
    expect_setequal(
      mpaKey(res$pairs[is.na(res$pairs$ancestryRule), ]), c("M2|F1", "M2|F2")
    )
    expect_identical(res$ancestryCoverage$n, c(1L, 1L, 0L, 0L, 0L, 1L))
  }
})

test_that("scaling guard: 10^5 candidate pairs are matched without a per-pair R loop", {
  skip_on_cran()
  n <- 640L
  ids <- sprintf("A%04d", seq_len(n))
  ancestry <- rep(mpaLevels, length.out = n)
  bigPed <- data.frame(
    id = ids, sire = NA_character_, dam = NA_character_,
    sex = rep(c("M", "F"), each = n / 2L), age = 10, ancestry = ancestry,
    stringsAsFactors = FALSE
  )
  bigK <- diag(0.5, n)
  dimnames(bigK) <- list(ids, ids)
  rules <- data.frame(
    ancestry1 = c("INDIAN", "HYBRID"), ancestry2 = c("CHINESE", "JAPANESE"),
    severity = c("block", "flag"), stringsAsFactors = FALSE
  )
  elapsed <- system.time(
    res <- reportMatePairs(bigPed, bigK, minAge = 1, ancestryRules = rules)
  )[["elapsed"]]
  ## a vectorised matcher takes ~1 s here; looping reportAncestryViolations()
  ## over two-animal groups measured ~0.5 ms per pair (~50 s)
  expect_lt(elapsed, 10)

  ## independent oracle: count the block/flag pairs from the level table
  male <- factor(ancestry[seq_len(n / 2L)], levels = mpaLevels)
  female <- factor(ancestry[n / 2L + seq_len(n / 2L)], levels = mpaLevels)
  tab <- table(male, female)
  nBlock <- tab["INDIAN", "CHINESE"] + tab["CHINESE", "INDIAN"]
  nFlag <- tab["HYBRID", "JAPANESE"] + tab["JAPANESE", "HYBRID"]
  expect_identical(nrow(res$excluded), as.integer(nBlock))
  expect_identical(nrow(res$pairs), as.integer((n / 2L)^2 - nBlock))
  expect_identical(sum(!is.na(res$pairs$ancestryRule)), as.integer(nFlag))
})
