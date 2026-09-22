# Tests for readAncestryRules() -- issue #168 Slice 1 file reader.
# Mirrors readKinshipOverrides(): reads a user-uploaded
# ancestry1,ancestry2,severity rules table from a CSV/text/Excel file into a
# data.frame to feed checkAncestryRules() (the sibling validator).

test_that("readAncestryRules reads an ancestry1,ancestry2,severity CSV into a data.frame", {
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("ancestry1,ancestry2,severity",
               "INDIAN,CHINESE,block",
               "INDIAN,HYBRID,flag"), csv)

  res <- readAncestryRules(csv)

  expect_true(is.data.frame(res))
  expect_true(all(c("ancestry1", "ancestry2", "severity") %in% names(res)))
  expect_identical(nrow(res), 2L)
  expect_identical(as.character(res$ancestry1), c("INDIAN", "INDIAN"))
  expect_identical(as.character(res$ancestry2), c("CHINESE", "HYBRID"))
  expect_identical(as.character(res$severity), c("block", "flag"))
})

test_that("readAncestryRules output validates with checkAncestryRules", {
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("ancestry1,ancestry2,severity", "INDIAN,CHINESE,block"), csv)

  res <- checkAncestryRules(readAncestryRules(csv))
  expect_identical(nrow(res), 1L)
  expect_type(res$ancestry1, "character")
})

test_that("readAncestryRules reads an ancestry rules Excel file", {
  skip_if_not_installed("openxlsx")
  xf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(xf), add = TRUE)
  df <- data.frame(ancestry1 = c("INDIAN", "INDIAN"),
                   ancestry2 = c("CHINESE", "HYBRID"),
                   severity = c("block", "flag"),
                   stringsAsFactors = FALSE)
  status <- create_wkbk(file = xf, df_list = list(df),
                        sheetnames = "rules", replace = TRUE)
  skip_if_not(isTRUE(status))
  res <- readAncestryRules(xf)
  expect_true(is.data.frame(res))
  expect_true(all(c("ancestry1", "ancestry2", "severity") %in% names(res)))
  expect_identical(nrow(res), 2L)
})

test_that("the shipped example rules file reads and validates without warning", {
  f <- system.file("extdata", "examples", "example_ancestry_rules.csv",
                   package = "nprcgenekeepr")
  expect_true(nzchar(f))
  rules <- readAncestryRules(f)
  # The example names UNKNOWN AND OTHER (plan D6, non-idempotency guidance)
  # so validation must be warning-free, and it carries both severities so
  # Slice 2 has fixture coverage for block and flag paths alike.
  expect_warning(out <- checkAncestryRules(rules), NA)
  expect_identical(nrow(out), 4L)
  expect_setequal(unique(out$severity), c("block", "flag"))
  expect_true(all(c("UNKNOWN", "OTHER") %in% c(out$ancestry1, out$ancestry2)))
})
