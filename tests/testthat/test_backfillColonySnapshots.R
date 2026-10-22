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

## Eleven rows, counted by hand. Real animals:
##   S1  M  2000-01-01 to 2010-06-01     D1  F  2000-01-01 to 2012-01-01
##   D2  F  no birth date, left 2009-01-01, dam of K1
##   D3  F  no birth date, left 2011-01-01, no offspring
##   X1  F  no birth date, no exit date, status UNKNOWN, dam of K3
##   K1  M  2002-03-01 (S1 x D2)         K2  F  2004-05-01 (S1 x D1)
##   K3  M  2006-01-01 (K1 x X1)          K4  F  2008-01-01 (U0001 x D1)
##   Z1  M  2001-01-01, no exit date, status UNKNOWN
## and U0001, a generated stand-in sire, which is never an animal.
##
## Counted as alive (an undated parent from its first dated offspring until it
## leaves; an animal with no exit date only when the studbook says ALIVE):
##   2003-01-01  S1, D1, D2 (placed by K1), K1               4 (2 M, 2 F)
##   2007-01-01  S1, D1, D2, K1, K2, K3                      6 (3 M, 3 F)
##   2011-06-01  D1, K1, K2, K3, K4 (S1, D2, D3 have left)   5 (2 M, 3 F)
## X1 and Z1 never count. With D3 (no offspring, so it cannot be placed) they
## are the animals the studbook does not rule out: 3, 3 and 2 on the three
## dates (D3 left 2011-01-01). Recorded sires among the living: 1 of 4, 3 of
## 6, 3 of 5 (K4's sire is the stand-in); recorded dams: 1 of 4, 3 of 6, 4 of 5.
undatedColony <- function() {
  ped <- data.frame(
    id = c("S1", "D1", "D2", "D3", "X1", "K1", "K2", "K3", "K4", "U0001", "Z1"),
    sire = c(NA, NA, NA, NA, NA, "S1", "S1", "K1", "U0001", NA, NA),
    dam = c(NA, NA, NA, NA, NA, "D2", "D1", "X1", "D1", NA, NA),
    sex = c("M", "F", "F", "F", "F", "M", "F", "M", "F", "M", "M"),
    birth = as.Date(c(
      "2000-01-01", "2000-01-01", NA, NA, NA, "2002-03-01", "2004-05-01",
      "2006-01-01", "2008-01-01", NA, "2001-01-01"
    )),
    exit = as.Date(c(
      "2010-06-01", "2012-01-01", "2009-01-01", "2011-01-01", NA, NA, NA, NA,
      NA, NA, NA
    )),
    status = c(
      "DECEASED", "DECEASED", "DECEASED", "DECEASED", "UNKNOWN", "ALIVE",
      "ALIVE", "ALIVE", "ALIVE", "UNKNOWN", "UNKNOWN"
    ),
    placeholder = c(rep(FALSE, 9L), TRUE, FALSE),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}
undatedDates <- as.Date(c("2003-01-01", "2007-01-01", "2011-06-01"))

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

## An error that names what is wrong. R's own "unused argument (from = ...)"
## also contains the argument's name, so it is refused outright: before an
## argument exists these checks must fail, not pass by accident.
expectStopNaming <- function(expr, ...) {
  msg <- tryCatch(
    {
      force(expr)
      NA_character_
    },
    error = function(e) conditionMessage(e)
  )
  expect_false(is.na(msg), info = "expected an error, got none")
  expect_false(grepl("unused argument", msg, fixed = TRUE), info = msg)
  for (term in c(...)) {
    expect_match(msg, term, fixed = TRUE)
  }
}

expectSameRows <- function(actual, expected) {
  rownames(actual) <- NULL
  rownames(expected) <- NULL
  expect_equal(actual, expected)
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
