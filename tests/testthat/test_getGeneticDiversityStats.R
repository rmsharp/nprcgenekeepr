## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## Tests for getGeneticDiversityStats() -- issue #112 Slice S3.
## The assembler builds, for each breeding group, the four heat-map metric
## colour indices (Value, Origin, Production, Inbreeding) by calling the four
## per-group providers (getProportionLow, getIndianOriginStatus,
## getProductionStatus, getKinshipWithMaleStatus) and returns the
## group x metric data frame that makeGeneticDiversityHeatmap() (S1) renders.
## Fixtures are hand-built and a fixed currentDate (2020-07-01) is used so that
## the derived age (from birth) and the production birth window
## (currentYear-2 .. currentYear-1 = 2018-2019) are deterministic.

currentDate <- as.Date("2020-07-01")

## Reuse the S2 kinship-matrix idiom: every off-diagonal pair starts "related"
## (0.25, above the 0.015625 threshold), the diagonal is a founder 0.5, and
## each `unrelated` pair is set symmetrically to 0 (below threshold).
makeKmat <- function(ids, unrelated = list()) {
  kmat <- matrix(0.25, nrow = length(ids), ncol = length(ids),
                 dimnames = list(ids, ids))
  diag(kmat) <- 0.5
  for (pair in unrelated) {
    kmat[pair[1L], pair[2L]] <- 0
    kmat[pair[2L], pair[1L]] <- 0
  }
  kmat
}

## Pedigree fixture. Adults carry exit = NA (still present); offspring pass a
## real exit inside the 2018-2019 window so getProductionStatus counts them.
ped <- data.frame(
  id = c("f1", "f2", "m1", "o1", "o2",
         "c1", "c2", "c3", "cm", "co",
         "h1", "h2", "ho",
         "u1", "u2", "u3", "u4",
         "a1", "a2",
         "n1", "n2"),
  sire = NA_character_,
  dam = NA_character_,
  sex = c("F", "F", "M", "M", "F",
          "F", "F", "F", "M", "M",
          "F", "F", "M",
          "F", "F", "F", "M",
          "F", "M",
          "M", "M"),
  birth = as.Date(c(
    "2008-01-01", "2009-01-01", "2005-01-01", "2018-06-01", "2019-02-01",
    "2008-01-01", "2009-01-01", "2010-01-01", "2004-01-01", "2018-06-01",
    "2008-01-01", "2009-01-01", "2018-06-01",
    "2008-01-01", "2009-01-01", "2010-01-01", "2005-01-01",
    "2008-01-01", "2005-01-01",
    "2005-01-01", "2006-01-01")),
  exit = as.Date(c(
    NA, NA, NA, "2019-06-01", "2019-12-01",
    NA, NA, NA, NA, "2019-06-01",
    NA, NA, "2019-06-01",
    NA, NA, NA, NA,
    NA, NA,
    NA, NA)),
  ancestry = c(
    "INDIAN", "INDIAN", "INDIAN", "INDIAN", "INDIAN",
    "CHINESE", "INDIAN", "INDIAN", "INDIAN", "INDIAN",
    "INDIAN", "INDIAN", "INDIAN",
    "INDIAN", "INDIAN", "INDIAN", "INDIAN",
    "INDIAN", "INDIAN",
    "INDIAN", "INDIAN"),
  stringsAsFactors = FALSE
)

## Genetic-value report frame (id + value), the shape reportGV(ped)$report
## exposes. rankSubjects() emits exactly "Low Value" / "High Value" /
## "Undetermined".
gv <- data.frame(
  id = ped$id,
  value = c(
    "High Value", "High Value", "High Value", "High Value", "High Value",
    "Low Value", "Low Value", "Low Value", "High Value", "High Value",
    "High Value", "High Value", "High Value",
    "Low Value", "High Value", "Undetermined", "Undetermined",
    "Undetermined", "Undetermined",
    "High Value", "High Value"),
  stringsAsFactors = FALSE
)

## Full kinship matrix over every fixture id. Only the green group's two
## females are unrelated to its single adult male; everyone else stays related.
kmat <- makeKmat(ped$id, list(c("f1", "m1"), c("f2", "m1")))

