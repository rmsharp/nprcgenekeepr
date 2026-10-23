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

## S1005 (BACKLOG ruling S1004): an Excel history upload is read, validated and
## held exactly as the CSV upload above (before the fix the module showed
## "Could not read snapshot history" and kept no history).
test_that("modSnapshotTrendsServer's history upload reads an Excel history as it does the CSV", {
  skip_if_not_installed("shiny")

  history <- read.csv(exampleHistoryPath, stringsAsFactors = FALSE)
  xf <- writeTestXlsx(history, "history")
  on.exit(unlink(xf), add = TRUE)

  shiny::testServer(modSnapshotTrendsServer,
                     args = list(snapshotSource = shiny::reactive(NULL)), {
    session$setInputs(historyFile = fileInfo(xf))

    result <- session$getReturned()
    hist <- result$history()
    expect_true(is.data.frame(hist))
    expect_identical(nrow(hist), 4L)
    expect_s3_class(hist$snapshotDate, "Date")
    expect_true(result$isReady())
  })
})

## ===========================================================================
## Build earlier snapshots (S1039; issue #170, Slice 3, design B1, B3, B10)
## ===========================================================================
##
## modSnapshotTrendsServer(id, snapshotSource, fullPedigree) gains the panel
## that rebuilds past snapshots with backfillColonySnapshots(). Decided with
## the owner at the S1039 gates (AskUserQuestion):
##  * the counts table shown before the run is previewBackfillSupport(), the
##    same exported function a script calls, so the app never does more than a
##    script (design B1);
##  * the panel calls backfillColonySnapshots() and adds nothing of its own to
##    the numbers: the full pedigree (processedPedigree, never the focal-
##    trimmed analysisPedigree), the guIter and guThresh of the last analysis,
##    and its other reportGV() settings (snapshotSource()$reportArgs);
##  * rows reach the history only when the button is clicked, join the history
##    already there, and a date already there is not rebuilt;
##  * warnings of the build are summarized, never left to escape, and a build
##    that fails leaves the history as it was;
##  * the module returns one more reactive, backfillSupport.
## The panel's wording is the owner's; these tests pin ids and key words.
##
## Fixtures: the shipped qcPed (280 animals, 1959 to 2017). Its default series
## is 57 dates, 1961-01-01 to 2017-01-01; most builds below start in 2012 (six
## dates, 0.5 s at 10 iterations).

backfillStartDate <- "2012-01-01"
backfillStartDates <- seq(as.Date("2012-01-01"), as.Date("2017-01-01"), by = "year")

## The analysis a user would have run: reportGV() on the living animals of
## qcPed at 10 iterations, computed once.
backfillFixtureCache <- new.env(parent = emptyenv())
backfillAnalysis <- function() {
  if (is.null(backfillFixtureCache$gv)) {
    ped <- nprcgenekeepr::qcPed
    backfillFixtureCache$gv <- suppressWarnings(
      reportGV(ped, guIter = 10L, guThresh = 4L)
    )
  }
  backfillFixtureCache$gv
}

## What the Genetic Value tab hands over after a run (reportArgs is the new
## element of design B10).
makeBackfillSource <- function(ped = nprcgenekeepr::qcPed, reportArgs = NULL) {
  src <- list(
    ped = ped, geneticValue = backfillAnalysis(), guIter = 10L, guThresh = 4L
  )
  if (!is.null(reportArgs)) {
    src$reportArgs <- reportArgs
  }
  shiny::reactive(src)
}

## A source that stops with a silent req() error, as the real one does before
## any analysis has run.
noAnalysisYet <- function() shiny::reactive(shiny::req(FALSE))

serverArgs <- function(source = makeBackfillSource(),
                       fullPedigree = shiny::reactive(nprcgenekeepr::qcPed)) {
  list(snapshotSource = source, fullPedigree = fullPedigree)
}

## Replaces showNotification() for the rest of the calling test and returns the
## environment that records each call. Needed because testServer() does not
## raise an error that escapes an observer (it only prints it), so "no error
## escapes" is shown by the error being reported as a notification instead.
recordNotifications <- function(.env = parent.frame()) {
  seen <- new.env(parent = emptyenv())
  seen$all <- list()
  testthat::local_mocked_bindings(
    showNotification = function(ui, ..., type = "default") {
      seen$all[[length(seen$all) + 1L]] <- list(
        text = paste(as.character(ui), collapse = " "), type = type
      )
      invisible(NULL)
    },
    .package = "nprcgenekeepr",
    .env = .env
  )
  seen
}
notificationsOfType <- function(seen, type) {
  Filter(function(note) identical(note$type, type), seen$all)
}

