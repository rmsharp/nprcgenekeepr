## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S1026 (BACKLOG.md docs-audit part 2, the loose ends the S1025 handoff
## listed). Each was measured against today's repo at S1026; at the scope
## question the owner ruled LE6 "leave them as dated records".
##
##   LE1 BACKLOG.md says CL9 is "the open item below" (the Changed Columns tab
##       was fixed S1020) and still carries the "(3) Left unsettled by the doc
##       slices" paragraph, which is now settled.
##   LE2 ROADMAP.md says Quarto slices 3 and 4 have "status not recorded
##       here"; slice 3 is slide decks (none exist) and slice 4 is the manual
##       leaving the CRAN vignette set (not done).
##   LE3 ROADMAP.md says the other audit ids "were not re-checked"; all five
##       (NEW-45, PED-1, NEW-17, NEW-13, NEW-23) are done and in the code.
##   LE4 module-contract.md says Learning 347's "about 53" test lines "was
##       not re-counted".
##   LE5 the "6 of 474 parent-to-union edges that still differ in row" of the
##       founder-positioning audit are not parents: each is the last leg out
##       of a rectilinear routing jog, and every parent sits on its union's
##       row.
##   LE6 the slice 7b and slice 8 audit reports say what became of their open
##       items (RO8, RO3, AR3, the file:line question, the six edges).
##
## Blocks marked "(green at HEAD)" re-measure the repo and pass before the
## fix; they pin the facts the new wording states, so a later change that
## breaks one is a reason to re-read the page, not to edit the test.

## plainSource(), sourceLines(), expectWording() and occurrences() are in
## helper-pageText.R.

root <- function() testthat::test_path("..", "..")

## -- LE1 ---------------------------------------------------------------------

test_that("LE1: BACKLOG.md says CL9 was fixed and drops the settled paragraph", {
  text <- plainSource("BACKLOG.md")
  expectWording(
    text,
    now = c("CL9, the Changed Columns tab, was fixed S1020"),
    gone = c("CL9 is the open item below",
             "Left unsettled by the doc slices",
             "RO8", "RO3", "AR3", "parent-to-union"))
})

test_that("LE1 (green at HEAD): the CC5 ruling stays in BACKLOG.md", {
  text <- plainSource("BACKLOG.md")
  expect_equal(occurrences(text, "CC5 is the owner's call"), 1L)
})

## -- LE2 ---------------------------------------------------------------------

test_that("LE2 (green at HEAD): no slide deck; the manual is a knitr vignette", {
  skip_if_not(file.exists(file.path(root(), "DESCRIPTION")), "no source tree")
  dirs <- file.path(root(), c("vignettes", "dev", "inst", "docs"))
  skip_if_not(any(dir.exists(dirs)), "no source tree")
  files <- list.files(dirs, pattern = "\\.(qmd|Rmd|yml|yaml)$",
                      recursive = TRUE, full.names = TRUE)
  decks <- Filter(function(f) {
    any(grepl("revealjs", readLines(f, warn = FALSE), fixed = TRUE))
  }, files)
  expect_length(decks, 0L)
  vig <- file.path(root(), "vignettes")
  skip_if_not(dir.exists(vig), "vignettes/ not present")
  expect_true(file.exists(file.path(vig, "a3manual.Rmd")))
  expect_true(dir.exists(file.path(vig, "manual_components")))
  desc <- readLines(file.path(root(), "DESCRIPTION"), warn = FALSE)
  expect_true(any(grepl("^VignetteBuilder:\\s*knitr", desc)))
  ignore <- file.path(root(), ".Rbuildignore")
  if (file.exists(ignore)) {
    expect_false(any(grepl("a3manual|manual_components",
                           readLines(ignore, warn = FALSE))))
  }
})

test_that("LE2: ROADMAP.md says what became of Quarto slices 3 and 4", {
  text <- plainSource("methodology", "ROADMAP.md")
  expectWording(
    text,
    now = c(paste("Slice 3 (Quarto slide decks) is not started: no revealjs",
                  "file is in the repository."),
            paste("Slice 4 (the manual leaves the CRAN vignette set) is not",
                  "done: a3manual.Rmd and manual_components/ are still built",
                  "by knitr (VignetteBuilder: knitr), and the analysis ties it",
                  "to a CRAN resubmission.")),
    gone = c("status not recorded here"))
})

