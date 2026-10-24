## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 2, the gene drop" (owner
## pick S1054; plan docs/planning/performance-memory-campaign-plan.md, Phase 2
## and section 5.2). An opt-in time budget (decision D4): it runs only when
## NPRC_RUN_PERF=true, never on CRAN, and only from the source tree, since it
## reads its input through tools/perf/harness.R. Wall-clock limits fail under
## desktop load (test_markerKinship.R and test_markerParentageLikelihood.R skip
## on CI for that reason), so the failure message carries the load average.
##
## The input is the plan's synthetic 10,000-animal colony (synthetic, not a
## real studbook: tools/perf/harness.R synthColony(), 6,090 animals after the
## app's QC and trim). geneDrop() on it at 1,000 iterations took 4.5 s on this
## Mac before Phase 2, and a fast version 0.78 s (S1054). The budget is 2.4 s,
## at least 3 times the fast version's time, as the median of 3 timed runs
## after one untimed run. The synthetic colony separates the two more clearly
## than the example's 3,694 animals (1.87 s against 0.43 s).

pkgRoot <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
harnessFile <- file.path(pkgRoot, "tools", "perf", "harness.R")

test_that("geneDrop() on the synthetic 10,000-animal colony takes under 2.4 s", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  skip_if_not(file.exists(file.path(pkgRoot, "BACKLOG.md")),
              "not the source tree: tools/perf/ is not in a built package")
  perf <- new.env(parent = asNamespace("nprcgenekeepr"))
  sys.source(harnessFile, envir = perf)
  ped <- perf$synthetic10000(FALSE)$ped
  drop <- function() {
    perf$withSeed(20261024L, geneDrop(
      ped$id, ped$sire, ped$dam, ped$gen, n = 1000L
    ))
  }
  drop()
  timings <- vapply(seq_len(3L), function(i) {
    system.time(drop())[["elapsed"]]
  }, numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, 2.4, label = sprintf(
    "median of 3 runs, %.2f s (runs %s; load: %s)", med,
    toString(sprintf("%.2f", timings)), loadAverage()
  ))
})
