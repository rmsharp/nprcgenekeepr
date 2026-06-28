## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Issue #13 item-3 follow-up (Session 219): the kinship-override feature's
## behavior and limitations must be documented in the user-facing in-app
## documentation -- at a minimum where the coefficients are supplied (the
## Genetic Value tab override upload), plus the relevant guidance panels.
##
## These tests assert that documentation is present in the three surfaces a
## user sees inside the running app:
##   - the override-upload helpText rendered by modGeneticValueUI()
##   - inst/extdata/ui_guidance/genetic_value.html  (Genetic Value tab guidance)
##   - inst/extdata/ui_guidance/summary_stats.html  (relationship-table guidance)
##
## Phrases are asserted within single contiguous strings because helpText()
## renders each argument as a separate (newline-separated) text node.

context("Kinship-override in-app documentation (issue #13 item 3)")

test_that(paste(
  "Genetic Value tab supply-point help documents override behavior and",
  "limits"), {
  ui <- as.character(modGeneticValueUI("gv"))

  ## Overrides change the kinship VALUE only (not the pedigree structure).
  expect_true(grepl("change the kinship value", ui, fixed = TRUE))

  ## They reach rankings / breeding groups / summary stats regardless of order.
  expect_true(grepl("regardless of tab order", ui, fixed = TRUE))

  ## Item 3b: the relationship-table LABEL stays pedigree-derived, so the
  ## label and the overridden value can disagree.
  expect_true(grepl("relationship label", ui, ignore.case = TRUE))

  ## Item 3a: the gene-drop convergence check (gvaConvergence) ignores
  ## overrides.
  expect_true(grepl("convergence check ignores", ui, ignore.case = TRUE))

  ## Item 3c: overrides on an animal missing a parent have edge cases that
  ## are a current limitation.
  expect_true(grepl("current limitation", ui, ignore.case = TRUE))
})

test_that(paste(
  "genetic_value.html guidance documents kinship overrides and their",
  "limits"), {
  path <- system.file("extdata", "ui_guidance", "genetic_value.html",
                      package = "nprcgenekeepr")
  expect_true(nzchar(path))
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_true(grepl("override", txt, ignore.case = TRUE))
  expect_true(grepl("regardless of tab order", txt, fixed = TRUE))
  ## Item 3a: the convergence check does not use the overrides.
  expect_true(grepl("does not use", txt, ignore.case = TRUE))
  ## Item 3c: edge cases are a current limitation.
  expect_true(grepl("limitation", txt, ignore.case = TRUE))
})

test_that(paste(
  "summary_stats.html guidance documents the override label-vs-value",
  "divergence"), {
  path <- system.file("extdata", "ui_guidance", "summary_stats.html",
                      package = "nprcgenekeepr")
  expect_true(nzchar(path))
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_true(grepl("override", txt, ignore.case = TRUE))
  ## Item 3b: relationship label stays pedigree-derived.
  expect_true(grepl("relationship label", txt, ignore.case = TRUE))
  expect_true(grepl("pedigree-derived", txt, ignore.case = TRUE))
})
