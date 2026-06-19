#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Structure/type contract for the bundled `rhesusGenotypes` data object.
#' `rhesusGenotypes` is a 31-animal, two-haplotype-per-animal MHC genotype
#' table re-exported (S124, owner pick A7) to carry canonical character column
#' types: id, first_name, and second_name are all character (they shipped as
#' stringsAsFactors-era factors). These tests pin both the corrected types and
#' the preserved data values so a future re-export cannot silently regress the
#' types or drop/alter rows.
g <- nprcgenekeepr::rhesusGenotypes

test_that("rhesusGenotypes shape and columns are preserved", {
  expect_s3_class(g, "data.frame")
  expect_identical(dim(g), c(31L, 3L))
  expect_named(g, c("id", "first_name", "second_name"))
})

test_that("rhesusGenotypes id is character (not factor), values preserved", {
  expect_type(g$id, "character")
  expect_false(is.factor(g$id))
  expect_identical(length(unique(g$id)), 31L)
  expect_identical(sum(is.na(g$id)), 0L)
  expect_true("0BNY0G" %in% g$id)
  expect_true("I67LRJ" %in% g$id)
  expect_true("K0M2RD" %in% g$id)
})

test_that("rhesusGenotypes first_name is character (not factor), values preserved", {
  expect_type(g$first_name, "character")
  expect_false(is.factor(g$first_name))
  expect_identical(length(unique(g$first_name)), 18L)
  expect_identical(sum(is.na(g$first_name)), 0L)
  expect_true("A004_B002" %in% g$first_name)
  expect_true("A008_B015b" %in% g$first_name)
})

test_that("rhesusGenotypes second_name is character (not factor), values preserved", {
  expect_type(g$second_name, "character")
  expect_false(is.factor(g$second_name))
  expect_identical(length(unique(g$second_name)), 23L)
  expect_identical(sum(is.na(g$second_name)), 0L)
  expect_true("A004_B048a" %in% g$second_name)
  expect_true("A002a_B069a" %in% g$second_name)
})
