## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #151 Slice 1 RED: tests for reportMatePairs(), written against a
## function that does not exist yet. See
## docs/planning/issue151-individual-mate-pair-analysis-plan.md Section 4
## (Interface catalog) and Section 5 (Slice 1 test list) for the contract
## these tests assert.
##
## Fixture: an 11-individual hand-built pedigree, deliberately shaped to
## reproduce the plan's own Section 2.6 finding (filterAge()'s NA-passes
## semantics means the age control alone cannot bound candidate-pair table
## size) as a small, deterministic regression case -- S3/D3 have NA age
## (like 81% of the real examplePedigree "alive" fixture) and would survive
## the age filter untouched; only the D4 population-scope parameter excludes
## them (Dragon #1).
##
## sireId/damId/kinship/markerKinship/sireIndivMeanKin/sireGu/
## damIndivMeanKin/damGu are the exact $pairs column names the plan's
## Section 4 interface catalog specifies.

ped <- data.frame(
  id = c(
    "S1", "D1", "S2", "D2", "S3", "D3",
    "A", "B", "C", "Y", "E"
  ),
  sire = c(
    NA, NA, NA, NA, NA, NA,
    "S1", "S2", "S1", "S2", "S2"
  ),
  dam = c(
    NA, NA, NA, NA, NA, NA,
    "D1", "D2", "D1", "D2", "D2"
  ),
  sex = c(
    "M", "F", "M", "F", "M", "F",
    "M", "F", "F", "M", "F"
  ),
  age = c(
    10, 10, 10, 10, NA, NA,
    5, 5, 5, 0.5, NA
  ),
  stringsAsFactors = FALSE
)
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)

## Only A, B, and C are genotyped -- markerKmat deliberately covers a
## strict subset of ped$id, matching modMarkerGenetics' own "not every
## animal has an uploaded genotype" contract (plan Section 2.2).
markerKmat <- matrix(
  c(
    0.500, 0.015, 0.220,
    0.015, 0.500, 0.030,
    0.220, 0.030, 0.500
  ),
  nrow = 3L, ncol = 3L,
  dimnames = list(c("A", "B", "C"), c("A", "B", "C"))
)

geneticValues <- list(report = data.frame(
  id = ped$id,
  indivMeanKin = c(
    0.05, 0.06, 0.07, 0.08, 0.09, 0.10,
    0.11, 0.12, 0.13, 0.14, 0.15
  ),
  gu = c(
    12, 13, 14, 15, 16, 17,
    18, 19, 20, 21, 22
  ),
  stringsAsFactors = FALSE
))

pairKey <- function(pairsFrame) {
  paste(pairsFrame$sireId, pairsFrame$damId, sep = "|")
}

test_that("reportMatePairs composes opposite-sex + minAge eligibility exactly like filterPairs/filterAge", {
  result <- reportMatePairs(ped, kmat, minAge = 1L)

  # every surviving pair is opposite-sex: sireId is always male, damId
  # always female (regardless of the two ids' relative order in kmat)
  sireSex <- ped$sex[match(result$pairs$sireId, ped$id)]
  damSex <- ped$sex[match(result$pairs$damId, ped$id)]
  expect_true(all(sireSex == "M"))
  expect_true(all(damSex == "F"))

  # Y (age 0.5) fails minAge = 1 and must not appear in $pairs at all
  expect_false(any(result$pairs$sireId == "Y" | result$pairs$damId == "Y"))

  # Y's excluded pairs are reported with the under-age reason
  yExcluded <- result$excluded[
    result$excluded$sireId == "Y" | result$excluded$damId == "Y",
  ]
  expect_true(nrow(yExcluded) > 0L)
  expect_true(all(yExcluded$reason == "under minimum age"))
})

test_that("the D4 population-scope parameter bounds output size, not the age filter (plan Dragon #1)", {
  fullResult <- reportMatePairs(ped, kmat, minAge = 1L)

  # sanity check the fixture itself reproduces the finding: S3/D3 have NA
  # age, which filterAge() PASSES (not excludes) -- so with no population
  # scope, S3/D3 pairs are present in the unscoped result.
  expect_true(any(fullResult$pairs$sireId == "S3"))
  expect_true(any(fullResult$pairs$damId == "D3"))

  scopedIds <- setdiff(ped$id, c("S3", "D3"))
  scopedResult <- reportMatePairs(ped, kmat,
    minAge = 1L,
    populationIds = scopedIds
  )

  # population scoping -- not age -- is what excludes S3/D3
  expect_false(any(scopedResult$pairs$sireId == "S3" |
    scopedResult$pairs$damId == "S3"))
  expect_false(any(scopedResult$pairs$sireId == "D3" |
    scopedResult$pairs$damId == "D3"))

  # scoped result is a strict subset of the unscoped result
  fullKeys <- pairKey(fullResult$pairs)
  scopedKeys <- pairKey(scopedResult$pairs)
  expect_true(all(scopedKeys %in% fullKeys))
  expect_true(length(scopedKeys) < length(fullKeys))
})

