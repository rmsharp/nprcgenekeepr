## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 0, the measuring harness"
## (owner pick S1052; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 0 and Appendix A). Every later phase of the campaign claims a speed-up
## or a smaller memory peak, and each claim is only as good as the tool that
## measured it. tools/perf/harness.R is that tool; `Rscript tools/perf/run.R
## <scenario>` runs one measurement and prints SECONDS= and PEAK_MB= for the
## ratchet gates in methodology/.quality-gates.json.
##
## These tests check the tool, not the package's speed: a timed number is only
## checked to be a non-negative number, never against a budget (the budgets are
## opt-in tests and ratchet gates, plan decision D4). Each of the 20 scenarios
## (one per row of the plan's section 3) runs here on a small stand-in input,
## labelled "quick", so this file stays fast; the full-size runs are the
## baseline doc's job.
##
## tools/ sits outside a built package (.Rbuildignore), so these blocks skip
## there and run from the source tree.

pkgRoot <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
harnessFile <- file.path(pkgRoot, "tools", "perf", "harness.R")
runFile <- file.path(pkgRoot, "tools", "perf", "run.R")

## skipUnlessSourceTree() is in helper-perfCampaign.R.

## The harness's functions, in an environment that sees the package's own
## functions (exported or not), as run.R gives them after pkgload::load_all().
loadPerfHarness <- function() {
  skipUnlessSourceTree()
  perf <- new.env(parent = asNamespace("nprcgenekeepr"))
  sys.source(harnessFile, envir = perf)
  perf
}

## One row of the plan's section 3 each, in its order.
sectionThreeScenarios <- c(
  "reportGV-example",
  "gvStages-example", "gvStages-all", "gvStages-synthetic10000",
  "convertRelationships-150", "convertRelationships-300",
  "convertRelationships-600",
  "kinMatrix2LongForm-all", "kinMatrix2LongForm-all-removeDups",
  "groupAddAssign-10", "groupAddAssign-1000",
  "groupAddAssign-harem-10", "groupAddAssign-harem-1000",
  "diagram-rhesus-direct", "diagram-rhesus-rectilinear",
  "diagram-example-direct",
  "backfill-jmac", "gvaConvergence-example",
  "kinshipSparse-example", "kinshipSparse-all"
)
scenarioColumns <- c("scenario", "input", "label", "seconds", "peakMb",
                     "resultMb")

## A gc() result in the shape R 4.6 prints, with a "limit (Mb)" column before
## "max used", or in the older shape without it. The memory numbers are the
## same in both, so a reader that finds "max used" by position gets one wrong.
fakeGc <- function(withLimit) {
  cols <- list(used = c(1e6, 2e6), `(Mb)` = c(53.5, 15.3),
               `gc trigger` = c(2e6, 8e6), `(Mb)` = c(107, 61.1),
               `limit (Mb)` = c(NA, 16384), `max used` = c(1.5e6, 3e6),
               `(Mb)` = c(80.2, 22.9))
  if (!withLimit) cols <- cols[names(cols) != "limit (Mb)"]
  matrix(unlist(cols), nrow = 2L,
         dimnames = list(c("Ncells", "Vcells"), names(cols)))
}

test_that("the source tree holds the harness and its runner", {
  skipUnlessSourceTree()
  expect_true(file.exists(harnessFile))
  expect_true(file.exists(runFile))
})

test_that("tools/ is kept out of the built package", {
  skipUnlessSourceTree()
  ignored <- readLines(file.path(pkgRoot, ".Rbuildignore"), warn = FALSE)
  expect_true("^tools$" %in% ignored)
})

test_that("the memory reader finds 'max used' by name in both gc() shapes", {
  perf <- loadPerfHarness()
  expect_equal(perf$maxUsedMb(fakeGc(withLimit = TRUE)), 103.1)
  expect_equal(perf$maxUsedMb(fakeGc(withLimit = FALSE)), 103.1)
  expect_equal(perf$usedMb(fakeGc(withLimit = TRUE)), 68.8)
  expect_equal(perf$usedMb(fakeGc(withLimit = FALSE)), 68.8)
})

