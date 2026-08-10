## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #149 Slice 2): the full modCrossCenterIdentity Shiny module --
## 3 file uploads (Center A pedigree, Center B pedigree, mapping), validated
## via checkCrossCenterMapping() (Slice 1), a lineage-change preview once
## clean (D6), a shiny::modalDialog() confirmation gate (D7), and 5
## downloadable export artifacts (D8), per
## docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md
## section 5 Slice 2.
##
## D3/D4/D9: the module is fully self-contained (its own 3 fileInputs, no
## shared$... dependency), so modCrossCenterIdentityServer(id) takes no
## named data args -- matching modInputServer's own args = list() precedent
## in test_moduleContract.R.

testthat::skip_on_cran()

## -- Shared fixtures --------------------------------------------------------
## Same P1/P2/T1/S1 (Center A) / X9/Q1/O1 (Center B) shape as
## test_checkCrossCenterMapping.R / test_resolveCrossCenterIds.R, extended
## with a `sex` column so the Slice 1 D10 merge-column-preservation fix is
## end-to-end verifiable through this UI/export layer too: T1 (Center A) and
## X9 (Center B) are the SAME physical animal, both recording sex "M". T1's
## real parents (P1/P2) are only known to Center A; Center B's own X9 record
## is an artificial founder (sire/dam both NA) -- exactly the failure mode
## this whole feature exists to fix, and why the merged sire/dam below
## resolve to source "A", not "both".

.ccPedA <- data.frame(
  id   = c("P1", "P2", "T1", "S1"),
  sire = c(NA_character_, NA_character_, "P1", "P1"),
  dam  = c(NA_character_, NA_character_, "P2", "P2"),
  sex  = c("M", "F", "M", "F"),
  stringsAsFactors = FALSE
)

.ccPedB <- data.frame(
  id   = c("X9", "Q1", "O1"),
  sire = c(NA_character_, NA_character_, "X9"),
  dam  = c(NA_character_, NA_character_, "Q1"),
  sex  = c("M", "F", "M"),
  stringsAsFactors = FALSE
)

.ccMapping <- data.frame(idA = "T1", idB = "X9", stringsAsFactors = FALSE)

.writeCcCsv <- function(df) {
  path <- tempfile(fileext = ".csv")
  write.csv(df, path, row.names = FALSE)
  path
}

.ccUploadInputs <- function(pedA = .ccPedA, pedB = .ccPedB,
                             mapping = .ccMapping) {
  list(
    pedAFile = list(name = "pedA.csv", datapath = .writeCcCsv(pedA)),
    pedBFile = list(name = "pedB.csv", datapath = .writeCcCsv(pedB)),
    mappingFile = list(name = "mapping.csv", datapath = .writeCcCsv(mapping))
  )
}

## -- UI shape ----------------------------------------------------------

test_that("modCrossCenterIdentityUI returns a shiny.tag object", {
  ui <- modCrossCenterIdentityUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modCrossCenterIdentityUI has the 3 file inputs and the Validate button", {
  ui_html <- as.character(modCrossCenterIdentityUI("test"))

  expect_true(grepl("pedAFile", ui_html))
  expect_true(grepl("pedBFile", ui_html))
  expect_true(grepl("mappingFile", ui_html))
  expect_true(grepl("validate", ui_html))
  expect_true(grepl("Validate Mapping", ui_html))
})

test_that("modCrossCenterIdentityUI has Validation/Preview/Export tabs", {
  ui_html <- as.character(modCrossCenterIdentityUI("test"))

  expect_true(grepl("Validation", ui_html))
  expect_true(grepl("Preview", ui_html))
  expect_true(grepl("Export", ui_html))
})

test_that("modCrossCenterIdentityUI has a Confirm Merge action button", {
  ui_html <- as.character(modCrossCenterIdentityUI("test"))

  expect_true(grepl("confirmMerge", ui_html))
  expect_true(grepl("Confirm Merge", ui_html))
})

test_that("modCrossCenterIdentityUI has all 5 export download buttons", {
  ui_html <- as.character(modCrossCenterIdentityUI("test"))

  expect_true(grepl("downloadMergedPedigree", ui_html))
  expect_true(grepl("downloadMapping", ui_html))
  expect_true(grepl("downloadValidationResults", ui_html))
  expect_true(grepl("downloadMergeSummary", ui_html))
  expect_true(grepl("downloadProvenance", ui_html))
})

