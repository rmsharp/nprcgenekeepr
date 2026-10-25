## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 5, founder statistics"
## (owner pick S1058; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 5 and section 5.2). An opt-in time budget (decision D4): it runs only
## when NPRC_RUN_PERF=true, never on CRAN, and only from the source tree, since
## it reads its input through tools/perf/harness.R, the same input the
## gvStages-synthetic10000 scenario measures (the owner chose it for Phase 5's
## gate, S1058). Wall-clock limits fail under desktop load, so the failure
## message carries the load average.
##
## calcFEFG() plus calcFGSE() on the synthetic 10,000-animal colony (generated,
## not a real studbook: 6,090 rows after the app's trim, 327 founders) at the
## app's 1,000 iterations took 2.37 s on this Mac in the scenario (S1058). The
## budget is 0.6 s, the median of 3 timed runs after one untimed run.

pkgRoot <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
harnessFile <- file.path(pkgRoot, "tools", "perf", "harness.R")

test_that("calcFEFG() and calcFGSE() on the synthetic colony take under 0.6 s", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  skip_if_not(file.exists(file.path(pkgRoot, "BACKLOG.md")),
              "not the source tree: tools/perf/ is not in a built package")
  perf <- new.env(parent = asNamespace("nprcgenekeepr"))
  sys.source(harnessFile, envir = perf)
  ped <- perf$synthetic10000(FALSE)$ped
  alleles <- perf$withSeed(20261024L, geneDrop(
    ped$id, ped$sire, ped$dam, ped$gen, n = 1000L
  ))
  both <- function() {
    calcFEFG(ped, alleles)
    calcFGSE(ped, alleles)
  }
  both()
  timings <- vapply(seq_len(3L), function(i) {
    system.time(both())[["elapsed"]]
  }, numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, 0.6, label = sprintf(
    "median of 3 runs, %.2f s (runs %s; load: %s)", med,
    toString(sprintf("%.2f", timings)), loadAverage()
  ))
})
