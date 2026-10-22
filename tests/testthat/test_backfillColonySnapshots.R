## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## RED (S1037; issue #170, Slice 1 of docs/planning/retrospective-snapshot-
## backfill-plan.md section 5; BACKLOG.md:33): backfillColonySnapshots(ped,
## dates, guIter, guThresh, ...) rebuilds one Genetic-Health Trends snapshot
## per past date from the birth and exit dates in a QC'd pedigree and returns
## list(history = <the rows>). Method (design B2): for each date, copy the
## pedigree, blank every exit date after the date, take the real animals born
## on or before the date with no exit left as the population (generated
## stand-in parents never enter it), trim to the population and its ancestors
## (removeUninformative = FALSE, addBackParents = FALSE), then reportGV() and
## createColonySnapshot() under the new rule "reconstructedLiving" (B3).
##
## Slice 1 scope: explicit dates only, dated animals only. An animal with no
## birth date is left out for now (the B4 call is Slice 2's), a date that
## cannot be analysed stops the run and names the date (per-date skipping is
## Slice 2's B8), and there is no grid, support report or existing-history
## argument yet. Nothing here touches the app.
##
## Why the blanking matters (design section 2.2, measured S1036): the
## estimators read the pedigree's exit column as it stands, so setting only the
## population for a past date finds no living breeders, because an animal alive
## in 1990 has almost always left since.

