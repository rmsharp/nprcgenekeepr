#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("alleleFreq")
library(testthat)
ped1Alleles <- nprcgenekeepr::ped1Alleles
ids <- ped1Alleles$id
alleles <- ped1Alleles[, !(names(ped1Alleles) %in% c("id", "parent"))]
test_that("alleleFreq forms dataframe with correct calculations", {
  aF <- alleleFreq(alleles[[1]], ids = NULL)
  expect_equal(aF$freq[aF$allele == 20004], 10)
  expect_equal(aF$freq[aF$allele == 20012], 11)
  aF <- alleleFreq(alleles[[4]], ids = NULL)
  expect_equal(aF$freq[aF$allele == 20004], 14)
  expect_equal(aF$freq[aF$allele == 20012], 9)
  aF <- alleleFreq(ped1Alleles[[1]], ids = ids)
  expect_equal(aF$freq[aF$allele == 20004], 10)
  expect_equal(aF$freq[aF$allele == 20012], 10)
  aF <- alleleFreq(ped1Alleles[[4]], ids = ids)
  expect_equal(aF$freq[aF$allele == 20004], 13)
  expect_equal(aF$freq[aF$allele == 20012], 9)
})
