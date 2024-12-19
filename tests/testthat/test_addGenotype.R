#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("addGenotype")
library(testthat)
library(stringi)
qcPed <- nprcgenekeepr::qcPed

qcPed <- qcPed[order(qcPed$id), ]
ped <- qcPed
genotype <- data.frame(id = ped$id[50 + 1:20],
                       first_name = stri_c("first", 1:20),
                       second_name = stri_c("second", 1:20),
                       stringsAsFactors = FALSE)

test_that("addGenotype forms correct dataframe", {
  newPed <- addGenotype(ped, genotype)
  newPed <- newPed[order(newPed$id), ]
  expect_equal(as.character(newPed$first[newPed$id == ped$id[50 + 1]]), "10001")
  expect_equal(as.character(newPed$second[newPed$id == ped$id[50 + 1]]),
               "10021")
  expect_equal(as.character(newPed$first[newPed$id == ped$id[50 + 2]]),
               "10012")
  expect_equal(as.character(newPed$second[newPed$id == ped$id[50 + 2]]),
               "10032")
})
