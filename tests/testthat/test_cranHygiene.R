## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## CRAN 3.0.0 plan Phase 3 (docs/planning/cran-3.0.0-submission-plan.md): the
## static items of the submission. Everything here reads the source tree, so it
## skips under an installed package.

pkgRoot <- testthat::test_path("..", "..")

## -- The DOI ----------------------------------------------------------------

test_that("the markerParentageLikelihood() help cites the paper's real DOI", {
  ## doi.org answers "handle not found" for the old one; Crossref's record of
  ## Meagher and Thompson (1986), 29(1):87-106, has the new one.
  now <- "10.1016/0040-5809(86)90006-7"
  gone <- "10.1016/0040-5809(86)90007-1"
  man <- manText("markerParentageLikelihood")
  skip_if(is.na(man), "man/ not available (installed package)")
  ## tools::parse_Rd() expands \doi{} into text that holds the DOI twice.
  expect_gt(occurrences(man, now), 0L)
  expect_identical(occurrences(man, gone), 0L)
  roxygen <- roxygenText("markerParentageLikelihood.R")
  skip_if(is.na(roxygen), "R/ not available (installed package)")
  expectWording(roxygen, now, gone)
})

## -- The old cover notes ----------------------------------------------------

test_that("the old cover notes live in cran/archive/, out of the tarball", {
  ignored <- readRbuildignorePatterns()
  oldNotes <- paste0(
    c(
      "20200415", "20200510", "20200517", "20201107", "20210324", "20210330",
      "20241220", "20250504"
    ),
    "_cran-comments.md"
  )
  expect_true(all(file.exists(file.path(pkgRoot, "cran", "archive", oldNotes))))
  expect_length(
    list.files(pkgRoot, pattern = "^[0-9]+_cran-comments\\.md$"), 0L
  )
  expect_true("^cran$" %in% ignored)
  ## A dated note left at the root by mistake still never ships.
  expect_true("^[0-9]+_cran-comments\\.md$" %in% ignored)
})

test_that("the live cover note stays at the root, where submit_cran() reads it", {
  ignored <- readRbuildignorePatterns()
  expect_true(file.exists(file.path(pkgRoot, "cran-comments.md")))
  expect_true("^cran-comments\\.md$" %in% ignored)
})

test_that(".gitignore has no regex line for the live cover note", {
  gitignorePath <- file.path(pkgRoot, ".gitignore")
  skip_if_not(file.exists(gitignorePath), ".gitignore not present")
  ## .gitignore takes globs, so this line matched no file.
  expect_false(
    "^cran-comments\\.md$" %in% readLines(gitignorePath, warn = FALSE)
  )
})

## -- The two help examples that did not run ---------------------------------

## Runs the help example of `topic` in an empty folder and gives the environment
## it ran in, after checking that it is real code on a temporary file, runs with
## no warning and leaves the folder empty.
runHelpExample <- function(topic) {
  code <- exampleLines(topic)
  expect_gt(length(code), 0L)
  expect_false(any(grepl("Not run", code, fixed = TRUE)))
  expect_true(any(grepl("tempfile(", code, fixed = TRUE)))
  env <- new.env(parent = globalenv())
  workDir <- withr::local_tempdir()
  withr::with_dir(workDir, {
    expect_warning(eval(parse(text = code), envir = env), NA)
  })
  expect_length(list.files(workDir, all.files = TRUE, no.. = TRUE), 0L)
  env
}

test_that("the readKinshipOverrides() example reads and checks a real file", {
  env <- runHelpExample("readKinshipOverrides")
  expect_identical(env$overrides$id1, c("A1", "A3"))
  expect_identical(env$overrides$id2, c("A2", "A4"))
  expect_identical(env$overrides$kinship, c(0.25, 0.125))
})

test_that("the readTwinRelations() example reads and checks a real file", {
  env <- runHelpExample("readTwinRelations")
  expect_identical(env$twinRelations$id1, "S1")
  expect_identical(env$twinRelations$id2, "S2")
  expect_identical(env$twinRelations$code, "MZ twin")
})
