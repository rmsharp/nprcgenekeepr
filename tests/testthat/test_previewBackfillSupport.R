## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## RED (S1039; issue #170, Slice 3 of docs/planning/retrospective-snapshot-
## backfill-plan.md section 5, design 5.2 item 8; BACKLOG.md:33): the panel
## that builds earlier snapshots shows, before the run, how many animals each
## date rests on. The owner ruled that the app never does more than a script
## (design B1), and today the counts exist only inside
## backfillColonySnapshots(), so at the PRE-RED gate (S1039, AskUserQuestion:
## "Export a preview function") one small function is exported:
##
##   previewBackfillSupport(ped, dates = NULL, from = NULL, to = NULL,
##                          by = "year", minAnimals = 2L)
##
## It lays out the same dates as the build and returns the same per-date table
## the build returns as $support, without the gene drop, so a script user can
## pick the start year knowingly and the panel calls the very same code. It
## takes the build's date arguments and none of its settings (guIter, guThresh,
## existingHistory, updateProgress and the reportGV() arguments mean nothing
## without a gene drop).
##
## Counts are pinned from the hand-counted fixtures of
## test_backfillColonySnapshots.R (now in helper-backfillColony.R) and from the
## figures measured S1038 on the shipped example (design 5.2).

## The support table a real build reports, for the same arguments.
builtSupport <- function(ped, ...) {
  set.seed(1L)
  suppressWarnings(
    backfillColonySnapshots(ped, guIter = 10L, guThresh = 1L, ...)
  )$support
}

test_that("previewBackfillSupport is exported", {
  ns <- readLines(system.file("NAMESPACE", package = "nprcgenekeepr"))
  expect_true("export(previewBackfillSupport)" %in% ns)
})

test_that("it returns the table a build reports for the same dates", {
  ped <- handBuiltColony()
  preview <- previewBackfillSupport(ped, dates = handDates)
  expect_s3_class(preview, "data.frame")
  expect_identical(names(preview), c(
    "snapshotDate", "nLiving", "nPlacedByOffspring", "nPossiblyAlive",
    "pctSireKnown", "pctDamKnown"
  ))
  expectSameRows(preview, builtSupport(ped, dates = handDates))
  ## and for the default series, with and without undated animals
  expectSameRows(previewBackfillSupport(ped), builtSupport(ped))
  expectSameRows(
    previewBackfillSupport(undatedColony(), dates = undatedDates),
    builtSupport(undatedColony(), dates = undatedDates)
  )
})

test_that("it gives the hand counts of the small colonies", {
  ## the same figures test_backfillColonySnapshots.R pins for the build
  support <- previewBackfillSupport(undatedColony(), dates = undatedDates)
  expect_identical(support$snapshotDate, undatedDates)
  expect_identical(support$nLiving, c(4L, 6L, 5L))
  expect_identical(support$nPlacedByOffspring, c(1L, 1L, 0L))
  expect_identical(support$nPossiblyAlive, c(3L, 3L, 2L))
  expect_equal(support$pctSireKnown, c(25, 50, 60))
  expect_equal(support$pctDamKnown, c(25, 50, 80))
  every <- previewBackfillSupport(handBuiltColony())
  expect_identical(
    every$snapshotDate,
    seq(as.Date("2000-01-01"), as.Date("2012-01-01"), by = "year")
  )
  expect_identical(
    every$nLiving,
    c(2L, 4L, 5L, 5L, 5L, 6L, 7L, 7L, 7L, 8L, 8L, 8L, 7L)
  )
})

test_that("it gives the example colony's counts at 1970, 1990 and 2000", {
  ## counted S1038 with code independent of the build (design 5.2 item 3)
  dates <- as.Date(c("1970-01-01", "1990-01-01", "2000-01-01"))
  support <- previewBackfillSupport(jmacQc(), dates = dates)
  expect_identical(support$nLiving, c(65L, 204L, 230L))
  expect_identical(support$nPlacedByOffspring, c(21L, 3L, 0L))
  expect_identical(support$nPossiblyAlive, c(24L, 2L, 2L))
  expect_equal(support$pctSireKnown, 100 * c(1, 1, 90) / c(65, 204, 230))
  expect_equal(support$pctDamKnown, 100 * c(44, 194, 210) / c(65, 204, 230))
})

test_that("the example colony's default series is 53 yearly dates, 1966 to 2018", {
  ## the default pinned nowhere else (S1038 gotcha): the first 1 January with
  ## two living animals, to the last 1 January on or before the latest date in
  ## the data. Counts only, so this is fast; the build of the same series takes
  ## about 8 s at guIter 10.
  support <- previewBackfillSupport(jmacQc())
  expect_identical(nrow(support), 53L)
  expect_identical(support$snapshotDate[[1L]], as.Date("1966-01-01"))
  expect_identical(support$snapshotDate[[53L]], as.Date("2018-01-01"))
  expect_identical(
    support$snapshotDate, seq(as.Date("1966-01-01"), by = "year", length.out = 53L)
  )
  ## the first points rest on very little: two animals against 57 more that
  ## the studbook does not rule out (design 5.2 item 3)
  expect_identical(support$nLiving[[1L]], 2L)
  expect_identical(support$nPossiblyAlive[[1L]], 57L)
  expect_identical(support$nLiving[support$snapshotDate == "1967-01-01"], 13L)
  expect_identical(support$nLiving[support$snapshotDate == "1968-01-01"], 33L)
  expect_identical(support$nLiving[[53L]], 344L)
})

