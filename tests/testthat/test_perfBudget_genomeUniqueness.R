## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 1, genome uniqueness"
## (owner pick S1053; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 1 and section 5.2). An opt-in time budget (decision D4): it runs only
## when NPRC_RUN_PERF=true, never on CRAN, and only from the source tree, since
## it reads its input through tools/perf/harness.R, the same input the
## perf_reportGV_example_seconds gate measures. Wall-clock limits fail under
## desktop load (test_markerKinship.R and test_markerParentageLikelihood.R skip
## on CI for that reason), so the failure message carries the load average.
##
## calcGU() plus calcGUSE() on the example as the app trims it, at the app's
## 1,000 iterations, threshold 4 and byID = TRUE, took 2.94 s on this Mac
## (docs/audits/PERF_BASELINE_2026-10-24.md). The budget is 1.0 s, the median
## of 3 timed runs after one untimed run.

pkgRoot <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
harnessFile <- file.path(pkgRoot, "tools", "perf", "harness.R")

test_that("calcGU() and calcGUSE() on the app's example take under 1 second", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  skip_if_not(file.exists(file.path(pkgRoot, "BACKLOG.md")),
              "not the source tree: tools/perf/ is not in a built package")
  perf <- new.env(parent = asNamespace("nprcgenekeepr"))
  sys.source(harnessFile, envir = perf)
  ped <- perf$exampleTrim(FALSE)$ped
  probands <- as.character(ped$id[ped$population])
  alleles <- perf$withSeed(20261024L, geneDrop(
    ped$id, ped$sire, ped$dam, ped$gen, n = 1000L
  ))
  both <- function() {
    calcGU(alleles, threshold = 4L, byID = TRUE, pop = probands)
    calcGUSE(alleles, threshold = 4L, byID = TRUE, pop = probands)
  }
  both()
  timings <- vapply(seq_len(3L), function(i) {
    system.time(both())[["elapsed"]]
  }, numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, 1.0, label = sprintf(
    "median of 3 runs, %.2f s (runs %s; load: %s)", med,
    toString(sprintf("%.2f", timings)), loadAverage()
  ))
})