test_that("markerKinship is NA when either id lacks genotype data, populated when both are genotyped", {
  result <- reportMatePairs(ped, kmat, markerKmat = markerKmat, minAge = 1L)

  abRow <- result$pairs[result$pairs$sireId == "A" & result$pairs$damId == "B", ]
  expect_identical(nrow(abRow), 1L)
  expect_identical(abRow$markerKinship, markerKmat["A", "B"])

  # S1 x B: S1 is not genotyped -> markerKinship must be NA, pair not dropped
  s1bRow <- result$pairs[result$pairs$sireId == "S1" & result$pairs$damId == "B", ]
  expect_identical(nrow(s1bRow), 1L)
  expect_true(is.na(s1bRow$markerKinship))
})

test_that("sireIndivMeanKin/sireGu/damIndivMeanKin/damGu are correctly looked up per id from geneticValues$report", {
  result <- reportMatePairs(ped, kmat,
    geneticValues = geneticValues,
    minAge = 1L
  )

  abRow <- result$pairs[result$pairs$sireId == "A" & result$pairs$damId == "B", ]
  expect_identical(nrow(abRow), 1L)

  expectedSire <- geneticValues$report[geneticValues$report$id == "A", ]
  expectedDam <- geneticValues$report[geneticValues$report$id == "B", ]

  expect_identical(abRow$sireIndivMeanKin, expectedSire$indivMeanKin)
  expect_identical(abRow$sireGu, expectedSire$gu)
  expect_identical(abRow$damIndivMeanKin, expectedDam$indivMeanKin)
  expect_identical(abRow$damGu, expectedDam$gu)
})

test_that("the excluded frame reports under-age and user-excluded reasons from a closed vocabulary", {
  result <- reportMatePairs(ped, kmat, minAge = 1L, exclude = "C")

  # C never appears in $pairs once excluded
  expect_false(any(result$pairs$sireId == "C" | result$pairs$damId == "C"))

  cExcluded <- result$excluded[
    result$excluded$sireId == "C" | result$excluded$damId == "C",
  ]
  expect_true(nrow(cExcluded) > 0L)
  # C's own user-exclusion produced at least one "user-excluded" row. This
  # is `any()`, not `all()`: a pair mentioning C can independently carry
  # the "under minimum age" reason instead (e.g. Y x C -- Y fails minAge
  # regardless of C's exclude-list membership), and that is correct, not a
  # defect -- reason is per-pair, not per-individual.
  expect_true(any(cExcluded$reason == "user-excluded"))

  # the reason column is a closed, enumerable vocabulary (plan Dragon #5)
  expect_true(all(result$excluded$reason %in% c(
    "under minimum age", "user-excluded"
  )))
})

test_that("NULL markerKmat / NULL geneticValues degrade gracefully -- columns present, all NA, no error", {
  expect_no_error(
    result <- reportMatePairs(ped, kmat,
      markerKmat = NULL, geneticValues = NULL, minAge = 1L
    )
  )

  expectedCols <- c(
    "sireId", "damId", "kinship", "markerKinship",
    "sireIndivMeanKin", "sireGu", "damIndivMeanKin", "damGu"
  )
  expect_true(all(expectedCols %in% names(result$pairs)))
  expect_true(nrow(result$pairs) > 0L)
  expect_true(all(is.na(result$pairs$markerKinship)))
  expect_true(all(is.na(result$pairs$sireIndivMeanKin)))
  expect_true(all(is.na(result$pairs$sireGu)))
  expect_true(all(is.na(result$pairs$damIndivMeanKin)))
  expect_true(all(is.na(result$pairs$damGu)))
})

test_that("reportMatePairs errors loudly on a malformed ped or kmat shape", {
  # regexp-matched so this test cannot spuriously pass merely because
  # reportMatePairs() doesn't exist yet ("could not find function" is an
  # error too, but not THIS error) -- it only passes once the intended
  # validation actually fires.
  badPed <- ped[, setdiff(names(ped), "sex")]
  expect_error(reportMatePairs(badPed, kmat, minAge = 1L), "required column")

  expect_error(
    reportMatePairs(ped, kmat = "not a matrix", minAge = 1L),
    "matrix"
  )
})

test_that("an empty populationIds returns a zero-row $pairs frame with the full column shape, not an error", {
  expect_no_error(
    result <- reportMatePairs(ped, kmat,
      minAge = 1L, populationIds = character(0L)
    )
  )

  expectedCols <- c(
    "sireId", "damId", "kinship", "markerKinship",
    "sireIndivMeanKin", "sireGu", "damIndivMeanKin", "damGu"
  )
  expect_identical(nrow(result$pairs), 0L)
  expect_true(all(expectedCols %in% names(result$pairs)))
})
