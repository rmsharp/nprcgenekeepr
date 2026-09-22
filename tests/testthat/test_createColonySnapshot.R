## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #167 Slice 2: createColonySnapshot(ped, geneticValue, membershipRule,
# guIter, guThresh, snapshotDate = Sys.Date()) turns one reportGV() result
# into a one-row data.frame in the ratified 27-column D1 schema. Every metric
# field is a value the nprcgenekeeprGV object already carries or a Summary
# Statistics aggregate (mean/median/calcSkewness()/calcKurtosis()) of its
# report columns -- the function recomputes no estimator (plan section 5
# Slice 2; Dragons 1-2). guIter/guThresh are required arguments with no
# defaults (owner decision, S758): reportGV()'s return object does not carry
# them, and a default would silently record false D4 provenance. The claimed
# membershipRule is verified against ped and the report and a contradiction
# stop()s (owner decision, S758): wholePedigree means the report covers
# exactly ped$id; focalPopulation means ped carries the logical population
# column and the report covers exactly ped$id[ped$population] (D3: the rules
# are what the generation path can actually guarantee).

## The exact D1 column list (27 columns, three groups of nine) ratified by the
## issue #167 plan and fixed by Slice 1's RED phase (test_readSnapshotHistory.R
## pins the same vector against the committed fixture).
snapshotColumns <- c(
  # provenance / comparability (D4)
  "schemaVersion", "snapshotDate", "packageVersion", "membershipRule",
  "guIter", "guThresh", "nAnimals", "nMales", "nFemales",
  # colony scalars, verbatim from reportGV()
  "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
  "nMaleFounders", "nFemaleFounders", "nFounders",
  # colony aggregates of per-animal metrics (Summary Statistics definitions)
  "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
  "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
  "skewnessGu", "kurtosisGu"
)

qcPed <- nprcgenekeepr::qcPed
gvWhole <- reportGV(qcPed, guIter = 20L)
focalIds <- qcPed$id[is.na(qcPed$exit)]
focalPed <- setPopulation(qcPed, focalIds)
gvFocal <- reportGV(focalPed, guIter = 20L)

test_that("createColonySnapshot returns one row in the exact D1 schema", {
  snapshot <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20L, guThresh = 1L,
    snapshotDate = as.Date("2026-06-30")
  )
  expect_true(is.data.frame(snapshot))
  expect_identical(nrow(snapshot), 1L)
  expect_identical(names(snapshot), snapshotColumns)
  expect_identical(snapshot$schemaVersion, 1L)
  expect_s3_class(snapshot$snapshotDate, "Date")
  expect_type(snapshot$packageVersion, "character")
  expect_identical(
    snapshot$packageVersion,
    as.character(utils::packageVersion("nprcgenekeepr"))
  )
  expect_identical(snapshot$membershipRule, "wholePedigree")
  expect_type(snapshot$guIter, "integer")
  expect_type(snapshot$guThresh, "integer")
  expect_type(snapshot$nAnimals, "integer")
  expect_type(snapshot$nMales, "integer")
  expect_type(snapshot$nFemales, "integer")
  expect_type(snapshot$nMaleFounders, "integer")
  expect_type(snapshot$nFemaleFounders, "integer")
  expect_type(snapshot$nFounders, "integer")
  expect_true(all(vapply(
    snapshot[, c(
      "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
      "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
      "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
      "skewnessGu", "kurtosisGu"
    )],
    is.numeric, logical(1L)
  )))
})

test_that("provenance fields record exactly what the caller states (D4)", {
  snapshot <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20L, guThresh = 1L,
    snapshotDate = as.Date("2026-06-30")
  )
  expect_identical(snapshot$guIter, 20L)
  expect_identical(snapshot$guThresh, 1L)
  ## doubles that are whole numbers are accepted and coerced to integer
  snapshotDbl <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20, guThresh = 1,
    snapshotDate = as.Date("2026-06-30")
  )
  expect_identical(snapshotDbl$guIter, 20L)
  expect_identical(snapshotDbl$guThresh, 1L)
})

test_that("composition counts are hand-derivable from the report rows", {
  snapshot <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20L, guThresh = 1L,
    snapshotDate = as.Date("2026-06-30")
  )
  report <- gvWhole$report
  expect_identical(snapshot$nAnimals, nrow(report))
  expect_identical(snapshot$nMales, sum(report$sex == "M", na.rm = TRUE))
  expect_identical(snapshot$nFemales, sum(report$sex == "F", na.rm = TRUE))
  ## qcPed is a frozen shipped dataset: pin the concrete values too, so a
  ## silent population change cannot hide inside the derived comparison.
  ## qcPed holds one sex == "U" animal, so nMales + nFemales < nAnimals.
  expect_identical(snapshot$nAnimals, 280L)
  expect_identical(snapshot$nMales, 108L)
  expect_identical(snapshot$nFemales, 171L)
})