## -- UI: the panel's pieces ---------------------------------------------------

test_that("modSnapshotTrendsUI has the Build Earlier Snapshots panel", {
  ui_html <- as.character(modSnapshotTrendsUI("test"))

  expect_true(grepl("test-buildBackfill", ui_html, fixed = TRUE))
  expect_true(grepl("Build earlier snapshots", ui_html, fixed = TRUE))
  expect_true(grepl("test-backfillStart", ui_html, fixed = TRUE))
  expect_true(grepl("Start year", ui_html, fixed = TRUE))
  expect_true(grepl("test-backfillCostUI", ui_html, fixed = TRUE))
  ## the box says what the rows are and where they are filed
  expect_true(grepl("reconstructedLiving", ui_html, fixed = TRUE))
})

test_that("modSnapshotTrendsUI has the Earlier Snapshots tab with the counts table", {
  ui_html <- as.character(modSnapshotTrendsUI("test"))

  expect_true(grepl("Earlier Snapshots", ui_html, fixed = TRUE))
  expect_true(grepl("test-backfillSupportTable", ui_html, fixed = TRUE))
  expect_true(grepl("test-backfillSkippedTable", ui_html, fixed = TRUE))
  expect_true(grepl("What each date rests on", ui_html, fixed = TRUE))
  ## the three tabs that were there stay
  for (label in c("History", "Trends", "Deltas")) {
    expect_true(grepl(label, ui_html, fixed = TRUE), info = label)
  }
})

test_that("modSnapshotTrendsServer declares fullPedigree after snapshotSource", {
  expect_identical(
    names(formals(modSnapshotTrendsServer)),
    c("id", "snapshotSource", "fullPedigree")
  )
})

## -- Server: the counts table ---------------------------------------------------

test_that("backfillSupport waits for the full pedigree (a silent req error)", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = serverArgs(fullPedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    expect_true(is.function(result$backfillSupport))
    expect_error(result$backfillSupport(), class = "shiny.silent.error")
  })
})

test_that("backfillSupport is the whole default series, from previewBackfillSupport()", {
  skip_if_not_installed("shiny")
  expected <- previewBackfillSupport(nprcgenekeepr::qcPed)

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    support <- session$getReturned()$backfillSupport()
    expect_identical(nrow(support), 57L)
    expect_identical(support$snapshotDate[[1L]], as.Date("1961-01-01"))
    expect_identical(support$snapshotDate[[57L]], as.Date("2017-01-01"))
    expect_equal(support, expected)
    ## the start year changes what is built, not what the table shows
    session$setInputs(backfillStart = backfillStartDate)
    expect_equal(session$getReturned()$backfillSupport(), expected)
  })
})

test_that("backfillSupport needs the full pedigree, not the analysis", {
  skip_if_not_installed("shiny")
  expected <- previewBackfillSupport(nprcgenekeepr::qcPed)

  shiny::testServer(modSnapshotTrendsServer,
                     args = serverArgs(source = noAnalysisYet()), {
    expect_equal(session$getReturned()$backfillSupport(), expected)
  })
})

## -- Server: the cost line --------------------------------------------------------

test_that("the cost line names the date count, the iterations and that it is an estimate", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    session$setInputs(backfillStart = backfillStartDate)
    html <- as.character(output$backfillCostUI$html)
    expect_match(html, "6 snapshots", fixed = TRUE)
    expect_match(html, "2012-01-01", fixed = TRUE)
    expect_match(html, "2017-01-01", fixed = TRUE)
    expect_match(html, "10 iterations", fixed = TRUE)
    expect_match(html, "estimate", fixed = TRUE)
  })
})

test_that("before an analysis has run the cost line asks for one", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer,
                     args = serverArgs(source = noAnalysisYet()), {
    html <- as.character(output$backfillCostUI$html)
    expect_match(html, "Run Genetic Value Analysis", fixed = TRUE)
    expect_false(grepl("estimate", html, fixed = TRUE))
  })
})

## -- Server: building ---------------------------------------------------------------

test_that("Build does nothing before an analysis has run", {
  skip_if_not_installed("shiny")

  seen <- recordNotifications()
  for (source in list(noAnalysisYet(), shiny::reactive(NULL))) {
    shiny::testServer(modSnapshotTrendsServer,
                       args = serverArgs(source = source), {
      session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
      result <- session$getReturned()
      expect_null(result$history())
      expect_false(result$isReady())
    })
  }
  ## a missing analysis is the quiet "not ready yet", not an error to show
  expect_length(seen$all, 0L)
})