test_that("from, to and by lay out the dates as the build does", {
  ped <- handBuiltColony()
  yearly <- previewBackfillSupport(ped, from = "2005-01-01", to = "2008-01-01")
  expect_identical(
    yearly$snapshotDate,
    as.Date(c("2005-01-01", "2006-01-01", "2007-01-01", "2008-01-01"))
  )
  halves <- previewBackfillSupport(ped,
    from = as.Date("2005-01-01"), to = as.Date("2006-01-01"), by = "6 months"
  )
  expect_identical(
    halves$snapshotDate,
    as.Date(c("2005-01-01", "2005-07-01", "2006-01-01"))
  )
  expect_identical(
    range(previewBackfillSupport(ped, from = "2010-01-01")$snapshotDate),
    as.Date(c("2010-01-01", "2012-01-01"))
  )
  expect_identical(
    range(previewBackfillSupport(ped, to = "2002-01-01")$snapshotDate),
    as.Date(c("2000-01-01", "2002-01-01"))
  )
})

test_that("minAnimals moves only the default start", {
  ped <- handBuiltColony()
  expect_identical(
    range(previewBackfillSupport(ped, minAnimals = 5L)$snapshotDate),
    as.Date(c("2002-01-01", "2012-01-01"))
  )
  ## on the example colony 1967 has 13 living animals and 1968 has 33
  support <- previewBackfillSupport(jmacQc(), minAnimals = 30L)
  expect_identical(support$snapshotDate[[1L]], as.Date("1968-01-01"))
  expect_identical(nrow(support), 51L)
  ## a date asked for by name is never refused for having few animals
  named <- previewBackfillSupport(ped, dates = "2000-01-01", minAnimals = 50L)
  expect_identical(named$nLiving, 2L)
})

test_that("dates may be given out of order or as text, and come back in order", {
  ped <- handBuiltColony()
  expect_identical(
    previewBackfillSupport(ped, dates = rev(handDates))$snapshotDate, handDates
  )
  expect_identical(
    previewBackfillSupport(ped, dates = c("2007-01-01", "2011-01-01"))$nLiving,
    c(7L, 8L)
  )
})

test_that("a date with nobody alive has a row of zeros and missing percentages", {
  support <- previewBackfillSupport(handBuiltColony(),
    dates = as.Date(c("1999-01-01", "2007-01-01"))
  )
  expect_identical(support$nLiving, c(0L, 7L))
  expect_identical(support$nPossiblyAlive[[1L]], 0L)
  expect_true(is.na(support$pctSireKnown[[1L]]))
  expect_true(is.na(support$pctDamKnown[[1L]]))
})

test_that("arguments that do not make sense stop and name the argument", {
  ped <- handBuiltColony()
  expectStopNaming(
    previewBackfillSupport(ped, dates = handDates, from = "2005-01-01"),
    "'dates'", "'from'"
  )
  expectStopNaming(
    previewBackfillSupport(ped, dates = handDates, to = "2008-01-01"),
    "'dates'", "'to'"
  )
  expectStopNaming(
    previewBackfillSupport(ped, dates = handDates, by = "month"),
    "'dates'", "'by'"
  )
  expectStopNaming(
    previewBackfillSupport(ped, from = "2008-01-01", to = "2005-01-01"),
    "'from'", "'to'"
  )
  expectStopNaming(previewBackfillSupport(ped, from = "not a date"), "'from'")
  expectStopNaming(previewBackfillSupport(ped, to = "2008-13-45"), "'to'")
  expectStopNaming(previewBackfillSupport(ped, by = "fortnightly"), "'by'")
  for (bad in list(1L, 0L, 2.5, NA_integer_, c(2L, 3L), "2")) {
    expectStopNaming(previewBackfillSupport(ped, minAnimals = bad), "'minAnimals'")
  }
  ## no January has 9 living animals in this colony (8 at most)
  expectStopNaming(previewBackfillSupport(ped, minAnimals = 9L), "'minAnimals'")
  expectStopNaming(
    previewBackfillSupport(ped, dates = c(handDates, handDates)), "'dates'"
  )
  expectStopNaming(
    previewBackfillSupport(ped, dates = c("2007-01-01", NA)), "'dates'"
  )
})

test_that("a pedigree missing a required column stops, naming every one", {
  ped <- handBuiltColony()
  msg <- tryCatch(
    previewBackfillSupport(ped[, setdiff(names(ped), c("birth", "exit"))],
      dates = handDates
    ),
    error = function(e) conditionMessage(e)
  )
  expect_false(grepl("could not find function", msg, fixed = TRUE), info = msg)
  expect_match(msg, "birth", fixed = TRUE)
  expect_match(msg, "exit", fixed = TRUE)
  expect_match(msg, "previewBackfillSupport", fixed = TRUE)
  expectStopNaming(previewBackfillSupport("not a pedigree"), "'ped'")
})

test_that("it counts only: the gene drop is never run", {
  testthat::local_mocked_bindings(
    reportGV = function(...) stop("reportGV was reached"),
    .package = "nprcgenekeepr"
  )
  support <- previewBackfillSupport(handBuiltColony(), dates = handDates)
  expect_identical(support$nLiving, c(7L, 8L))
})

test_that("it leaves the pedigree it is given as it found it", {
  ped <- handBuiltColony()
  before <- ped
  previewBackfillSupport(ped, dates = handDates)
  previewBackfillSupport(ped)
  expect_identical(ped, before)
})

test_that("the arguments keep their documented order and defaults", {
  args <- formals(previewBackfillSupport)
  expect_identical(
    names(args), c("ped", "dates", "from", "to", "by", "minAnimals")
  )
  expect_null(args$dates)
  expect_null(args$from)
  expect_null(args$to)
  expect_identical(args$by, "year")
  expect_identical(args$minAnimals, 2L)
})
