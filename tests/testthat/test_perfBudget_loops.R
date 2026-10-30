## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Prepare the 3.0.0 CRAN submission", plan Phase 2 (owner pick
## S1095, "Example+loops+skip 315"; docs/planning/cran-3.0.0-submission-plan.md
## section 3.4). An opt-in time budget, as the performance campaign's are
## (its decision D4): it runs only when NPRC_RUN_PERF=true and never on CRAN.
## Wall-clock limits fail under desktop load, so the failure message carries
## the load average.
##
## Four help examples and two tutorial chunks run findLoops() and countLoops()
## on the shipped example (3,694 animals); on win-builder those four examples
## took 19.9 s (S1094). Today's code took 1.01 s and 1.31 s, a prototype that
## looks each animal up once 0.37 s and 0.50 s (S1095, this Mac, load about 7).
## The budget is 1.4 s for the two together, the median of 3 timed runs after
## one untimed run: 1.6 times the prototype's 0.87 s, and today's 2.3 s fails.

test_that("findLoops() then countLoops() on the example take under 1.4 s", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  ptree <- createPedTree(nprcgenekeepr::examplePedigree)
  loops <- function() countLoops(findLoops(ptree), ptree)
  loops()
  timings <- vapply(seq_len(3L), function(i) {
    system.time(loops())[["elapsed"]]
  }, numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, 1.4, label = sprintf(
    "median of 3 runs, %.2f s (runs %s; load: %s)", med,
    toString(sprintf("%.2f", timings)), loadAverage()
  ))
})
