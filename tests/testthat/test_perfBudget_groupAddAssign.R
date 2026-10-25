## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 4, group formation"
## (owner pick S1056; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 4 and section 5.2). An opt-in time budget (decision D4): it runs only
## when NPRC_RUN_PERF=true and never on CRAN. Wall-clock limits fail under
## desktop load (test_markerKinship.R and test_markerParentageLikelihood.R skip
## on CI for that reason), so the failure message carries the load average.
##
## The input is the ratchet gate's (perf_groupAddAssign_1000_seconds,
## tools/perf/run.R groupAddAssign-1000): 6 groups and 1,000 trials on the
## tutorial's 280 candidates. Today's code took 23.0 s on it (S1052, median of
## 3) and a prototype of the new code 4.4 s in a fresh process (S1056, this
## Mac). The budget is 14 s, more than 3 times the prototype's time, as the
## median of 3 timed runs after one untimed run.

test_that("groupAddAssign() forms 6 groups in 1,000 trials on the example's 280 candidates in under 14 s", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  input <- exampleGroupInput()
  form <- function() {
    withr::with_seed(1L, groupAddAssign(input$candidates, input$kmat, input$ped,
                                        iter = 1000L, numGp = 6L))
  }
  form()
  timings <- vapply(seq_len(3L), function(i) {
    system.time(form())[["elapsed"]]
  }, numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, 14, label = sprintf(
    "median of 3 runs, %.2f s (runs %s; load: %s)", med,
    toString(sprintf("%.2f", timings)), loadAverage()
  ))
})
