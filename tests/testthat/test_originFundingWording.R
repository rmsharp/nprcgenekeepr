## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:84 (owner-reported S930, decided S952): only version one of the
## package was developed at the Oregon National Primate Research Center and
## paid for by NIH grants P51 RR13986 and P51 OD011092, yet the pages that
## state the origin and the funding said the whole work was supported. The
## owner ruled two changes, wherever each sentence appears:
##
##  1. "The goal of nprcgenekeepr is to implement genetic tools for colony
##     management" becomes "The primary goal of nprcgenekeepr ...".
##  2. "This work has been supported in part by NIH grants ..." becomes "Work
##     on this package up to and including version 1.0 was supported in part
##     by NIH grants ...", the same two grants to the same two centers.
##
## Where the sentences are: the colony manager guide (the goal sentence once,
## the grant sentence twice), the engineering article (grant), the manual
## introduction (both; README.md is knitted from it, so it is checked too) and
## the project overview in CLAUDE.md (grant). Not covered, by the owner's
## scope: the DESCRIPTION funder entries, the About tab in the app, the
## outreach plan and "initially conceived and developed" at ONPRC.
##
## Every file read here sits outside a built package (.Rbuildignore'd or not
## installed), so each block skips where its file is absent and runs from the
## source tree, where the close-out suite runs. Emphasis marks (`, *, _) and
## line breaks do not count as a difference.

pkg_root <- testthat::test_path("..", "..")

pageText <- function(...) {
  path <- file.path(pkg_root, ...)
  skip_if_not(file.exists(path), paste(basename(path), "not present"))
  text <- paste(readLines(path, warn = FALSE), collapse = " ")
  text <- gsub("[`*_]", "", text)
  gsub("\\s+", " ", text)
}

occurrences <- function(text, phrase) {
  hits <- gregexpr(phrase, text, fixed = TRUE)[[1L]]
  sum(hits > 0L)
}

primaryGoal <- "The primary goal of nprcgenekeepr is to implement"
oldGoal <- "The goal of nprcgenekeepr is to implement"

versionOneGrants <- paste(
  "Work on this package up to and including version 1.0 was supported in",
  "part by NIH grants P51 RR13986 to the Southwest National Primate Research",
  "Center and P51 OD011092 to the Oregon National Primate Research Center."
)
oldGrants <- "This work has been supported in part by NIH grants"

expectPrimaryGoal <- function(text) {
  expect_equal(occurrences(text, primaryGoal), 1L)
  expect_equal(occurrences(text, oldGoal), 0L)
}

expectVersionOneGrants <- function(text, n) {
  expect_equal(occurrences(text, versionOneGrants), n)
  expect_equal(occurrences(text, oldGrants), 0L)
}

test_that("the guide's purpose section says the primary goal", {
  guide <- pageText("vignettes", "articles", "colony-manager-guide.qmd")
  expectPrimaryGoal(guide)
  expect_equal(
    occurrences(guide, paste(primaryGoal, "genetic tools for colony",
                             "management")), 1L)
})

test_that("the manual introduction says the primary goal", {
  expectPrimaryGoal(pageText("vignettes", "manual_components",
                             "_introduction.Rmd"))
})

test_that("README.md says the primary goal", {
  expectPrimaryGoal(pageText("README.md"))
})

test_that("both of the guide's acknowledgments say version 1.0 and earlier", {
  expectVersionOneGrants(
    pageText("vignettes", "articles", "colony-manager-guide.qmd"), 2L)
})

test_that("the engineering article's acknowledgment says version 1.0 and earlier", {
  expectVersionOneGrants(
    pageText("vignettes", "articles", "engineering-the-2.0.0-release.qmd"),
    1L)
})

test_that("the manual introduction's acknowledgment says version 1.0 and earlier", {
  expectVersionOneGrants(
    pageText("vignettes", "manual_components", "_introduction.Rmd"), 1L)
})

test_that("README.md's acknowledgment says version 1.0 and earlier", {
  expectVersionOneGrants(pageText("README.md"), 1L)
})

test_that("the CLAUDE.md overview's acknowledgment says version 1.0 and earlier", {
  expectVersionOneGrants(pageText("CLAUDE.md"), 1L)
})
