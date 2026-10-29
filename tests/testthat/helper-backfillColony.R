## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Fixtures shared by test_backfillColonySnapshots.R and
## test_previewBackfillSupport.R (issue #170): the hand-counted colonies, the
## shipped Japanese macaque example read the way the app reads it, and the
## error check both files use. Moved here from test_backfillColonySnapshots.R
## in S1039 (RED) so the two files do not keep a copy each; nothing in them
## changed.

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

## Runs backfillColonySnapshots() with a seed and lets through only its
## failed-dates warning (kind "backfillFailedDates"), so reportGV()'s own
## warnings can neither hide it nor stand in for it. Moved here from
## test_backfillColonySnapshots.R in S1085 (REFACTOR), where it matched the
## warning's words; it now goes by the warning's kind.
runBackfill <- function(ped, ..., seed = 1L) {
  set.seed(seed)
  withCallingHandlers(
    backfillColonySnapshots(ped, guIter = 20L, guThresh = 1L, ...),
    warning = function(w) {
      if (!inherits(w, "backfillFailedDates")) {
        invokeRestart("muffleWarning")
      }
    }
  )
}

## The failed-dates warning a run raises, caught whole: on the hand-built
## colony nobody was alive on 1999-01-01, so 1 of the 3 default dates fails.
## Used by test_backfillColonySnapshots.R and by test_modSnapshotTrends.R,
## whose panel tests are fed what the real function raises (S1085, owner
## ruling "App uses its own words").
failedDatesWarningOf <- function(ped = handBuiltColony(),
                                 dates = as.Date(c(
                                   "1999-01-01", "2007-01-01", "2011-01-01"
                                 )),
                                 ...) {
  tryCatch(runBackfill(ped, dates = dates, ...), warning = function(w) w)
}
