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
