## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 3, the relationship
## table" (owner pick S1055; plan docs/planning/performance-memory-campaign-
## plan.md, Phase 3 and section 5.2). An opt-in time budget (decision D4): it
## runs only when NPRC_RUN_PERF=true and never on CRAN. Wall-clock limits fail
## under desktop load (test_markerKinship.R and test_markerParentageLikelihood.R
## skip on CI for that reason), so the failure message carries the load
## average.
##
## The input is the ratchet gate's (perf_convertRelationships_300_seconds,
## tools/perf/run.R convertRelationships-300): the example's first 300 animals
## as the app's Summary Statistics sees them (45,150 pairs). Today's code took
## 6.4 s on it and a vector prototype 0.076 s, median of 3 warm runs (S1055,
## this Mac). The budget is 0.5 s, more than 3 times the prototype's time, as
## the median of 3 timed runs after one untimed run.

test_that("convertRelationships() on the example's first 300 animals takes under 0.5 s", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  input <- exampleRelationsInput(300L)
  convert <- function() convertRelationships(input$kmat, input$ped)
  convert()
  timings <- vapply(seq_len(3L), function(i) {
    system.time(convert())[["elapsed"]]
  }, numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, 0.5, label = sprintf(
    "median of 3 runs, %.2f s (runs %s; load: %s)", med,
    toString(sprintf("%.2f", timings)), loadAverage()
  ))
})
