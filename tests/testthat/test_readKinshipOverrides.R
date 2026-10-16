# Tests for readKinshipOverrides() -- issue #13 Slice 2 file reader.
# Mirrors getGenotypes(): reads a user-uploaded id1,id2,kinship table from a
# CSV/text file into a data.frame to feed checkKinshipOverrides()/reportGV().

test_that("readKinshipOverrides reads an id1,id2,kinship CSV into a data.frame", {
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("id1,id2,kinship",
               "F1,F2,0.4",
               "F3,F4,0.1"), csv)

  res <- readKinshipOverrides(csv)

  expect_true(is.data.frame(res))
  expect_true(all(c("id1", "id2", "kinship") %in% names(res)))
  expect_identical(nrow(res), 2L)
  expect_identical(as.character(res$id1), c("F1", "F3"))
  expect_identical(as.character(res$id2), c("F2", "F4"))
  expect_equal(res$kinship, c(0.4, 0.1))
})

test_that("readKinshipOverrides output validates with checkKinshipOverrides", {
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("id1,id2,kinship", "A,B,0.25"), csv)

  res <- checkKinshipOverrides(readKinshipOverrides(csv))
  expect_identical(nrow(res), 1L)
  expect_type(res$id1, "character")
})

## Issue #111 coverage backfill: the Excel (.xls/.xlsx) branch (line 37) was
## never reached because both existing tests use .csv files.
test_that("readKinshipOverrides reads an id1,id2,kinship Excel file", {
  skip_if_not_installed("openxlsx")
  xf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(xf), add = TRUE)
  df <- data.frame(id1 = c("F1", "F3"), id2 = c("F2", "F4"),
                   kinship = c(0.4, 0.1), stringsAsFactors = FALSE)
  status <- create_wkbk(file = xf, df_list = list(df),
                        sheetnames = "ovr", replace = TRUE)
  skip_if_not(isTRUE(status))
  res <- readKinshipOverrides(xf)
  expect_true(is.data.frame(res))
  expect_true(all(c("id1", "id2", "kinship") %in% names(res)))
  expect_identical(nrow(res), 2L)
})

## S1005 (BACKLOG ruling S1004): an Excel file is read as text, so the reader
## must turn the numeric `kinship` column into numbers, as the CSV path does.
## `id1` and `id2` are ids and stay text.
test_that("readKinshipOverrides gives an Excel file the same table as the CSV of the same data", {
  df <- data.frame(id1 = c("F1", "F3"), id2 = c("F2", "F4"),
                   kinship = c(0.4, 0.1), stringsAsFactors = FALSE)
  xf <- writeTestXlsx(df, "ovr")
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(c(xf, csv)), add = TRUE)
  write.csv(df, csv, row.names = FALSE)

  res <- readKinshipOverrides(xf)

  expect_type(res$kinship, "double")
  expect_equal(res, readKinshipOverrides(csv))
})

test_that("an Excel kinship file passes checkKinshipOverrides", {
  df <- data.frame(id1 = c("F1", "F3"), id2 = c("F2", "F4"),
                   kinship = c(0.4, 0.1), stringsAsFactors = FALSE)
  xf <- writeTestXlsx(df, "ovr")
  on.exit(unlink(xf), add = TRUE)

  res <- checkKinshipOverrides(readKinshipOverrides(xf))

  expect_identical(nrow(res), 2L)
  expect_equal(res$kinship, c(0.4, 0.1))
})

test_that("readKinshipOverrides converts the Excel kinship column but keeps numeric-looking ids as text", {
  df <- data.frame(id1 = c("1001", "1002"), id2 = c("1003", "1004"),
                   kinship = c(0.4, 0.1), stringsAsFactors = FALSE)
  xf <- writeTestXlsx(df, "ovr")
  on.exit(unlink(xf), add = TRUE)

  res <- readKinshipOverrides(xf)

  expect_equal(res$kinship, c(0.4, 0.1))
  expect_identical(res$id1, c("1001", "1002"))
  expect_identical(res$id2, c("1003", "1004"))
})

## Guard (passes before the fix): a cell that is not a number must not be
## blanked; the column stays text and the check names it, as for a CSV.
test_that("a cell that is not a number leaves the Excel kinship column as text, so the check names it", {
  df <- data.frame(id1 = c("F1", "F3"), id2 = c("F2", "F4"),
                   kinship = c("0.4", "abc"), stringsAsFactors = FALSE)
  xf <- writeTestXlsx(df, "ovr")
  on.exit(unlink(xf), add = TRUE)

  res <- readKinshipOverrides(xf)

  expect_identical(res$kinship, c("0.4", "abc"))
  expect_error(checkKinshipOverrides(res), "'kinship' column must be numeric")
})

test_that("a blank kinship cell reads as NA in an Excel file, so the check says so", {
  df <- data.frame(id1 = c("F1", "F3"), id2 = c("F2", "F4"),
                   kinship = c(0.4, NA), stringsAsFactors = FALSE)
  xf <- writeTestXlsx(df, "ovr")
  on.exit(unlink(xf), add = TRUE)

  res <- readKinshipOverrides(xf)

  expect_type(res$kinship, "double")
  expect_true(is.na(res$kinship[2L]))
  expect_error(checkKinshipOverrides(res), "must not contain NA")
})
