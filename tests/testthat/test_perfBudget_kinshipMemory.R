## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 6, kinship memory" (owner
## pick S1059; plan docs/planning/performance-memory-campaign-plan.md, Phase 6
## and section 5.2). An opt-in memory budget (decision D4): it runs only when
## NPRC_RUN_PERF=true, never on CRAN, and only from the source tree, since it
## reads its input and its peak measure through tools/perf/harness.R, the ones
## the kinMatrix2LongForm-all scenario and its ratchet gate use. The peak is a
## high-water mark sampled at garbage collections (the harness's measure()),
## so each budget takes the median of 3 measured runs after one unmeasured run.
##
## On the example's whole kinship matrix (3,694 animals, 13.6 million cells),
## measured in one R process as a test runs (S1059): kinMatrix2LongForm()
## peaked at 1,011 to 1,035 MB with today's code and 312.5 MB with a
## prototype of the new; getAnimalsWithHighKinship() at threshold 1/64 at
## 1,129 to 1,324 MB and 380 to 398 MB. The budgets, 500 and 600 MB, pass the
## new code with 1.5 times room and fail today's by about 2 times. Memory
## peaks repeat from run to run, so they do not need the 3 times room the
## time budgets keep for desktop load.

pkgRoot <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
harnessFile <- file.path(pkgRoot, "tools", "perf", "harness.R")

## The harness, and the example as the long-form scenario reads it: the living
## animals as the population, untrimmed, with the whole pedigree's matrix.
kinshipBudgetInput <- function() {
  perf <- new.env(parent = asNamespace("nprcgenekeepr"))
  sys.source(harnessFile, envir = perf)
  ped <- perf$exampleLiving(FALSE)$ped
  list(perf = perf, ped = ped,
       kmat = kinship(ped$id, ped$sire, ped$dam, ped$gen))
}

## The median peak (MB) of 3 measured runs of `f`, after one unmeasured run.
medianPeakMb <- function(perf, f) {
  f()
  peaks <- vapply(seq_len(3L), function(i) {
    perf$measure(f())$peakMb
  }, numeric(1L))
  list(median = stats::median(peaks), peaks = peaks)
}

skipUnlessKinshipBudgets <- function() {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the budgets")
  skip_if_not(file.exists(file.path(pkgRoot, "BACKLOG.md")),
              "not the source tree: tools/perf/ is not in a built package")
}

test_that("kinMatrix2LongForm() of the example's whole matrix peaks under 500 MB", {
  skipUnlessKinshipBudgets()
  input <- kinshipBudgetInput()
  peak <- medianPeakMb(input$perf, function() kinMatrix2LongForm(input$kmat))
  expect_lt(peak$median, 500, label = sprintf(
    "median peak of 3 runs, %.1f MB (runs %s)", peak$median,
    toString(sprintf("%.1f", peak$peaks))
  ))
})

test_that("getAnimalsWithHighKinship() on the example's whole matrix peaks under 600 MB", {
  skipUnlessKinshipBudgets()
  input <- kinshipBudgetInput()
  peak <- medianPeakMb(input$perf, function() {
    getAnimalsWithHighKinship(input$kmat, input$ped, threshold = 0.015625,
                              currentGroups = character(0L),
                              ignore = list(c("F", "F")), minAge = 1)
  })
  expect_lt(peak$median, 600, label = sprintf(
    "median peak of 3 runs, %.1f MB (runs %s)", peak$median,
    toString(sprintf("%.1f", peak$peaks))
  ))
})
