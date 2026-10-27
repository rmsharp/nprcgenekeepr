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

## Harem trials (BACKLOG.md "Breeding Groups: harem trials redo their set-up
## work every trial", owner pick S1072): the same 280 candidates in 6 harems.
## Today's code took 9.03 s on it in one process (S1072, median of 3; 10.69 s
## in a fresh process, S1066) and a prototype that builds the harem set-up
## once per call 4.17 s. The budget is 13 s, more than 3 times the
## prototype's time (plan section 5.2). Today's code passes it too, so the
## ratchet gate perf_groupAddAssign_harem_1000_seconds is the closer check.
test_that("groupAddAssign() forms 6 harems in 1,000 trials on the example's 280 candidates in under 13 s", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  input <- exampleGroupInput()
  form <- function() {
    withr::with_seed(1L, groupAddAssign(input$candidates, input$kmat, input$ped,
                                        iter = 1000L, numGp = 6L,
                                        harem = TRUE))
  }
  form()
  timings <- vapply(seq_len(3L), function(i) {
    system.time(form())[["elapsed"]]
  }, numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, 13, label = sprintf(
    "median of 3 runs, %.2f s (runs %s; load: %s)", med,
    toString(sprintf("%.2f", timings)), loadAverage()
  ))
})
