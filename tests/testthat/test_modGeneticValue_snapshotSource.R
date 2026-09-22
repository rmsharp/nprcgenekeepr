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
