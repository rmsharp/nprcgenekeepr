## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #167 Slice 4: modSnapshotTrendsUI/modSnapshotTrendsServer -- the 16th
# top-level tab (D7, "Genetic-Health Trends"). Upload/validate/append a
# snapshot-history CSV (Slice 1's reader/validator mold), generate a new
# snapshot from a live Genetic Value Analysis run via the S760
# snapshotSource reactive (createColonySnapshot(), Slice 2), and render
# trends/deltas (plotSnapshotTrends()/calcSnapshotDeltas(), Slice 3). The
# module-contract catalog signature is amended (S760 owner decision,
# docs/planning/issue167-longitudinal-monitoring-plan.md sec 4):
# modSnapshotTrendsServer(id, snapshotSource) -- ONE upstream reactive, so
# every declared parameter is read (module-contract rule 6); the plan's
# original pedigree/geneticValues catalog signature is superseded.
#
# The membership rule for a GENERATED snapshot is auto-derived from
# snapshotSource()$ped$population (S760 owner decision: truthful by
# construction from the analyzed pedigree, not a user-set dropdown that
# could contradict the data and hit createColonySnapshot()'s stop()). The
# DELTA comparison keeps a user-facing rule selector (S759's own wiring
# note), fed from the uploaded/generated history's own membershipRule
# values.

## Build the data.frame shiny's fileInput hands the server for an uploaded
## file (mirrors test_modGeneticValue_kinshipOverrides.R's own helper).
fileInfo <- function(path) {
  data.frame(
    name = basename(path), size = 1L, type = "text/csv",
    datapath = path, stringsAsFactors = FALSE
  )
}

exampleHistoryPath <- system.file("extdata", "examples",
  "example_snapshot_history.csv",
  package = "nprcgenekeepr"
)

## A live snapshotSource reactive, backed by a real reportGV() run -- the
## fixture every server test below drives the module with.
makeLiveSnapshotSource <- function() {
  ped <- nprcgenekeepr::qcPed
  gv <- reportGV(ped, guIter = 10L, guThresh = 4L)
  shiny::reactive(list(ped = ped, geneticValue = gv, guIter = 10L,
                       guThresh = 4L))
}

## -- UI shape -----------------------------------------------------------

test_that("modSnapshotTrendsUI returns a shiny.tag object", {
  ui <- modSnapshotTrendsUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modSnapshotTrendsUI has the history upload input and Generate Snapshot button", {
  ui_html <- as.character(modSnapshotTrendsUI("test"))

  expect_true(grepl("historyFile", ui_html))
  expect_true(grepl("generateSnapshot", ui_html))
  expect_true(grepl("Generate Snapshot", ui_html))
})

test_that("modSnapshotTrendsUI has the delta comparison selectors", {
  ui_html <- as.character(modSnapshotTrendsUI("test"))

  expect_true(grepl("deltaRule", ui_html))
  expect_true(grepl("deltaFrom", ui_html))
  expect_true(grepl("deltaTo", ui_html))
})

test_that("modSnapshotTrendsUI has History, Trends, and Deltas tabs", {
  ui_html <- as.character(modSnapshotTrendsUI("test"))

  expect_true(grepl("History", ui_html))
  expect_true(grepl("Trends", ui_html))
  expect_true(grepl("Deltas", ui_html))
})

test_that("modSnapshotTrendsUI has the two download buttons", {
  ui_html <- as.character(modSnapshotTrendsUI("test"))

  expect_true(grepl("downloadHistory", ui_html))
  expect_true(grepl("downloadDeltas", ui_html))
})

## -- Server: no data yet --------------------------------------------------

test_that("modSnapshotTrendsServer's history and isReady are empty before any upload or generation", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = shiny::reactive(NULL)), {
    result <- session$getReturned()
    expect_null(result$history())
    expect_false(result$isReady())
  })
})

## -- Server: upload (Slice 1 reader/validator reuse) -----------------------

test_that("modSnapshotTrendsServer's history upload reads and validates the fixture history (Slice 1 reuse)", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = shiny::reactive(NULL)), {
    session$setInputs(historyFile = fileInfo(exampleHistoryPath))

    result <- session$getReturned()
    hist <- result$history()
    expect_true(is.data.frame(hist))
    expect_identical(nrow(hist), 4L)
    expect_true(all(c("schemaVersion", "snapshotDate", "membershipRule") %in%
                      names(hist)))
    expect_s3_class(hist$snapshotDate, "Date")
    expect_true(result$isReady())
  })
})

