## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(nprcgenekeepr)
library(lubridate)
pedOne <- data.frame(
  ego_id = c(
    "s1", "d1", "s2", "d2", "o1", "o2", "o3",
    "o4"
  ),
  `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
  dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
  birth_date = mdy(
    paste0(
      sample(1L:12L, 8L, replace = TRUE), "-",
      sample(1L:28L, 8L, replace = TRUE), "-",
      sample(seq(0L, 15L, by = 3L), 8L, replace = TRUE) +
        2000L
    )
  ),
  stringsAsFactors = FALSE, check.names = FALSE
)

test_that("checkChangedColsLst identifies absence of column changes", {
  errorLst <- getEmptyErrorLst()
  expect_false(checkChangedColsLst(errorLst$changedCols))
})
test_that("checkChangedColsLst identifies presence of column changes", {
  errorLst <- qcStudbook(pedOne, reportErrors = TRUE, reportChanges = TRUE)
  expect_true(checkChangedColsLst(errorLst$changedCols))
})

# ============================================================================
# Every kind of rename counts (S988)
# ============================================================================
# BACKLOG.md:141-147 (S986 flag PB7): the function checked 12 of the 13 fields
# of getEmptyErrorLst()$changedCols, so a lowercase `geographicorigin` header
# was renamed with no notice and qcStudbook(reportErrors = TRUE) returned NULL.
# The owner ruled S986: count every kind.

test_that("checkChangedColsLst is TRUE when any one change field is the only one filled", {
  fields <- names(getEmptyErrorLst()$changedCols)
  expect_true("geographicoriginToGeographicOrigin" %in% fields)
  for (field in fields) {
    changedCols <- getEmptyErrorLst()$changedCols
    changedCols[[field]] <- "a to b"
    expect_true(checkChangedColsLst(changedCols), info = field)
  }
})

test_that("checkChangedColsLst is FALSE for NULL, an empty list and empty fields", {
  expect_false(checkChangedColsLst(NULL))
  expect_false(checkChangedColsLst(list()))
  expect_false(checkChangedColsLst(getEmptyErrorLst()$changedCols))
})

test_that("checkChangedColsLst counts a change field it has no name for", {
  expect_true(checkChangedColsLst(list(someFutureRename = "a to b")))
})

test_that("qcStudbook keeps a lowercase geographicorigin rename in its error list", {
  errorLst <- qcStudbook(pedLowercaseGeographicOrigin(),
                         reportErrors = TRUE, reportChanges = TRUE)
  expect_false(is.null(errorLst))
  expect_identical(errorLst$changedCols$geographicoriginToGeographicOrigin,
                   lowercaseGeographicOriginRename)
  expect_true(checkChangedColsLst(errorLst$changedCols))
})
