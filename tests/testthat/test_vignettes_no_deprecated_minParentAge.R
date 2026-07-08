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
## Scope: vignettes/ only. Prose or backtick mentions of `minParentAge` (with no
## `=`) do not match; archived example scripts under inst/extdata are out of
## scope by design.

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
    lines <- readLines(f, warn = FALSE)
    hits <- grep("minParentAge[[:space:]]*=[^=]", lines)
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
