# Tests for the appServer() server body (R/appServer.R).
#
# The existing test_appServer_dynamicTabs.R covers only the helper functions
# (shouldShowChangedColsTab, getErrorTab, getChangedColsTab) plus structural
# checks (is.function(appServer), a deparse(appServer) grep, and appUI() HTML
# greps). None of it drives appServer through shiny::testServer, so the entire
# server body -- logger/config init, the six navigation observeEvents, the
# child-module mounts, and the wiring observers that propagate child outputs
# into shared state and manage the dynamic Error List / Changed Columns tabs --
# ran only under the opt-in browser e2e (skipped here without shinytest2 +
# chromote), leaving R/appServer.R at 0% local coverage.
#
# These tests exercise that server body headlessly. Two layers:
#   (1) a bare shiny::testServer(appServer) boot that mounts every real child
#       module and fires the six nav handlers (integration smoke); and
#   (2) with_mocked_bindings() stubs of the four child servers appServer reads
#       from (modInput/modPedigree/modGeneticValue/modBreedingGroups), backed by
#       reactiveVals, so the wiring observers can be driven through every branch
#       and asserted via appServer's observable effects -- shared$currentStudbook
#       / currentPedigree / geneticValues / breedingGroups and the
#       errorTabShown() / changedColsTabShown() reactiveVals. The child modules
#       are covered by their own suites; here appServer's glue is the unit.

