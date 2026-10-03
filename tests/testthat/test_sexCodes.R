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
## Since S879 the scan covers every R/*.R file minus an allowlist (below).
library(testthat)

findBareSexCodeLiterals <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  q <- "[\"'][MFHU][\"']"
  # S874 (sexCodes adoption plan, docs/planning/sexcodes-adoption-plan.md):
  # widened from `==`/`!=` to also catch a letter on the left of the
  # operator, `%in%` sets and `identical()` calls.
  comparisonPattern <- paste0("(==|!=)\\s*", q, "|", q, "\\s*(==|!=)")
  membershipPattern <- paste0("%in%\\s*(c\\()?\\s*", q)
  identicalPattern <- paste0("identical\\([^)]*", q)
  # S875 (stage 2): a letter passed as a call argument, as in
  # `resolveBreedingAge(species, "M", ...)`.
  argumentPattern <- paste0("[(,]\\s*", q, "\\s*[,)]")
  # S876 (stage 3): a letter as an assigned or returned value, as in
  # `missingSex <- if (miss) "M" else "F"`: after `<-`, `else` or `)`.
  assignmentPattern <- paste0("(<-|\\belse\\b|\\))\\s*", q)
  pairPattern <- 'c\\(\\s*"[MFHU]"\\s*,\\s*"[MFHU]"\\s*\\)'
  offenders <- integer(0)
  for (i in seq_along(lines)) {
    line <- lines[[i]]
    if (grepl("^\\s*#", line)) {
      next
    }
    if (grepl(comparisonPattern, line) || grepl(membershipPattern, line) ||
          grepl(identicalPattern, line) || grepl(pairPattern, line) ||
          grepl(argumentPattern, line) || grepl(assignmentPattern, line)) {
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

# Sex-code adoption, stage 6 (docs/planning/sexcodes-adoption-plan.md section
# 4): the per-stage file lists are replaced by a scan of every R/*.R file, so a
# new bare sex letter anywhere in R/ fails here. Exempt: whole files that
# legitimately hold the letters (`convertSexCodes.R` defines the vocabulary,
# `createPedOne.R` and `createPedSix.R` are example data), and single lines
# that are not sex codes or are an owner-approved literal, matched by exact
# trimmed text so a new letter in the same file is still caught.
sexCodeAllowedFiles <- c(
  "sexCodes.R", "convertSexCodes.R", "createPedOne.R", "createPedSix.R"
)
sexCodeAllowedLines <- c(
  # "F" is FALSE, not female
  'falseValues <- c("N", "NO", "F", "FALSE")',
  'mark[text %in% c("FALSE", "false", "False", "F", "0")] <- FALSE',
  # "U" is the first letter of UNKNOWN
  'status[status %in% c("UNKNOWN", "U", "4")] <- "UNKNOWN"',
  # alphabet used to build obfuscated ids
  '"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",',
  '"M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y",',
  # owner kept the literal default of the exported groupAddAssign() (S873)
  'threshold = 0.015625, ignore = list(c("F", "F")),'
)

scanForBareSexCodeLiterals <- function(rDir, allowedFiles, allowedLines) {
  offenders <- character(0)
  for (f in setdiff(list.files(rDir, pattern = "\\.[Rr]$"), allowedFiles)) {
    path <- file.path(rDir, f)
    lines <- readLines(path, warn = FALSE)
    hits <- findBareSexCodeLiterals(path)
    hits <- hits[!(trimws(lines[hits]) %in% allowedLines)]
    if (length(hits) > 0L) {
      offenders <- c(offenders, paste0(f, ":", toString(hits)))
    }
  }
  offenders
}

test_that("no bare sex-code literals remain anywhere in R/ outside the allowlist", {
  rDir <- testthat::test_path("..", "..", "R")
  skip_if(!dir.exists(rDir), "R/ source not available (installed package)")
  offenders <- scanForBareSexCodeLiterals(
    rDir, sexCodeAllowedFiles, sexCodeAllowedLines
  )
  expect_identical(
    offenders, character(0),
    info = paste0(
      "Bare sex-code literal(s) in R/; route through sexCodes instead:\n",
      paste(offenders, collapse = "\n")
    )
  )
})

test_that("every allowlisted file and line still exists in R/", {
  rDir <- testthat::test_path("..", "..", "R")
  skip_if(!dir.exists(rDir), "R/ source not available (installed package)")
  expect_true(all(file.exists(file.path(rDir, sexCodeAllowedFiles))))
  allLines <- unlist(lapply(
    list.files(rDir, pattern = "\\.[Rr]$", full.names = TRUE),
    function(f) trimws(readLines(f, warn = FALSE))
  ))
  expect_identical(
    setdiff(sexCodeAllowedLines, allLines), character(0),
    info = "An allowlisted line no longer exists; remove it from the allowlist."
  )
})

test_that("the R/ scan flags a new letter, honours the allowlist, skips comments", {
  d <- tempfile("rdir")
  dir.create(d)
  on.exit(unlink(d, recursive = TRUE))
  writeLines('x <- sex == "M"', file.path(d, "newCode.R"))
  writeLines(c("# sex == \"M\"", "x <- sexCodes[[\"male\"]]"),
             file.path(d, "clean.R"))
  writeLines(c('y <- c("F", "FALSE")', 'z <- sex == "F"'),
             file.path(d, "mixed.R"))
  writeLines('w <- sex == "U"', file.path(d, "whole.R"))
  expect_identical(
    scanForBareSexCodeLiterals(
      d, allowedFiles = "whole.R", allowedLines = 'y <- c("F", "FALSE")'
    ),
    c("mixed.R:2", "newCode.R:1")
  )
})

test_that("the guard flags each bare-literal form it claims to catch", {
  tmp <- tempfile(fileext = ".R")
  on.exit(unlink(tmp))
  writeLines(c(
    "x <- sex == \"M\"",
    "x <- sex != 'F'",
    "x <- \"H\" == sex",
    "x <- sex %in% c(\"U\", \"M\")",
    "x <- identical(sexOf[[p]], \"M\")",
    "x <- resolveBreedingAge(species, \"M\", 3)",
    "x <- f(a, 'F')",
    "m <- if (miss) \"M\" else \"F\"",
    "x <- \"U\"",
    "x <- if (a) sexCodes[[\"male\"]] else sexCodes[[\"female\"]]",
    "x <- sex == sexCodes[[\"male\"]]",
    "x <- f(species, sexCodes[[\"male\"]], 3)",
    "#' sex == \"M\" in roxygen",
    "# sex == \"M\" in a comment",
    "x <- convert == \"MALE\""
  ), tmp)
  expect_identical(findBareSexCodeLiterals(tmp), c(1:5, 6L, 7L, 8L, 9L))
})