## One required column dropped, for the missing-column tests.
pedNoDam <- ped[, names(ped) != "dam"]
gvNoValue <- gv[, "id", drop = FALSE]

g1 <-c("f1", "f2", "m1", "o1", "o2")   # all-green group
g2 <- c("c1", "c2", "c3", "cm", "co")   # all-red group

test_that("assembles a group x metric colorIndex frame (green + red groups)", {
  res <- getGeneticDiversityStats(list(g1, g2), ped, gv, kmat,
                                  housing = "shelter_pens",
                                  currentDate = currentDate)
  expect_s3_class(res, "data.frame")
  expect_identical(nrow(res), 2L)
  expect_identical(
    names(res),
    c("group", "Value", "Origin", "Production", "Inbreeding")
  )
  expect_identical(res$Value, c(3L, 1L))
  expect_identical(res$Origin, c(3L, 1L))
  expect_identical(res$Production, c(3L, 1L))
  expect_identical(res$Inbreeding, c(3L, 1L))
})

test_that("metric columns are integer indices and the group label is text", {
  res <- getGeneticDiversityStats(list(g1, g2), ped, gv, kmat,
                                  currentDate = currentDate)
  expect_type(res$group, "character")
  expect_type(res$Value, "integer")
  expect_type(res$Origin, "integer")
  expect_type(res$Production, "integer")
  expect_type(res$Inbreeding, "integer")
  expect_true(all(unlist(res[-1L]) %in% c(1L, 2L, 3L)))
})

test_that("unnamed groups get default 'Group N' row labels", {
  res <- getGeneticDiversityStats(list(g1, g2), ped, gv, kmat,
                                  currentDate = currentDate)
  expect_identical(res$group, c("Group 1", "Group 2"))
})

test_that("named groups use their names as row labels", {
  res <- getGeneticDiversityStats(list(Alpha = g1, Beta = g2), ped, gv, kmat,
                                  currentDate = currentDate)
  expect_identical(res$group, c("Alpha", "Beta"))
})

test_that("Undetermined animals are excluded from the Value denominator", {
  ## Among {u1 Low, u2 High} the Low proportion is 1/2 = 0.5 -> yellow (2).
  ## If the two Undetermined members were counted it would be 1/4 = 0.25 ->
  ## green (3), so this locks the exclusion.
  res <- getGeneticDiversityStats(list(c("u1", "u2", "u3", "u4")), ped, gv,
                                  kmat, currentDate = currentDate)
  expect_identical(res$Value, 2L)
})

test_that("a group with no assessed values scores Value red (undefined)", {
  res <- getGeneticDiversityStats(list(c("a1", "a2")), ped, gv, kmat,
                                  currentDate = currentDate)
  expect_identical(res$Value, 1L)
})

test_that("undefined Inbreeding (no breeding-age females) scores red", {
  ## n1/n2 are both male, so getKinshipWithMaleStatus returns NA; the
  ## assembler maps that undefined metric to red (1), never NA.
  res <- getGeneticDiversityStats(list(c("n1", "n2")), ped, gv, kmat,
                                  currentDate = currentDate)
  expect_identical(res$Inbreeding, 1L)
  expect_true(res$Inbreeding %in% c(1L, 2L, 3L))
})

test_that("housing scalar selects the production thresholds", {
  gH <- c("h1", "h2", "ho")   # 2 dams, 1 offspring -> production 0.5
  shelter <- getGeneticDiversityStats(list(gH), ped, gv, kmat,
                                      housing = "shelter_pens",
                                      currentDate = currentDate)
  corral <- getGeneticDiversityStats(list(gH), ped, gv, kmat,
                                     housing = "corral",
                                     currentDate = currentDate)
  expect_identical(shelter$Production, 1L)   # 0.5 < 0.6 -> red
  expect_identical(corral$Production, 2L)    # 0.5 in [0.5, 0.53] -> yellow
})

test_that("a per-group housing vector applies each group's own thresholds", {
  gH <- c("h1", "h2", "ho")
  res <- getGeneticDiversityStats(list(gH, gH), ped, gv, kmat,
                                  housing = c("shelter_pens", "corral"),
                                  currentDate = currentDate)
  expect_identical(res$Production, c(1L, 2L))
})

