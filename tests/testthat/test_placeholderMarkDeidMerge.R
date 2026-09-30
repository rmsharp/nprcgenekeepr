## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# De-identification and the cross-center merge keep the placeholder mark
# (placeholder-marking plan Slice 5, S811). A center can mark a real animal
# whose id looks like a made-up stand-in (U1234) as FALSE in the `placeholder`
# column that qcStudbook() writes. Two places still guessed from the id's shape:
#
#  * obfuscateId() gave a real U1234 a random alias, and the id-shape rule read
#    that alias as a stand-in, so the de-identified pedigree (whose marks
#    survive in the column) and a reader without the column disagreed. It now
#    takes an optional `placeholder` vector: a stand-in gets a stand-in-shaped
#    alias, a real animal a real-shaped one, and NA or NULL is read by the id's
#    shape as before. obfuscatePed() passes the column.
#  * resolveCrossCenterIds() NA-filled the mark of a linked animal when only one
#    center's file carried the column, so qcStudbook() then guessed by shape and
#    turned a real U1234 back into a stand-in; and when the two centers
#    disagreed (one real, one stand-in) it stopped with a "conflicting
#    placeholder values" error that checkCrossCenterMapping() never reports.
#    Owner, S811: a real record wins over a stand-in, a mark on one side is
#    kept, two stand-ins stay a stand-in, and the merge no longer errors.
library(testthat)

## True when the id-shape rule alone reads the id as a stand-in.
looksLikeStandIn <- function(id) nprcgenekeepr:::isGeneratedUnknownId(id)

## -- obfuscateId(placeholder =) ---------------------------------------------

test_that("obfuscateId gives a real U1234 marked FALSE an alias the id-shape rule reads as real", {
  set.seed(811L)
  for (rep in seq_len(20L)) {
    alias <- obfuscateId(c("U1234", "U0001"), size = 6L,
                         placeholder = c(FALSE, TRUE))
    expect_false(looksLikeStandIn(alias[["U1234"]]))
    expect_true(looksLikeStandIn(alias[["U0001"]]))
  }
})

test_that("obfuscateId gives a stand-in whose id does not look like one a stand-in-shaped alias", {
  set.seed(811L)
  for (rep in seq_len(20L)) {
    alias <- obfuscateId(c("Xq9", "Xq10"), size = 6L,
                         placeholder = c(TRUE, FALSE))
    expect_true(looksLikeStandIn(alias[["Xq9"]]))
    expect_false(looksLikeStandIn(alias[["Xq10"]]))
  }
})

test_that("obfuscateId reads an NA mark by the id's shape", {
  set.seed(811L)
  alias <- obfuscateId(c("U0002", "Xq9", "U1234"), size = 6L,
                       placeholder = c(NA, NA, NA))
  expect_true(looksLikeStandIn(alias[["U0002"]]))
  expect_false(looksLikeStandIn(alias[["Xq9"]]))
  ## U1234 has the full stand-in shape, so an NA mark reads it as one
  expect_true(looksLikeStandIn(alias[["U1234"]]))
})

test_that("obfuscateId without a mark still reads every id by its shape (guard)", {
  set.seed(811L)
  ids <- c("U0001", "U1", "Xq9", "U1234")
  alias <- obfuscateId(ids, size = 6L)
  expect_identical(unname(looksLikeStandIn(alias)),
                   unname(looksLikeStandIn(ids)))
  expect_identical(names(alias), ids)
})

test_that("obfuscateId lengthens only stand-in aliases when a marked id needs it (guard for D10)", {
  set.seed(811L)
  alias <- obfuscateId(c("Xq9", "Xq10"), size = 4L,
                       placeholder = c(TRUE, FALSE))
  expect_gte(nchar(alias[["Xq9"]]), 5L)
  expect_identical(nchar(alias[["Xq10"]]), 4L)
})

test_that("obfuscateId stops when the mark is not one value per id", {
  expect_error(
    obfuscateId(c("A1", "A2", "A3"), size = 6L, placeholder = c(TRUE, FALSE)),
    "placeholder must have one value per id"
  )
})

test_that("obfuscateId stops when the mark is not logical", {
  expect_error(
    obfuscateId(c("A1", "A2"), size = 6L, placeholder = c("yes", "no")),
    "placeholder must be logical"
  )
})

## -- obfuscatePed() keeps the mark ------------------------------------------