test_that("Build does nothing before a full pedigree is there", {
  skip_if_not_installed("shiny")

  seen <- recordNotifications()
  shiny::testServer(modSnapshotTrendsServer,
                     args = serverArgs(fullPedigree = shiny::reactive(NULL)), {
    session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    expect_null(session$getReturned()$history())
  })
  expect_length(seen$all, 0L)
})

test_that("Build adds one reconstructedLiving row per date from the start year", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    suppressWarnings(
      session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    )
    result <- session$getReturned()
    hist <- result$history()
    expect_true(result$isReady())
    expect_identical(hist$snapshotDate, backfillStartDates)
    expect_identical(
      as.character(hist$membershipRule), rep("reconstructedLiving", 6L)
    )
    ## the provenance is the last analysis's, frozen in snapshotSource
    expect_identical(unique(hist$guIter), 10L)
    expect_identical(unique(hist$guThresh), 4L)
    expect_error(checkSnapshotHistory(hist), NA)
  })
})

test_that("the rows the panel appends equal the function's rows for the same inputs", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed
  set.seed(11L)
  expected <- suppressWarnings(backfillColonySnapshots(ped,
    guIter = 10L, guThresh = 4L, from = backfillStartDate
  ))$history

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    set.seed(11L)
    suppressWarnings(
      session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    )
    built <- session$getReturned()$history()
    rownames(built) <- NULL
    rownames(expected) <- NULL
    expect_equal(built, expected)
  })
})

test_that("a focal-trimmed analysis still rebuilds the whole colony (the full pedigree is used)", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed
  ## what the Genetic Value tab holds after a focal-animal analysis: the focal
  ## animals and their ancestors. Building from it would shrink every past
  ## population (24 to 32 animals a year here against 47 to 64).
  living <- ped$id[is.na(ped$exit)]
  focal <- trimPedigree(tail(living, 12L), ped,
    removeUninformative = FALSE, addBackParents = FALSE
  )
  expect_lt(nrow(focal), nrow(ped))
  set.seed(11L)
  expected <- suppressWarnings(backfillColonySnapshots(ped,
    guIter = 10L, guThresh = 4L, from = backfillStartDate
  ))$history
  shrunk <- suppressWarnings(backfillColonySnapshots(focal,
    guIter = 10L, guThresh = 4L, from = backfillStartDate
  ))$history
  expect_false(identical(shrunk$nAnimals, expected$nAnimals))

  shiny::testServer(modSnapshotTrendsServer,
                     args = serverArgs(source = makeBackfillSource(ped = focal)), {
    set.seed(11L)
    suppressWarnings(
      session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    )
    built <- session$getReturned()$history()
    expect_identical(built$nAnimals, expected$nAnimals)
  })
})

test_that("the panel calls the function with the full pedigree and the last analysis's settings", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed
  living <- ped$id[is.na(ped$exit)]
  twins <- data.frame(
    id1 = living[[1L]], id2 = living[[2L]], code = "MZ twin",
    stringsAsFactors = FALSE
  )
  reportArgs <- list(
    breedingTable = NULL, gestationTable = NULL, breedingAgeDefault = 5,
    gestationDefault = 99L, kinshipOverrides = NULL, twinRelations = twins,
    guCutoff = 12, zScoreCutoff = -1.5, axisPriority = "mk"
  )
  captured <- new.env(parent = emptyenv())
  testthat::local_mocked_bindings(
    backfillColonySnapshots = function(ped, dates = NULL, guIter, guThresh,
                                       from = NULL, to = NULL, by = "year",
                                       existingHistory = NULL, minAnimals = 2L,
                                       updateProgress = NULL, ...) {
      captured$ped <- ped
      captured$guIter <- guIter
      captured$guThresh <- guThresh
      captured$from <- from
      captured$existingHistory <- existingHistory
      captured$updateProgress <- updateProgress
      captured$dots <- list(...)
      stop("stop here: only the call is under test")
    },
    .package = "nprcgenekeepr"
  )

  shiny::testServer(modSnapshotTrendsServer,
                     args = serverArgs(source = makeBackfillSource(
                       ped = ped[1:20, ], reportArgs = reportArgs
                     )), {
    session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    expect_identical(captured$ped, nprcgenekeepr::qcPed)
    expect_identical(captured$guIter, 10L)
    expect_identical(captured$guThresh, 4L)
    expect_identical(captured$from, as.Date(backfillStartDate))
    expect_null(captured$existingHistory)
    expect_true(is.function(captured$updateProgress))
    for (setting in names(reportArgs)) {
      expect_identical(captured$dots[[setting]], reportArgs[[setting]],
        info = setting
      )
    }
  })
})

