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

g1 <- c("f1", "f2", "m1", "o1", "o2")   # all-green group
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
  pedNoDam <- ped[, names(ped) != "dam"]
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
  gvNoValue <- gv[, "id", drop = FALSE]
  expect_error(
    getGeneticDiversityStats(list(g1), ped, gvNoValue, kmat,
                             currentDate = currentDate),
    "value"
  )
})

test_that("assembler output feeds makeGeneticDiversityHeatmap end to end", {
  res <- getGeneticDiversityStats(list(g1, g2), ped, gv, kmat,
                                  currentDate = currentDate)
  p <- makeGeneticDiversityHeatmap(res)
  expect_s3_class(p, "ggplot")
})
