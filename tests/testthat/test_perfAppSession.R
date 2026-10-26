## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 9, the app's memory:
## implementation, session 9a" (owner pick S1063; design
## docs/planning/app-kinship-memory-design.md section 8, owner ruling F6,
## S1062). The scripted app session that measured the app's memory step by
## step (docs/audits/PERF_BASELINE_2026-10-24.md Appendix A, extended by the
## design's Appendix A with the Genetic Diversity, Mate Pair and Marker
## Genetics steps and a kinship() trace) joins tools/perf/, so that Phase 9's
## "before" and "after" tables come from the same committed tool.
##
## The tool drives the running app in Chrome, so it is not a ratchet gate and
## these tests never run it (design section 8): they check that its three
## files parse and that it lists the design's steps in the order of the
## design's section 2.1 table. tools/ sits outside a built package
## (.Rbuildignore), so these blocks skip there and run from the source tree.

pkgRoot <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
appSessionFiles <- c(
  steps = file.path(pkgRoot, "tools", "perf", "appSession.R"),
  runner = file.path(pkgRoot, "tools", "perf", "runAppSession.R"),
  app = file.path(pkgRoot, "tools", "perf", "appSession", "app.R")
)

## skipUnlessSourceTree() is in helper-perfCampaign.R.

## The design's section 2.1 table, one row per step, in its order.
appSessionStepNames <- c(
  "app started",
  "upload + QC",
  "open Genetic Diversity (no groups)",
  "Genetic Value run (1,000 iterations)",
  "open Summary Statistics",
  "Breeding Groups: Form Groups (defaults)",
  "open Genetic Diversity (groups formed)",
  "Mate Pair: Find Eligible Pairs (defaults)",
  "open Marker Genetics",
  "open its Linkage and LD Block Metrics tab"
)

test_that("the app session's three files exist and parse", {
  skipUnlessSourceTree()
  for (f in appSessionFiles) {
    expect_true(file.exists(f), info = f)
    expect_no_error(parse(file = f))
  }
})

test_that("the app session lists the design's ten steps, in order", {
  skipUnlessSourceTree()
  steps <- new.env()
  sys.source(appSessionFiles[["steps"]], envir = steps)
  expect_identical(names(steps$appSessionSteps), appSessionStepNames)
  expect_true(all(vapply(steps$appSessionSteps, is.function, logical(1L))))
})
