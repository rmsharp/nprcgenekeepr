#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr

# Tests for getFileDirectRelatives(), the file-sourced sibling of
# getLkDirectRelatives(): it reads a pedigree file through the internal
# getPedigreeSource() "file" provider (via getPedigree()), then delegates the
# pedigree walk to the source-agnostic getPedDirectRelatives(), returning the
# full connected pedigree component for the focal animals. Fully offline and
# deterministic. Unlike the LabKey source (fail-soft NULL), the file source
# errors loudly on bad input -- these tests pin that contract.

connectedPedFixture <- function() {
  # Founders S1, D1, X1; O1 & O2 are full sibs of S1 x D1; GC1 is the
  # offspring of O1 x X1. Focal O1's full connected component is the entire
  # family, including the collateral sibling O2.
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

test_that(
  "getFileDirectRelatives reads a pedigree file and returns the full connected component",
  {
    ped <- connectedPedFixture()
    tmp <- tempfile(fileext = ".csv")
    on.exit(unlink(tmp), add = TRUE)
    write.csv(ped, tmp, row.names = FALSE)

    result <- getFileDirectRelatives(ids = "O1", fileName = tmp)

    # Full connected component for O1 = the entire fixture, including sib O2.
    expect_setequal(result$id, c("S1", "D1", "X1", "O1", "O2", "GC1"))
    expect_true("O2" %in% result$id)
  }
)

test_that(
  "getFileDirectRelatives matches getPedDirectRelatives on the same pedigree",
  {
    ped <- connectedPedFixture()
    tmp <- tempfile(fileext = ".csv")
    on.exit(unlink(tmp), add = TRUE)
    write.csv(ped, tmp, row.names = FALSE)

    expect_setequal(
      getFileDirectRelatives(ids = "O1", fileName = tmp)$id,
      getPedDirectRelatives(ids = "O1", ped = getPedigree(tmp))$id
    )
  }
)

test_that(
  "getFileDirectRelatives delegates to getPedigreeSource('file') then getPedDirectRelatives",
  {
    skip_if_not_installed("mockery")
    ped <- connectedPedFixture()
    srcMock <- mockery::mock(ped)
    relMock <- mockery::mock("walked")
    mockery::stub(getFileDirectRelatives, "getPedigreeSource", srcMock)
    mockery::stub(getFileDirectRelatives, "getPedDirectRelatives", relMock)

    result <- getFileDirectRelatives(
      ids = "O1", fileName = "peds.csv", sep = ";", unrelatedParents = TRUE
    )

    mockery::expect_called(srcMock, 1)
    srcArgs <- mockery::mock_args(srcMock)[[1]]
    expect_identical(srcArgs[["sourceType"]], "file")
    expect_identical(srcArgs[["fileName"]], "peds.csv")
    expect_identical(srcArgs[["sep"]], ";")

    mockery::expect_called(relMock, 1)
    relArgs <- mockery::mock_args(relMock)[[1]]
    expect_identical(relArgs[["ids"]], "O1")
    expect_identical(relArgs[["ped"]], ped)
    expect_true(relArgs[["unrelatedParents"]])
    expect_identical(result, "walked")
  }
)

test_that("getFileDirectRelatives errors when fileName is missing", {
  expect_error(getFileDirectRelatives(ids = "O1"), "fileName")
  expect_error(getFileDirectRelatives(ids = "O1", fileName = NULL), "fileName")
})

test_that("getFileDirectRelatives errors when the file does not exist", {
  expect_error(
    getFileDirectRelatives(
      ids = "O1",
      fileName = file.path(tempdir(), "no_such_pedigree_file.csv")
    ),
    "not found"
  )
})

test_that("getFileDirectRelatives errors when the file lacks id/sire/dam", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)
  write.csv(data.frame(id = c("A", "B"), stringsAsFactors = FALSE), tmp,
            row.names = FALSE)
  expect_error(getFileDirectRelatives(ids = "A", fileName = tmp), "column")
})

test_that("getFileDirectRelatives threads sep through to the file reader", {
  ped <- connectedPedFixture()
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)
  write.table(ped, tmp, row.names = FALSE, sep = ";", quote = TRUE)

  result <- getFileDirectRelatives(ids = "O1", fileName = tmp, sep = ";")

  expect_setequal(result$id, c("S1", "D1", "X1", "O1", "O2", "GC1"))
})