test_that("modSnapshotTrendsServer ignores a malformed history upload (checkSnapshotHistory() violation surfaces, history stays unchanged)", {
  skip_if_not_installed("shiny")

  badCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(badCsv), add = TRUE)
  # Missing required columns -> checkSnapshotHistory() stop()s.
  writeLines(c("schemaVersion,snapshotDate", "1,2025-01-15"), badCsv)

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = shiny::reactive(NULL)), {
    session$setInputs(historyFile = fileInfo(exampleHistoryPath))
    validNrow <- nrow(session$getReturned()$history())

    session$setInputs(historyFile = fileInfo(badCsv))

    result <- session$getReturned()
    expect_identical(nrow(result$history()), validNrow)
  })
})

## -- Server: snapshot generation (Slice 2 reuse via snapshotSource) --------

test_that("modSnapshotTrendsServer's Generate Snapshot is a no-op when no GVA run has happened yet", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = shiny::reactive(NULL)), {
    session$setInputs(generateSnapshot = 1)

    result <- session$getReturned()
    expect_null(result$history())
  })
})

test_that("modSnapshotTrendsServer's Generate Snapshot creates and appends a row from a live GVA run, with the auto-derived membershipRule", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = makeLiveSnapshotSource()), {
    session$setInputs(generateSnapshot = 1)

    result <- session$getReturned()
    hist <- result$history()
    expect_true(is.data.frame(hist))
    expect_identical(nrow(hist), 1L)
    expect_identical(hist$membershipRule, "wholePedigree")
    expect_identical(hist$guIter, 10L)
    expect_identical(hist$guThresh, 4L)
    expect_identical(hist$snapshotDate, Sys.Date())
  })
})

test_that("modSnapshotTrendsServer's Generate Snapshot appends onto an already-uploaded history", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = makeLiveSnapshotSource()), {
    session$setInputs(historyFile = fileInfo(exampleHistoryPath))
    session$setInputs(generateSnapshot = 1)

    result <- session$getReturned()
    hist <- result$history()
    expect_identical(nrow(hist), 5L)
    expect_true(Sys.Date() %in% hist$snapshotDate)
  })
})

## -- Server: deltas (Slice 3 reuse) -----------------------------------------

test_that("modSnapshotTrendsServer's deltas compute from the selected rule/from/to, with the D4 comparabilityFlag visible", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = shiny::reactive(NULL)), {
    session$setInputs(historyFile = fileInfo(exampleHistoryPath))
    session$setInputs(deltaRule = "wholePedigree", deltaFrom = "2025-07-15",
                      deltaTo = "2026-01-15")

    result <- session$getReturned()
    deltas <- result$deltas()
    expect_true(is.data.frame(deltas))
    expect_true("comparabilityFlag" %in% names(deltas))
    ## The fixture's guIter changes 5000 -> 10000 between these two
    ## wholePedigree snapshots (D4): the gene-drop-derived rows must be
    ## flagged, not silently averaged away.
    expect_true(any(grepl("guIter", deltas$comparabilityFlag)))
  })
})

## -- Server: downloads -------------------------------------------------------

test_that("modSnapshotTrendsServer's Download Updated History writes the current history", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = shiny::reactive(NULL)), {
    session$setInputs(historyFile = fileInfo(exampleHistoryPath))

    histPath <- output$downloadHistory
    histOut <- utils::read.csv(histPath, stringsAsFactors = FALSE)
    expect_identical(nrow(histOut), 4L)
  })
})

test_that("modSnapshotTrendsServer's Download Delta Table writes the current delta comparison", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = shiny::reactive(NULL)), {
    session$setInputs(historyFile = fileInfo(exampleHistoryPath))
    session$setInputs(deltaRule = "wholePedigree", deltaFrom = "2025-01-15",
                      deltaTo = "2025-07-15")

    deltaPath <- output$downloadDeltas
    deltaOut <- utils::read.csv(deltaPath, stringsAsFactors = FALSE)
    expect_true("comparabilityFlag" %in% names(deltaOut))
  })
})