# getSiteInfo() warns when no site-configuration file is present, which is the
# normal state in the test environment; appServer() calls it at boot. Muffle
# only that specific, expected warning so the suite stays clean without hiding
# any genuine warning from appServer's logic.
muffleConfig <- function(expr) {
  withCallingHandlers(
    expr,
    warning = function(w) {
      if (grepl("configuration file is missing", conditionMessage(w),
                fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )
}

# ---- Stubs for the four child servers appServer reads from -----------------
# Each stub creates its controllable reactiveVals when mounted (inside the
# testServer reactive domain) and stashes them in ctl so a test can drive them.
ctl <- new.env()

stubInput <- function(id, ...) {
  ctl$studbook <- shiny::reactiveVal(NULL)
  ctl$qc <- shiny::reactiveVal(NULL)
  ctl$err <- shiny::reactiveVal(NULL)
  ctl$fname <- shiny::reactiveVal(NULL)
  ctl$changed <- shiny::reactiveVal(NULL)
  list(
    cleanedStudbook = shiny::reactive(ctl$studbook()),
    qcSummary = shiny::reactive(ctl$qc()),
    errorLst = shiny::reactive(ctl$err()),
    pedigreeFileName = shiny::reactive(ctl$fname()),
    changedCols = shiny::reactive(ctl$changed()),
    genotypeData = shiny::reactive(NULL),
    minSireAge = shiny::reactive(NULL),
    minDamAge = shiny::reactive(NULL),
    isReady = shiny::reactive(FALSE),
    debugMode = shiny::reactive(FALSE)
  )
}

stubPed <- function(id, ...) {
  ctl$ped <- shiny::reactiveVal(NULL)
  list(
    pedigree = shiny::reactive(ctl$ped()),
    processedPedigree = shiny::reactive(NULL),
    focalAnimals = shiny::reactive(NULL),
    nAnimals = shiny::reactive(0L),
    populationCount = shiny::reactive(0L),
    isReady = shiny::reactive(FALSE)
  )
}

stubGV <- function(id, ...) {
  ctl$gv <- shiny::reactiveVal(NULL)
  list(
    geneticValues = shiny::reactive(ctl$gv()),
    topAnimals = shiny::reactive(NULL),
    nAnalyzed = shiny::reactive(0L),
    kinshipMatrix = shiny::reactive(NULL),
    kinshipOverrides = shiny::reactive(NULL),
    founderStats = shiny::reactive(NULL),
    maleFounders = shiny::reactive(NULL),
    femaleFounders = shiny::reactive(NULL)
  )
}

stubBG <- function(id, ...) {
  ctl$grp <- shiny::reactiveVal(NULL)
  list(
    groups = shiny::reactive(ctl$grp()),
    nGroups = shiny::reactive(0L),
    score = shiny::reactive(0L),
    unassigned = shiny::reactive(character(0L)),
    groupKinship = shiny::reactive(NULL)
  )
}

# No-op stub for the downstream modules appServer mounts but does not read from
# (pyramid, summary stats, genetic diversity, potential parents). Stubbing these
# in the wiring test keeps it a unit test of appServer's glue -- the real
# modules are covered by their own suites and their mount lines are covered by
# the boot test above -- and avoids benign plotting warnings (empty-data min/max
# and geom_vline) when they react to the minimal stub pedigree.
noopServer <- function(id, ...) invisible(NULL)

# A real error list with QC errors (female sire / male dam): checkErrorLst TRUE.
errorLstWithErrors <- function() {
  qcStudbook(nprcgenekeepr::pedFemaleSireMaleDam, reportErrors = TRUE)
}

# A clean pedigree whose sire column has a space ("si re"): valid data (no QC
# errors, so checkErrorLst FALSE) but a renamed column (changedCols non-empty).
cleanChangedErrorLst <- function() {
  cleanPed <- data.frame(
    ego_id = c("d1", "s1", "o1"),
    `si re` = c(NA, NA, "s1"),
    dam_id = c(NA, NA, "d1"),
    sex = c("F", "M", "F"),
    birth_date = lubridate::mdy(c("1-1-2010", "1-1-2010", "1-1-2015")),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  qcStudbook(cleanPed, reportErrors = TRUE, reportChanges = TRUE)
}

# =============================================================================
# 1. Boot: every real child module mounts, config observer runs, nav handlers
#    fire. Exercises init (logger/shared/config observe), all module mounts, and
#    the six goto_* observeEvents with the real modules in place.
# =============================================================================

test_that("appServer boots with all real modules and fires nav handlers", {
  booted <- FALSE
  bgAtInit <- "unset"
  pedAtInit <- "unset"
  gvAtInit <- "unset"

  muffleConfig(shiny::testServer(appServer, {
    session$flushReact()
    bgAtInit <<- shared$breedingGroups
    pedAtInit <<- shared$currentPedigree
    gvAtInit <<- shared$geneticValues
    # Fire all six home-page navigation buttons.
    session$setInputs(goto_input = 1L)
    session$setInputs(goto_pedigree = 1L)
    session$setInputs(goto_pyramid = 1L)
    session$setInputs(goto_genetic = 1L)
    session$setInputs(goto_summary = 1L)
    session$setInputs(goto_breeding = 1L)
    session$flushReact()
    booted <<- TRUE
  }))

  expect_true(booted)
  # Nothing is loaded at boot, so shared data slots are empty.
  expect_null(bgAtInit)
  expect_null(pedAtInit)
  expect_null(gvAtInit)
})

# =============================================================================
# 2. Wiring: child-module outputs propagate into shared state.
# =============================================================================

test_that("appServer wires child-module outputs into shared state", {
  studbookSet <- FALSE
  pedSet <- FALSE
  gvSet <- FALSE
  bgGroups <- "unset"

  testthat::with_mocked_bindings(
    modInputServer = stubInput,
    modPedigreeServer = stubPed,
    modGeneticValueServer = stubGV,
    modBreedingGroupsServer = stubBG,
    modPyramidServer = noopServer,
    modSummaryStatsServer = noopServer,
    modGeneticDiversityServer = noopServer,
    modPotentialParentsServer = noopServer,
    .package = "nprcgenekeepr",
    {
      muffleConfig(shiny::testServer(appServer, {
        session$flushReact()
        # cleanedStudbook -> shared$currentStudbook (studbook observer if-branch)
        ctl$studbook(data.frame(id = "a", stringsAsFactors = FALSE))
        ctl$qc(list(errors = 0L, warnings = 0L, records = 1L))
        session$flushReact()
        studbookSet <<- !is.null(shared$currentStudbook)
        # pedigree() -> shared$currentPedigree (req passes)
        ctl$ped(data.frame(id = "a", stringsAsFactors = FALSE))
        session$flushReact()
        pedSet <<- !is.null(shared$currentPedigree)
        # geneticValues() -> shared$geneticValues (req passes)
        ctl$gv(data.frame(id = "a", value = 1, stringsAsFactors = FALSE))
        session$flushReact()
        gvSet <<- !is.null(shared$geneticValues)
        # groups() -> shared$breedingGroups (issue #112 S4 capture)
        ctl$grp(list(c("a", "b")))
        session$flushReact()
        bgGroups <<- shared$breedingGroups
      }))
    }
  )

  expect_true(studbookSet)
  expect_true(pedSet)
  expect_true(gvSet)
  expect_identical(bgGroups, list(c("a", "b")))
})

# =============================================================================
# 3. QC notifications: pass / error / warning branches each fire.
# =============================================================================

test_that("appServer shows QC notifications for pass, error, and warning", {
  rec <- new.env()
  rec$types <- character(0L)
  recNote <- function(ui, ..., type = "default", duration = NULL) {
    rec$types <- c(rec$types, type)
    invisible("note-id")
  }

  testthat::with_mocked_bindings(
    modInputServer = stubInput,
    modPedigreeServer = stubPed,
    modGeneticValueServer = stubGV,
    modBreedingGroupsServer = stubBG,
    showNotification = recNote,
    .package = "nprcgenekeepr",
    {
      muffleConfig(shiny::testServer(appServer, {
        session$flushReact()
        # QC passed: no errors, no warnings, records > 0 -> "message"
        ctl$qc(list(errors = 0L, warnings = 0L, records = 5L))
        session$flushReact()
        # QC errors present -> "error"
        ctl$qc(list(errors = 2L, warnings = 0L, records = 5L))
        session$flushReact()
        # QC warnings present -> "warning"
        ctl$qc(list(errors = 0L, warnings = 3L, records = 5L))
        session$flushReact()
      }))
    }
  )

  expect_true("message" %in% rec$types)
  expect_true("error" %in% rec$types)
  expect_true("warning" %in% rec$types)
})

# =============================================================================
# 4. Dynamic Error List tab: inserted when errors are present, removed when
#    they clear.
# =============================================================================

test_that("appServer inserts and removes the Error List tab", {
  inserted <- FALSE
  removed <- FALSE

  testthat::with_mocked_bindings(
    modInputServer = stubInput,
    modPedigreeServer = stubPed,
    modGeneticValueServer = stubGV,
    modBreedingGroupsServer = stubBG,
    .package = "nprcgenekeepr",
    {
      muffleConfig(shiny::testServer(appServer, {
        session$flushReact()
        # A real error list plus a file name -> insert the Error List tab.
        ctl$err(errorLstWithErrors())
        ctl$fname("pedigree.csv")
        session$flushReact()
        inserted <<- errorTabShown()
        # Errors clear -> remove the Error List tab.
        ctl$err(NULL)
        session$flushReact()
        removed <<- !errorTabShown()
      }))
    }
  )

  expect_true(inserted)
  expect_true(removed)
})

# =============================================================================
# 5. Dynamic Changed Columns tab: both target positions (after Error List when
#    errors are shown, after Input otherwise) and removal.
# =============================================================================

test_that("appServer inserts the Changed Columns tab in both positions", {
  # Scenario A: errors present, so the Changed Columns tab targets "Error List".
  errShownA <- FALSE
  ccShownA <- FALSE
  ccRemovedA <- FALSE
  # Scenario B: a clean-but-changed error list (no errors), so the tab targets
  # "Input" (the else-branch of the targetTab selection).
  errShownB <- "unset"
  ccShownB <- FALSE

  ccFixture <- cleanChangedErrorLst()

  testthat::with_mocked_bindings(
    modInputServer = stubInput,
    modPedigreeServer = stubPed,
    modGeneticValueServer = stubGV,
    modBreedingGroupsServer = stubBG,
    .package = "nprcgenekeepr",
    {
      muffleConfig(shiny::testServer(appServer, {
        session$flushReact()
        ctl$err(errorLstWithErrors())
        ctl$fname("pedigree.csv")
        session$flushReact()
        errShownA <<- errorTabShown()
        # errorTabShown() is TRUE -> targetTab = "Error List".
        ctl$changed(ccFixture$changedCols)
        session$flushReact()
        ccShownA <<- changedColsTabShown()
        # Changed columns clear -> remove the Changed Columns tab.
        ctl$changed(NULL)
        session$flushReact()
        ccRemovedA <<- !changedColsTabShown()
      }))

      muffleConfig(shiny::testServer(appServer, {
        session$flushReact()
        # Non-NULL error list with no QC errors: checkErrorLst() FALSE, so the
        # Error List tab is not shown and the Changed Columns tab targets
        # "Input".
        ctl$err(ccFixture)
        ctl$fname("pedigree.csv")
        ctl$changed(ccFixture$changedCols)
        session$flushReact()
        errShownB <<- errorTabShown()
        ccShownB <<- changedColsTabShown()
      }))
    }
  )

  expect_true(errShownA)
  expect_true(ccShownA)
  expect_true(ccRemovedA)
  expect_false(errShownB)
  expect_true(ccShownB)
})

# =============================================================================
# 6. ORIP module mount gating (#49): not mounted by default; mounted for a real
#    ONPRC configuration.
# =============================================================================

test_that("appServer mounts the ORIP module only for an ONPRC configuration", {
  orip <- new.env()
  orip$mounted <- FALSE
  stubOrip <- function(id, ...) {
    orip$mounted <- TRUE
    invisible(NULL)
  }

  # Default environment: shouldShowOripTab() is FALSE -> module not mounted.
  orip$mounted <- FALSE
  testthat::with_mocked_bindings(
    modORIPReportingServer = stubOrip,
    .package = "nprcgenekeepr",
    {
      muffleConfig(shiny::testServer(appServer, {
        session$flushReact()
      }))
    }
  )
  expect_false(orip$mounted)

  # ONPRC configuration: shouldShowOripTab() mocked TRUE -> module mounted.
  orip$mounted <- FALSE
  testthat::with_mocked_bindings(
    shouldShowOripTab = function(center, hasConfigFile) TRUE,
    modORIPReportingServer = stubOrip,
    .package = "nprcgenekeepr",
    {
      muffleConfig(shiny::testServer(appServer, {
        session$flushReact()
      }))
    }
  )
  expect_true(orip$mounted)
})
