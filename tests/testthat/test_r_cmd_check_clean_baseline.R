## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md ("Up Next", found S636): R-CMD-check.yaml went red on all 5
## platforms because check-r-package@v2's default error-on: "warning" trips
## on a real devtools::check() WARNING ("unstated dependencies in tests:
## kinship2"). A live CI run (S637) additionally confirmed a long-standing
## NOTE ("vignettes/figure/ looks like a leftover from 'knitr'", first
## documented ~S520) that had been repeatedly flagged and deferred as
## "pre-existing/unrelated" across 80+ sessions without ever being fixed.
## Both are deterministic, diagnosed root causes -- unlike a third NOTE found
## the same session (a single-occurrence, single-platform chromium
## temp-detritus artifact, filed separately to BACKLOG.md, not guarded here).
##
## These tests guard both real causes directly, following the established
## test_rbuildignore.R precedent (S534): parse the config/filesystem state
## directly rather than trusting devtools::check()'s own abbreviated NOTE/
## WARNING table, so a future regression is caught by the test suite instead
## of only by a check result someone has to notice and trace back.

pkg_root <- testthat::test_path("..", "..")
description_path <- file.path(pkg_root, "DESCRIPTION")
no_description_msg <- "DESCRIPTION absent; guard not applicable"

## Reads a comma-separated DESCRIPTION dependency field (Imports/Suggests/
## Depends/...) and returns the bare package names, with any parenthetical
## version constraint (e.g. "Rlabkey (>= 3.2.0)") stripped off.
readDescriptionField <- function(field) {
  raw <- read.dcf(description_path, fields = field)[1, field]
  if (is.na(raw)) {
    return(character(0))
  }
  pkgs <- strsplit(raw, ",")[[1]]
  pkgs <- trimws(gsub("\\s*\\([^)]*\\)\\s*$", "", trimws(pkgs)))
  pkgs[nzchar(pkgs)]
}

test_that("DESCRIPTION declares kinship2 as a Suggests dependency", {
  skip_if_not(file.exists(description_path), no_description_msg)

  suggests <- readDescriptionField("Suggests")
  expect_true(
    "kinship2" %in% suggests,
    info = paste(
      "kinship2 is called live (via :: / :::) in tests/testthat/",
      "helper-comparePedigreeStructure.R and test_comparePedigreeStructure.R",
      "but is not declared anywhere in DESCRIPTION -- this is exactly what",
      "devtools::check()'s 'checking for unstated dependencies in tests'",
      "WARNING flags, and what trips R-CMD-check.yaml's error-on: \"warning\"",
      "gate in CI (BACKLOG.md, found S636)"
    )
  )
})

test_that("vignettes/ contains no leftover 'figure' directory (knitr-leftover NOTE guard)", {
  figure_dir <- file.path(pkg_root, "vignettes", "figure")
  expect_false(
    dir.exists(figure_dir),
    info = paste(
      "vignettes/figure/ is a stale, dead knitr-leftover artifact -- the",
      "vignette chunk that shares its name (a2interactive.Rmd,",
      "plot-focal-age-sex-pyramid) regenerates its own plot live and does",
      "not reference this static file -- devtools::check() flags any",
      "directory literally named 'figure' under vignettes/ as a leftover to",
      "remove (long-standing, first documented ~S520, never fixed)"
    )
  )
})
