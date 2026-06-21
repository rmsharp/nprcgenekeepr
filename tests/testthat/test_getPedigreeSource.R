#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr

# Tests for the internal data-source adapter getPedigreeSource(), which
# formalizes the fetch boundary used by getLkDirectRelatives(): a pluggable
# pedigree source (labkey | dataframe) returning a normalized ped data.frame
# (id, sex, birth, death, exit, dam, sire), or NULL on a LabKey fetch failure.

normalizedPedFixture <- function() {
  data.frame(
    id    = c("S1", "D1", "X1", "O1", "O2", "GC1"),
    sex   = c("M", "F", "M", "F", "M", "M"),
    birth = c("2000-01-01", "2000-01-01", "2000-01-01",
              "2010-01-01", "2010-01-01", "2018-01-01"),
    death = c(NA, NA, NA, NA, NA, NA),
    exit  = c(NA, NA, NA, NA, NA, NA),
    dam   = c(NA, NA, NA, "D1", "D1", "O1"),
    sire  = c(NA, NA, NA, "S1", "S1", "X1"),
    stringsAsFactors = FALSE
  )
}

test_that("getPedigreeSource('dataframe') returns the supplied normalized ped", {
  ped <- normalizedPedFixture()
  expect_identical(getPedigreeSource(sourceType = "dataframe", ped = ped), ped)
})

test_that("getPedigreeSource('dataframe') errors on a missing or malformed ped", {
  expect_error(
    getPedigreeSource(sourceType = "dataframe", ped = NULL), "data.frame"
  )
  expect_error(
    getPedigreeSource(sourceType = "dataframe", ped = "not a data.frame"),
    "data.frame"
  )
  # present but missing the walk-critical id/sire/dam columns
  expect_error(
    getPedigreeSource(
      source = "dataframe",
      ped = data.frame(id = "A", stringsAsFactors = FALSE)
    ),
    "column"
  )
})

test_that("getPedigreeSource('labkey') renames fetched columns via mapPedColumns", {
  skip_if_not_installed("mockery")
  fakeSite <- list(
    baseUrl = "https://example.test", folderPath = "/X",
    schemaName = "study", queryName = "demographics",
    lkPedColumns = c("Id", "gender", "birth", "death",
                     "lastDayAtCenter", "Id/parents/dam", "Id/parents/sire"),
    mapPedColumns = c("id", "sex", "birth", "death", "exit", "dam", "sire")
  )
  raw <- data.frame(
    a = c("S1", "O1"), b = c("M", "F"), c = c("2000", "2010"),
    d = c(NA, NA), e = c(NA, NA), f = c(NA, "D1"), g = c(NA, "S1"),
    stringsAsFactors = FALSE
  )
  demoMock <- mockery::mock(raw)
  mockery::stub(getPedigreeSource, "getDemographics", demoMock)

  result <- getPedigreeSource(sourceType = "labkey", siteInfo = fakeSite)

  mockery::expect_called(demoMock, 1)
  expect_identical(names(result), fakeSite$mapPedColumns)
  expect_identical(result$id, c("S1", "O1"))
  expect_identical(result$dam, c(NA, "D1"))
})

test_that("getPedigreeSource('labkey') returns NULL when the fetch warns", {
  skip_if_not_installed("mockery")
  fakeSite <- list(lkPedColumns = c("Id", "gender"),
                   mapPedColumns = c("id", "sex"))
  mockery::stub(getPedigreeSource, "getDemographics",
                function(...) warning("simulated fetch warning"))
  expect_null(getPedigreeSource(sourceType = "labkey", siteInfo = fakeSite))
})

test_that("getPedigreeSource('labkey') returns NULL when the fetch errors", {
  skip_if_not_installed("mockery")
  fakeSite <- list(lkPedColumns = c("Id", "gender"),
                   mapPedColumns = c("id", "sex"))
  mockery::stub(getPedigreeSource, "getDemographics",
                function(...) stop("simulated fetch error"))
  expect_null(getPedigreeSource(sourceType = "labkey", siteInfo = fakeSite))
})

test_that("getPedigreeSource() rejects an unknown source", {
  expect_error(getPedigreeSource(sourceType = "bogus"), "should be one of")
})

test_that("getPedigreeSource('file') reads a CSV and returns the normalized ped", {
  ped <- normalizedPedFixture()
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)
  write.csv(ped, tmp, row.names = FALSE)
  result <- getPedigreeSource(sourceType = "file", fileName = tmp)
  expect_true(is.data.frame(result))
  expect_true(all(c("id", "sire", "dam") %in% names(result)))
  expect_identical(result$id, ped$id)
})

test_that("getPedigreeSource('file') errors when fileName is missing", {
  expect_error(getPedigreeSource(sourceType = "file"), "fileName")
  expect_error(getPedigreeSource(sourceType = "file", fileName = NULL), "fileName")
})

test_that("getPedigreeSource('file') errors when the file does not exist", {
  expect_error(
    getPedigreeSource(
      sourceType = "file",
      fileName = file.path(tempdir(), "no_such_pedigree_file.csv")
    ),
    "not found"
  )
})

test_that("getPedigreeSource('file') errors when the file lacks id/sire/dam", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)
  write.csv(data.frame(id = c("A", "B"), stringsAsFactors = FALSE), tmp,
            row.names = FALSE)
  expect_error(
    getPedigreeSource(sourceType = "file", fileName = tmp), "column"
  )
})

test_that("getPedigreeSource('file') delegates to getPedigree with fileName and sep", {
  skip_if_not_installed("mockery")
  ped <- normalizedPedFixture()
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)
  write.csv(ped, tmp, row.names = FALSE)  # must exist for the file.exists() guard
  pedMock <- mockery::mock(ped)
  mockery::stub(getPedigreeSource, "getPedigree", pedMock)

  result <- getPedigreeSource(sourceType = "file", fileName = tmp, sep = ";")

  mockery::expect_called(pedMock, 1)
  callArgs <- mockery::mock_args(pedMock)[[1]]
  expect_identical(callArgs[[1]], tmp)        # fileName threaded to getPedigree
  expect_identical(callArgs[["sep"]], ";")    # sep threaded to getPedigree
  expect_identical(result, ped)
})
