## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md XARCH-4 remainder (docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md
## Sec.3 XARCH-4): the M/F/H/U sex-code literals were scattered as bare string
## comparisons across getPotentialSires.R, calculateSexRatio.R, fillBins.R,
## filterPairs.R, modBreedingGroups.R, and modSummaryStats.R -- no shared
## source of truth existed. This test enforces the centralization
## structurally: none of those six files may contain a bare sex-code
## comparison or ignore-pair in executable code; they must reference the
## sexCodes constant instead. Roxygen `#'` lines (prose, @examples) are
## skipped -- user-facing documentation legitimately shows literal "M"/"F"
## values to illustrate the API, and is out of this item's scope.
library(testthat)

findBareSexCodeLiterals <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  comparisonPattern <- '(==|!=)\\s*"[MFHU]"'
  pairPattern <- 'c\\(\\s*"[MFHU]"\\s*,\\s*"[MFHU]"\\s*\\)'
  offenders <- integer(0)
  for (i in seq_along(lines)) {
    line <- lines[[i]]
    if (grepl("^\\s*#'", line)) {
      next
    }
    if (grepl(comparisonPattern, line) || grepl(pairPattern, line)) {
      offenders <- c(offenders, i)
    }
  }
  offenders
}

test_that("sexCodes defines the four canonical values", {
  expect_identical(sexCodes[["male"]], "M")
  expect_identical(sexCodes[["female"]], "F")
  expect_identical(sexCodes[["hermaphrodite"]], "H")
  expect_identical(sexCodes[["unknown"]], "U")
})

test_that("no bare sex-code literals remain in the 6 XARCH-4 files", {
  files <- c(
    "getPotentialSires.R", "calculateSexRatio.R", "fillBins.R",
    "filterPairs.R", "modBreedingGroups.R", "modSummaryStats.R"
  )
  offenders <- character(0)
  for (f in files) {
    src <- testthat::test_path("..", "..", "R", f)
    skip_if(!file.exists(src), "R/ source not available (installed package)")
    hits <- findBareSexCodeLiterals(src)
    if (length(hits) > 0L) {
      offenders <- c(offenders, paste0(f, ":", toString(hits)))
    }
  }
  expect_identical(
    offenders, character(0),
    info = paste0(
      "Bare sex-code literal(s) remain; route through sexCodes instead:\n",
      paste(offenders, collapse = "\n")
    )
  )
})