## -- Server: validation (D2/D5) -----------------------------------------

test_that("modCrossCenterIdentityServer reports zero issues for a clean mapping", {
  skip_if_not_installed("shiny")

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs())
    session$setInputs(validate = 1)

    result <- session$getReturned()
    expect_equal(nrow(result$issues()), 0L)
  })
})

test_that("modCrossCenterIdentityServer collects every issue for a dirty mapping without stopping", {
  skip_if_not_installed("shiny")

  ## idB "X9" duplicated (uniqueness) AND idA "NOPE" absent from pedA$id
  ## (existence) -- both tier-A problem types at once (matches
  ## test_checkCrossCenterMapping.R's own multi-issue fixture, Dragon #8's
  ## "not just the happy path" requirement).
  badMapping <- data.frame(
    idA = c("T1", "NOPE"), idB = c("X9", "X9"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs(mapping = badMapping))
    session$setInputs(validate = 1)

    result <- session$getReturned()
    problems <- result$issues()
    expect_true(nrow(problems) > 0L)
    expect_true(any(problems$type == "uniqueness"))
    expect_true(any(problems$type == "existence"))
  })
})

test_that("modCrossCenterIdentityServer catches a structural upload error without crashing the app", {
  skip_if_not_installed("shiny")

  badPedA <- .ccPedA[, c("id", "sire")] # missing dam -- a structural problem

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs(pedA = badPedA))
    session$setInputs(validate = 1)

    result <- session$getReturned()
    problems <- result$issues()
    expect_equal(nrow(problems), 1L)
    expect_equal(problems$type, "structural")
    expect_true(grepl("dam", problems$message))
  })
})

test_that("modCrossCenterIdentityServer computes the merged pedigree once clean, carrying D10's sex column through", {
  skip_if_not_installed("shiny")

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs())
    session$setInputs(validate = 1)

    result <- session$getReturned()
    merged <- result$mergedPedigree()
    expect_false("X9" %in% merged$id)
    expect_true("T1" %in% merged$id)
    expect_equal(merged$sex[merged$id == "T1"], "M")
  })
})

## -- Server: confirm gate (D7) -------------------------------------------

test_that("modCrossCenterIdentityServer's confirmed reactive starts FALSE and only flips TRUE after the modal confirm click", {
  skip_if_not_installed("shiny")

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs())
    session$setInputs(validate = 1)

    result <- session$getReturned()
    expect_false(result$confirmed())

    session$setInputs(confirmMerge = 1)
    session$setInputs(confirmMergeOk = 1)
    expect_true(result$confirmed())
  })
})

test_that("modCrossCenterIdentityServer's confirm click is a no-op while issues remain", {
  skip_if_not_installed("shiny")

  badMapping <- data.frame(
    idA = c("T1", "NOPE"), idB = c("X9", "X9"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs(mapping = badMapping))
    session$setInputs(validate = 1)
    session$setInputs(confirmMerge = 1)
    session$setInputs(confirmMergeOk = 1)

    result <- session$getReturned()
    expect_false(result$confirmed())
  })
})

test_that("modCrossCenterIdentityServer resets confirmed to FALSE when the mapping is re-validated", {
  skip_if_not_installed("shiny")

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs())
    session$setInputs(validate = 1)
    session$setInputs(confirmMerge = 1)
    session$setInputs(confirmMergeOk = 1)

    result <- session$getReturned()
    expect_true(result$confirmed())

    do.call(session$setInputs, .ccUploadInputs())
    session$setInputs(validate = 2)
    expect_false(result$confirmed())
  })
})

## -- Server: exports (D8) -------------------------------------------------

test_that("modCrossCenterIdentityServer's Merged Pedigree/Mapping/Validation Results downloads write the expected artifacts once confirmed", {
  skip_if_not_installed("shiny")

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs())
    session$setInputs(validate = 1)
    session$setInputs(confirmMerge = 1)
    session$setInputs(confirmMergeOk = 1)

    mergedPath <- output$downloadMergedPedigree
    merged <- utils::read.csv(mergedPath, stringsAsFactors = FALSE)
    expect_false("X9" %in% merged$id)
    expect_equal(merged$sex[merged$id == "T1"], "M")

    mappingPath <- output$downloadMapping
    mappingOut <- utils::read.csv(mappingPath, stringsAsFactors = FALSE)
    expect_equal(mappingOut$idA, "T1")
    expect_equal(mappingOut$idB, "X9")

    validationPath <- output$downloadValidationResults
    validationOut <- utils::read.csv(validationPath, stringsAsFactors = FALSE)
    expect_equal(nrow(validationOut), 0L)
  })
})

