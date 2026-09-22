## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #167 Slice 3: calcSnapshotDeltas(history, from, to,
# membershipRule = NULL) compares two same-rule snapshots from a validated
# history and returns a per-metric delta table (plan section 5 Slice 3; D6)
# with the D4 comparability flag column. Owner decisions (S759, pre-RED):
# (1) the membershipRule argument was added to the plan's catalog signature
# because a snapshot is identified by the (snapshotDate, membershipRule)
# pair and the fixture proves a date alone can be ambiguous -- NULL
# auto-resolves a single-rule history and stop()s, naming the rules, when
# several are present; deltas always compare like with like (D3), never
# across rules. (2) The table has one row per numeric column -- the 18
# metric columns plus the 3 composition counts (churn visibility, Dragon 3)
# -- with columns metric/from/to/delta/comparabilityFlag. The flag is
# NA_character_ when the two snapshots are comparable; otherwise it names
# each differing provenance field and both values. Flag sets are
# evidence-based (verified from R/reportGV.R, S759): guIter drives the gene
# drop feeding fg/fgSE/neGD AND the gu aggregates (8 rows); guThresh
# reaches only calcGU() (the 5 gu aggregate rows); a packageVersion
# difference flags every row.

validatedSnapshotHistory <- function() {
  checkSnapshotHistory(read.csv(system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  ), stringsAsFactors = FALSE))
}

## The 21 numeric (non-provenance-string) schema columns, in schema order.
deltaMetrics <- c(
  "nAnimals", "nMales", "nFemales",
  "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
  "nMaleFounders", "nFemaleFounders", "nFounders",
  "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
  "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
  "skewnessGu", "kurtosisGu"
)

## Gene-drop-affected metrics: guIter feeds the geneDrop() call whose alleles
## reach calcFEFG() (fg, fgSE, and neGD via calcGeneDiversity(FG)) and
## calcGU() (the gu aggregates). guThresh reaches only calcGU().
guIterAffected <- c(
  "fg", "fgSE", "neGD",
  "meanGu", "medianGu", "meanGuSE", "skewnessGu", "kurtosisGu"
)
guThreshAffected <- c(
  "meanGu", "medianGu", "meanGuSE", "skewnessGu", "kurtosisGu"
)

## One plausible snapshot row with controllable provenance fields, for
## constructing histories with known comparability.
makeSnapshotRow <- function(snapshotDate,
                            membershipRule = "wholePedigree",
                            packageVersion = "2.0.0.9000",
                            guIter = 10000L,
                            guThresh = 3L) {
  data.frame(
    schemaVersion = 1L,
    snapshotDate = as.Date(snapshotDate),
    packageVersion = packageVersion,
    membershipRule = membershipRule,
    guIter = guIter,
    guThresh = guThresh,
    nAnimals = 390L,
    nMales = 130L,
    nFemales = 260L,
    fe = 14.9,
    fg = 9.1,
    fgSE = 0.13,
    neGD = 44.2,
    neSexRatio = 231.1,
    neVariance = 198.3,
    nMaleFounders = 12L,
    nFemaleFounders = 24L,
    nFounders = 36L,
    meanIndivMeanKin = 0.0798,
    medianIndivMeanKin = 0.0781,
    skewnessIndivMeanKin = 0.38,
    kurtosisIndivMeanKin = 2.8,
    meanGu = 0.229,
    medianGu = 0.221,
    meanGuSE = 0.0027,
    skewnessGu = 0.3,
    kurtosisGu = 3.0,
    stringsAsFactors = FALSE
  )
}

test_that("calcSnapshotDeltas returns the 21-row delta table in schema order", {
  deltas <- calcSnapshotDeltas(validatedSnapshotHistory(),
    from = "2025-01-15", to = "2025-07-15",
    membershipRule = "wholePedigree"
  )
  expect_s3_class(deltas, "data.frame")
  expect_identical(
    names(deltas),
    c("metric", "from", "to", "delta", "comparabilityFlag")
  )
  expect_identical(nrow(deltas), 21L)
  expect_identical(deltas$metric, deltaMetrics)
  expect_type(deltas$metric, "character")
  expect_true(is.numeric(deltas$from))
  expect_true(is.numeric(deltas$to))
  expect_true(is.numeric(deltas$delta))
  expect_type(deltas$comparabilityFlag, "character")
})

