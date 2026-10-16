## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S1002, BACKLOG "Every Summary Statistics popover header reads the text
## character(0)", found S994): the twelve export-button popovers of the Summary
## Statistics page are built with shinyBS::popify(title = NULL, ...), and
## shinyBS writes that NULL into the page as the text 'character(0)', so each
## popover draws a gray title bar reading "character(0)" above its one sentence.
## The owner ruled (S1002) to drop the title bar. An empty title does that: in
## the app's Bootstrap 4 theme (bslib flatly) a popover whose title is '' draws
## no header at all (measured S1002 in headless Chrome: header display "none",
## height 0; with title NULL the header was 35 px tall and read "character(0)").
##
## The three box-plot popovers of the same page are added by the server with
## shinyBS::addPopover() and real titles; they are not in this page text and are
## not touched.

## The twelve popover calls the Summary Statistics page draws, each as the text
## shinyBS writes into the page, named by the button id without the module
## prefix.
popoverCalls <- function() {
  html <- as.character(modSummaryStatsUI("x"))
  calls <- regmatches(html, gregexpr(
    "shinyBS\\.addTooltip\\('x-[^']+', 'popover', \\{[^}]*\\}", html
  ))[[1L]]
  stats::setNames(
    calls,
    sub("^shinyBS\\.addTooltip\\('x-([^']+)'.*$", "\\1", calls)
  )
}

## The title shinyBS gave one call (NA when the call has no title entry).
popoverTitle <- function(call) {
  if (!grepl("'title': '", call, fixed = TRUE)) {
    return(NA_character_)
  }
  sub(".*'title': '([^']*)'.*$", "\\1", call)
}

popoverContent <- function(call) {
  sub(".*'content': '([^']*)'.*$", "\\1", call)
}

popoverIds <- c(
  "downloadKinship", "downloadMaleFounders", "downloadFemaleFounders",
  "downloadFirstOrder", "downloadRelationships", "downloadRelationClasses",
  "downloadMkHist", "downloadZscoreHist", "downloadGuHist",
  "downloadMkBox", "downloadZscoreBox", "downloadGuBox"
)

## -- Reader (green at HEAD): the RED failures below are about the title, not
## -- about a reader that finds nothing ----------------------------------------

test_that("the reader finds the twelve popovers and a title entry on each", {
  calls <- popoverCalls()
  expect_length(calls, 12L)
  expect_true(all(grepl("'title': '", calls, fixed = TRUE)))
  expect_false(anyNA(vapply(calls, popoverTitle, character(1L))))
})

## -- The defect (RED) ------------------------------------------------------------

test_that("no Summary Statistics export popover title reads character(0)", {
  calls <- popoverCalls()
  titles <- vapply(calls, popoverTitle, character(1L))
  offenders <- names(titles)[titles == "character(0)"]
  expect_length(offenders, 0L)
  expect_false(any(grepl("character(0)", calls, fixed = TRUE)),
               info = paste("offenders:", paste(offenders, collapse = ", ")))
})

test_that("every export popover title is empty, so the title bar is not drawn", {
  calls <- popoverCalls()
  for (id in names(calls)) {
    expect_identical(popoverTitle(calls[[id]]), "", info = id)
  }
})

## -- What must not change (green at HEAD and after) ---------------------------

test_that("the twelve popovers keep their button ids and their sentences", {
  calls <- popoverCalls()
  expect_setequal(names(calls), popoverIds)
  contents <- vapply(calls, popoverContent, character(1L))
  expect_true(all(nzchar(contents)))
  ## The two relationship exports are the only popovers the sentence test in
  ## test_docsAuditHousekeepingWording.R does not pin.
  expect_identical(
    unname(contents["downloadRelationships"]),
    "This exports all pairwise relationship designations to a CSV file."
  )
  expect_identical(
    unname(contents["downloadRelationClasses"]),
    "This exports the relationship class frequency table to a CSV file."
  )
})