test_that("modCrossCenterIdentityServer's Merge Summary download is the lineage-change table with resolved values/sources", {
  skip_if_not_installed("shiny")

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs())
    session$setInputs(validate = 1)
    session$setInputs(confirmMerge = 1)
    session$setInputs(confirmMergeOk = 1)

    summaryPath <- output$downloadMergeSummary
    summaryOut <- utils::read.csv(summaryPath, stringsAsFactors = FALSE)
    expect_equal(summaryOut$idA, "T1")
    expect_equal(summaryOut$idB, "X9")
    ## T1's real parents are only recorded at Center A; X9's own Center-B
    ## record is an artificial founder (NA sire/dam) -- so both resolved
    ## sire and dam must come from source "A", not "both".
    expect_equal(summaryOut$sireSource, "A")
    expect_equal(summaryOut$damSource, "A")
    expect_equal(summaryOut$resolved_sire, "P1")
    expect_equal(summaryOut$resolved_dam, "P2")
  })
})

test_that("modCrossCenterIdentityServer's Provenance download carries timestamp/filenames/version/counts/per-individual source", {
  skip_if_not_installed("shiny")

  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    do.call(session$setInputs, .ccUploadInputs())
    session$setInputs(validate = 1)
    session$setInputs(confirmMerge = 1)
    session$setInputs(confirmMergeOk = 1)

    provPath <- output$downloadProvenance
    prov <- utils::read.csv(provPath, stringsAsFactors = FALSE)

    expect_true("timestamp" %in% names(prov))
    expect_equal(prov$pedAFileName[1], "pedA.csv")
    expect_equal(prov$pedBFileName[1], "pedB.csv")
    expect_equal(prov$mappingFileName[1], "mapping.csv")
    expect_equal(prov$packageVersion[1], getVersion(date = FALSE))
    expect_equal(prov$nPedA[1], 4L)
    expect_equal(prov$nPedB[1], 3L)
    expect_equal(prov$nMapped[1], 1L)
    expect_equal(prov$idA, "T1")
    expect_equal(prov$sireSource, "A")
    expect_equal(prov$damSource, "A")
  })
})

## -- Internal helpers -----------------------------------------------------

test_that(".buildCrossCenterLineagePreview builds one row per mapped pair with resolved values and sources", {
  preview <- .buildCrossCenterLineagePreview(.ccPedA, .ccPedB, .ccMapping)

  expect_equal(nrow(preview), 1L)
  expect_equal(preview$idA, "T1")
  expect_equal(preview$idB, "X9")
  expect_equal(preview$pedA_sire, "P1")
  expect_equal(preview$pedA_dam, "P2")
  expect_true(is.na(preview$pedB_sire))
  expect_true(is.na(preview$pedB_dam))
  expect_equal(preview$resolved_sire, "P1")
  expect_equal(preview$resolved_dam, "P2")
  expect_equal(preview$sireSource, "A")
  expect_equal(preview$damSource, "A")
})

test_that(".buildCrossCenterMergeProvenance builds a provenance data.frame with the documented fields", {
  merged <- resolveCrossCenterIds(.ccPedA, .ccPedB, .ccMapping)
  preview <- .buildCrossCenterLineagePreview(.ccPedA, .ccPedB, .ccMapping)

  prov <- .buildCrossCenterMergeProvenance(
    pedAFileName = "pedA.csv", pedBFileName = "pedB.csv",
    mappingFileName = "mapping.csv",
    pedA = .ccPedA, pedB = .ccPedB, mapping = .ccMapping,
    merged = merged, lineagePreview = preview
  )

  expect_true(all(c("timestamp", "pedAFileName", "pedBFileName",
                     "mappingFileName", "packageVersion", "nPedA", "nPedB",
                     "nMapped", "nMerged", "idA", "sireSource",
                     "damSource") %in% names(prov)))
  expect_equal(prov$nPedA[1], 4L)
  expect_equal(prov$nPedB[1], 3L)
  expect_equal(prov$nMapped[1], 1L)
  expect_equal(prov$nMerged[1], nrow(merged))
  expect_equal(prov$idA, "T1")
})
