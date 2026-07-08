## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Issue #118 (publish slice): the effective-population-size feature adds three
## population-genetic summaries to the Genetic Value Analysis -- gene diversity
## (GD), a demographic sex-ratio effective size, and a variance effective size.
## They render on two tabs (Summary Statistics and Genetic Value), so every user
## who sees a number must be able to find what it means and what it assumes.
##
## Mirroring test_kinshipOverrideDocs.R (S285 precedent), these tests statically
## scan the in-app guidance surfaces and the vignette / NEWS sources and fail if
## the metrics are not explained where they display:
##   - inst/extdata/ui_guidance/population_genetics_terms.html (definitions panel)
##   - inst/extdata/ui_guidance/summary_stats.html            (Summary Stats guide)
##   - inst/extdata/ui_guidance/genetic_value.html            (Genetic Value guide)
##   - vignettes/manual_components/_summary_statistics.Rmd    (manual component)
##   - NEWS.Rmd                                               (user release notes)
##
## Phrases are matched either fixed (exact spelling, formula/label text) or as a
## case-insensitive regex (prose), never both, to match the grepl() contract.

context("Effective population size / gene diversity in-app documentation (#118)")

test_that("population_genetics_terms.html defines GD and both Ne estimates", {
  path <- system.file("extdata", "ui_guidance",
                      "population_genetics_terms.html",
                      package = "nprcgenekeepr")
  expect_true(nzchar(path))
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")

  ## Gene diversity (E1): the label the UI shows plus the plain-language sense.
  expect_true(grepl("Gene Diversity", txt, fixed = TRUE))
  expect_true(grepl("heterozygosity", txt, fixed = TRUE))

  ## Sex-ratio effective size (E2): its label, its living-breeder population,
  ## and the balanced-vs-skewed intuition.
  expect_true(grepl("Sex-Ratio", txt, fixed = TRUE))
  expect_true(grepl("balanced", txt, fixed = TRUE))

  ## Variance effective size (E3): its label, the Crow & Kimura (1970) source,
  ## and the fewer-than-two-breeders degeneracy (N/A).
  expect_true(grepl("Variance", txt, fixed = TRUE))
  expect_true(grepl("Crow", txt, fixed = TRUE))
  expect_true(grepl("Kimura", txt, fixed = TRUE))
  expect_true(grepl("fewer than two", txt, fixed = TRUE))

  ## Both effective sizes are over the current living breeders -- a different
  ## population than the analysis-set founder statistics above.
  expect_true(grepl("living breeders", txt, ignore.case = TRUE))

  ## The shared idealizing-assumptions caveat (the #82 D6 discipline).
  expect_true(grepl("Wright", txt, fixed = TRUE))

  ## Plain-language forward-pointer: a rate-of-coancestry effective size may be
  ## added later (no issue/slice refs in user-facing prose).
  expect_true(grepl("coancestry", txt, fixed = TRUE))
})

test_that("summary_stats.html notes the living-breeder effective-size block", {
  path <- system.file("extdata", "ui_guidance", "summary_stats.html",
                      package = "nprcgenekeepr")
  expect_true(nzchar(path))
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_true(grepl("Effective Population Size", txt, fixed = TRUE))
  ## The population distinct from the analysis-set founder statistics.
  expect_true(grepl("living breeders", txt, ignore.case = TRUE))
})

test_that("genetic_value.html cross-references the definitions panel", {
  path <- system.file("extdata", "ui_guidance", "genetic_value.html",
                      package = "nprcgenekeepr")
  expect_true(nzchar(path))
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_true(grepl("effective population size", txt, ignore.case = TRUE))
  ## Points the user to where the definitions live.
  expect_true(grepl("Summary Statistics", txt, fixed = TRUE))
})

test_that("_summary_statistics.Rmd lists the three new metrics", {
  path <- testthat::test_path("..", "..", "vignettes", "manual_components",
                              "_summary_statistics.Rmd")
  skip_if_not(file.exists(path),
              "vignette manual component not present in this build")
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_true(grepl("gene diversity", txt, ignore.case = TRUE))
  expect_true(grepl("effective population size", txt, ignore.case = TRUE))
  expect_true(grepl("living breeders", txt, ignore.case = TRUE))
})

test_that("NEWS.Rmd announces the effective-population-size feature", {
  path <- testthat::test_path("..", "..", "NEWS.Rmd")
  skip_if_not(file.exists(path), "NEWS.Rmd not present in this build")
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_true(grepl("effective population size", txt, ignore.case = TRUE))
  expect_true(grepl("gene diversity", txt, ignore.case = TRUE))
})
