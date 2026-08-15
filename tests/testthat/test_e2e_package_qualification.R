## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Guards the opt-in E2E tier (test-{app,e2e}-*.R) against BARE calls to this
## package's own exported functions.
##
## Why this can't be caught any other way: .github/workflows/shinytest2.yaml
## does NOT run the tier through tests/testthat.R -- it spawns one
## `Rscript -e 'testthat::test_dir("tests/testthat", filter = ...)'` per module
## group. tests/testthat.R is the only thing that calls library(nprcgenekeepr),
## and test_dir() does not attach the package under test, so in that process a
## bare `someExportedFunction()` resolves to nothing:
##
##   $ Rscript -e 'exists("makeExamplePedigreeFile")'
##   FALSE
##
## Every LOCAL verification path this project documents (CLAUDE.md's fast
## single-file recipe, its clean-regression read, devtools::test()) starts with
## pkgload::load_all(), which DOES attach the package -- so the bare call passes
## locally and every one of them, and fails only in the nightly E2E job, which
## is not a per-PR gate. That is exactly the drift shape
## test_shinytest2_workflow_coverage.R exists to catch for the group-regex
## partition; this file catches it for package qualification.
##
## Concrete case that surfaced it (Session 584): issue #151 Slice 2 shipped
## test-e2e-mate-pair-analysis-module.R with a bare
## makeExamplePedigreeFile() at line 58. The scheduled shinytest2 run went red
## the night it landed and stayed red for 3 consecutive days before anyone
## looked. See PROJECT_LEARNINGS.md.
##
## The fix for a hit is always the same: qualify the call as
## nprcgenekeepr::theFunction(). All other files in the tier already comply.

e2e_tier_files <- function() {
  list.files(
    testthat::test_path(),
    pattern = "^test-(app|e2e)-.*\\.R$",
    full.names = TRUE
  )
}

## Every name called as `name(...)` in the file. A `::`-qualified call is a call
## to `::` itself -- its function slot is not a name -- so nprcgenekeepr::foo()
## is correctly never collected here.
called_names <- function(path) {
  found <- character()
  walk <- function(x) {
    if (is.call(x) && is.name(x[[1L]])) {
      found <<- c(found, as.character(x[[1L]]))
    }
    if (is.recursive(x)) {
      ## An empty argument slot (e.g. `x[, 1]`) is the missing symbol, which
      ## errors on any use -- try() absorbs it.
      for (i in seq_along(x)) try(walk(x[[i]]), silent = TRUE)
    }
  }
  exprs <- parse(path)
  for (i in seq_along(exprs)) walk(exprs[[i]])
  unique(found)
}

## Top-level `name <- ...` / `name = ...` / `name <<- ...` bindings the file
## makes for itself (e.g. makeMatePairE2eGenotypeFile).
self_defined_names <- function(path) {
  exprs <- parse(path)
  out <- character()
  for (i in seq_along(exprs)) {
    x <- exprs[[i]]
    if (is.call(x) && length(x) >= 3L && is.name(x[[1L]]) &&
        as.character(x[[1L]]) %in% c("<-", "=", "<<-") && is.name(x[[2L]])) {
      out <- c(out, as.character(x[[2L]]))
    }
  }
  out
}

## Names the tier gets for free from helper-*.R / setup.R, which testthat
## sources before the test files in BOTH environments.
helper_defined_names <- function() {
  helpers <- list.files(
    testthat::test_path(),
    pattern = "^(helper|setup).*\\.R$",
    full.names = TRUE
  )
  env <- new.env(parent = emptyenv())
  for (h in helpers) try(sys.source(h, envir = env), silent = TRUE)
  ls(env, all.names = TRUE)
}

test_that("no E2E-tier test file calls a package export without nprcgenekeepr::", {
  files <- e2e_tier_files()
  expect_true(
    length(files) > 0,
    info = "no test-{app,e2e}-*.R files found under tests/testthat"
  )

  exports <- getNamespaceExports("nprcgenekeepr")
  expect_true(
    length(exports) > 0,
    info = "getNamespaceExports() returned nothing -- guard cannot evaluate"
  )

  helpers <- helper_defined_names()

  offenders <- character()
  for (path in files) {
    bare <- setdiff(
      intersect(called_names(path), exports),
      c(helpers, self_defined_names(path))
    )
    if (length(bare) > 0) {
      offenders <- c(offenders, sprintf(
        "%s -> %s", basename(path), paste(sort(bare), collapse = ", ")
      ))
    }
  }

  expect_identical(
    offenders, character(),
    info = paste0(
      "These E2E-tier files call a package export bare. The nightly ",
      "shinytest2 job runs testthat::test_dir() WITHOUT attaching the ",
      "package, so each of these is a 'could not find function' error there ",
      "even though it passes under pkgload::load_all() locally. Qualify each ",
      "call as nprcgenekeepr::<fn>(). Offenders:\n  ",
      paste(offenders, collapse = "\n  ")
    )
  )
})
