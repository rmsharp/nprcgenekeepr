## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)

## -- Internal helpers -----------------------------------------------------
## Slice 1 of issue #150 (docs/planning/issue150-deidentified-pedigree-export-
## plan.md sec 5): script-callable core only, no UI. .buildDeidentificationManifest()
## mirrors .buildCrossCenterMergeProvenance()'s shape (R/modCrossCenterIdentity.R) --
## a pure, one-row data.frame builder, sec 3 D4/sec 4 interface catalog.

test_that(".buildDeidentificationManifest builds a one-row data.frame with the documented D4 fields", {
  pedGood <- qcStudbook(nprcgenekeepr::pedGood)
  exported <- obfuscatePed(pedGood, size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
  warningText <- "This export removes identifying ids, names, and shifts dates."

  manifest <- .buildDeidentificationManifest(
    pedRows = exported, size = 6L, maxDelta = 30L, linkedDateShift = TRUE,
    warningText = warningText
  )

  expect_s3_class(manifest, "data.frame")
  expect_equal(nrow(manifest), 1L)
  expect_true(all(c("timestamp", "packageVersion", "size", "maxDelta",
                     "linkedDateShift", "nRows", "warningText") %in%
                    names(manifest)))
  expect_equal(manifest$size, 6L)
  expect_equal(manifest$maxDelta, 30L)
  expect_true(manifest$linkedDateShift)
  expect_equal(manifest$nRows, nrow(exported))
  expect_equal(manifest$warningText, warningText)
})

test_that(".buildDeidentificationManifest never includes the id map or any raw pre-obfuscation value (D4)", {
  # D4 (sec 3): the manifest is the "non-sensitive ... auditable" artifact --
  # explicitly never the id map itself (D5) and never a raw pre-obfuscation
  # value. Guard against a future edit accidentally widening the field set.
  pedGood <- qcStudbook(nprcgenekeepr::pedGood)
  exported <- obfuscatePed(pedGood, size = 6L, maxDelta = 30L, linkedDateShift = TRUE)

  manifest <- .buildDeidentificationManifest(
    pedRows = exported, size = 6L, maxDelta = 30L, linkedDateShift = TRUE,
    warningText = "warning"
  )

  expect_false(any(c("map", "id", "sire", "dam", "birth", "exit") %in%
                     names(manifest)))
})

## -- Slice 2 (issue #150 Slice 2): the full modDeidentifiedExport Shiny
## module -- Configure & Preview / Export tabs, no fileInput (D1: reads
## shared$currentPedigree), a modalDialog() confirm gate (D2/D6, mirrors
## modCrossCenterIdentityServer's own Confirm->Export shape), and 3
## downloadable artifacts (de-identified pedigree, transformation manifest,
## re-identification map distinctly labeled per D5), per
## docs/planning/issue150-deidentified-pedigree-export-plan.md sec 5 Slice 2.

## -- UI shape ---------------------------------------------------------------

test_that("modDeidentifiedExportUI returns a shiny.tag object", {
  ui <- modDeidentifiedExportUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modDeidentifiedExportUI has the size/maxDelta/linkedDateShift configuration inputs", {
  ui_html <- as.character(modDeidentifiedExportUI("test"))

  expect_true(grepl("size", ui_html))
  expect_true(grepl("maxDelta", ui_html))
  expect_true(grepl("linkedDateShift", ui_html))
})

test_that("modDeidentifiedExportUI has Configure & Preview and Export tabs", {
  ui_html <- as.character(modDeidentifiedExportUI("test"))

  expect_true(grepl("Configure", ui_html))
  expect_true(grepl("Preview", ui_html))
  expect_true(grepl("Export", ui_html))
})

test_that("modDeidentifiedExportUI has a Confirm Export action button and the D6 warning text", {
  ui_html <- as.character(modDeidentifiedExportUI("test"))

  expect_true(grepl("confirmExport", ui_html))
  expect_true(grepl("Confirm Export", ui_html))
  # D6: the institutional-responsibility warning is shown statically on the
  # Configure tab, not only inside the modal (verified separately below).
  expect_true(grepl("institution", ui_html, ignore.case = TRUE))
})

test_that("modDeidentifiedExportUI has 3 distinct download buttons, with the map one labeled DO NOT SHARE (D5)", {
  ui_html <- as.character(modDeidentifiedExportUI("test"))

  expect_true(grepl("downloadPedigree", ui_html))
  expect_true(grepl("downloadManifest", ui_html))
  expect_true(grepl("downloadMap", ui_html))
  expect_true(grepl("DO NOT SHARE", ui_html))
})

## -- Server: no pedigree loaded ----------------------------------------------

test_that("modDeidentifiedExportServer's Generate Preview is a no-op when no pedigree is loaded", {
  skip_if_not_installed("shiny")

  shiny::testServer(modDeidentifiedExportServer,
                     args = list(pedigree = shiny::reactive(NULL)), {
    session$setInputs(preview = 1)

    result <- session$getReturned()
    expect_error(result$exportedPedigree(), class = "shiny.silent.error")
  })
})

## -- Server: preview generation (D1/D2/D3) -----------------------------------

test_that("modDeidentifiedExportServer's Generate Preview aliases id/sire/dam and never produces a negative age (module-level proof, issue #150 D3)", {
  skip_if_not_installed("shiny")

  # Same fixture/seed as test_obfuscatePed.R's own linkedDateShift regression
  # test: a realistic short-lived-individual gap that reproduces the S514
  # negative-age defect under the OLD (pre-#150) independent-per-column
  # behavior. This proves the MODULE wires linkedDateShift = TRUE through end
  # -to-end -- not just that obfuscatePed() itself is correct in isolation.
  ped <- qcStudbook(nprcgenekeepr::pedGood)
  ped$exit <- ped$birth + 10L

  set_seed(3L)
  shiny::testServer(modDeidentifiedExportServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
    session$setInputs(preview = 1)

    result <- session$getReturned()
    exported <- result$exportedPedigree()
    expect_false(any(exported$id %in% ped$id))
    expect_false(any(exported$sire[!is.na(exported$sire)] %in% ped$id))
    expect_true(all(exported$age >= 0))
  })
})

