## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
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
## `cols` of 5 or more names holding an NA (docs-audit part 2 flag PB4, owner
## ruling S986). The help says an NA is an ordinary non-match, but the first
## check read the NA straight into `if ()`, so once `cols` was as long as the
## required set (5) and a required name was missing, the function stopped with
## "missing value where TRUE/FALSE needed". Four names worked only because
## `length(cols) < 5` is read first.
# `answer()` is the value checkRequiredCols() returns, or the error message it
# stops with, so one failing case does not end the block before the next.
answer <- function(cols, reportErrors) {
  tryCatch(checkRequiredCols(cols, reportErrors),
    error = function(e) conditionMessage(e)
  )
}
test_that("checkRequiredCols returns the missing cols of 5+ names with NA", {
  expect_identical(answer(c("id", "sire", "dam", "sex", NA), TRUE), "birth")
  expect_identical(answer(c(NA, "id", "sire", "dam", "sex"), TRUE), "birth")
  expect_identical(answer(c("id", "sire", NA, "sex", "birth"), TRUE), "dam")
  expect_identical(
    answer(c("id", "sire", "dam", "x", "y", NA), TRUE),
    c("sex", "birth")
  )
  expect_identical(
    answer(c("id", "sire", "dam", "sex", NA, NA), TRUE),
    "birth"
  )
  expect_identical(answer(rep(NA_character_, 5L), TRUE), requiredCols)
})
test_that("checkRequiredCols stops naming the missing cols of 5+ names, NA", {
  expect_error(
    checkRequiredCols(c("id", "sire", "dam", "sex", NA), reportErrors = FALSE),
    "Required field(s) missing: birth.",
    fixed = TRUE
  )
  expect_error(
    checkRequiredCols(c(NA, "id", "sire", "dam", "sex"), reportErrors = FALSE),
    "Required field(s) missing: birth.",
    fixed = TRUE
  )
  expect_error(
    checkRequiredCols(c("id", "sire", "dam", "x", "y", NA),
      reportErrors = FALSE
    ),
    "Required field(s) missing: sex, birth.",
    fixed = TRUE
  )
  expect_error(
    checkRequiredCols(rep(NA_character_, 5L), reportErrors = FALSE),
    "Required field(s) missing: id, sire, dam, sex, birth.",
    fixed = TRUE
  )
})
test_that("checkRequiredCols accepts an NA beside every required col", {
  # Passes before the fix: every required name is found, so the NA is never
  # read. Pins that the fix does not turn an NA into a missing column.
  for (reportErrors in c(TRUE, FALSE)) {
    expect_null(checkRequiredCols(c(requiredCols, NA), reportErrors))
    expect_null(checkRequiredCols(c(NA, requiredCols), reportErrors))
    expect_null(checkRequiredCols(
      c("id", "sire", NA, "dam", "sex", "birth", NA), reportErrors
    ))
  }
})
test_that("an NA in cols never changes what checkRequiredCols reports", {
  # Bases of 3 and 4 names reach 4 and 5 once the NA is added, so both sides of
  # the `length(cols) < 5` limit are compared.
  bases <- list(
    c("id", "sire", "dam"),
    c("id", "sire", "dam", "sex"),
    c("id", "sire", "dam", "sex", "x"),
    c("id", "sire", "dam", "x", "y", "z"),
    requiredCols
  )
  for (base in bases) {
    for (reportErrors in c(TRUE, FALSE)) {
      expected <- answer(base, reportErrors)
      info <- paste0(toString(base), "; reportErrors ", reportErrors)
      expect_identical(answer(c(base, NA), reportErrors), expected,
        info = info
      )
      expect_identical(answer(c(NA, base), reportErrors), expected,
        info = info
      )
    }
  }
})