test_that("the memory reader stops when gc() has no 'max used' column", {
  perf <- loadPerfHarness()
  noMax <- fakeGc(withLimit = FALSE)[, 1:4]
  expect_error(perf$maxUsedMb(noMax), "max used")
})

test_that("on a real gc() result the peak is at least the memory in use", {
  perf <- loadPerfHarness()
  g <- gc()
  expect_gte(perf$maxUsedMb(g), perf$usedMb(g))
})

test_that("measure() returns time, peak memory, result size and the value", {
  perf <- loadPerfHarness()
  m <- perf$measure(rev(seq_len(1e5)))
  expect_named(m, c("seconds", "peakMb", "resultMb", "value"))
  for (field in c("seconds", "peakMb", "resultMb")) {
    expect_true(is.numeric(m[[field]]) && length(m[[field]]) == 1L,
                info = field)
    expect_true(is.finite(m[[field]]) && m[[field]] >= 0, info = field)
  }
  ## 100,000 integers take about 0.38 MB, so a zero here means the result
  ## was never sized.
  expect_gt(m$resultMb, 0.3)
  expect_identical(m$value, rev(seq_len(1e5)))
})

test_that("measure() runs its expression once, inside the timed window", {
  perf <- loadPerfHarness()
  calls <- 0L
  m <- perf$measure({
    calls <- calls + 1L
    Sys.sleep(0.05)
    calls
  })
  expect_identical(calls, 1L)
  expect_identical(m$value, 1L)
  expect_gte(m$seconds, 0.04)
})

test_that("measure() lets an error in its expression through", {
  perf <- loadPerfHarness()
  expect_error(perf$measure(stop("harness probe failure")),
               "harness probe failure")
})

test_that("synthColony() gives one colony per seed, in the studbook's shape", {
  perf <- loadPerfHarness()
  first <- perf$synthColony(500, seed = 1)
  expect_identical(perf$synthColony(500, seed = 1), first)
  expect_false(identical(perf$synthColony(500, seed = 2), first))
  expect_named(first, c("id", "sire", "dam", "sex", "birth", "exit"))
  expect_identical(nrow(first), 500L)
  expect_false(anyDuplicated(first$id) > 0L)
  expect_s3_class(first$birth, "Date")
  expect_s3_class(first$exit, "Date")
})

test_that("synthColony() passes the package's QC with no errors", {
  perf <- loadPerfHarness()
  colony <- perf$synthColony(500, seed = 1)
  expect_null(qcStudbook(colony, reportErrors = TRUE))
})

test_that("synthColony() leaves the caller's random numbers as they were", {
  perf <- loadPerfHarness()
  withr::local_seed(42)
  before <- get(".Random.seed", envir = globalenv())
  perf$synthColony(100, seed = 1)
  expect_identical(get(".Random.seed", envir = globalenv()), before)
})

test_that("synthColony() stops with a plain message below 21 animals", {
  perf <- loadPerfHarness()
  ## 20 founders are the floor, so 21 is the smallest colony with an offspring.
  expect_identical(nrow(perf$synthColony(21, seed = 1)), 21L)
  expect_error(perf$synthColony(20, seed = 1), "at least 21")
  expect_error(perf$synthColony(NA, seed = 1), "at least 21")
  expect_error(perf$synthColony(100.5, seed = 1), "at least 21")
})

test_that("appAnalysisPed() gives the app's analysis pedigree for the example", {
  perf <- loadPerfHarness()
  ## The plan's section 2: the app's path trims the example to 708 rows with
  ## the 332 living animals as the population.
  trimmed <- perf$appAnalysisPed(examplePedigree)
  expect_identical(nrow(trimmed), 708L)
  expect_identical(sum(trimmed$population), 332L)
  untrimmed <- perf$appAnalysisPed(examplePedigree, trim = FALSE)
  expect_identical(nrow(untrimmed), 3694L)
  expect_true(all(trimmed$id %in% untrimmed$id))
  ## "example (all 3694)": the same pedigree, untrimmed, every animal in the
  ## population.
  everyone <- perf$appAnalysisPed(examplePedigree, trim = FALSE,
                                  everyone = TRUE)
  expect_identical(nrow(everyone), 3694L)
  expect_true(all(everyone$population))
})

