#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Structure/type contract for the bundled `rhesusPedigree` data object.
#' `rhesusPedigree` is an obfuscated 375-animal rhesus studbook re-exported
#' (S123, owner pick A6) to carry canonical pedigree column types matching
#' `examplePedigree`: id/sire/dam are character, birth/exit are Date. These
#' tests pin both the corrected types and the preserved data values so a
#' future re-export cannot silently regress the types or drop/alter rows.
ped <- nprcgenekeepr::rhesusPedigree

test_that("rhesusPedigree shape and columns are preserved", {
  expect_s3_class(ped, "data.frame")
  expect_identical(dim(ped), c(375L, 8L))
  expect_named(
    ped,
    c("id", "sire", "dam", "sex", "gen", "birth", "exit", "age")
  )
})

test_that("rhesusPedigree id/sire/dam are character (not factor), values preserved", {
  expect_type(ped$id, "character")
  expect_type(ped$sire, "character")
  expect_type(ped$dam, "character")
  expect_false(is.factor(ped$id))
  expect_false(is.factor(ped$sire))
  expect_false(is.factor(ped$dam))
  expect_identical(length(unique(ped$id)), 375L)
  expect_identical(sum(is.na(ped$id)), 0L)
  expect_identical(sum(is.na(ped$sire)), 124L)
  expect_identical(sum(is.na(ped$dam)), 124L)
  expect_true("BRI2MW" %in% ped$id)
})

test_that("rhesusPedigree sex is a factor with levels F, M", {
  expect_s3_class(ped$sex, "factor")
  expect_identical(levels(ped$sex), c("F", "M"))
  expect_identical(sum(is.na(ped$sex)), 0L)
})

test_that("rhesusPedigree gen is integer", {
  expect_type(ped$gen, "integer")
  expect_identical(sum(is.na(ped$gen)), 0L)
})

test_that("rhesusPedigree birth is a Date (not factor), values preserved", {
  expect_s3_class(ped$birth, "Date")
  expect_false(is.factor(ped$birth))
  expect_identical(sum(is.na(ped$birth)), 85L)
  expect_identical(min(ped$birth, na.rm = TRUE), as.Date("1970-07-03"))
  expect_identical(max(ped$birth, na.rm = TRUE), as.Date("2013-12-21"))
  expect_identical(ped$birth[ped$id == "BRI2MW"], as.Date("1998-12-06"))
})

test_that("rhesusPedigree exit is a Date, all NA", {
  expect_s3_class(ped$exit, "Date")
  expect_false(is.logical(ped$exit))
  expect_true(all(is.na(ped$exit)))
  expect_identical(sum(is.na(ped$exit)), 375L)
})

test_that("rhesusPedigree age is numeric", {
  expect_type(ped$age, "double")
  expect_identical(sum(is.na(ped$age)), 85L)
})
