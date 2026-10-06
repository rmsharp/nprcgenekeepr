## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
data("ped1Alleles")
ids <- ped1Alleles$id
alleles <- ped1Alleles[, !(names(ped1Alleles) %in% c("id", "parent"))]
test_that("alleleFreq forms dataframe with correct calculations", {
  aF <- alleleFreq(alleles[[1L]], ids = NULL)
  expect_identical(aF$freq[aF$allele == 20004L], 10L)
  expect_identical(aF$freq[aF$allele == 20004L], 10L)
  expect_identical(aF$freq[aF$allele == 20012L], 11L)
  aF <- alleleFreq(alleles[[4L]], ids = NULL)
  expect_identical(aF$freq[aF$allele == 20004L], 14L)
  expect_identical(aF$freq[aF$allele == 20012L], 9L)
  aF <- alleleFreq(ped1Alleles[[1L]], ids = ids)
  expect_identical(aF$freq[aF$allele == 20004L], 10L)
  expect_identical(aF$freq[aF$allele == 20012L], 10L)
  aF <- alleleFreq(ped1Alleles[[4L]], ids = ids)
  expect_identical(aF$freq[aF$allele == 20004L], 13L)
  expect_identical(aF$freq[aF$allele == 20012L], 9L)
})

# S925: with no alleles (a pop that names no animal), the table had no allele
# column to rename and alleleFreq() stopped with "'names' attribute [2] must be
# the same length as the vector [1]". It now returns an empty table with the
# same two columns, of the same types, as a non-empty result.
test_that("alleleFreq returns an empty two-column table for no alleles (S925)", {
  full <- alleleFreq(alleles[[1L]], ids = NULL)
  aF <- alleleFreq(integer(0L), ids = NULL)
  expect_s3_class(aF, "data.frame")
  expect_named(aF, c("allele", "freq"))
  expect_identical(nrow(aF), 0L)
  expect_identical(class(aF$allele), class(full$allele))
  expect_identical(typeof(aF$freq), typeof(full$freq))

  aFids <- alleleFreq(integer(0L), ids = character(0L))
  expect_named(aFids, c("allele", "freq"))
  expect_identical(nrow(aFids), 0L)
})
