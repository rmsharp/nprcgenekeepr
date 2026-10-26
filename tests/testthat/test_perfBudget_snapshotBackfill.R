## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 10, snapshot backfill
## and convergence: follow-through" (owner pick S1065; plan
## docs/planning/performance-memory-campaign-plan.md, Phase 10 and section
## 5.2). An opt-in time budget (decision D4): it runs only when
## NPRC_RUN_PERF=true, never on CRAN, and only from the source tree, since it
## reads its inputs through tools/perf/harness.R, the same inputs the
## backfill-jmac and gvaConvergence-example scenarios measure. Wall-clock
## limits fail under desktop load (test_markerKinship.R and
## test_markerParentageLikelihood.R skip on CI for that reason), so the
## failure message carries the load average.
##
## Phase 10 changed none of the timed code: Phases 1, 2 and 5 made these calls
## faster. Measured S1065 on this Mac the way this file times them (median of
## 3 runs after one untimed run, load average about 9): the backfill 0.61 s
## and the convergence check 0.49 s, against 9.42 s and 4.73 s in
## docs/audits/PERF_BASELINE_2026-10-24.md. The budget is 2 s for each, more
## than 3 times today's time and far under the baseline's (owner ruling S1065,
## "Add one").

pkgRoot <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
harnessFile <- file.path(pkgRoot, "tools", "perf", "harness.R")

## The median of 3 timed runs of `run`, after one untimed run, as an
## expectation that it is under `budget` seconds.
expectMedianUnder <- function(run, budget) {
  run()
  timings <- vapply(seq_len(3L), function(i) {
    system.time(run())[["elapsed"]]
  }, numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, budget, label = sprintf(
    "median of 3 runs, %.2f s (runs %s; load: %s)", med,
    toString(sprintf("%.2f", timings)), loadAverage()
  ))
}

perfHarness <- function() {
  perf <- new.env(parent = asNamespace("nprcgenekeepr"))
  sys.source(harnessFile, envir = perf)
  perf
}

test_that("Build Earlier Snapshots on jmac, 3 dates at 1,000 iterations, takes under 2 seconds", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  skip_if_not(file.exists(file.path(pkgRoot, "BACKLOG.md")),
              "not the source tree: tools/perf/ is not in a built package")
  perf <- perfHarness()
  ped <- perf$jmac(FALSE)$ped
  dates <- as.Date(c("2000-01-01", "2010-01-01", "2018-07-01"))
  expectMedianUnder(function() {
    perf$withSeed(3L, suppressWarnings(
      backfillColonySnapshots(ped, dates = dates, guIter = 1000L,
                              guThresh = 4L)
    ))
  }, 2.0)
})

test_that("gvaConvergence(nMax = 3000) on the app's example takes under 2 seconds", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  skip_if_not(file.exists(file.path(pkgRoot, "BACKLOG.md")),
              "not the source tree: tools/perf/ is not in a built package")
  perf <- perfHarness()
  ped <- perf$exampleTrim(FALSE)$ped
  expectMedianUnder(function() {
    perf$withSeed(5L, gvaConvergence(ped, nMax = 3000L, guThresh = 4L))
  }, 2.0)
})
