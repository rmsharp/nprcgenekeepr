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
## Slice 1 scope was explicit dates and dated animals only. Slice 2 (S1038,
## same issue; the owner's calls were put with AskUserQuestion) adds, in the
## second half of this file:
##  * who counts (design B4): an animal with no birth date counts from the
##    day its first dated offspring was born until it leaves, and an animal
##    with no exit date counts only when the studbook lists it as living, the
##    test the app applies today (isLivingAnimal(), so status UNKNOWN never
##    counts);
##  * the yearly series (design B6): from, to, by and minAnimals, the series
##    starting at the first 1 January with at least minAnimals living animals;
##  * the support table (B5), skips for dates already in existingHistory (B7),
##    dates that fail reported in skipped instead of stopping the run (B8)
##    and the updateProgress callback.
## Nothing here touches the app.
##
## Why the blanking matters (design section 2.2, measured S1036): the
## estimators read the pedigree's exit column as it stands, so setting only the
## population for a past date finds no living breeders, because an animal alive
## in 1990 has almost always left since.

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

test_that("dates, when given, must be real and distinct", {
  ## Slice 2: leaving dates out is no longer an error, it builds the yearly
  ## series (tested below), so only the values that are given are checked.
  ped <- handBuiltColony()
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

test_that("a run in which no date can be built stops and names the date", {
  ## With other dates that work, a failing date is reported in `skipped` and
  ## the run carries on (B8, tested below); alone, there is nothing to return.
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
  ## S1038: an undated parent now counts from its first dated offspring, so
  ## 1990 reads 204 (the 201 animals with a birth date plus 3 such parents);
  ## the sizes below do not change with the rule (design section 2.2, and
  ## measured again S1038 on 102 dates of both example studbooks).
  expect_identical(history$nAnimals, c(204L, 230L, 369L))
  expect_lt(max(abs(history$neSexRatio - c(3.9, 62.0, 136.6))), 0.06)
  expect_lt(max(abs(history$neVariance - c(54.1, 68.0, 92.5))), 0.06)
  shortcut <- vapply(dates, function(d) shortcutNeSexRatio(ped, d), numeric(1L))
  expect_lt(max(abs(shortcut - c(0.0, 0.0, 30.9))), 0.06)
})

## ---------------------------------------------------------------------------
## Slice 2 (S1038)
## ---------------------------------------------------------------------------

## Runs the function with a seed and lets through only the warning this slice
## adds, so reportGV()'s own warnings can neither hide it nor stand in for it.
runBackfill <- function(ped, ..., seed = 1L) {
  set.seed(seed)
  withCallingHandlers(
    backfillColonySnapshots(ped, guIter = 20L, guThresh = 1L, ...),
    warning = function(w) {
      if (!grepl("could not be rebuilt", conditionMessage(w), fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )
}

test_that("an undated parent counts from its first dated offspring until it leaves", {
  history <- runBackfill(undatedColony(), dates = undatedDates)$history
  expect_identical(history$snapshotDate, undatedDates)
  expect_identical(history$nAnimals, c(4L, 6L, 5L))
  expect_identical(history$nMales, c(2L, 3L, 2L))
  expect_identical(history$nFemales, c(2L, 3L, 3L))
})

test_that("an animal with no exit date counts only when the studbook lists it as living", {
  ## X1 (no birth date, dam of K3) and Z1 (born 2001) are UNKNOWN with no exit
  ## date. The app does not count them as living today, so neither counts on
  ## any date; 2007-01-01 is a date on which both would otherwise count.
  ped <- undatedColony()
  asked <- as.Date("2007-01-01")
  history <- runBackfill(ped, dates = asked)$history
  expect_identical(history$nAnimals, 6L)
  expect_identical(history$nMales, 3L)
  ## With no status column the app judges by the exit date alone, so "no exit
  ## date" means alive and both count: S1, D1, D2, X1, K1, K2, K3 and Z1.
  noStatus <- ped[, setdiff(names(ped), "status")]
  history <- runBackfill(noStatus, dates = asked)$history
  expect_identical(history$nAnimals, 8L)
  expect_identical(history$nMales, 4L)
})

test_that("the support table reports what each date rests on", {
  result <- runBackfill(undatedColony(), dates = undatedDates)
  support <- result$support
  expect_s3_class(support, "data.frame")
  expect_identical(names(support), c(
    "snapshotDate", "nLiving", "nPlacedByOffspring", "nPossiblyAlive",
    "pctSireKnown", "pctDamKnown"
  ))
  expect_identical(support$snapshotDate, undatedDates)
  expect_identical(support$nLiving, result$history$nAnimals)
  expect_identical(support$nLiving, c(4L, 6L, 5L))
  expect_identical(support$nPlacedByOffspring, c(1L, 1L, 0L))
  expect_identical(support$nPossiblyAlive, c(3L, 3L, 2L))
  expect_equal(support$pctSireKnown, c(25, 50, 60))
  expect_equal(support$pctDamKnown, c(25, 50, 80))
})

test_that("the example colony's support table matches the hand counts", {
  ## Counted S1038 with code independent of the function. Possibly alive =
  ## animals with no birth date that are not counted and have no exit date on
  ## or before the date: 1970 has 20 with no dated offspring at all and 4
  ## whose first dated offspring came later; 1990 and 2000 have the two
  ## UNKNOWN dams (2NTIGG, 4R3TIJ), never counted.
  ped <- jmacQc()
  dates <- as.Date(c("1970-01-01", "1990-01-01", "2000-01-01"))
  result <- suppressWarnings(runBackfill(ped, dates = dates, seed = 7L))
  expect_identical(result$history$nAnimals, c(65L, 204L, 230L))
  support <- result$support
  expect_identical(support$nLiving, c(65L, 204L, 230L))
  expect_identical(support$nPlacedByOffspring, c(21L, 3L, 0L))
  expect_identical(support$nPossiblyAlive, c(24L, 2L, 2L))
  ## recorded sires among the living: 1 of 65, 1 of 204, 90 of 230; recorded
  ## dams: 44, 194 and 210
  expect_equal(support$pctSireKnown, 100 * c(1, 1, 90) / c(65, 204, 230))
  expect_equal(support$pctDamKnown, 100 * c(44, 194, 210) / c(65, 204, 230))
})

test_that("from, to and by lay out the dates", {
  ped <- handBuiltColony()
  yearly <- runBackfill(ped, from = "2005-01-01", to = "2008-01-01")
  years <- as.Date(c("2005-01-01", "2006-01-01", "2007-01-01", "2008-01-01"))
  expect_identical(yearly$history$snapshotDate, years)
  expect_identical(yearly$support$snapshotDate, years)
  halves <- runBackfill(ped,
    from = as.Date("2005-01-01"), to = as.Date("2006-01-01"), by = "6 months"
  )
  expect_identical(
    halves$history$snapshotDate,
    as.Date(c("2005-01-01", "2005-07-01", "2006-01-01"))
  )
})

test_that("the series starts at the first January with enough animals and ends at the last in the data", {
  ped <- handBuiltColony()
  ## living on 1 January 2000 to 2012: 2 4 5 5 5 6 7 7 7 8 8 8 7; the latest
  ## date in the data is D1's exit, 2012-01-01
  every <- runBackfill(ped)
  januaries <- seq(as.Date("2000-01-01"), as.Date("2012-01-01"), by = "year")
  expect_identical(every$support$snapshotDate, januaries)
  expect_identical(
    every$support$nLiving,
    c(2L, 4L, 5L, 5L, 5L, 6L, 7L, 7L, 7L, 8L, 8L, 8L, 7L)
  )
  expect_identical(every$history$snapshotDate, januaries)
  ## minAnimals moves only the start
  five <- runBackfill(ped, minAnimals = 5L)
  expect_identical(
    range(five$support$snapshotDate),
    as.Date(c("2002-01-01", "2012-01-01"))
  )
  ## either end can be given and the other still defaults
  expect_identical(
    range(runBackfill(ped, from = "2010-01-01")$support$snapshotDate),
    as.Date(c("2010-01-01", "2012-01-01"))
  )
  expect_identical(
    range(runBackfill(ped, to = "2002-01-01")$support$snapshotDate),
    as.Date(c("2000-01-01", "2002-01-01"))
  )
  ## a date asked for by name is never refused for having few animals
  named <- runBackfill(ped, dates = "2000-01-01", minAnimals = 50L)
  expect_identical(named$history$nAnimals, 2L)
})

test_that("arguments that do not make sense stop and name the argument", {
  ped <- handBuiltColony()
  ## each message puts the argument's name in single quotes, as the others do
  expectStopNaming(
    runBackfill(ped, dates = handDates, from = "2005-01-01"),
    "'dates'", "'from'"
  )
  expectStopNaming(
    runBackfill(ped, dates = handDates, to = "2008-01-01"), "'dates'", "'to'"
  )
  expectStopNaming(
    runBackfill(ped, dates = handDates, by = "month"), "'dates'", "'by'"
  )
  expectStopNaming(
    runBackfill(ped, from = "2008-01-01", to = "2005-01-01"), "'from'", "'to'"
  )
  expectStopNaming(runBackfill(ped, from = "not a date"), "'from'")
  expectStopNaming(
    runBackfill(ped, from = c("2005-01-01", "2006-01-01")), "'from'"
  )
  expectStopNaming(runBackfill(ped, to = "2008-13-45"), "'to'")
  expectStopNaming(runBackfill(ped, by = "fortnightly"), "'by'")
  expectStopNaming(runBackfill(ped, by = c("year", "month")), "'by'")
  for (bad in list(1L, 0L, 2.5, NA_integer_, c(2L, 3L), "2")) {
    expectStopNaming(runBackfill(ped, minAnimals = bad), "'minAnimals'")
  }
  ## no January has 9 living animals in this colony (8 at most)
  expectStopNaming(runBackfill(ped, minAnimals = 9L), "'minAnimals'")
  expectStopNaming(
    runBackfill(ped, updateProgress = "not a function"), "'updateProgress'"
  )
})

test_that("dates already in existingHistory are skipped, listed and left untouched", {
  ped <- handBuiltColony()
  existing <- runBackfill(ped, dates = handDates[[1L]])$history
  ## a marker no recomputation would reproduce: the row must come back as given
  existing$fe <- 999
  result <- runBackfill(ped,
    dates = handDates, existingHistory = existing, seed = 2L
  )
  expect_identical(result$history$snapshotDate, handDates)
  expect_identical(result$history$fe[[1L]], 999)
  expect_identical(result$history$nAnimals, c(7L, 8L))
  expect_error(checkSnapshotHistory(result$history), NA)
  expect_identical(result$skipped$snapshotDate, handDates[[1L]])
  expect_match(result$skipped$reason, "already in existingHistory", fixed = TRUE)
  ## the support table still covers every date asked for
  expect_identical(result$support$snapshotDate, handDates)
})

test_that("a row of another rule on the same date does not count as already there", {
  ped <- handBuiltColony()
  recorded <- runBackfill(ped, dates = handDates[[1L]])$history
  recorded$membershipRule <- "focalPopulation"
  result <- runBackfill(ped,
    dates = handDates[[1L]], existingHistory = recorded
  )
  expect_identical(nrow(result$history), 2L)
  expect_setequal(
    as.character(result$history$membershipRule),
    c("focalPopulation", "reconstructedLiving")
  )
  expect_identical(nrow(result$skipped), 0L)
  expect_error(checkSnapshotHistory(result$history), NA)
})

test_that("when every date is already there the history comes back unchanged", {
  ped <- handBuiltColony()
  existing <- runBackfill(ped, dates = handDates)$history
  expect_warning(
    result <- runBackfill(ped, dates = handDates, existingHistory = existing),
    NA
  )
  expectSameRows(result$history, existing)
  expect_identical(nrow(result$skipped), 2L)
})

test_that("existingHistory may be empty or carry extra columns, and must be valid", {
  ped <- handBuiltColony()
  first <- runBackfill(ped, dates = handDates[[1L]])$history
  ## a zero-row history is the same as none
  fromEmpty <- runBackfill(ped, dates = handDates, existingHistory = first[0L, ])
  expect_identical(fromEmpty$history$snapshotDate, handDates)
  expect_identical(nrow(fromEmpty$skipped), 0L)
  ## a column the user added is kept; the new rows get NA there
  noted <- first
  noted$note <- "checked by hand"
  kept <- runBackfill(ped, dates = handDates, existingHistory = noted)
  expect_identical(kept$history$note, c("checked by hand", NA))
  ## what is not a valid history stops, and the message names the argument
  expectStopNaming(
    runBackfill(ped,
      dates = handDates,
      existingHistory = first[, setdiff(names(first), "neSexRatio")]
    ),
    "'existingHistory'", "neSexRatio"
  )
  expectStopNaming(
    runBackfill(ped, dates = handDates, existingHistory = "not a history"),
    "'existingHistory'"
  )
})

test_that("a date that cannot be analyzed is reported and the others still run", {
  ped <- handBuiltColony()
  dates <- as.Date(c("1999-01-01", "2007-01-01", "2011-01-01"))
  expect_warning(
    result <- runBackfill(ped, dates = dates),
    "1 of 3 dates could not be rebuilt"
  )
  expect_identical(result$history$snapshotDate, dates[2:3])
  expect_identical(result$history$nAnimals, c(7L, 8L))
  expect_identical(result$skipped$snapshotDate, dates[[1L]])
  ## the reason is the condition message itself, not one wrapped around it
  expect_match(result$skipped$reason, "needs at least 2 animals", fixed = TRUE)
  expect_false(grepl("could not be built", result$skipped$reason, fixed = TRUE))
  ## the support table still has its row: nobody was alive on 1999-01-01
  expect_identical(result$support$snapshotDate, dates)
  expect_identical(result$support$nLiving, c(0L, 7L, 8L))
  expect_identical(result$support$nPossiblyAlive[[1L]], 0L)
  expect_true(is.na(result$support$pctSireKnown[[1L]]))
  expect_true(is.na(result$support$pctDamKnown[[1L]]))
})

test_that("when no date can be built the run stops and names every date it tried", {
  expectStopNaming(
    runBackfill(handBuiltColony(),
      dates = as.Date(c("1998-01-01", "1999-01-01"))
    ),
    "1998-01-01", "1999-01-01"
  )
})

test_that("a failing date beside one already there still returns the history", {
  ped <- handBuiltColony()
  existing <- runBackfill(ped, dates = handDates[[1L]])$history
  both <- as.Date(c("1999-01-01", "2007-01-01"))
  expect_warning(
    result <- runBackfill(ped, dates = both, existingHistory = existing),
    "1 of 2 dates could not be rebuilt"
  )
  expectSameRows(result$history, existing)
  expect_identical(result$skipped$snapshotDate, both)
})

## S1085 (owner ruling "App uses its own words"): the failed-dates warning is
## its own kind, backfillFailedDates, and carries its two counts, so the
## Genetic-Health Trends panel can say it in the app's words (its table is
## headed Dates not built) while a script keeps the sentence naming 'skipped'.

test_that("the failed-dates warning is its own kind and carries its two counts", {
  w <- failedDatesWarningOf()
  expect_s3_class(w, "backfillFailedDates")
  expect_s3_class(w, "warning")
  expect_identical(w$nFailed, 1L)
  expect_identical(w$nDates, 3L)
  ## a script still gets today's sentence, word for word, with no call
  expect_identical(
    conditionMessage(w),
    "1 of 3 dates could not be rebuilt and are listed in 'skipped'."
  )
  expect_null(conditionCall(w))
})

test_that("a date already there counts among the dates tried, not the failed", {
  ped <- handBuiltColony()
  existing <- runBackfill(ped, dates = handDates[[1L]])$history
  w <- failedDatesWarningOf(ped,
    dates = as.Date(c("1999-01-01", "2007-01-01")),
    existingHistory = existing
  )
  expect_s3_class(w, "backfillFailedDates")
  expect_identical(w$nFailed, 1L)
  expect_identical(w$nDates, 2L)
  expect_identical(
    conditionMessage(w),
    "1 of 2 dates could not be rebuilt and are listed in 'skipped'."
  )
})

test_that("updateProgress is called once per date with the date's place in the run", {
  calls <- list()
  recorder <- function(n = 1L, detail = NULL, value = 0L, reset = FALSE) {
    calls[[length(calls) + 1L]] <<- list(n = n, detail = detail, value = value)
  }
  dates <- as.Date(c("1999-01-01", "2007-01-01", "2011-01-01"))
  suppressWarnings(
    runBackfill(handBuiltColony(), dates = dates, updateProgress = recorder)
  )
  ## a date that fails still counts as a step, and reportGV()'s own per-animal
  ## calls are not passed on
  expect_length(calls, 3L)
  expect_equal(vapply(calls, function(x) x$n, numeric(1L)), rep(3, 3L))
  expect_equal(vapply(calls, function(x) x$value, numeric(1L)), 1:3)
  expect_identical(
    vapply(calls, function(x) x$detail, character(1L)),
    c("1999-01-01", "2007-01-01", "2011-01-01")
  )
})

test_that("the result holds the history, the support table and the skipped dates", {
  result <- runBackfill(handBuiltColony(), dates = handDates)
  expect_identical(names(result), c("history", "support", "skipped"))
  expect_s3_class(result$skipped, "data.frame")
  expect_identical(names(result$skipped), c("snapshotDate", "reason"))
  expect_identical(nrow(result$skipped), 0L)
  expect_s3_class(result$skipped$snapshotDate, "Date")
  expect_type(result$skipped$reason, "character")
})

test_that("the arguments keep their documented order and defaults", {
  signature <- deparse(args(backfillColonySnapshots), width.cutoff = 500L)[[1L]]
  signature <- sub("^function ?\\(", "function(", trimws(signature))
  expect_identical(signature, paste0(
    "function(ped, dates = NULL, guIter, guThresh, from = NULL, to = NULL, ",
    "by = \"year\", existingHistory = NULL, minAnimals = 2L, ",
    "updateProgress = NULL, ...)"
  ))
})

## ---------------------------------------------------------------------------
## Twin pairs (S1039, issue #170 Slice 3; the owner chose "Fix it in the
## function" at the PRE-RED gate)
## ---------------------------------------------------------------------------
##
## kinship() stops when a declared MZ pair names an animal that is not in the
## pedigree it is given ("All twinRelations id1/id2 values must be present in
## id."). On a past date that pedigree holds only the animals alive then and
## their ancestors, so a twin born later, or one who left and has no
## descendants, is not in it, and every date failed. Measured S1039 on the
## shipped example: one declared pair, a 1995 animal with a 2016 animal, gave
## "No snapshot could be built" for both 2000-01-01 and 2015-01-01. The app
## declares twins on the Pedigree tab, so the panel would hit it too.
##
## Declared MZ animals form groups (A-B and B-C make {A, B, C}, kinship's own
## rule). A group with an animal missing on a date cannot change anyone's
## kinship there through that animal, but the animals of it that are present
## are still identical twins of each other, so each date keeps the groups
## restricted to the animals present. An id that is in no pedigree at all is
## still a mistake and still stops, once, before any date.

twinPair <- function(id1, id2, code = "MZ twin") {
  data.frame(id1 = id1, id2 = id2, code = code, stringsAsFactors = FALSE)
}

test_that("a twin pair with an animal missing on a date is left out for that date", {
  ped <- handBuiltColony()
  ## K1 lives 2005-01-01 to 2008-01-01 and K5 is born 2010-06-01, so on
  ## 2007-01-01 K5 is not born and on 2011-01-01 K1 has left and has no
  ## descendants; each date lacks one of the two.
  without <- runBackfill(ped, dates = handDates)
  with <- runBackfill(ped, dates = handDates, twinRelations = twinPair("K1", "K5"))
  expect_identical(with$history$snapshotDate, handDates)
  expect_identical(nrow(with$skipped), 0L)
  expectSameRows(with$history, without$history)
  expectSameRows(with$support, without$support)
})

test_that("a twin pair is applied on the dates both animals are present", {
  ped <- handBuiltColony()
  ## K2 (born 2006) and K3 (born 2008) are both alive on 2011-01-01; on
  ## 2007-01-01 K3 is not born. Declaring them identical raises their kinship
  ## with each other from 0 to 0.5, and the mean kinship over the eight
  ## animals from 9/64 to 45/256 (measured S1039); nothing else in the row
  ## depends on it.
  pair <- twinPair("K2", "K3")
  without <- runBackfill(ped, dates = handDates)$history
  with <- runBackfill(ped, dates = handDates, twinRelations = pair)
  expect_identical(nrow(with$skipped), 0L)
  expectSameRows(with$history[1L, ], without[1L, ])
  expect_equal(without$meanIndivMeanKin[[2L]], 9 / 64)
  expect_equal(with$history$meanIndivMeanKin[[2L]], 45 / 256)
  kinshipColumns <- c(
    "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
    "kurtosisIndivMeanKin"
  )
  other <- setdiff(names(without), kinshipColumns)
  expectSameRows(with$history[2L, other], without[2L, other])
})

test_that("a chain of pairs through an animal who is missing still joins the animals present", {
  ## K2-K1 and K1-K3 make {K1, K2, K3}. K1 left in 2008, so on 2011-01-01 it
  ## is not in the pedigree, but K2 and K3 are still identical twins: the row
  ## equals the one for the pair (K2, K3).
  ped <- handBuiltColony()
  chain <- rbind(twinPair("K2", "K1"), twinPair("K1", "K3"))
  viaChain <- runBackfill(ped, dates = handDates[[2L]], twinRelations = chain)
  expect_identical(nrow(viaChain$skipped), 0L)
  expect_equal(viaChain$history$meanIndivMeanKin, 45 / 256)
  direct <- runBackfill(ped,
    dates = handDates[[2L]], twinRelations = twinPair("K2", "K3")
  )
  expectSameRows(viaChain$history, direct$history)
})

test_that("an id that is in no pedigree at all still stops, naming it", {
  ped <- handBuiltColony()
  expectStopNaming(
    runBackfill(ped, dates = handDates, twinRelations = twinPair("K1", "NOPE")),
    "twinRelations", "NOPE"
  )
  expectStopNaming(
    runBackfill(ped, dates = handDates, twinRelations = twinPair("NOPE", "K1")),
    "twinRelations", "NOPE"
  )
})

test_that("the example colony rebuilds both dates with a pair declared across them", {
  ## the case measured S1039: an animal born 1995-06-23 and one born
  ## 2016-05-05, on dates either side of the second birth
  ped <- jmacQc()
  early <- "03JG2L"
  late <- "0ZV8DV"
  expect_identical(ped$birth[ped$id == early], as.Date("1995-06-23"))
  expect_identical(ped$birth[ped$id == late], as.Date("2016-05-05"))
  dates <- as.Date(c("2000-01-01", "2015-01-01"))
  result <- runBackfill(ped,
    dates = dates, twinRelations = twinPair(early, late), seed = 7L
  )
  expect_identical(result$history$snapshotDate, dates)
  expect_identical(nrow(result$skipped), 0L)
})