test_that("there is one scenario for each row of the plan's section 3", {
  perf <- loadPerfHarness()
  expect_identical(perf$scenarioNames(), sectionThreeScenarios)
})

test_that("every scenario runs on its small stand-in input", {
  perf <- loadPerfHarness()
  for (name in perf$scenarioNames()) {
    rows <- perf$runScenario(name, quick = TRUE)
    expect_s3_class(rows, "data.frame")
    expect_identical(names(rows), scenarioColumns, info = name)
    expect_gte(nrow(rows), 1L)
    expect_true(all(rows$scenario == name), info = name)
    ## A quick run must never be mistaken for a baseline.
    expect_true(all(grepl("quick", rows$input, fixed = TRUE)), info = name)
    for (field in c("seconds", "peakMb", "resultMb")) {
      expect_true(all(is.finite(rows[[field]]) & rows[[field]] >= 0),
                  info = paste(name, field))
    }
  }
})

test_that("runScenario() names the known scenarios when given an unknown one", {
  perf <- loadPerfHarness()
  expect_error(perf$runScenario("noSuchScenario"), "noSuchScenario")
  expect_error(perf$runScenario("noSuchScenario"), "reportGV-example")
})

test_that("a scenario's headline is its total time and its highest peak", {
  perf <- loadPerfHarness()
  rows <- data.frame(scenario = "s", input = "i", label = c("a", "b"),
                     seconds = c(1.5, 2), peakMb = c(10, 30),
                     resultMb = c(1, 2))
  expect_identical(perf$headline(rows), c(seconds = 3.5, peakMb = 30))
})

## Expects exactly one "<key>=<number>" line in `lines`, the line a gate's
## `extract` reads.
expectOneNumberLine <- function(lines, key) {
  pattern <- sprintf("^%s=[0-9]+(\\.[0-9]+)?$", key)
  expect_identical(sum(grepl(pattern, lines)), 1L,
                   label = sprintf("the number of %s= lines", key))
}

## The output of `Rscript tools/perf/run.R <args>`, run from the project root
## as a gate's command runs (quality_ratchet.py); skips outside the source tree
## or without Rscript.
runFromCommandLine <- function(args) {
  skipUnlessSourceTree()
  rscript <- file.path(R.home("bin"), "Rscript")
  skip_if_not(file.exists(rscript), "Rscript is not installed")
  withr::with_dir(pkgRoot, suppressWarnings(
    system2(rscript, c(runFile, args), stdout = TRUE, stderr = TRUE)))
}

test_that("runMain() prints SECONDS= and PEAK_MB= for a scenario", {
  perf <- loadPerfHarness()
  res <- perf$runMain(c("reportGV-example", "--quick"))
  expect_identical(res$status, 0L)
  expectOneNumberLine(res$lines, "SECONDS")
  expectOneNumberLine(res$lines, "PEAK_MB")
})

test_that("runMain() fails and lists the scenarios for a wrong or no name", {
  perf <- loadPerfHarness()
  wrong <- perf$runMain("noSuchScenario")
  expect_false(identical(wrong$status, 0L))
  expect_true(any(grepl("reportGV-example", wrong$lines, fixed = TRUE)))
  none <- perf$runMain(character())
  expect_false(identical(none$status, 0L))
  expect_true(any(grepl("Usage", none$lines, fixed = TRUE)))
  expect_true(any(grepl("reportGV-example", none$lines, fixed = TRUE)))
})

test_that("run.R runs a scenario from the command line, as a gate does", {
  out <- runFromCommandLine(c("reportGV-example", "--quick"))
  expect_null(attr(out, "status"))
  expectOneNumberLine(out, "SECONDS")
  expectOneNumberLine(out, "PEAK_MB")
})

## ---- --runs N: the middle of N runs (S1078) --------------------------------
## A single run of reportGV-example read 0.21-0.23 s or 0.30-0.33 s, depending
## on whether one full garbage collection (0.09-0.12 s) fell inside it, and
## trivial differences decide that (the folder's path, one extra line in the
## script). The middle of 5 runs in one process read 0.17-0.18 s in every
## folder tried, so the perf_reportGV_example_seconds gate reads that (owner
## ruling S1078, "Middle of 5 runs").

