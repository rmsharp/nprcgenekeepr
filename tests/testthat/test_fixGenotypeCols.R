#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("fixGenotypeCols")
library(testthat)
library(stringi)
test_that("fixGenotypeCols correct column names correctly", {
  genotype <- data.frame(id = stri_c(2500 + 1:20),
                         first_name = stri_c("A", 10000L + 1L:20L),
                         second_name = stri_c("second_name", 1:20),
                         stringsAsFactors = FALSE)
  ped <- fixGenotypeCols(genotype)
  expect_equal(names(ped), c("id", "first_name", "second_name"))
  genotype <- data.frame(id = stri_c(2500 + 1:20),
                         firstname = stri_c("A", 10000L + 1L:20L),
                         second_name = stri_c("second_name", 1:20),
                         stringsAsFactors = FALSE)
  ped <- fixGenotypeCols(genotype)
  expect_equal(names(ped), c("id", "first_name", "second_name"))
  genotype <- data.frame(id = stri_c(2500 + 1:20),
                         first_name = stri_c("A", 10000L + 1L:20L),
                         secondname = stri_c("second_name", 1:20),
                         stringsAsFactors = FALSE)
  ped <- fixGenotypeCols(genotype)
  expect_equal(names(ped), c("id", "first_name", "second_name"))
  genotype <- data.frame(id = stri_c(2500 + 1:20),
                         firstname = stri_c("A", 10000L + 1L:20L),
                         secondname = stri_c("second_name", 1:20),
                         stringsAsFactors = FALSE)
  ped <- fixGenotypeCols(genotype)
  expect_equal(names(ped), c("id", "first_name", "second_name"))
})
