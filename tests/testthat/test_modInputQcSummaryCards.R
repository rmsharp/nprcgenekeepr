## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# The Input tab's QC Summary shows three boxes: Records Processed, Errors and
# Warnings. The app's theme is Bootstrap 4 (bslib, flatly), which has no styling
# for the Bootstrap 3 "panel" classes the boxes used to carry, so every box
# showed plain grey (BACKLOG.md:8, found S933; the cause was found S936: the
# compiled theme has 0 ".panel" rules and 113 ".card" rules). The boxes are now
# Bootstrap 4 cards: a header coloured by what the check found (red when there
# are errors, orange when there are warnings, green when the count is 0) and a
# body holding the count. Headless shiny::testServer only; the serialized HTML
# text is matched, as elsewhere in this suite.

testthat::skip_on_cran()

# --- fixtures ---------------------------------------------------------------

# A storedResults() payload with the given numbers of error and warning rows.
storedWith <- function(nErrors = 0L, nWarnings = 0L, nRecords = 1L) {
  cleaned <- if (nRecords > 0L) {
    data.frame(id = LETTERS[seq_len(nRecords)], stringsAsFactors = FALSE)
  } else {
    NULL
  }
  list(
    cleaned = cleaned,
    errors = data.frame(Row = rep(NA_integer_, nErrors),
                        Error = rep("Some Error", nErrors),
                        Details = rep("detail", nErrors),
                        stringsAsFactors = FALSE),
    warnings = data.frame(Row = rep(NA_integer_, nWarnings),
                          Warning = rep("Some Warning", nWarnings),
                          Details = rep("detail", nWarnings),
                          stringsAsFactors = FALSE),
    changedCols = NULL, hasChangedCols = FALSE, genotype = NULL
  )
}

# The rendered QC summary as one HTML string.
renderSummaryHtml <- function(stored) {
  html <- NULL
  shiny::testServer(modInputServer, {
    storedResults(stored)
    session$flushReact()
    html <<- paste(as.character(output$qcSummaryUI), collapse = "")
  })
  html
}

# The three boxes of the rendered summary, as one HTML string per box, in the
# order Records Processed, Errors, Warnings. A box is the text from one
# <div class="card ..."> up to the next one (or the end of the string).
renderSummaryBoxes <- function(stored) {
  html <- renderSummaryHtml(stored)
  starts <- gregexpr("<div class=\"card[ \"]", html)[[1L]]
  if (starts[1L] < 0L) return(character(0L))
  ends <- c(starts[-1L] - 1L, nchar(html))
  substring(html, starts, ends)
}

# The one box with this title. A missing box is reported as a missing box (and
# returns "" so the colour checks that follow still run).
boxFor <- function(boxes, title) {
  hit <- boxes[grepl(paste0(">", title, "<"), boxes, fixed = TRUE)]
  expect_length(hit, 1L)
  if (length(hit) == 1L) hit else ""
}

# --- the colour follows what the check found --------------------------------

test_that("clean data: Records Processed is blue, Errors and Warnings are green", {
  boxes <- renderSummaryBoxes(storedWith(nErrors = 0L, nWarnings = 0L))
  expect_length(boxes, 3L)
  expect_match(boxFor(boxes, "Records Processed"), "bg-primary", fixed = TRUE)
  expect_match(boxFor(boxes, "Errors"), "bg-success", fixed = TRUE)
  expect_match(boxFor(boxes, "Warnings"), "bg-success", fixed = TRUE)
})

test_that("one error turns the Errors box red and leaves Warnings green", {
  boxes <- renderSummaryBoxes(storedWith(nErrors = 1L, nWarnings = 0L))
  expect_match(boxFor(boxes, "Errors"), "bg-danger", fixed = TRUE)
  expect_match(boxFor(boxes, "Errors"), "border-danger", fixed = TRUE)
  expect_match(boxFor(boxes, "Warnings"), "bg-success", fixed = TRUE)
})

test_that("one warning turns the Warnings box orange and leaves Errors green", {
  boxes <- renderSummaryBoxes(storedWith(nErrors = 0L, nWarnings = 1L))
  expect_match(boxFor(boxes, "Warnings"), "bg-warning", fixed = TRUE)
  expect_match(boxFor(boxes, "Warnings"), "border-warning", fixed = TRUE)
  expect_match(boxFor(boxes, "Errors"), "bg-success", fixed = TRUE)
})

test_that("errors and warnings together colour both boxes and keep the fix message", {
  stored <- storedWith(nErrors = 3L, nWarnings = 2L)
  boxes <- renderSummaryBoxes(stored)
  expect_match(boxFor(boxes, "Errors"), "bg-danger", fixed = TRUE)
  expect_match(boxFor(boxes, "Warnings"), "bg-warning", fixed = TRUE)
  html <- renderSummaryHtml(stored)
  expect_match(html, "alert-danger", fixed = TRUE)
  expect_match(html, "Please review and fix errors", fixed = TRUE)
})

# --- each count sits in the box with its own colour -------------------------

test_that("each count is shown in the box that carries its colour", {
  boxes <- renderSummaryBoxes(
    storedWith(nErrors = 3L, nWarnings = 2L, nRecords = 5L))
  expect_match(boxFor(boxes, "Records Processed"), "<h2>5</h2>", fixed = TRUE)
  expect_match(boxFor(boxes, "Errors"), "<h2>3</h2>", fixed = TRUE)
  expect_match(boxFor(boxes, "Warnings"), "<h2>2</h2>", fixed = TRUE)
  expect_false(grepl("bg-warning", boxFor(boxes, "Errors"), fixed = TRUE))
  expect_false(grepl("bg-danger", boxFor(boxes, "Warnings"), fixed = TRUE))
})

# --- the cause: no Bootstrap 3 panel class is left --------------------------

test_that("no Bootstrap 3 panel class is left in the QC summary", {
  for (stored in list(storedWith(0L, 0L), storedWith(2L, 0L),
                      storedWith(0L, 2L), storedWith(2L, 2L))) {
    html <- renderSummaryHtml(stored)
    expect_false(grepl("panel", html, fixed = TRUE))
    expect_match(html, "card-header", fixed = TRUE)
    expect_match(html, "card-body", fixed = TRUE)
  }
})

# --- edge: no records at all -------------------------------------------------

test_that("zero records and zero errors still draws three green-or-blue boxes", {
  boxes <- renderSummaryBoxes(storedWith(0L, 0L, nRecords = 0L))
  expect_length(boxes, 3L)
  expect_match(boxFor(boxes, "Records Processed"), "<h2>0</h2>", fixed = TRUE)
  expect_match(boxFor(boxes, "Errors"), "bg-success", fixed = TRUE)
  expect_match(boxFor(boxes, "Warnings"), "bg-success", fixed = TRUE)
  html <- renderSummaryHtml(storedWith(0L, 0L, nRecords = 0L))
  expect_false(grepl("Data passed quality control", html, fixed = TRUE))
})
