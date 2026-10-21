## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S1027 (BACKLOG.md docs-audit part 2, the last six slice 6d rulings). Each
## finding was re-measured against today's code at S1027 and the owner ruled:
## CC5 (the ORIP Reporting tab's "Export Demographics" writes the whole
## pedigree) stays as it is and the manual says what the button saves; CB3,
## CB4, CC2, CC3 and CD3 stay as they are. With the six ruled, the docs-audit
## item comes off BACKLOG.md.
##
##   SR1 the ORIP Reporting manual page says what Export Demographics saves.
##   SR2 the slice 6d re-check report records the six rulings.
##   SR3 BACKLOG.md carries no docs-audit item and no pointer to one.
##
## Blocks marked "(green at HEAD)" re-measure the repo and pass before the
## fix; they pin the facts the new wording states, so a later change that
## breaks one is a reason to re-read the page, not to edit the test.

## plainSource(), sourceLines() and expectWording() are in helper-pageText.R.

## -- SR1 ---------------------------------------------------------------------

test_that("SR1: the manual says what Export Demographics saves", {
  text <- plainSource("vignettes", "manual_components", "_orip_reporting.Rmd")
  expectWording(
    text,
    now = paste("Export Demographics saves the pedigree the analysis is",
                "using, as it stands, to demographics_<date>.csv; it is not",
                "a summary."),
    gone = character(0L))
})

test_that("SR1 (green at HEAD): the module names the file the manual names", {
  text <- plainSource("R", "modORIPReporting.R")
  expectWording(
    text,
    now = c("paste0(\"demographics_\", Sys.Date(), \".csv\")",
            paste0("downloadButton(ns(\"downloadDemographics\"), ",
                   "\"Export Demographics\")")),
    gone = character(0L))
})

## -- SR2 ---------------------------------------------------------------------

test_that("SR2: the 6d re-check report records the six rulings", {
  lines <- sourceLines("docs", "audits",
                       "DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md")
  para <- grep("^\\*\\*Update S1027:\\*\\*", lines, value = TRUE)
  expect_length(para, 1L)
  expectWording(
    plainText(para),
    now = c("Update S1027:",
            paste("CC5 (Export Demographics) was ruled: leave the code and",
                  "say in the manual what the button saves"),
            paste("CB3, CB4, CC2, CC3 and CD3 were ruled: leave all five as",
                  "they are"),
            "re-measured 2026-10-21"),
    gone = character(0L))
})

## -- SR3 ---------------------------------------------------------------------

test_that("SR3: BACKLOG.md no longer carries the docs-audit item", {
  text <- plainSource("BACKLOG.md")
  expectWording(
    text,
    now = "the documentation audit is finished",
    gone = c("Audit the internal and user-facing documentation",
             "Slices audited, and their wording findings FIXED",
             "CC5",
             "Export Demographics",
             "documentation audit above",
             "docs-audit item (47 lines"))
})

test_that("SR3 (green at HEAD): the other open items stay", {
  text <- plainSource("BACKLOG.md")
  expectWording(
    text,
    now = c("Move the version to 3.0.0 just before release",
            "Create a tutorial for prospective contributors",
            "Retrospective colony-snapshot backfill",
            "Work with LabKey (Josh Eckels)",
            "Two kinship2 drawing features the Diagram tab still lacks",
            "NPRC outreach & announcement plan",
            "Develop paper(s) for peer-reviewed journals"),
    gone = character(0L))
})
