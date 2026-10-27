## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 7, the diagram's solver"
## (owner pick S1060; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 7 and section 5.2). An opt-in time budget (decision D4): it runs only
## when NPRC_RUN_PERF=true, never on CRAN, and only from the source tree, since
## it reads its input through tools/perf/harness.R, the example as the app
## trims it (708 animals), the input of the diagram-example-direct scenario and
## its ratchet gate. Wall-clock limits fail under desktop load, so the failure
## message carries the load average.
##
## The budget times the solve inside the example's diagram: the seconds spent
## in quadprog's solver, either routine, while makePedigreeMatingLayout()
## draws it (one solve over 1,489 nodes). Measured S1060: 11.3 s with today's
## dense solve.QP(), 3.0 s with a prototype of the compact one. The budget,
## 9 s for the median of 3 timed runs, keeps 3 times room over the new time
## and fails today's code. The whole diagram (13.2 s today, 4.8 s new) cannot
## do both, so it is timed by the ratchet gate
## (perf_diagram_example_direct_seconds), not here (owner ruling S1060).

pkgRoot <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
harnessFile <- file.path(pkgRoot, "tools", "perf", "harness.R")

skipUnlessDiagramBudget <- function() {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true to run the time budgets")
  skip_if_not(file.exists(file.path(pkgRoot, "BACKLOG.md")),
              "not the source tree: tools/perf/ is not in a built package")
}

## The example as the app trims it, read the way the harness reads it.
diagramBudgetPed <- function() {
  perf <- new.env(parent = asNamespace("nprcgenekeepr"))
  sys.source(harnessFile, envir = perf)
  perf$exampleTrim(FALSE)$ped
}

## The seconds spent inside quadprog's two solvers while `code` runs.
solverSeconds <- function(code) {
  seconds <- 0.0
  timed <- function(solver) {
    force(solver)
    function(...) {
      start <- proc.time()[["elapsed"]]
      on.exit(seconds <<- seconds + proc.time()[["elapsed"]] - start)
      solver(...)
    }
  }
  testthat::with_mocked_bindings(
    code,
    solve.QP = timed(quadprog::solve.QP),
    solve.QP.compact = timed(quadprog::solve.QP.compact),
    .package = "quadprog"
  )
  seconds
}

test_that("the solve inside the example's diagram takes under 9 s", {
  skipUnlessDiagramBudget()
  ped <- diagramBudgetPed()
  draw <- function() {
    suppressMessages(suppressWarnings(
      makePedigreeMatingLayout(ped, edgeStyle = "direct")
    ))
  }
  timings <- vapply(seq_len(3L), function(i) solverSeconds(draw()),
                    numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, 9.0, label = sprintf(
    "median of 3 runs, %.2f s (runs %s; load: %s)", med,
    toString(sprintf("%.2f", timings)), loadAverage()
  ))
})

test_that("the example's solver positions are today's", {
  skipUnlessDiagramBudget()
  calls <- diagramSolverCalls(diagramBudgetPed())
  expect_length(calls, 1L)
  for (i in seq_along(calls)) {
    expect_identical(outcome(.solveJointQP, calls[[i]]),
                     outcome(solveJointQPReference, calls[[i]]),
                     info = paste("call", i))
  }
})

## BACKLOG.md "Pedigree Diagram: about 1.7 s of the 708-animal layout is
## outside its solver" (owner pick S1073): the penalty table's product with
## itself, worked out by blocks where that is exact (.penaltyCrossprod(),
## test_diagramSolverEquivalence.R). Measured S1073 on the example's table
## (1,480 rows, 1,489 columns) with R's own math library: 1.07 s whole, 0.04 s
## by blocks (a prototype). The budget, 0.3 s for the median of 3 timed runs
## after one untimed run (which also makes the once-a-session check), fails
## today's whole multiplication and keeps about 7 times room over the new
## time. With a library that does the whole product fast (OpenBLAS) the table
## is multiplied whole and the budget holds as well.
test_that("the penalty product inside the example's diagram takes under 0.3 s", {
  skipUnlessDiagramBudget()
  pmat <- penaltyMatrixOf(diagramSolverCalls(diagramBudgetPed())[[1L]])
  invisible(.penaltyCrossprod(pmat))
  timings <- vapply(seq_len(3L), function(i) {
    system.time(.penaltyCrossprod(pmat))[["elapsed"]]
  }, numeric(1L))
  med <- stats::median(timings)
  expect_lt(med, 0.3, label = sprintf(
    "median of 3 runs, %.3f s (runs %s; load: %s)", med,
    toString(sprintf("%.3f", timings)), loadAverage()
  ))
})