test_that("modDeidentifiedExportServer's Generate Preview populates map and manifest reactives (D4/D5)", {
  skip_if_not_installed("shiny")

  ped <- qcStudbook(nprcgenekeepr::pedGood)

  shiny::testServer(modDeidentifiedExportServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
    session$setInputs(preview = 1)

    result <- session$getReturned()
    map <- result$map()
    expect_identical(class(map), "character")
    expect_named(map, ped$id)

    manifest <- result$manifest()
    expect_s3_class(manifest, "data.frame")
    expect_equal(nrow(manifest), 1L)
    expect_equal(manifest$size, 6L)
    expect_equal(manifest$maxDelta, 30L)
    expect_true(manifest$linkedDateShift)
  })
})

test_that("modDeidentifiedExportServer's manifest reflects the params actually used to produce the preview, not live input state changed afterward", {
  skip_if_not_installed("shiny")

  # Forced correctness requirement found during Pre-RED (not a plan D-decision
  # -- a mechanical trap, same category as D1/D2/D4/D5/D7/D9): if the curator
  # tweaks size/maxDelta AFTER generating a preview but BEFORE confirming/
  # exporting, the manifest must still describe the params that produced the
  # CURRENT exported pedigree -- not whatever the sliders read at export time.
  ped <- qcStudbook(nprcgenekeepr::pedGood)

  shiny::testServer(modDeidentifiedExportServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
    session$setInputs(preview = 1)

    ## Change the configuration WITHOUT re-generating the preview.
    session$setInputs(size = 10L, maxDelta = 15L)

    result <- session$getReturned()
    manifest <- result$manifest()
    expect_equal(manifest$size, 6L)
    expect_equal(manifest$maxDelta, 30L)
  })
})