test_that("the start year is left to the function's default until one is chosen", {
  skip_if_not_installed("shiny")
  captured <- new.env(parent = emptyenv())
  captured$called <- FALSE
  testthat::local_mocked_bindings(
    backfillColonySnapshots = function(ped, ..., from = NULL) {
      captured$called <- TRUE
      captured$from <- from
      stop("stop here: only the call is under test")
    },
    .package = "nprcgenekeepr"
  )

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    session$setInputs(buildBackfill = 1)
    expect_true(captured$called)
    expect_null(captured$from)
  })
})

test_that("Build adds to the history already there and leaves its rows alone", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    session$setInputs(historyFile = fileInfo(exampleHistoryPath))
    before <- session$getReturned()$history()
    expect_identical(nrow(before), 4L)
    suppressWarnings(
      session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    )
    hist <- session$getReturned()$history()
    expect_identical(nrow(hist), 10L)
    expect_identical(sum(hist$membershipRule == "reconstructedLiving"), 6L)
    kept <- hist[hist$membershipRule != "reconstructedLiving", ]
    rownames(kept) <- NULL
    rownames(before) <- NULL
    expect_equal(kept[, names(before)], before)
  })
})

test_that("a second Build adds nothing: the dates are already there", {
  skip_if_not_installed("shiny")

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    suppressWarnings(
      session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    )
    first <- session$getReturned()$history()
    suppressWarnings(session$setInputs(buildBackfill = 2))
    second <- session$getReturned()$history()
    expect_identical(nrow(second), 6L)
    expect_equal(second, first)
  })
})

test_that("the warnings of a build are summarized in one notification", {
  skip_if_not_installed("shiny")
  seen <- recordNotifications()

  ## reportGV() warns on this fixture at 10 iterations (8 warnings across the
  ## six dates, measured S1039), and the function adds its own when a date
  ## cannot be rebuilt: the reader gets one warning notice, not eight.
  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    suppressWarnings(
      session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    )
    expect_identical(nrow(session$getReturned()$history()), 6L)
  })
  noted <- notificationsOfType(seen, "warning")
  expect_length(noted, 1L)
  expect_match(noted[[1L]]$text, "Founder genome equivalents", fixed = TRUE)
  expect_length(notificationsOfType(seen, "error"), 0L)
})

test_that("a warning raised inside the build does not escape", {
  skip_if_not_installed("shiny")
  seen <- recordNotifications()
  ## A complete history, so that redrawing the trend plot for it raises no
  ## warning of its own (ggplot2 reports the NA metrics of a 10-iteration
  ## build); only the build's two warnings are in play.
  complete <- checkSnapshotHistory(readSnapshotHistory(exampleHistoryPath))
  testthat::local_mocked_bindings(
    backfillColonySnapshots = function(...) {
      warning("first note from the build")
      warning("second note from the build")
      list(history = complete, support = data.frame(),
           skipped = data.frame(snapshotDate = as.Date(character(0L)),
                                reason = character(0L)))
    },
    .package = "nprcgenekeepr"
  )

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    expect_no_warning(
      session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    )
    expect_identical(nrow(session$getReturned()$history()), 4L)
  })
  noted <- notificationsOfType(seen, "warning")
  expect_length(noted, 1L)
  expect_match(noted[[1L]]$text, "first note from the build", fixed = TRUE)
  expect_match(noted[[1L]]$text, "second note from the build", fixed = TRUE)
})

test_that("a build that fails leaves the history as it was and is reported as an error", {
  skip_if_not_installed("shiny")
  seen <- recordNotifications()
  testthat::local_mocked_bindings(
    backfillColonySnapshots = function(...) {
      stop("No snapshot could be built. 2012-01-01: needs at least 2 animals")
    },
    .package = "nprcgenekeepr"
  )

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    session$setInputs(backfillStart = backfillStartDate, buildBackfill = 1)
    expect_null(session$getReturned()$history())
    session$setInputs(historyFile = fileInfo(exampleHistoryPath))
    session$setInputs(buildBackfill = 2)
    expect_identical(nrow(session$getReturned()$history()), 4L)
  })
  failed <- notificationsOfType(seen, "error")
  expect_length(failed, 2L)
  expect_match(failed[[1L]]$text, "No snapshot could be built", fixed = TRUE)
})

test_that("a start date that is not a date is reported, not built", {
  skip_if_not_installed("shiny")
  seen <- recordNotifications()

  shiny::testServer(modSnapshotTrendsServer, args = serverArgs(), {
    session$setInputs(backfillStart = "not a date", buildBackfill = 1)
    expect_null(session$getReturned()$history())
  })
  failed <- notificationsOfType(seen, "error")
  expect_length(failed, 1L)
  expect_match(failed[[1L]]$text, "earlier snapshots", ignore.case = TRUE)
})