test_that("deltas match hand-computed values on the fixture", {
  ## wholePedigree 2025-01-15 -> 2025-07-15, values hand-copied from
  ## inst/extdata/examples/example_snapshot_history.csv rows 1 and 2, in
  ## deltaMetrics (schema) order.
  fromExpected <- c(
    360, 120, 240,
    14.2, 8.6, 0.21, 42.5, 213.3, 187.4,
    12, 24, 36,
    0.0812, 0.0794, 0.42, 2.9, 0.213, 0.205, 0.0041, 0.35, 3.1
  )
  toExpected <- c(
    372, 124, 248,
    14.5, 8.8, 0.2, 43.1, 220.6, 191.2,
    12, 24, 36,
    0.0805, 0.0788, 0.4, 2.8, 0.219, 0.211, 0.004, 0.33, 3.0
  )
  deltas <- calcSnapshotDeltas(validatedSnapshotHistory(),
    from = "2025-01-15", to = "2025-07-15",
    membershipRule = "wholePedigree"
  )
  expect_equal(deltas$from, fromExpected)
  expect_equal(deltas$to, toExpected)
  expect_equal(deltas$delta, toExpected - fromExpected)
})

test_that("date arguments accept character and Date equally", {
  history <- validatedSnapshotHistory()
  fromCharacter <- calcSnapshotDeltas(history,
    from = "2025-01-15", to = "2025-07-15",
    membershipRule = "wholePedigree"
  )
  fromDate <- calcSnapshotDeltas(history,
    from = as.Date("2025-01-15"), to = as.Date("2025-07-15"),
    membershipRule = "wholePedigree"
  )
  expect_identical(fromCharacter, fromDate)
})

test_that("a shared date resolves to the requested membership rule", {
  ## 2026-01-15 exists under BOTH rules in the fixture; the wholePedigree
  ## row (nAnimals 381), not the focalPopulation row (145), must be chosen.
  deltas <- calcSnapshotDeltas(validatedSnapshotHistory(),
    from = "2025-07-15", to = "2026-01-15",
    membershipRule = "wholePedigree"
  )
  expect_equal(deltas$to[deltas$metric == "nAnimals"], 381)
})

test_that("a packageVersion difference flags every row", {
  ## 2025-01-15 (1.0.5) -> 2025-07-15 (2.0.0): same guIter/guThresh, so the
  ## only provenance difference is packageVersion -- and it flags all rows.
  deltas <- calcSnapshotDeltas(validatedSnapshotHistory(),
    from = "2025-01-15", to = "2025-07-15",
    membershipRule = "wholePedigree"
  )
  expect_false(anyNA(deltas$comparabilityFlag))
  expect_true(all(grepl("packageVersion", deltas$comparabilityFlag)))
  expect_true(all(grepl("1.0.5", deltas$comparabilityFlag, fixed = TRUE)))
  expect_true(all(grepl("2.0.0", deltas$comparabilityFlag, fixed = TRUE)))
  ## guIter and guThresh are equal across this pair -- never named.
  expect_false(any(grepl("guIter", deltas$comparabilityFlag)))
  expect_false(any(grepl("guThresh", deltas$comparabilityFlag)))
})

test_that("a guIter difference flags exactly the gene-drop metrics", {
  ## 2025-07-15 (guIter 5000, pkg 2.0.0) -> 2026-01-15 (guIter 10000,
  ## pkg 2.0.0.9000): the 8 gene-drop rows name guIter (with both values);
  ## deterministic rows are flagged only for the packageVersion change.
  deltas <- calcSnapshotDeltas(validatedSnapshotHistory(),
    from = "2025-07-15", to = "2026-01-15",
    membershipRule = "wholePedigree"
  )
  affected <- deltas$metric %in% guIterAffected
  expect_true(all(grepl("guIter", deltas$comparabilityFlag[affected])))
  expect_true(all(grepl("5000", deltas$comparabilityFlag[affected])))
  expect_true(all(grepl("10000", deltas$comparabilityFlag[affected])))
  expect_false(any(grepl("guIter", deltas$comparabilityFlag[!affected])))
  ## The packageVersion change still flags every row.
  expect_true(all(grepl("packageVersion", deltas$comparabilityFlag)))
})

