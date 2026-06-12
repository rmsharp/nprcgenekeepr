#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(stringi)
requiredCols <- getRequiredCols()
test_that("checkRequiredCols detects missing cols", {
  cols <- stri_c(
    "id,sire,siretype,dam,damtype,sex,numberofparentsknown,birth,",
    "arrivalatcenter,death,departure,status,ancestry,fromcenter?,",
    "origin"
  )
  expect_true(all(requiredCols %in% checkRequiredCols(cols,
    reportErrors = TRUE
  )))
})
test_that("checkRequiredCols returns missing cols (no error) on NA in cols", {
  # Out-of-contract input: `cols` shorter than the required set, containing NA,
  # with required cols absent. The robust contract returns the missing required
  # columns rather than erroring on the NA (intentional; see @details). Pins the
  # `%in%` form against the legacy sapply/`if (!any(col == cols))` form, which
  # errored with "missing value where TRUE/FALSE needed".
  expect_identical(
    checkRequiredCols(c("dam", "sex", "birth", NA), reportErrors = TRUE),
    c("id", "sire")
  )
  expect_identical(
    checkRequiredCols(c("id", NA), reportErrors = TRUE),
    c("sire", "dam", "sex", "birth")
  )
})
