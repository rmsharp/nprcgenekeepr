## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Issue #119 Slice 5: the quality-control and potential-parent entry points
## deprecated the scalar `minParentAge` argument in favor of the sex-specific
## `minSireAge` / `minDamAge` parameters. Every user-facing vignette code chunk
## must call the new parameters so the package renders without tripping its own
## lifecycle::deprecate_warn() on a vignette rebuild. This guard scans the
## vignette sources and fails if any chunk still passes `minParentAge = ...`,
## preventing re-introduction while the deprecated alias remains available.
##
## Scope: vignettes/ only, and only inside executed R code chunks (between
## ```{r}/```{R} fences and the closing ```). Prose and inline backtick code
## spans outside a chunk do not match, even if they mention `minParentAge =`
## in historical narrative text; archived example scripts under inst/extdata
## are out of scope by design. See helper-vignette-minParentAge-scan.R.

test_that("no vignette code chunk calls the deprecated minParentAge=", {
  vig_dir <- testthat::test_path("..", "..", "vignettes")
  skip_if_not(dir.exists(vig_dir),
              "vignettes/ not present in this build; guard not applicable")
  vig_files <- list.files(vig_dir, pattern = "[.](Rmd|qmd)$",
                          recursive = TRUE, full.names = TRUE,
                          ignore.case = TRUE)
  skip_if(length(vig_files) == 0L, "no vignette sources found")

  offenders <- character(0)
  for (f in vig_files) {
    hits <- findDeprecatedMinParentAgeOffenders(f)
    if (length(hits) > 0L) {
      rel <- sub(".*/vignettes/", "", f)
      offenders <- c(offenders, paste0(rel, ":", hits))
    }
  }

  expect_identical(
    offenders, character(0),
    info = paste0("Deprecated `minParentAge=` call(s) still in vignettes; ",
                  "migrate to minSireAge/minDamAge:\n",
                  paste(offenders, collapse = "\n"))
  )
})

## Session 364 (chunk-aware checker): findDeprecatedMinParentAgeOffenders()
## does not exist yet -- these three fixtures are the RED phase for that
## refactor. Regression case (2) reproduces the exact false positive found in
## vignettes/articles/engineering-the-2.0.0-release.qmd:344.

test_that("flags a live minParentAge= call inside a code chunk", {
  f <- withr::local_tempfile(fileext = ".qmd")
  writeLines(c(
    "```{r}",
    "qcStudbook(minParentAge = 2)",
    "```"
  ), f)
  expect_length(findDeprecatedMinParentAgeOffenders(f), 1L)
})

test_that("does not flag prose mentioning minParentAge = 2", {
  f <- withr::local_tempfile(fileext = ".qmd")
  writeLines(
    "A single flat `minParentAge = 2` default was replaced.",
    f
  )
  expect_length(findDeprecatedMinParentAgeOffenders(f), 0L)
})

test_that("does not flag an inline backtick code span in prose", {
  f <- withr::local_tempfile(fileext = ".qmd")
  writeLines(
    "See `minParentAge = 2` in the old API.",
    f
  )
  expect_length(findDeprecatedMinParentAgeOffenders(f), 0L)
})