test_that("a guThresh-only difference flags exactly the gu metrics", {
  history <- checkSnapshotHistory(rbind(
    makeSnapshotRow("2026-01-15", guThresh = 3L),
    makeSnapshotRow("2026-07-15", guThresh = 1L)
  ))
  deltas <- calcSnapshotDeltas(history,
    from = "2026-01-15", to = "2026-07-15"
  )
  affected <- deltas$metric %in% guThreshAffected
  expect_true(all(grepl("guThresh", deltas$comparabilityFlag[affected])))
  expect_true(all(is.na(deltas$comparabilityFlag[!affected])))
  ## fg is gene-drop derived but guThresh does not reach it (calcGU only).
  expect_true(is.na(deltas$comparabilityFlag[deltas$metric == "fg"]))
})

test_that("a guIter-only difference flags exactly the gene-drop metrics", {
  history <- checkSnapshotHistory(rbind(
    makeSnapshotRow("2026-01-15", guIter = 5000L),
    makeSnapshotRow("2026-07-15", guIter = 10000L)
  ))
  deltas <- calcSnapshotDeltas(history,
    from = "2026-01-15", to = "2026-07-15"
  )
  affected <- deltas$metric %in% guIterAffected
  expect_true(all(grepl("guIter", deltas$comparabilityFlag[affected])))
  expect_true(all(is.na(deltas$comparabilityFlag[!affected])))
})

test_that("a fully comparable pair carries NA flags and auto-resolves", {
  ## Same packageVersion, guIter, and guThresh; a single membership rule, so
  ## membershipRule = NULL must resolve it without being told.
  history <- checkSnapshotHistory(rbind(
    makeSnapshotRow("2026-01-15"),
    makeSnapshotRow("2026-07-15")
  ))
  deltas <- calcSnapshotDeltas(history,
    from = "2026-01-15", to = "2026-07-15"
  )
  expect_identical(nrow(deltas), 21L)
  expect_true(all(is.na(deltas$comparabilityFlag)))
})

test_that("calcSnapshotDeltas stops when rules are mixed and none is given", {
  expect_error(
    calcSnapshotDeltas(validatedSnapshotHistory(),
      from = "2025-01-15", to = "2025-07-15"
    ),
    "membershipRule"
  )
  ## The message names the rules present, so the user can pick one.
  expect_error(
    calcSnapshotDeltas(validatedSnapshotHistory(),
      from = "2025-01-15", to = "2025-07-15"
    ),
    "wholePedigree"
  )
  expect_error(
    calcSnapshotDeltas(validatedSnapshotHistory(),
      from = "2025-01-15", to = "2025-07-15"
    ),
    "focalPopulation"
  )
})

test_that("calcSnapshotDeltas stops on a membership rule not in the history", {
  expect_error(
    calcSnapshotDeltas(validatedSnapshotHistory(),
      from = "2025-01-15", to = "2025-07-15",
      membershipRule = "bogusRule"
    ),
    "bogusRule"
  )
})

test_that("calcSnapshotDeltas stops when a date is absent under the rule", {
  expect_error(
    calcSnapshotDeltas(validatedSnapshotHistory(),
      from = "2024-01-01", to = "2025-07-15",
      membershipRule = "wholePedigree"
    ),
    "2024-01-01"
  )
  expect_error(
    calcSnapshotDeltas(validatedSnapshotHistory(),
      from = "2025-01-15", to = "2030-01-01",
      membershipRule = "wholePedigree"
    ),
    "2030-01-01"
  )
  ## 2026-01-15 exists in the fixture -- but not under focalPopulation twice:
  ## the focalPopulation series has a single snapshot, so a second
  ## focalPopulation date is absent under that rule.
  expect_error(
    calcSnapshotDeltas(validatedSnapshotHistory(),
      from = "2025-01-15", to = "2026-01-15",
      membershipRule = "focalPopulation"
    ),
    "2025-01-15"
  )
})

test_that("calcSnapshotDeltas stops when from equals to", {
  expect_error(
    calcSnapshotDeltas(validatedSnapshotHistory(),
      from = "2025-01-15", to = "2025-01-15",
      membershipRule = "wholePedigree"
    ),
    "different"
  )
})

test_that("calcSnapshotDeltas stops on a malformed history", {
  expect_error(
    calcSnapshotDeltas(data.frame(x = 1),
      from = "2025-01-15", to = "2025-07-15"
    ),
    "must have columns"
  )
})
