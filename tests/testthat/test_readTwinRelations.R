# Tests for readTwinRelations() -- issue #137 Slice 3 file reader.
# Mirrors readKinshipOverrides(): reads a user-uploaded id1,id2,code twin
# -relations sidecar table from a CSV/Excel file into a data.frame to feed
# checkTwinRelations() (structure/domain validation stays the caller's job,
# same division of labor as readKinshipOverrides()/checkKinshipOverrides()).

test_that("readTwinRelations reads an id1,id2,code CSV into a data.frame", {
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("id1,id2,code",
               "S1,S2,MZ twin",
               "S3,S4,DZ twin"), csv)

  res <- readTwinRelations(csv)

  expect_true(is.data.frame(res))
  expect_true(all(c("id1", "id2", "code") %in% names(res)))
  expect_identical(nrow(res), 2L)
  expect_identical(as.character(res$id1), c("S1", "S3"))
  expect_identical(as.character(res$id2), c("S2", "S4"))
  expect_identical(as.character(res$code), c("MZ twin", "DZ twin"))
})

test_that("readTwinRelations output validates with checkTwinRelations", {
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("id1,id2,code", "S1,S2,UZ twin"), csv)

  ped <- data.frame(
    id = c("F1", "F2", "S1", "S2"),
    sire = c(NA, NA, "F1", "F1"),
    dam = c(NA, NA, "F2", "F2"),
    sex = c("M", "F", "F", "M"),
    stringsAsFactors = FALSE
  )

  res <- checkTwinRelations(ped, readTwinRelations(csv))
  expect_identical(nrow(res), 1L)
  expect_type(res$id1, "character")
})

## Excel (.xls/.xlsx) branch, mirroring test_readKinshipOverrides.R's own
## coverage-backfill test for the same underlying dispatch.
test_that("readTwinRelations reads an id1,id2,code Excel file", {
  skip_if_not_installed("openxlsx")
  xf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(xf), add = TRUE)
  df <- data.frame(id1 = c("S1", "S3"), id2 = c("S2", "S4"),
                   code = c("MZ twin", "DZ twin"), stringsAsFactors = FALSE)
  status <- create_wkbk(file = xf, df_list = list(df),
                        sheetnames = "twins", replace = TRUE)
  skip_if_not(isTRUE(status))
  res <- readTwinRelations(xf)
  expect_true(is.data.frame(res))
  expect_true(all(c("id1", "id2", "code") %in% names(res)))
  expect_identical(nrow(res), 2L)
})