## A stand-in for runScenario() that records its calls and returns one row
## per call, its seconds and peak taken in turn from `seconds` and `peakMb`.
recordingScenario <- function(seconds, peakMb) {
  calls <- 0L
  run <- function(name, quick = FALSE) {
    calls <<- calls + 1L
    data.frame(scenario = name, input = "i", label = "a",
               seconds = seconds[[calls]], peakMb = peakMb[[calls]],
               resultMb = 1, stringsAsFactors = FALSE)
  }
  list(run = run, calls = function() calls)
}

test_that("runMain() with --runs N runs the scenario N times, prints the middle", {
  perf <- loadPerfHarness()
  stand <- recordingScenario(seconds = c(0.31, 0.46, 0.18, 0.17, 0.18),
                             peakMb = c(70, 90, 60, 50, 55))
  perf$runScenario <- stand$run
  res <- perf$runMain(c("reportGV-example", "--runs", "5"))
  expect_identical(res$status, 0L)
  expect_identical(stand$calls(), 5L)
  expect_identical(grep("^SECONDS=", res$lines, value = TRUE), "SECONDS=0.18")
  expect_identical(grep("^PEAK_MB=", res$lines, value = TRUE), "PEAK_MB=60.0")
  ## The flag may come before the name, and --quick still applies.
  stand <- recordingScenario(seconds = c(0.4, 0.2, 0.3), peakMb = c(1, 3, 2))
  perf$runScenario <- stand$run
  res <- perf$runMain(c("--runs", "3", "--quick", "reportGV-example"))
  expect_identical(res$status, 0L)
  expect_identical(stand$calls(), 3L)
  expect_identical(grep("^SECONDS=", res$lines, value = TRUE), "SECONDS=0.30")
  ## Without --runs the scenario runs once, as before.
  stand <- recordingScenario(seconds = 0.31, peakMb = 70)
  perf$runScenario <- stand$run
  res <- perf$runMain("reportGV-example")
  expect_identical(stand$calls(), 1L)
  expect_identical(grep("^SECONDS=", res$lines, value = TRUE), "SECONDS=0.31")
})

test_that("runMain() refuses a --runs value that is not a whole number above 0", {
  perf <- loadPerfHarness()
  stand <- recordingScenario(seconds = 0.1, peakMb = 1)
  perf$runScenario <- stand$run
  for (bad in list("0", "-1", "2.5", "abc", character())) {
    res <- perf$runMain(c("reportGV-example", "--runs", bad))
    label <- if (length(bad)) bad else "no value"
    expect_identical(res$status, 2L, info = label)
    expect_true(any(grepl("Usage", res$lines, fixed = TRUE)), info = label)
    expect_true(any(grepl("--runs", res$lines, fixed = TRUE)), info = label)
  }
  expect_identical(stand$calls(), 0L)
})

test_that("run.R passes --runs through from the command line", {
  out <- runFromCommandLine(c("reportGV-example", "--quick", "--runs", "2"))
  expect_null(attr(out, "status"))
  expect_identical(sum(grepl("reportGV (n = 10)", out, fixed = TRUE)), 2L)
  expectOneNumberLine(out, "SECONDS")
})

## The command of one gate in methodology/.quality-gates.json, read as text
## (jsonlite is not a dependency): the "command" line of the gate's block.
gateCommand <- function(gate) {
  manifest <- readLines(file.path(pkgRoot, "methodology",
                                  ".quality-gates.json"))
  start <- grep(sprintf('"name": "%s"', gate), manifest, fixed = TRUE)
  expect_length(start, 1L)
  block <- manifest[start:length(manifest)]
  block <- block[seq_len(grep("^\\s*}", block)[[1L]])]
  line <- grep('^\\s*"command": ', block, value = TRUE)
  expect_length(line, 1L)
  sub('^\\s*"command": "(.*)",?\\s*$', "\\1", line)
}

test_that("the reportGV gate times the middle of 5 runs", {
  skipUnlessSourceTree()
  expect_identical(gateCommand("perf_reportGV_example_seconds"),
                   "Rscript tools/perf/run.R reportGV-example --runs 5")
})