test_that("colony scalars are copied verbatim from the reportGV object", {
  snapshot <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20L, guThresh = 1L,
    snapshotDate = as.Date("2026-06-30")
  )
  expect_identical(snapshot$fe, gvWhole$fe)
  expect_identical(snapshot$fg, gvWhole$fg)
  expect_identical(snapshot$fgSE, gvWhole$fgSE)
  expect_identical(snapshot$neGD, gvWhole$neGD)
  expect_identical(snapshot$neSexRatio, gvWhole$neSexRatio)
  expect_identical(snapshot$neVariance, gvWhole$neVariance)
  expect_identical(snapshot$nMaleFounders, gvWhole$nMaleFounders)
  expect_identical(snapshot$nFemaleFounders, gvWhole$nFemaleFounders)
  expect_identical(snapshot$nFounders, gvWhole$total)
})

test_that("aggregates equal the Summary Statistics definitions, full precision", {
  snapshot <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20L, guThresh = 1L,
    snapshotDate = as.Date("2026-06-30")
  )
  report <- gvWhole$report
  ## The Summary Statistics table (makeGeneticSummaryTable) reports
  ## summary()'s Mean/Median plus calcSkewness()/calcKurtosis() over
  ## indivMeanKin and gu. mean()/median() with na.rm = TRUE are those same
  ## definitions at full precision (summary() signif()s to 4 digits for
  ## display; a snapshot must not bake that rounding in -- Dragon 5).
  expect_identical(
    snapshot$meanIndivMeanKin, mean(report$indivMeanKin, na.rm = TRUE)
  )
  expect_identical(
    snapshot$medianIndivMeanKin,
    stats::median(report$indivMeanKin, na.rm = TRUE)
  )
  expect_identical(
    snapshot$skewnessIndivMeanKin, calcSkewness(report$indivMeanKin)
  )
  expect_identical(
    snapshot$kurtosisIndivMeanKin, calcKurtosis(report$indivMeanKin)
  )
  expect_identical(snapshot$meanGu, mean(report$gu, na.rm = TRUE))
  expect_identical(snapshot$medianGu, stats::median(report$gu, na.rm = TRUE))
  expect_identical(snapshot$meanGuSE, mean(report$guSE, na.rm = TRUE))
  expect_identical(snapshot$skewnessGu, calcSkewness(report$gu))
  expect_identical(snapshot$kurtosisGu, calcKurtosis(report$gu))
  ## and they tie back to summary()'s displayed values within its 4
  ## significant digits -- proving reuse of the definition, not a new one
  expect_equal(
    snapshot$meanIndivMeanKin,
    unname(summary(report$indivMeanKin)[["Mean"]]),
    tolerance = 1e-3
  )
  expect_equal(
    snapshot$meanGu, unname(summary(report$gu)[["Mean"]]),
    tolerance = 1e-3
  )
})

test_that("focalPopulation snapshots describe the designated focal set", {
  snapshot <- createColonySnapshot(focalPed, gvFocal, "focalPopulation",
    guIter = 20L, guThresh = 1L,
    snapshotDate = as.Date("2026-06-30")
  )
  expect_identical(snapshot$membershipRule, "focalPopulation")
  expect_identical(snapshot$nAnimals, length(focalIds))
  report <- gvFocal$report
  expect_identical(snapshot$nAnimals, nrow(report))
  expect_identical(snapshot$nMales, sum(report$sex == "M", na.rm = TRUE))
  expect_identical(snapshot$nFemales, sum(report$sex == "F", na.rm = TRUE))
  expect_identical(snapshot$fe, gvFocal$fe)
  expect_identical(snapshot$fg, gvFocal$fg)
  expect_identical(
    snapshot$meanIndivMeanKin, mean(report$indivMeanKin, na.rm = TRUE)
  )
  expect_error(checkSnapshotHistory(snapshot), NA)
})