## -- Server: confirm gate (D2/D6) --------------------------------------------

test_that("modDeidentifiedExportServer's confirmed reactive starts FALSE and only flips TRUE after the modal confirm click", {
  skip_if_not_installed("shiny")

  ped <- qcStudbook(nprcgenekeepr::pedGood)

  shiny::testServer(modDeidentifiedExportServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
    session$setInputs(preview = 1)

    result <- session$getReturned()
    expect_false(result$confirmed())

    session$setInputs(confirmExport = 1)
    session$setInputs(confirmExportOk = 1)
    expect_true(result$confirmed())
  })
})

test_that("modDeidentifiedExportServer resets confirmed to FALSE when the preview is regenerated (stale-confirmation dragon, mirrors #149 D5)", {
  skip_if_not_installed("shiny")

  ped <- qcStudbook(nprcgenekeepr::pedGood)

  shiny::testServer(modDeidentifiedExportServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
    session$setInputs(preview = 1)
    session$setInputs(confirmExport = 1)
    session$setInputs(confirmExportOk = 1)

    result <- session$getReturned()
    expect_true(result$confirmed())

    session$setInputs(preview = 2)
    expect_false(result$confirmed())
  })
})

## -- Server: exports (D5) -----------------------------------------------------

test_that("modDeidentifiedExportServer's Download De-Identified Pedigree writes the exported (aliased) pedigree", {
  skip_if_not_installed("shiny")

  ped <- qcStudbook(nprcgenekeepr::pedGood)

  shiny::testServer(modDeidentifiedExportServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
    session$setInputs(preview = 1)
    session$setInputs(confirmExport = 1)
    session$setInputs(confirmExportOk = 1)

    result <- session$getReturned()
    pedPath <- output$downloadPedigree
    pedOut <- utils::read.csv(pedPath, stringsAsFactors = FALSE)
    expect_equal(nrow(pedOut), nrow(ped))
    expect_false(any(pedOut$id %in% ped$id))
  })
})

test_that("modDeidentifiedExportServer's Download Re-identification Key round-trips originalId/aliasId matching the map reactive", {
  skip_if_not_installed("shiny")

  ped <- qcStudbook(nprcgenekeepr::pedGood)

  shiny::testServer(modDeidentifiedExportServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
    session$setInputs(preview = 1)
    session$setInputs(confirmExport = 1)
    session$setInputs(confirmExportOk = 1)

    result <- session$getReturned()
    map <- result$map()

    mapPath <- output$downloadMap
    mapOut <- utils::read.csv(mapPath, stringsAsFactors = FALSE)
    expect_true(all(c("originalId", "aliasId") %in% names(mapOut)))
    expect_equal(sort(mapOut$originalId), sort(names(map)))
    expect_equal(mapOut$aliasId[order(mapOut$originalId)],
                 unname(map[order(names(map))]))
  })
})

test_that("modDeidentifiedExportServer's Download Transformation Manifest writes the D4 manifest", {
  skip_if_not_installed("shiny")

  ped <- qcStudbook(nprcgenekeepr::pedGood)

  shiny::testServer(modDeidentifiedExportServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(size = 6L, maxDelta = 30L, linkedDateShift = TRUE)
    session$setInputs(preview = 1)
    session$setInputs(confirmExport = 1)
    session$setInputs(confirmExportOk = 1)

    manifestPath <- output$downloadManifest
    manifestOut <- utils::read.csv(manifestPath, stringsAsFactors = FALSE)
    expect_equal(nrow(manifestOut), 1L)
    expect_equal(manifestOut$size, 6L)
    expect_equal(manifestOut$maxDelta, 30L)
    expect_true(manifestOut$linkedDateShift)
    expect_false(any(c("map", "id", "sire", "dam") %in% names(manifestOut)))
  })
})
