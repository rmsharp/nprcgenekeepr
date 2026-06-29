## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## The example pedigree datasets carry deliberately "messy" headers so that
## qcStudbook()/fixColumnNames() normalization is exercised. The sire column
## uses a realistic period-bearing header ("sire.id") -- a period in a column
## name is a common habit of inexperienced data providers -- NOT the malformed
## "si.re"/"si re" that mis-split the word "sire" (see GitHub issue #53).

test_that("example pedigree datasets use the corrected 'sire.id' header", {
  expect_identical(
    names(nprcgenekeepr::pedGood),
    c("ego_id", "sire.id", "dam_id", "sex", "birth_date")
  )
  expect_identical(
    names(nprcgenekeepr::pedDuplicateIds),
    c("ego_id", "sire.id", "dam_id", "sex", "birth_date")
  )
  expect_identical(
    names(nprcgenekeepr::pedFemaleSireMaleDam),
    c("ego_id", "sire.id", "dam_id", "sex", "birth_date")
  )
  expect_identical(
    names(nprcgenekeepr::pedMissingBirth),
    c("ego_id", "sire.id", "dam_id", "sex")
  )
  expect_identical(
    names(nprcgenekeepr::pedSameMaleIsSireAndDam),
    c("ego_id", "sire.id", "dam_id", "sex", "birth_date")
  )
  expect_identical(
    names(nprcgenekeepr::pedOne),
    c("ego_id", "sire.id", "dam_id", "sex", "birth_date")
  )
})

test_that("the malformed 'si.re' / 'si re' sire header is gone from shipped data", {
  peds <- list(
    nprcgenekeepr::pedGood, nprcgenekeepr::pedDuplicateIds,
    nprcgenekeepr::pedFemaleSireMaleDam, nprcgenekeepr::pedMissingBirth,
    nprcgenekeepr::pedSameMaleIsSireAndDam, nprcgenekeepr::pedOne
  )
  for (ped in peds) {
    expect_false(any(names(ped) %in% c("si.re", "si re")))
  }
})

test_that("example datasets still normalize to canonical pedigree columns", {
  ## Invariant guard (passes before and after the rename): fixColumnNames()
  ## maps the messy headers to the canonical studbook columns.
  canonical <- c("id", "sire", "dam", "sex", "birth")
  peds <- list(
    nprcgenekeepr::pedGood, nprcgenekeepr::pedDuplicateIds,
    nprcgenekeepr::pedFemaleSireMaleDam,
    nprcgenekeepr::pedSameMaleIsSireAndDam, nprcgenekeepr::pedOne
  )
  for (ped in peds) {
    fixed <- fixColumnNames(names(ped), getEmptyErrorLst())$newColNames
    expect_true(all(canonical %in% fixed))
  }
  ## pedMissingBirth intentionally lacks the birth column
  fixed <- fixColumnNames(
    names(nprcgenekeepr::pedMissingBirth), getEmptyErrorLst()
  )$newColNames
  expect_true(all(c("id", "sire", "dam", "sex") %in% fixed))
})
