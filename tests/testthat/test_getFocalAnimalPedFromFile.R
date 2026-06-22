#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr

# Tests for getFocalAnimalPedFromFile(), the file-sourced sibling of
# getFocalAnimalPed(): it reads a list of focal animal IDs from a file (first
# column, like getFocalAnimalPed), then builds the focal animals' full connected
# pedigree component from a SEPARATE pedigree file via getFileDirectRelatives()
# -- so the focal-animal pipeline no longer requires a LabKey/EHR connection.
# Fully offline and deterministic. The underlying file source errors loudly, but
# this function is the app boundary, so it is FAIL-SOFT: instead of throwing, it
# returns a classed "nprcgenekeeprFileErr" object whose $message names WHY the
# read failed (unreadable focal-id list file, a missing / not-found / unreadable
# / wrong-column pedigree file, or no focal IDs present in the pedigree). The app
# surfaces that $message as the "File Read Error" detail. This is distinct from
# the LabKey path, which returns an nprcgenekeeprErr.

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

# --- Pedigree-file problems: a classed error naming WHY, not a bare NULL -------

test_that("getFocalAnimalPedFromFile reports a missing pedigree file argument", {
  focalFile <- writeFocalIdFile("O1")
  on.exit(unlink(focalFile), add = TRUE)

  res1 <- getFocalAnimalPedFromFile(focalFile)
  res2 <- getFocalAnimalPedFromFile(focalFile, pedigreeFileName = NULL)

  expect_s3_class(res1, "nprcgenekeeprFileErr")
  expect_match(res1$message, "pedigree file must be supplied", ignore.case = TRUE)
  expect_s3_class(res2, "nprcgenekeeprFileErr")
  expect_match(res2$message, "pedigree file must be supplied", ignore.case = TRUE)
})

test_that("getFocalAnimalPedFromFile reports a pedigree file that does not exist", {
  focalFile <- writeFocalIdFile("O1")
  on.exit(unlink(focalFile), add = TRUE)

  result <- getFocalAnimalPedFromFile(
    focalFile,
    file.path(tempdir(), "no_such_pedigree_file.csv")
  )

  expect_s3_class(result, "nprcgenekeeprFileErr")
  expect_match(result$message, "not found", ignore.case = TRUE)
})

test_that("getFocalAnimalPedFromFile reports a pedigree file lacking id/sire/dam", {
  focalFile <- writeFocalIdFile("A")
  badPed <- tempfile(fileext = ".csv")
  utils::write.csv(data.frame(id = c("A", "B"), stringsAsFactors = FALSE),
                   badPed, row.names = FALSE)
  on.exit(unlink(c(focalFile, badPed)), add = TRUE)

  result <- getFocalAnimalPedFromFile(focalFile, badPed)

  expect_s3_class(result, "nprcgenekeeprFileErr")
  expect_match(result$message, "id, sire, and dam", ignore.case = TRUE)
})

test_that("getFocalAnimalPedFromFile reports an unreadable pedigree file", {
  focalFile <- writeFocalIdFile("O1")
  # An .xlsx-named file holding plain CSV text is dispatched to the Excel reader
  # by extension but cannot be parsed as a workbook -- an unreadable file.
  badPed <- tempfile(fileext = ".xlsx")
  writeLines(c("id,sire,dam", "O1,NA,NA"), badPed)
  on.exit(unlink(c(focalFile, badPed)), add = TRUE)

  result <- getFocalAnimalPedFromFile(focalFile, badPed)

  expect_s3_class(result, "nprcgenekeeprFileErr")
  expect_match(result$message, "could not be read", ignore.case = TRUE)
})

# --- Focal-id list file problems: was an UNCAUGHT throw; now a classed error ---

test_that("getFocalAnimalPedFromFile reports an unreadable focal-id list file", {
  pedFile <- writePedFile()
  on.exit(unlink(pedFile), add = TRUE)
  missingFocal <- file.path(tempdir(), "no_such_focal_id_file.csv")

  result <- getFocalAnimalPedFromFile(missingFocal, pedFile)

  expect_s3_class(result, "nprcgenekeeprFileErr")
  expect_match(result$message, "focal animal ID list", ignore.case = TRUE)
})

test_that("getFocalAnimalPedFromFile reports an empty focal-id list file", {
  pedFile <- writePedFile()
  emptyFocal <- tempfile(fileext = ".csv")
  file.create(emptyFocal)
  on.exit(unlink(c(pedFile, emptyFocal)), add = TRUE)

  result <- getFocalAnimalPedFromFile(emptyFocal, pedFile)

  expect_s3_class(result, "nprcgenekeeprFileErr")
  expect_match(result$message, "focal animal ID list", ignore.case = TRUE)
})

# --- Empty result: focal IDs absent from the pedigree (was a silent 0-row) -----

test_that("getFocalAnimalPedFromFile reports when no focal IDs are in the pedigree", {
  focalFile <- writeFocalIdFile("ZZZ") # not present in the fixture pedigree
  pedFile <- writePedFile()
  on.exit(unlink(c(focalFile, pedFile)), add = TRUE)

  result <- getFocalAnimalPedFromFile(focalFile, pedFile)

  expect_s3_class(result, "nprcgenekeeprFileErr")
  expect_match(result$message, "None of the focal IDs", ignore.case = TRUE)
})

test_that("getFocalAnimalPedFromFile threads sep through to the pedigree file reader", {
  focalFile <- writeFocalIdFile("O1")
  pedFile <- writePedFile(sep = ";")
  on.exit(unlink(c(focalFile, pedFile)), add = TRUE)

  result <- getFocalAnimalPedFromFile(focalFile, pedFile, sep = ";")

  expect_setequal(result$id, c("S1", "D1", "X1", "O1", "O2", "GC1"))
})

# --- Console hygiene: a missing focal-id file errors silently --------------
# read.csv() on a missing/unreadable file signals a "cannot open file ..."
# WARNING before it errors. The error is caught and turned into a classed
# nprcgenekeeprFileErr, but the benign warning otherwise leaks to the console.
# The function should fail soft AND silently: no leaked warning, same classed
# error, error still propagates from the underlying read (control preserved).

test_that(
  "getFocalAnimalPedFromFile emits no warning for a missing focal-id file", {
  pedFile <- writePedFile()
  on.exit(unlink(pedFile), add = TRUE)
  missingFocal <- file.path(tempdir(), "no_such_focal_id_file.csv")

  expect_no_warning(
    result <- getFocalAnimalPedFromFile(missingFocal, pedFile)
  )
  # Behaviour is unchanged apart from the silenced warning.
  expect_s3_class(result, "nprcgenekeeprFileErr")
  expect_match(result$message, "focal animal ID list", ignore.case = TRUE)
})

test_that(
  "readFocalAnimalIds still errors but emits no warning on a missing file", {
  missingFocal <- file.path(tempdir(), "no_such_focal_id_file.csv")

  warned <- FALSE
  threw <- FALSE
  withCallingHandlers(
    tryCatch(
      readFocalAnimalIds(missingFocal),
      error = function(e) threw <<- TRUE
    ),
    warning = function(w) {
      warned <<- TRUE
      invokeRestart("muffleWarning")
    }
  )

  expect_true(threw) # the read error still propagates (control flow preserved)
  expect_false(warned) # but the "cannot open file" warning is muffled
})
