#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr

# Tests for getFocalAnimalPedFromFile(), the file-sourced sibling of
# getFocalAnimalPed(): it reads a list of focal animal IDs from a file (first
# column, like getFocalAnimalPed), then builds the focal animals' full connected
# pedigree component from a SEPARATE pedigree file via getFileDirectRelatives()
# -- so the focal-animal pipeline no longer requires a LabKey/EHR connection.
# Fully offline and deterministic. The underlying file source errors loudly, but
# this function is the app boundary, so it is FAIL-SOFT: it returns NULL on any
# pedigree-file problem (mirroring the app's other file inputs, which surface a
# "File Read Error"), distinct from the LabKey path's nprcgenekeeprErr.

focalFileTestPed <- function() {
  # Founders S1, D1, X1; O1 & O2 are full sibs of S1 x D1; GC1 is the offspring
  # of O1 x X1. Focal O1's full connected component is the entire family,
  # including the collateral sibling O2.
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

writeFocalIdFile <- function(ids) {
  tmp <- tempfile(fileext = ".csv")
  utils::write.csv(data.frame(id = ids, stringsAsFactors = FALSE), tmp,
                   row.names = FALSE)
  tmp
}

writePedFile <- function(ped = focalFileTestPed(), sep = ",") {
  tmp <- tempfile(fileext = ".csv")
  utils::write.table(ped, tmp, row.names = FALSE, sep = sep, quote = TRUE)
  tmp
}

test_that(
  "getFocalAnimalPedFromFile reads focal IDs and returns the connected component",
  {
    focalFile <- writeFocalIdFile("O1")
    pedFile <- writePedFile()
    on.exit(unlink(c(focalFile, pedFile)), add = TRUE)

    result <- getFocalAnimalPedFromFile(focalFile, pedFile)

    expect_s3_class(result, "data.frame")
    # Full connected component for O1 = the entire fixture, including sib O2.
    expect_setequal(result$id, c("S1", "D1", "X1", "O1", "O2", "GC1"))
    expect_true("O2" %in% result$id)
    expect_true(all(c("id", "sire", "dam") %in% names(result)))
  }
)

test_that(
  "getFocalAnimalPedFromFile matches getFileDirectRelatives on the same inputs",
  {
    focalFile <- writeFocalIdFile(c("O1", "O2"))
    pedFile <- writePedFile()
    on.exit(unlink(c(focalFile, pedFile)), add = TRUE)

    expect_identical(
      getFocalAnimalPedFromFile(focalFile, pedFile),
      getFileDirectRelatives(ids = c("O1", "O2"), fileName = pedFile)
    )
  }
)

test_that(
  "getFocalAnimalPedFromFile delegates to getFileDirectRelatives with ids/fileName/sep",
  {
    skip_if_not_installed("mockery")
    focalFile <- writeFocalIdFile(c("O1", "O2"))
    on.exit(unlink(focalFile), add = TRUE)

    relMock <- mockery::mock("walked")
    mockery::stub(getFocalAnimalPedFromFile, "getFileDirectRelatives", relMock)

    result <- getFocalAnimalPedFromFile(focalFile, "peds.csv", sep = ";")

    mockery::expect_called(relMock, 1)
    relArgs <- mockery::mock_args(relMock)[[1]]
    expect_identical(relArgs[["ids"]], c("O1", "O2"))
    expect_identical(relArgs[["fileName"]], "peds.csv")
    expect_identical(relArgs[["sep"]], ";")
    expect_identical(result, "walked")
  }
)

test_that("getFocalAnimalPedFromFile returns NULL when pedigreeFileName is missing", {
  focalFile <- writeFocalIdFile("O1")
  on.exit(unlink(focalFile), add = TRUE)

  expect_null(getFocalAnimalPedFromFile(focalFile))
  expect_null(getFocalAnimalPedFromFile(focalFile, pedigreeFileName = NULL))
})

test_that("getFocalAnimalPedFromFile returns NULL when the pedigree file does not exist", {
  focalFile <- writeFocalIdFile("O1")
  on.exit(unlink(focalFile), add = TRUE)

  expect_null(
    getFocalAnimalPedFromFile(
      focalFile,
      file.path(tempdir(), "no_such_pedigree_file.csv")
    )
  )
})

test_that("getFocalAnimalPedFromFile returns NULL when the pedigree file lacks id/sire/dam", {
  focalFile <- writeFocalIdFile("A")
  badPed <- tempfile(fileext = ".csv")
  utils::write.csv(data.frame(id = c("A", "B"), stringsAsFactors = FALSE),
                   badPed, row.names = FALSE)
  on.exit(unlink(c(focalFile, badPed)), add = TRUE)

  expect_null(getFocalAnimalPedFromFile(focalFile, badPed))
})

test_that("getFocalAnimalPedFromFile threads sep through to the pedigree file reader", {
  focalFile <- writeFocalIdFile("O1")
  pedFile <- writePedFile(sep = ";")
  on.exit(unlink(c(focalFile, pedFile)), add = TRUE)

  result <- getFocalAnimalPedFromFile(focalFile, pedFile, sep = ";")

  expect_setequal(result$id, c("S1", "D1", "X1", "O1", "O2", "GC1"))
})