test_that("Origin column is omitted when the pedigree has no ancestry", {
  pedNoAnc <- ped[, names(ped) != "ancestry"]
  res <- getGeneticDiversityStats(list(g1), pedNoAnc, gv, kmat,
                                  currentDate = currentDate)
  expect_identical(names(res),
                   c("group", "Value", "Production", "Inbreeding"))
})

test_that("an empty groups list is an error", {
  expect_error(
    getGeneticDiversityStats(list(), ped, gv, kmat, currentDate = currentDate),
    "at least one group"
  )
})

test_that("a pedigree missing a required column is an error", {
  expect_error(
    getGeneticDiversityStats(list(g1), pedNoDam, gv, kmat,
                             currentDate = currentDate),
    "dam"
  )
})

test_that("a group member absent from the pedigree is an error", {
  expect_error(
    getGeneticDiversityStats(list(c("f1", "NOSUCH")), ped, gv, kmat,
                             currentDate = currentDate),
    "NOSUCH"
  )
})

test_that("a housing vector of the wrong length is an error", {
  expect_error(
    getGeneticDiversityStats(list(g1, g2), ped, gv, kmat,
                             housing = c("shelter_pens", "corral", "corral"),
                             currentDate = currentDate),
    "housing"
  )
})

test_that("a genetic-value frame without a value column is an error", {
  expect_error(
    getGeneticDiversityStats(list(g1), ped, gvNoValue, kmat,
                             currentDate = currentDate),
    "value"
  )
})

## Issue #123 (XARCH-5), NEW-24's first leftover: the two column checks are
## made by the shared assertRequiredColsPresent(), so a missing column reads
## "nprcgenekeepr: required column(s) missing in <where>: <columns>." like the
## reportGV(), reportMatePairs(), gvaConvergence() and qcStudbook() messages,
## and the error carries no call.

## Replace assertRequiredColsPresent() for the calling test with a recorder;
## returns the environment that collects the calls.
recordRequiredColsChecks <- function(envir = parent.frame()) {
  rec <- new.env()
  rec$calls <- list()
  local_mocked_bindings(
    assertRequiredColsPresent = function(availableCols, required, where) {
      rec$calls[[length(rec$calls) + 1L]] <- list(
        availableCols = availableCols, required = required, where = where
      )
      invisible(NULL)
    },
    .env = envir
  )
  rec
}

test_that("a ped missing columns is reported in the shared wording, in the required order", {
  expect_error(
    getGeneticDiversityStats(list(g1), pedNoDam, gv, kmat,
                             currentDate = currentDate),
    "required column\\(s\\) missing in getGeneticDiversityStats\\(ped\\): dam\\."
  )
  pedNoIdExit <- ped[, !names(ped) %in% c("id", "exit")]
  expect_error(
    getGeneticDiversityStats(list(g1), pedNoIdExit, gv, kmat,
                             currentDate = currentDate),
    "missing in getGeneticDiversityStats\\(ped\\): id, exit\\."
  )
  expect_error(
    getGeneticDiversityStats(list(g1), NULL, gv, kmat,
                             currentDate = currentDate),
    "missing in getGeneticDiversityStats\\(ped\\): id, dam, sex, birth, exit\\."
  )
})

test_that("a genetic-value frame missing columns is reported in the shared wording", {
  expect_error(
    getGeneticDiversityStats(list(g1), ped, gvNoValue, kmat,
                             currentDate = currentDate),
    paste0("required column\\(s\\) missing in ",
           "getGeneticDiversityStats\\(geneticValues\\): value\\.")
  )
  expect_error(
    getGeneticDiversityStats(list(g1), ped, gv[, "value", drop = FALSE], kmat,
                             currentDate = currentDate),
    "missing in getGeneticDiversityStats\\(geneticValues\\): id\\."
  )
  expect_error(
    getGeneticDiversityStats(list(g1), ped, data.frame(label = "x"), kmat,
                             currentDate = currentDate),
    "missing in getGeneticDiversityStats\\(geneticValues\\): id, value\\."
  )
})