## -- LE3 ---------------------------------------------------------------------

test_that("LE3 (green at HEAD): the five audit ids are in the code", {
  ns <- asNamespace("nprcgenekeepr")
  for (fn in c("getFounders", "isFounder", "calcFounderContributions")) {
    expect_true(is.function(get0(fn, envir = ns, inherits = FALSE)), info = fn)
  }
  expect_true("invalidIdChars" %in% names(getEmptyErrorLst()))
})

test_that("LE3: ROADMAP.md names the five ids as done", {
  text <- plainSource("methodology", "ROADMAP.md")
  expectWording(
    text,
    now = c("NEW-45", "PED-1 and NEW-17", "NEW-13 and NEW-23"),
    gone = c("were not re-checked"))
})

## -- LE4 ---------------------------------------------------------------------

test_that("LE4: module-contract.md states the recount of Learning 347's figure", {
  text <- plainSource("docs", "architecture", "module-contract.md")
  expectWording(
    text,
    now = c("S1026 counted the same way",
            "53 at S376's commit",
            "55 in those four files now",
            "14 reactives it returns today"),
    gone = c("that figure was not re-counted"))
})

## -- LE5 ---------------------------------------------------------------------

## The parent-to-union legs of a layout: the edges that end at a union node
## and do not start at one.
unionLegs <- function(layout) {
  e <- layout$edges
  e[startsWith(e$to, "__union_") & !startsWith(e$from, "__union_"),
    c("from", "to")]
}

test_that("LE5 (green at HEAD): parents sit on their union's row; 6 jog legs", {
  skip_on_cran()
  f <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                   package = "nprcgenekeepr")
  skip_if(identical(f, ""), "example file not installed")
  ped <- read.csv(f, stringsAsFactors = FALSE, na.strings = c("", "NA"))

  direct <- suppressWarnings(makePedigreeMatingLayout(ped,
                                                      edgeStyle = "direct"))
  yDirect <- stats::setNames(direct$nodes$y, direct$nodes$id)
  legsDirect <- unionLegs(direct)
  expect_equal(nrow(legsDirect), 474L)
  expect_false(any(grepl("^__jog_", direct$nodes$id)))
  expect_equal(sum(yDirect[legsDirect$from] != yDirect[legsDirect$to]), 0L)

  rect <- suppressWarnings(makePedigreeMatingLayout(ped))
  e <- rect$edges
  yRect <- stats::setNames(rect$nodes$y, rect$nodes$id)
  legs <- unionLegs(rect)
  expect_equal(nrow(legs), 474L)
  differs <- legs[yRect[legs$from] != yRect[legs$to], ]
  expect_equal(nrow(differs), 6L)
  expect_true(all(startsWith(differs$from, "__jog_")))
  ## Trace each jog leg back (jog_b <- jog_a <- parent): the parent's own row
  ## is the union's row.
  for (i in seq_len(nrow(differs))) {
    jogA <- sub("_b$", "_a", differs$from[i])
    parent <- e$from[e$to == jogA]
    expect_length(parent, 1L)
    expect_equal(unname(yRect[parent]), unname(yRect[differs$to[i]]),
                 info = differs$from[i])
  }
})

test_that("LE5: the founder-positioning audit says the six are jog legs", {
  text <- plainSource("docs", "audits",
                      "FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md")
  expectWording(
    text,
    now = c("last leg out of a rectilinear routing jog",
            "all 474 parent-to-union pairs sit on one row"),
    gone = c("the 6 are not investigated"))
})

## -- LE6 ---------------------------------------------------------------------

test_that("LE6: the slice 8 report records the ruling and the six edges", {
  text <- plainSource("docs", "audits",
                      "DOCS_STALENESS_AUDIT_SLICE8_2026-10-02.md")
  expectWording(
    text,
    now = c("Update S1026 (2026-10-21)",
            "the owner ruled to leave the file:line cites as dated records",
            "last leg out of a rectilinear routing jog"),
    gone = character(0))
})

test_that("LE6: the slice 7b report records that RO8, RO3 and AR3 are settled", {
  text <- plainSource("docs", "audits",
                      "DOCS_STALENESS_AUDIT_SLICE7B_2026-10-01.md")
  expectWording(
    text,
    now = c("Update S1026 (2026-10-21)",
            "RO8, the five ids of RO3 and AR3 are settled"),
    gone = character(0))
})
