context("hasGenotype")
library(testthat)
library(stringi)
genotype <- data.frame(id = stri_c(2500 + 1:20),
                       first = 10000L + 1L:20L,
                       second = 11000L + 1L:20L,
                       stringsAsFactors = FALSE)

test_that("hasGenotype ensures correct dataframe", {
  expect_true(hasGenotype(genotype))
genotype <- data.frame(id = stri_c(2500 + 1:20),
                       first = 10000L + 1L:20L,
                       second_name = stri_c("sec:ond_name", 1:20),
                       stringsAsFactors = FALSE)
expect_false(hasGenotype(genotype))
genotype <- data.frame(id = stri_c(2500 + 1:20),
                       first = 10000L + 1L:20L,
                       second_name = stri_c("second_name", 1:20),
                       stringsAsFactors = FALSE)
expect_false(hasGenotype(genotype))
genotype <- data.frame(ego = stri_c(2500 + 1:20),
                       first = 10000L + 1L:20L,
                       second = 11000L + 1L:20L,
                       stringsAsFactors = FALSE)
expect_false(hasGenotype(genotype))
genotype <- data.frame(id = stri_c(2500 + 1:20),
                       first_name = stri_c("first_name", 1:20),
                       second_name = stri_c("second_name", 1:20),
                       stringsAsFactors = FALSE)
expect_false(hasGenotype(genotype))
genotype <- data.frame(ego = stri_c(2500 + 1:20),
                       id = stri_c(2500 + 1:20),
                       first_name = stri_c("first_name", 1:20),
                       first = 10000L + 1L:20L,
                       second = 11000L + 1L:20L,
                       second_name = stri_c("second_name", 1:20),
                       stringsAsFactors = FALSE)
expect_true(hasGenotype(genotype))
})