test_that("a missing-column error carries no call, so the message is the whole report", {
  errPed <- tryCatch(
    getGeneticDiversityStats(list(g1), pedNoDam, gv, kmat,
                             currentDate = currentDate),
    error = function(e) e
  )
  expect_s3_class(errPed, "error")
  expect_null(conditionCall(errPed))
  errGv <- tryCatch(
    getGeneticDiversityStats(list(g1), ped, gvNoValue, kmat,
                             currentDate = currentDate),
    error = function(e) e
  )
  expect_s3_class(errGv, "error")
  expect_null(conditionCall(errGv))
})

test_that("a bad ped is reported before a bad genetic-value frame", {
  expect_error(
    getGeneticDiversityStats(list(g1), pedNoDam, gvNoValue, kmat,
                             currentDate = currentDate),
    "missing in getGeneticDiversityStats\\(ped\\): dam\\."
  )
})

test_that("the ped check is made by assertRequiredColsPresent() with the ped's names, its five columns and its label", {
  rec <- recordRequiredColsChecks()
  getGeneticDiversityStats(list(g1), ped, gv, kmat, currentDate = currentDate)
  pedCalls <- Filter(
    function(x) identical(x$where, "getGeneticDiversityStats(ped)"),
    rec$calls
  )
  expect_identical(
    pedCalls,
    list(list(availableCols = names(ped),
              required = c("id", "dam", "sex", "birth", "exit"),
              where = "getGeneticDiversityStats(ped)"))
  )
})

test_that("the genetic-value check is made by assertRequiredColsPresent() with the frame's names, its two columns and its label", {
  rec <- recordRequiredColsChecks()
  getGeneticDiversityStats(list(g1), ped, gv, kmat, currentDate = currentDate)
  gvCalls <- Filter(
    function(x) identical(x$where, "getGeneticDiversityStats(geneticValues)"),
    rec$calls
  )
  expect_identical(
    gvCalls,
    list(list(availableCols = names(gv),
              required = c("id", "value"),
              where = "getGeneticDiversityStats(geneticValues)"))
  )
})

test_that("assembler output feeds makeGeneticDiversityHeatmap end to end", {
  res <- getGeneticDiversityStats(list(g1, g2), ped, gv, kmat,
                                  currentDate = currentDate)
  p <- makeGeneticDiversityHeatmap(res)
  expect_s3_class(p, "ggplot")
})

## Animals with no birth date (S928): the group is still assessed. The
## Inbreeding metric leaves such animals out of its breeding-age counts. Found
## on the shipped example pedigree, where 1,432 of 3,694 animals have no birth
## date and the default top-ranked group has none on any of its 20 animals.

test_that("a group whose animals have no birth date completes; Inbreeding is undefined, so red", {
  pedNoBirth <- ped
  pedNoBirth$birth[pedNoBirth$id %in% g1] <- as.Date(NA)
  res <- getGeneticDiversityStats(list(g1), pedNoBirth, gv, kmat,
                                  currentDate = currentDate)
  expect_identical(nrow(res), 1L)
  expect_identical(res$Inbreeding, 1L)
  expect_s3_class(makeGeneticDiversityHeatmap(res), "ggplot")
})

test_that("an animal with no birth date does not count as a breeding-age female", {
  ## Only f1 is unrelated to the adult male m1; f2 is related to him. With f2's
  ## birth date removed she is left out, so f1 alone decides: 1 of 1 -> green
  ## (3). If f2 were counted as breeding age the group would be 1 of 2 -> red.
  kmatF1 <- makeKmat(ped$id, list(c("f1", "m1")))
  pedOneNoBirth <- ped
  pedOneNoBirth$birth[pedOneNoBirth$id == "f2"] <- as.Date(NA)
  res <- getGeneticDiversityStats(list(g1), pedOneNoBirth, gv, kmatF1,
                                  currentDate = currentDate)
  expect_identical(res$Inbreeding, 3L)
})

## Females with no birth date in the Production cell (S931 owner ruling): such a
## female counts as a breeding-age mother only if the pedigree lists an
## offspring for her, looked up in the WHOLE pedigree (not only her group). The
## group gH has two mothers (h1, h2) and one offspring born in the window, so
## Production is 0.5 (red) while both count.

