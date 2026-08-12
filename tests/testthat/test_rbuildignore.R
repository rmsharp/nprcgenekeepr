## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md (Housekeeping, found S533): .Rbuildignore is a list of perl
## regexes matched against build-tree paths; a typo'd pattern silently drops
## its coverage (no error, no warning) and only surfaces later as a
## devtools::check() top-level-files NOTE for whatever file it was meant to
## exclude. This guard exercises the currently-known real case directly, so
## a future re-typo of this pattern is caught by the test suite instead of
## only by a NOTE someone has to notice and trace back.

pkg_root <- testthat::test_path("..", "..")
rbuildignore_path <- file.path(pkg_root, ".Rbuildignore")
no_rbuildignore_msg <- ".Rbuildignore absent; guard not applicable"

readRbuildignorePatterns <- function() {
  lines <- readLines(rbuildignore_path, warn = FALSE)
  ## Comments start a line with "#"; blank lines carry no pattern.
  lines[nzchar(lines) & !grepl("^#", lines)]
}

anyPatternMatches <- function(patterns, path) {
  any(vapply(patterns, function(p) {
    isTRUE(tryCatch(grepl(p, path, perl = TRUE), error = function(e) FALSE))
  }, logical(1)))
}

test_that(".Rbuildignore covers the real methodology_trim.py at the repo root", {
  skip_if_not(file.exists(rbuildignore_path), no_rbuildignore_msg)

  patterns <- readRbuildignorePatterns()
  expect_true(
    anyPatternMatches(patterns, "methodology_trim.py"),
    info = paste(
      "no .Rbuildignore pattern matches the real file \"methodology_trim.py\" --",
      "a typo'd pattern (e.g. \"methodolog_trim\") silently stops excluding it,",
      "surfacing later as devtools::check()'s top-level-files NOTE"
    )
  )
})
