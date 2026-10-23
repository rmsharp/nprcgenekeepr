## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #167 Slice 4: modGeneticValueServer gains a new returned reactive,
# snapshotSource, so the new Genetic-Health Trends module (modSnapshotTrends,
# S760 catalog amendment -- docs/planning/issue167-longitudinal-monitoring-
# plan.md sec 4) can call createColonySnapshot() from a live analysis run
# without duplicating reportGV() (D7's "fed by the shared$geneticValues
# reactive" workflow, S760 owner decision). The captured fields are ped
# (the analyzed pedigree, post-trim, carrying its population column),
# geneticValue (the nprcgenekeeprGV object), guIter, and guThresh -- the
# EXACT values reportGV() was called with, captured atomically at run time
# (mirrors modDeidentifiedExportServer's exportRaw snapshot-params pattern,
# issue #150) so a slider changed after the run can never make the recorded
# provenance drift from what was actually analyzed (the #150 manifest
# dragon).

test_that("modGeneticValueServer's snapshotSource errors before any analysis has run", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed

  shiny::testServer(modGeneticValueServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    result <- session$getReturned()
    expect_error(result$snapshotSource(), class = "shiny.silent.error")
  })
})

test_that("modGeneticValueServer's snapshotSource carries ped/geneticValue/guIter/guThresh after a run", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed

  shiny::testServer(modGeneticValueServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(nIterations = 10, threshold = 4, runAnalysis = 1)
    gvResults() # force the eventReactive to run (mirrors test_modGeneticValue_coverage.R)

    result <- session$getReturned()
    src <- result$snapshotSource()
    expect_true(is.list(src))
    expect_true(is.data.frame(src$ped))
    expect_true("id" %in% names(src$ped))
    expect_s3_class(src$geneticValue, "nprcgenekeeprGV")
    expect_identical(src$guIter, 10L)
    expect_identical(src$guThresh, 4L)
  })
})

test_that("modGeneticValueServer's snapshotSource does not drift when sliders change after the run (mirrors the #150 manifest dragon)", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed

  shiny::testServer(modGeneticValueServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(nIterations = 10, threshold = 4, runAnalysis = 1)
    gvResults()

    ## Change the sliders WITHOUT re-running the analysis.
    session$setInputs(nIterations = 999, threshold = 9)

    result <- session$getReturned()
    src <- result$snapshotSource()
    expect_identical(src$guIter, 10L)
    expect_identical(src$guThresh, 4L)
  })
})

test_that("modGeneticValueServer's snapshotSource$ped carries the population column reportGV() actually analyzed", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed

  shiny::testServer(modGeneticValueServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    session$setInputs(nIterations = 10, threshold = 4, runAnalysis = 1)
    gvResults()

    result <- session$getReturned()
    src <- result$snapshotSource()
    expect_true("population" %in% names(src$ped))
    expect_setequal(
      src$ped$id[src$ped$population],
      as.character(src$geneticValue$report$id)
    )
  })
})

## ---------------------------------------------------------------------------
## reportArgs (S1039; issue #170, Slice 3 of docs/planning/retrospective-
## snapshot-backfill-plan.md, design B10)
## ---------------------------------------------------------------------------
##
## The Genetic-Health Trends panel that builds earlier snapshots reruns the
## analysis for past dates, and its rows must match the analysis the user just
## ran, so it needs the other settings that analysis passed to reportGV(): the
## species tables, the kinship overrides, the twin pairs and the three ranking
## cutoffs. snapshotSource gains one element, reportArgs, a named list holding
## exactly those nine values, captured with the run like guIter and guThresh
## (the #150 pattern), so a setting changed after the run cannot make the
## rebuilt rows differ from the analysis they sit beside.

reportArgNames <- c(
  "breedingTable", "gestationTable", "breedingAgeDefault",
  "gestationDefault", "kinshipOverrides", "twinRelations", "guCutoff",
  "zScoreCutoff", "axisPriority"
)

## Settings of every kind, on animals the run is certain to keep: the living
## animals of the shipped pedigree are its default population.
sourceSettings <- function(ped) {
  living <- ped$id[is.na(ped$exit)]
  list(
    overrides = list(
      breedingTable = data.frame(
        species = "RHESUS", gestation = 210L,
        minMaleBreedingAge = 7.0, minFemaleBreedingAge = 7.0,
        stringsAsFactors = FALSE
      ),
      gestationTable = data.frame(
        species = "RHESUS", gestation = 199L, stringsAsFactors = FALSE
      ),
      breedingAgeDefault = 5,
      gestationDefault = 99L
    ),
    twins = data.frame(
      id1 = living[[1L]], id2 = living[[2L]], code = "MZ twin",
      stringsAsFactors = FALSE
    ),
    overrideRows = c("id1,id2,kinship", paste(living[[3L]], living[[4L]], 0.3,
      sep = ","
    ))
  )
}