test_that("a female with no birth date and no offspring is left out of Production", {
  gH <- c("h1", "h2", "ho")
  pedH2NoBirth <- ped
  pedH2NoBirth$birth[pedH2NoBirth$id == "h2"] <- as.Date(NA)
  res <- getGeneticDiversityStats(list(gH), pedH2NoBirth, gv, kmat,
                                  currentDate = currentDate)
  ## h2 is left out: 1 birth over the 1 remaining mother -> green (3), not red.
  expect_identical(res$Production, 3L)
})

test_that("a mother with no birth date whose offspring are in another group still counts", {
  gH <- c("h1", "h2", "ho")
  pedH2Mother <- ped
  pedH2Mother$birth[pedH2Mother$id == "h2"] <- as.Date(NA)
  ## The offspring "co" belongs to g2, not to gH: only the whole pedigree sees it.
  pedH2Mother$dam[pedH2Mother$id == "co"] <- "h2"
  res <- getGeneticDiversityStats(list(gH, g2), pedH2Mother, gv, kmat,
                                  currentDate = currentDate)
  ## h2 counts: 1 birth over 2 mothers = 0.5 -> red (1).
  expect_identical(res$Production[1L], 1L)
})

test_that("a group whose only female has no birth date and no offspring has no Production value", {
  gOnly <- c("h2", "ho")
  pedH2NoBirth <- ped
  pedH2NoBirth$birth[pedH2NoBirth$id == "h2"] <- as.Date(NA)
  res <- getGeneticDiversityStats(list(gOnly), pedH2NoBirth, gv, kmat,
                                  currentDate = currentDate)
  expect_identical(res$Production, NA_integer_)
  expect_s3_class(makeGeneticDiversityHeatmap(res), "ggplot")
})

## Females with no birth date in the Inbreeding cell (S935 owner ruling): the
## same rule as Production. Such a female counts as a breeding-age female only
## if the pedigree lists an offspring for her, looked up in the WHOLE pedigree.
## A male with no birth date stays out of the potential mates.

test_that("a female with no birth date and an offspring in her own group counts for Inbreeding", {
  ## f1 is unrelated to the adult male m1; f2 is related to him. With f2's birth
  ## date removed and o1 listed as her offspring she counts: 1 of 2 -> red (1).
  ## Without the offspring she is left out and the group is green (3), as the
  ## "does not count" test above shows.
  kmatF1 <- makeKmat(ped$id, list(c("f1", "m1")))
  pedF2Mother <- ped
  pedF2Mother$birth[pedF2Mother$id == "f2"] <- as.Date(NA)
  pedF2Mother$dam[pedF2Mother$id == "o1"] <- "f2"
  res <- getGeneticDiversityStats(list(g1), pedF2Mother, gv, kmatF1,
                                  currentDate = currentDate)
  expect_identical(res$Inbreeding, 1L)
})

test_that("a mother with no birth date whose offspring are in another group counts for Inbreeding", {
  kmatF1 <- makeKmat(ped$id, list(c("f1", "m1")))
  pedF2Mother <- ped
  pedF2Mother$birth[pedF2Mother$id == "f2"] <- as.Date(NA)
  ## The offspring "co" belongs to g2, not to g1: only the whole pedigree sees it.
  pedF2Mother$dam[pedF2Mother$id == "co"] <- "f2"
  res <- getGeneticDiversityStats(list(g1, g2), pedF2Mother, gv, kmatF1,
                                  currentDate = currentDate)
  expect_identical(res$Inbreeding[1L], 1L)
})

test_that("a group whose only female has no birth date but an offspring has a defined Inbreeding", {
  ## Left out she would leave no breeding-age female, so Inbreeding would be
  ## undefined and scored red (1). Counted, and unrelated to m1: green (3).
  kmatF2 <- makeKmat(ped$id, list(c("f2", "m1")))
  pedF2Mother <- ped
  pedF2Mother$birth[pedF2Mother$id == "f2"] <- as.Date(NA)
  pedF2Mother$dam[pedF2Mother$id == "o1"] <- "f2"
  res <- getGeneticDiversityStats(list(c("f2", "m1")), pedF2Mother, gv, kmatF2,
                                  currentDate = currentDate)
  expect_identical(res$Inbreeding, 3L)
})
