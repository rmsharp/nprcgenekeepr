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

expectNoBareSexCodeLiterals <- function(files) {
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
}

test_that("sexCodes defines the four canonical values", {
  expect_identical(sexCodes[["male"]], "M")
  expect_identical(sexCodes[["female"]], "F")
  expect_identical(sexCodes[["hermaphrodite"]], "H")
  expect_identical(sexCodes[["unknown"]], "U")
})

test_that("no bare sex-code literals remain in the 6 XARCH-4 files", {
  expectNoBareSexCodeLiterals(c(
    "getPotentialSires.R", "calculateSexRatio.R", "fillBins.R",
    "filterPairs.R", "modBreedingGroups.R", "modSummaryStats.R"
  ))
})

# Sex-code adoption (docs/planning/sexcodes-adoption-plan.md): each stage
# adds its files here, then converts them. Stage 6 replaces this list with a
# scan of every R/*.R file minus an allowlist.
test_that("no bare sex-code literals remain in the stage 1 files", {
  expectNoBareSexCodeLiterals(c(
    "calcNeSexRatio.R", "createColonySnapshot.R",
    "getSexRatioWithAdditions.R", "getProductionStatus.R"
  ))
})

test_that("no bare sex-code literals remain in the stage 2 files", {
  expectNoBareSexCodeLiterals(c(
    "getSpeciesMinBreedingAge.R", "resolveBreedingAge.R",
    "checkParentAge.R", "getKinshipWithMaleStatus.R"
  ))
})

test_that("no bare sex-code literals remain in the stage 3 files", {
  expectNoBareSexCodeLiterals(c(
    "getPotentialParents.R", "reportGV.R", "modPyramid.R",
    "correctUnknownParentMeanKinship.R"
  ))
})

test_that("no bare sex-code literals remain in the stage 4 files", {
  expectNoBareSexCodeLiterals(c(
    "correctParentSex.R", "addParents.R", "modORIPReporting.R"
  ))
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
