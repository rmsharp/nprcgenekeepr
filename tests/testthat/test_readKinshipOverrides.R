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