## The hand-built colony of design section 5 Slice 1 (a), ten animals. S1 and
## D1 die inside the window (2010-06-01, 2012-01-01) and K1 dies 2008-01-01.
##
## On 2007-01-01 the living animals are S1, S2, D1, D2, D3, K1, K2 (7: three
## males, four females). K3, K4 and K5 are not born, so the trimmed pedigree
## names as parents only S1 (K1, K2), D1 (K1) and D2 (K2): breeders S1, D1, D2,
## one male and two females, neSexRatio = 4 * 1 * 2 / (1 + 2) = 8/3.
##
## On 2011-01-01 S1 has left; the living animals are S2, D1, D2, D3, K2, K3,
## K4, K5 (8: two males, six females). Breeders are S2 and K3 (males), D2, D3
## and K2 (females): neSexRatio = 4 * 2 * 3 / (2 + 3) = 4.8.
handBuiltColony <- function() {
  ped <- data.frame(
    id = c("S1", "S2", "D1", "D2", "D3", "K1", "K2", "K3", "K4", "K5"),
    sire = c(NA, NA, NA, NA, NA, "S1", "S1", "S2", "S2", "K3"),
    dam = c(NA, NA, NA, NA, NA, "D1", "D2", "D3", "D2", "K2"),
    sex = c("M", "M", "F", "F", "F", "M", "F", "M", "F", "F"),
    birth = as.Date(c(
      "2000-01-01", "2001-01-01", "2000-01-01", "2000-06-01", "2001-06-01",
      "2005-01-01", "2006-01-01", "2008-01-01", "2009-01-01", "2010-06-01"
    )),
    exit = as.Date(c(
      "2010-06-01", NA, "2012-01-01", NA, NA,
      "2008-01-01", NA, NA, NA, NA
    )),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}
handDates <- as.Date(c("2007-01-01", "2011-01-01"))

## The shortcut a script user has today: set only the population by dates and
## leave the exit column alone.
shortcutNeSexRatio <- function(ped, date) {
  ped$population <- !is.na(ped$birth) & ped$birth <= date &
    (is.na(ped$exit) | ped$exit > date)
  trimmed <- trimPedigree(ped$id[ped$population], ped,
    removeUninformative = FALSE, addBackParents = FALSE
  )
  calcNeSexRatio(trimmed)
}

## The shipped Japanese macaque example, read the way the app reads it: blanks
## are NA, and the default parent-age check stops this file so it is switched
## off (design Appendix B). Read once per run.
jmacQcCache <- new.env(parent = emptyenv())
jmacQc <- function() {
  path <- jmacExamplePath()
  skip_if(path == "", "shipped jmac example not found")
  if (is.null(jmacQcCache$ped)) {
    raw <- read.csv(path,
      na.strings = c("", "NA"), check.names = FALSE,
      stringsAsFactors = FALSE
    )
    jmacQcCache$ped <- suppressMessages(qcStudbook(raw,
      minSireAge = 0, minDamAge = 0, reportChanges = FALSE,
      reportErrors = FALSE
    ))
  }
  jmacQcCache$ped
}

## What the app records for a pedigree: the Pedigree tab sets the population to
## the living animals (R/modPedigree.R:372-374), the Genetic Value tab trims to
## it and its ancestors and runs reportGV() (R/modGeneticValue.R:302-342), and
## the Trends tab files the result under focalPopulation.
appSnapshot <- function(ped, snapshotDate, guIter, seed) {
  living <- setPopulation(ped, ped$id[isLivingAnimal(ped)])
  analysed <- trimPedigree(living$id[living$population], living,
    removeUninformative = FALSE, addBackParents = FALSE
  )
  set.seed(seed)
  gv <- suppressWarnings(reportGV(analysed,
    guIter = guIter, guThresh = 1L, byID = TRUE
  ))
  createColonySnapshot(analysed, gv, "focalPopulation",
    guIter = guIter, guThresh = 1L, snapshotDate = snapshotDate
  )
}

test_that("backfillColonySnapshots is exported", {
  ns <- readLines(system.file("NAMESPACE", package = "nprcgenekeepr"))
  expect_true("export(backfillColonySnapshots)" %in% ns)
})

test_that("a hand-built colony gives hand-derived sex-ratio effective sizes (B2)", {
  set.seed(1L)
  result <- backfillColonySnapshots(handBuiltColony(),
    dates = handDates, guIter = 20L, guThresh = 1L
  )
  expect_type(result, "list")
  expect_true("history" %in% names(result))
  history <- result$history
  expect_identical(nrow(history), 2L)
  expect_identical(history$snapshotDate, handDates)
  expect_identical(
    as.character(history$membershipRule), rep("reconstructedLiving", 2L)
  )
  ## who was alive: 7 then 8 animals (see the comment on handBuiltColony())
  expect_identical(history$nAnimals, c(7L, 8L))
  expect_identical(history$nMales, c(3L, 2L))
  expect_identical(history$nFemales, c(4L, 6L))
  ## 4 * M * F / (M + F) on the living breeders, worked out on paper
  expect_equal(history$neSexRatio, c(4 * 1 * 2 / (1 + 2), 4 * 2 * 3 / (2 + 3)))
  expect_equal(history$neSexRatio, c(8 / 3, 4.8))
})

test_that("setting only the population gives a different, wrong answer", {
  ## The reason the function exists: on 2007-01-01 S1 and D1 have left since,
  ## the shortcut finds no living breeding male, and returns 0.
  expect_equal(shortcutNeSexRatio(handBuiltColony(), handDates[[1L]]), 0)
  expect_false(isTRUE(all.equal(
    shortcutNeSexRatio(handBuiltColony(), handDates[[1L]]), 8 / 3
  )))
})

test_that("the history records the provenance it was given and validates", {
  set.seed(1L)
  history <- backfillColonySnapshots(handBuiltColony(),
    dates = handDates, guIter = 20L, guThresh = 1L
  )$history
  expect_identical(unique(history$guIter), 20L)
  expect_identical(unique(history$guThresh), 1L)
  expect_error(checkSnapshotHistory(history), NA)
})

test_that("dates may be given out of order or as ISO strings", {
  set.seed(1L)
  reversed <- backfillColonySnapshots(handBuiltColony(),
    dates = rev(handDates), guIter = 20L, guThresh = 1L
  )$history
  expect_identical(reversed$snapshotDate, handDates)
  set.seed(1L)
  asText <- backfillColonySnapshots(handBuiltColony(),
    dates = c("2007-01-01", "2011-01-01"), guIter = 20L, guThresh = 1L
  )$history
  expect_identical(asText$snapshotDate, handDates)
  expect_equal(asText$neSexRatio, c(8 / 3, 4.8))
})

test_that("arguments for reportGV() are passed on", {
  expect_error(
    backfillColonySnapshots(handBuiltColony(),
      dates = handDates, guIter = 20L, guThresh = 1L,
      notAReportGvArgument = 1L
    ),
    "unused argument"
  )
})

test_that("a pedigree missing a required column stops, naming every one", {
  ped <- handBuiltColony()
  expect_error(
    backfillColonySnapshots(ped[, setdiff(names(ped), "exit")],
      dates = handDates, guIter = 20L, guThresh = 1L
    ),
    "exit"
  )
  expect_error(
    backfillColonySnapshots(ped[, setdiff(names(ped), "birth")],
      dates = handDates, guIter = 20L, guThresh = 1L
    ),
    "birth"
  )
  both <- tryCatch(
    backfillColonySnapshots(ped[, setdiff(names(ped), c("birth", "exit"))],
      dates = handDates, guIter = 20L, guThresh = 1L
    ),
    error = function(e) conditionMessage(e)
  )
  expect_match(both, "birth", fixed = TRUE)
  expect_match(both, "exit", fixed = TRUE)
  expect_error(
    backfillColonySnapshots("not a pedigree",
      dates = handDates, guIter = 20L, guThresh = 1L
    ),
    "ped"
  )
})

test_that("guIter and guThresh are required and validated (B9)", {
  ped <- handBuiltColony()
  expect_error(
    backfillColonySnapshots(ped, dates = handDates, guThresh = 1L), "guIter"
  )
  expect_error(
    backfillColonySnapshots(ped, dates = handDates, guIter = 20L), "guThresh"
  )
  expect_error(
    backfillColonySnapshots(ped,
      dates = handDates, guIter = 2.5, guThresh = 1L
    ),
    "guIter"
  )
  expect_error(
    backfillColonySnapshots(ped,
      dates = handDates, guIter = 20L, guThresh = 0L
    ),
    "guThresh"
  )
})

test_that("dates are required and must be real, distinct dates", {
  ped <- handBuiltColony()
  expect_error(
    backfillColonySnapshots(ped, guIter = 20L, guThresh = 1L), "dates"
  )
  expect_error(
    backfillColonySnapshots(ped,
      dates = as.Date(character(0)), guIter = 20L, guThresh = 1L
    ),
    "dates"
  )
  expect_error(
    backfillColonySnapshots(ped,
      dates = c("2007-01-01", "not a date"), guIter = 20L, guThresh = 1L
    ),
    "dates"
  )
  expect_error(
    backfillColonySnapshots(ped,
      dates = as.Date(c("2007-01-01", NA)), guIter = 20L, guThresh = 1L
    ),
    "dates"
  )
  expect_error(
    backfillColonySnapshots(ped,
      dates = as.Date(c("2007-01-01", "2007-01-01")),
      guIter = 20L, guThresh = 1L
    ),
    "duplicate"
  )
})

test_that("a date nobody was alive on stops the run and names the date", {
  ## Slice 1 stops; Slice 2 (B8) reports it and carries on with the others.
  expect_error(
    backfillColonySnapshots(handBuiltColony(),
      dates = as.Date("1999-01-01"), guIter = 20L, guThresh = 1L
    ),
    "1999-01-01"
  )
})

test_that("the example colony at its export date equals what the app records", {
  ## The closure invariant (design B2): the studbook was exported 2018-07-11,
  ## so rebuilding that date must give the snapshot the app files for the same
  ## pedigree. The QC'd example holds 1,463 generated stand-in parents beside
  ## its 2,592 real animals; one that entered the population would give 1,804
  ## animals, not 339 (design section 2.6), which is what this catches. The
  ## same seed makes the gene-drop fields equal as well.
  ped <- jmacQc()
  expect_gt(sum(isGeneratedUnknownId(ped$id, ped = ped)), 1000L)
  exportDate <- as.Date("2018-07-11")
  expected <- appSnapshot(ped, exportDate, guIter = 20L, seed = 7L)
  expect_identical(expected$nAnimals, 339L)
  set.seed(7L)
  rebuilt <- suppressWarnings(backfillColonySnapshots(ped,
    dates = exportDate, guIter = 20L, guThresh = 1L
  ))$history
  expect_identical(nrow(rebuilt), 1L)
  expect_identical(as.character(rebuilt$membershipRule), "reconstructedLiving")
  compared <- setdiff(names(expected), c("membershipRule", "packageVersion"))
  expect_equal(rebuilt[, compared], expected[, compared], tolerance = 1e-10)
})

test_that("the example colony in 1990, 2000 and 2010 gives the measured sizes", {
  ## Measured S1036 (design section 2.2). Counts and the two effective sizes
  ## come from no gene drop, so they do not depend on the seed. The shortcut
  ## of leaving the exit column alone gives 0.0, 0.0 and 30.9 for the sex-ratio
  ## size at the same three dates.
  ped <- jmacQc()
  dates <- as.Date(c("1990-01-01", "2000-01-01", "2010-01-01"))
  set.seed(7L)
  history <- suppressWarnings(backfillColonySnapshots(ped,
    dates = dates, guIter = 20L, guThresh = 1L
  ))$history
  expect_identical(history$snapshotDate, dates)
  expect_identical(history$nAnimals, c(201L, 230L, 369L))
  expect_lt(max(abs(history$neSexRatio - c(3.9, 62.0, 136.6))), 0.06)
  expect_lt(max(abs(history$neVariance - c(54.1, 68.0, 92.5))), 0.06)
  shortcut <- vapply(dates, function(d) shortcutNeSexRatio(ped, d), numeric(1L))
  expect_lt(max(abs(shortcut - c(0.0, 0.0, 30.9))), 0.06)
})