makeMarkedPed <- function() {
  raw <- data.frame(
    id = c("U1234", "U0001", "D1", "K1", "K2"),
    sire = c(NA, NA, NA, "U1234", "U0001"),
    dam = c(NA, NA, NA, "D1", "D1"),
    sex = c("M", "M", "F", "F", "M"),
    birth = c("2000-01-01", "2000-01-01", "2000-01-01", "2010-01-01",
              "2011-01-01"),
    placeholder = c(FALSE, TRUE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  qcStudbook(raw, reportErrors = FALSE)
}

test_that("obfuscatePed keeps the placeholder column and gives each row an alias of its own kind", {
  ped <- makeMarkedPed()
  set.seed(811L)
  for (rep in seq_len(10L)) {
    obf <- obfuscatePed(ped, size = 6L, maxDelta = 30L, map = TRUE)
    out <- obf$ped
    expect_true("placeholder" %in% names(out))
    expect_identical(out$placeholder, ped$placeholder)
    ## the shape rule (what a reader without the column would use) agrees with
    ## the mark on every row: the real U1234 is not read as a stand-in
    expect_identical(unname(looksLikeStandIn(out$id)), out$placeholder)
    expect_false(looksLikeStandIn(obf$map[["U1234"]]))
    expect_true(looksLikeStandIn(obf$map[["U0001"]]))
  }
})

test_that("obfuscatePed of a pedigree with no placeholder column still aliases by shape (guard)", {
  ped <- makeMarkedPed()
  ped$placeholder <- NULL
  set.seed(811L)
  obf <- obfuscatePed(ped, size = 6L, maxDelta = 30L, map = TRUE)
  expect_false("placeholder" %in% names(obf$ped))
  expect_true(looksLikeStandIn(obf$map[["U0001"]]))
})

test_that("a de-identified export read back through qcStudbook keeps every mark", {
  ped <- makeMarkedPed()
  exported <- NULL
  set.seed(811L)
  shiny::testServer(modDeidentifiedExportServer,
                    args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
    session$setInputs(preview = 1)
    exported <<- session$getReturned()$exportedPedigree()
  })
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  utils::write.csv(exported, csv, row.names = FALSE, na = "")
  back <- qcStudbook(utils::read.csv(csv, stringsAsFactors = FALSE,
                                  na.strings = c("", "NA")),
                     reportErrors = FALSE)
  expect_identical(back$placeholder[match(exported$id, back$id)],
                   ped$placeholder)
  expect_identical(sum(back$placeholder), 1L)
})

## -- resolveCrossCenterIds() keeps and merges the mark ----------------------

makeCenters <- function(markA = FALSE, markB = NULL) {
  pedA <- data.frame(
    id = c("P1", "P2", "U1234"), sire = c(NA, NA, "P1"),
    dam = c(NA, NA, "P2"), stringsAsFactors = FALSE
  )
  if (!is.null(markA)) pedA$placeholder <- c(FALSE, FALSE, markA)
  pedB <- data.frame(
    id = c("X9", "O1"), sire = c(NA, "X9"), dam = c(NA, NA),
    stringsAsFactors = FALSE
  )
  if (!is.null(markB)) pedB$placeholder <- c(markB, FALSE)
  list(pedA = pedA, pedB = pedB,
       mapping = data.frame(idA = "U1234", idB = "X9",
                            stringsAsFactors = FALSE))
}

mergedMark <- function(x, id = "U1234") {
  merged <- resolveCrossCenterIds(x$pedA, x$pedB, x$mapping)
  merged$placeholder[merged$id == id]
}

test_that("a linked animal keeps its mark when only the first center's file has the column", {
  x <- makeCenters(markA = FALSE, markB = NULL)
  expect_identical(mergedMark(x), FALSE)
})

test_that("a linked animal keeps its mark when only the second center's file has the column", {
  x <- makeCenters(markA = NULL, markB = FALSE)
  expect_identical(mergedMark(x), FALSE)
  x <- makeCenters(markA = NULL, markB = TRUE)
  expect_identical(mergedMark(x), TRUE)
})

test_that("a real record wins over a stand-in when the two centers disagree, with no error", {
  x <- makeCenters(markA = FALSE, markB = TRUE)
  expect_no_error(resolveCrossCenterIds(x$pedA, x$pedB, x$mapping))
  expect_identical(mergedMark(x), FALSE)
  x <- makeCenters(markA = TRUE, markB = FALSE)
  expect_identical(mergedMark(x), FALSE)
})

test_that("two stand-ins stay a stand-in and two real records stay real (guard)", {
  expect_identical(mergedMark(makeCenters(markA = TRUE, markB = TRUE)), TRUE)
  expect_identical(mergedMark(makeCenters(markA = FALSE, markB = FALSE)),
                   FALSE)
})

test_that("a blank mark on one side does not hide the other side's mark", {
  expect_identical(mergedMark(makeCenters(markA = NA, markB = FALSE)), FALSE)
  expect_identical(mergedMark(makeCenters(markA = TRUE, markB = NA)), TRUE)
  expect_true(is.na(mergedMark(makeCenters(markA = NA, markB = NA))))
})

test_that("animals not named in the mapping keep their own marks through the merge (guard)", {
  x <- makeCenters(markA = FALSE, markB = FALSE)
  merged <- resolveCrossCenterIds(x$pedA, x$pedB, x$mapping)
  expect_identical(merged$placeholder[merged$id == "P1"], FALSE)
  ## O1 is B's own row, marked FALSE
  expect_identical(merged$placeholder[merged$id == "O1"], FALSE)
})

test_that("merging a marked file with an unmarked one, then QC, leaves a real U1234 real and marks both sides", {
  x <- makeCenters(markA = FALSE, markB = NULL)
  merged <- resolveCrossCenterIds(x$pedA, x$pedB, x$mapping)
  merged$sex <- "M"
  merged$sex[merged$id %in% c("P2")] <- "F"
  merged$birth <- "2000-01-01"
  merged$birth[merged$id %in% c("U1234")] <- "2005-01-01"
  merged$birth[merged$id %in% c("O1")] <- "2010-01-01"
  qc <- qcStudbook(merged, reportErrors = FALSE)
  expect_false(anyNA(qc$placeholder))
  expect_identical(qc$placeholder[qc$id == "U1234"], FALSE)
  expect_false(qc$placeholder[qc$id == "O1"])
})

test_that("checkCrossCenterMapping still reports only sire and dam conflicts, not a mark disagreement (guard)", {
  x <- makeCenters(markA = FALSE, markB = TRUE)
  problems <- checkCrossCenterMapping(x$pedA, x$pedB, x$mapping)
  expect_false(any(problems$type == "conflict"))
  expect_identical(nrow(problems), 0L)
})