sourceFileInfo <- function(path) {
  data.frame(
    name = basename(path), size = 1L, type = "text/csv",
    datapath = path, stringsAsFactors = FALSE
  )
}

test_that("snapshotSource carries reportArgs with one element for each setting", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed

  shiny::testServer(modGeneticValueServer,
                     args = list(pedigree = shiny::reactive(ped)), {
    suppressWarnings(session$setInputs(nIterations = 10, threshold = 4, runAnalysis = 1))
    suppressWarnings(gvResults())

    src <- session$getReturned()$snapshotSource()
    expect_true(is.list(src$reportArgs))
    expect_named(src$reportArgs, reportArgNames, ignore.order = TRUE)
    ## nothing was set: the unset ones are NULL (reportGV()'s own defaults),
    ## and the axis priority is the module's default, "gu"
    expect_null(src$reportArgs$breedingTable)
    expect_null(src$reportArgs$gestationTable)
    expect_null(src$reportArgs$kinshipOverrides)
    expect_null(src$reportArgs$twinRelations)
    expect_identical(src$reportArgs$axisPriority, axisPriorityChoice())
    expect_identical(src$reportArgs$guCutoff, guCutoffChoice())
    expect_identical(src$reportArgs$zScoreCutoff, zScoreCutoffChoice())
  })
})

test_that("reportArgs holds the settings the run was given", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed
  settings <- sourceSettings(ped)
  overrideCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(overrideCsv), add = TRUE)
  writeLines(settings$overrideRows, overrideCsv)

  shiny::testServer(modGeneticValueServer,
                     args = list(
                       pedigree = shiny::reactive(ped),
                       speciesOverrides = shiny::reactive(settings$overrides),
                       twinRelations = shiny::reactive(settings$twins)
                     ), {
    suppressWarnings(session$setInputs(
      nIterations = 10, threshold = 4,
      rankScheme = "categorical", axisPriority = "mk",
      guCutoff = 12, zScoreCutoff = -1.5,
      kinshipOverrideFile = sourceFileInfo(overrideCsv),
      runAnalysis = 1
    ))
    suppressWarnings(gvResults())

    args <- session$getReturned()$snapshotSource()$reportArgs
    expect_identical(args$breedingTable, settings$overrides$breedingTable)
    expect_identical(args$gestationTable, settings$overrides$gestationTable)
    expect_identical(args$breedingAgeDefault, 5)
    expect_identical(args$gestationDefault, 99L)
    expect_identical(args$twinRelations, settings$twins)
    expect_identical(args$guCutoff, 12)
    expect_identical(args$zScoreCutoff, -1.5)
    expect_identical(args$axisPriority, "mk")
    ## the validated frame the module read, not the file path
    expect_true(is.data.frame(args$kinshipOverrides))
    expect_identical(args$kinshipOverrides, kinshipOverrideData())
    expect_equal(args$kinshipOverrides$kinship, 0.3)
  })
})

test_that("reportArgs does not drift when settings change after the run", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed
  settings <- sourceSettings(ped)
  twinPairs <- shiny::reactiveVal(settings$twins)

  shiny::testServer(modGeneticValueServer,
                     args = list(
                       pedigree = shiny::reactive(ped),
                       twinRelations = twinPairs
                     ), {
    suppressWarnings(session$setInputs(
      nIterations = 10, threshold = 4, axisPriority = "gu", guCutoff = 10,
      runAnalysis = 1
    ))
    suppressWarnings(gvResults())

    ## change every setting WITHOUT re-running the analysis
    twinPairs(NULL)
    session$setInputs(axisPriority = "mk", guCutoff = 99, zScoreCutoff = -9)

    args <- session$getReturned()$snapshotSource()$reportArgs
    expect_identical(args$twinRelations, settings$twins)
    expect_identical(args$axisPriority, "gu")
    expect_identical(args$guCutoff, 10)
  })
})

test_that("a second run replaces reportArgs together with the rest of the source", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::qcPed
  settings <- sourceSettings(ped)
  twinPairs <- shiny::reactiveVal(NULL)

  shiny::testServer(modGeneticValueServer,
                     args = list(
                       pedigree = shiny::reactive(ped),
                       twinRelations = twinPairs
                     ), {
    suppressWarnings(session$setInputs(nIterations = 10, threshold = 4, runAnalysis = 1))
    suppressWarnings(gvResults())
    expect_null(session$getReturned()$snapshotSource()$reportArgs$twinRelations)

    twinPairs(settings$twins)
    suppressWarnings(session$setInputs(runAnalysis = 2))
    suppressWarnings(gvResults())
    src <- session$getReturned()$snapshotSource()
    expect_identical(src$reportArgs$twinRelations, settings$twins)
    expect_identical(src$guIter, 10L)
  })
})