test_that("a contradicted membershipRule claim stops (owner decision, S758)", {
  ## gvFocal's report covers 89 of focalPed's 280 animals -- not the whole
  ## pedigree
  expect_error(
    createColonySnapshot(focalPed, gvFocal, "wholePedigree",
      guIter = 20L, guThresh = 1L
    ),
    "wholePedigree"
  )
  ## qcPed carries no population column, so a focal claim is unverifiable
  expect_error(
    createColonySnapshot(qcPed, gvWhole, "focalPopulation",
      guIter = 20L, guThresh = 1L
    ),
    "population"
  )
  ## focalPed designates 89 animals but gvWhole's report covers all 280
  expect_error(
    createColonySnapshot(focalPed, gvWhole, "focalPopulation",
      guIter = 20L, guThresh = 1L
    ),
    "focalPopulation"
  )
})

test_that("an unknown membershipRule stops, naming the known rules (D3)", {
  expect_error(
    createColonySnapshot(qcPed, gvWhole, "livingAnimals",
      guIter = 20L, guThresh = 1L
    ),
    "wholePedigree"
  )
  expect_error(
    createColonySnapshot(qcPed, gvWhole, c("wholePedigree", "focalPopulation"),
      guIter = 20L, guThresh = 1L
    ),
    "membershipRule"
  )
})

test_that("a malformed or incomplete geneticValue object stops", {
  ## not a reportGV() result at all
  expect_error(
    createColonySnapshot(qcPed, gvWhole$report, "wholePedigree",
      guIter = 20L, guThresh = 1L
    ),
    "nprcgenekeeprGV"
  )
  ## missing a colony scalar
  gvNoFg <- gvWhole
  gvNoFg$fg <- NULL
  expect_error(
    createColonySnapshot(qcPed, gvNoFg, "wholePedigree",
      guIter = 20L, guThresh = 1L
    ),
    "fg"
  )
  ## report missing a required per-animal column
  gvNoGuSE <- gvWhole
  gvNoGuSE$report$guSE <- NULL
  expect_error(
    createColonySnapshot(qcPed, gvNoGuSE, "wholePedigree",
      guIter = 20L, guThresh = 1L
    ),
    "guSE"
  )
})

test_that("guIter and guThresh are required and validated (D4)", {
  expect_error(
    createColonySnapshot(qcPed, gvWhole, "wholePedigree", guThresh = 1L),
    "guIter"
  )
  expect_error(
    createColonySnapshot(qcPed, gvWhole, "wholePedigree", guIter = 20L),
    "guThresh"
  )
  expect_error(
    createColonySnapshot(qcPed, gvWhole, "wholePedigree",
      guIter = "many", guThresh = 1L
    ),
    "guIter"
  )
  expect_error(
    createColonySnapshot(qcPed, gvWhole, "wholePedigree",
      guIter = 20L, guThresh = -1L
    ),
    "guThresh"
  )
})

test_that("snapshotDate defaults to today and accepts Date or ISO string", {
  snapshot <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20L, guThresh = 1L
  )
  expect_identical(snapshot$snapshotDate, Sys.Date())
  fromString <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20L, guThresh = 1L,
    snapshotDate = "2026-03-01"
  )
  expect_identical(fromString$snapshotDate, as.Date("2026-03-01"))
  fromDate <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20L, guThresh = 1L,
    snapshotDate = as.Date("2026-03-01")
  )
  expect_identical(fromDate$snapshotDate, as.Date("2026-03-01"))
  expect_error(
    createColonySnapshot(qcPed, gvWhole, "wholePedigree",
      guIter = 20L, guThresh = 1L,
      snapshotDate = "03/01/2026"
    ),
    "ISO-8601"
  )
})

test_that("a generated snapshot validates, appends, and survives CSV", {
  snapshot <- createColonySnapshot(qcPed, gvWhole, "wholePedigree",
    guIter = 20L, guThresh = 1L,
    snapshotDate = as.Date("2026-06-30")
  )
  expect_error(checkSnapshotHistory(snapshot), NA)
  ## first snapshot of a new history
  first <- appendColonySnapshot(NULL, snapshot)
  expect_identical(nrow(first), 1L)
  ## appended to the committed Slice 1 fixture history
  history <- checkSnapshotHistory(readSnapshotHistory(system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  )))
  merged <- appendColonySnapshot(history, snapshot)
  expect_identical(nrow(merged), 5L)
  expect_identical(merged$snapshotDate[5L], as.Date("2026-06-30"))
  ## D2 / Dragon 5: the full-precision generated row survives the write.csv
  ## persistence path (Slice 1's round-trip guard, now with generated values)
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  write.csv(merged, csv, row.names = FALSE)
  reRead <- checkSnapshotHistory(readSnapshotHistory(csv))
  expect_identical(names(reRead), names(merged))
  expect_equal(reRead, merged)
})
