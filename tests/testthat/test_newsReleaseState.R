## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Release-note wording guard (S788, stage 1 of the NEWS.Rmd release-state
## sweep; Learning 785, owner ruling S774).
##
## NEWS.Rmd states the package's finished state at release, relative to the
## PRIOR release -- never an in-progress milestone ("first step", "continued",
## "final step", "groundwork", "arrives in a later step"). These tests scan the
## newest version block of NEWS.Rmd (the development block while one exists)
## for those markers, and check the detector itself on synthetic text so a
## guard that scans nothing, or misses a phrase, cannot pass silently.
##
## Later stages of the sweep add their own phrase patterns here, each one
## first as a failing test.
##
## NEWS.Rmd is build-ignored, so the two real-file tests skip inside an R CMD
## check tarball, like test_effectivePopulationSizeDocs.R.

library(testthat)

## The newest version block: from the first "# nprcgenekeepr" heading up to
## (not including) the second one. Returns the heading's 1-based line number
## in the file and the block's lines; an empty block if no heading exists.
newsTopBlock <- function(lines) {
  heads <- grep("^# nprcgenekeepr", lines)
  if (length(heads) == 0L) {
    return(list(start = 0L, lines = character(0L)))
  }
  end <- if (length(heads) > 1L) heads[2L] - 1L else length(lines)
  list(start = heads[1L], lines = lines[heads[1L]:end])
}

## The bullet entries of a block. An entry starts at a line beginning "- " and
## runs over the indented lines that follow it; `line` is the file line the
## entry starts on and `text` its wrapped lines joined into one string.
newsEntries <- function(block) {
  ls <- block$lines
  starts <- grep("^- ", ls)
  entries <- lapply(starts, function(i) {
    j <- i
    while (j < length(ls) && grepl("^  \\S", ls[j + 1L])) {
      j <- j + 1L
    }
    text <- paste(trimws(ls[i:j]), collapse = " ")
    data.frame(line = block$start + i - 1L, text = sub("^- ", "", text),
               stringsAsFactors = FALSE)
  })
  if (length(entries) == 0L) {
    return(data.frame(line = integer(0L), text = character(0L),
                      stringsAsFactors = FALSE))
  }
  do.call(rbind, entries)
}

## Markers of an in-progress milestone; matched case-insensitively.
milestonePhrases <- c(
  "continued)" = "continued\\)",
  "first/final/next step" = "\\b(first|final|next) step\\b",
  "later step(s)" = "\\blater steps?\\b",
  "groundwork" = "\\bgroundwork\\b",
  "arrive(s) in" = "\\barrives? in\\b",
  "follows below" = "\\bfollows below\\b",
  "future pass" = "\\bfuture pass\\b",
  "Development continues" = "Development continues",
  "yet" = "\\byet\\b"
)

## One row per (entry line, phrase) match.
findMilestones <- function(entries, phrases = milestonePhrases) {
  hits <- lapply(seq_len(nrow(entries)), function(i) {
    matched <- names(phrases)[vapply(phrases, grepl, logical(1L),
                                     x = entries$text[i], ignore.case = TRUE)]
    if (length(matched) == 0L) return(NULL)
    data.frame(line = entries$line[i], phrase = matched,
               stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, hits)
  if (is.null(out)) {
    return(data.frame(line = integer(0L), phrase = character(0L),
                      stringsAsFactors = FALSE))
  }
  out
}

asEntry <- function(text, line = 1L) {
  data.frame(line = line, text = text, stringsAsFactors = FALSE)
}

test_that("newsTopBlock() returns only the newest version block", {
  lines <- c("---", "title: NEWS", "---",
             "# nprcgenekeepr 3.0.0.9000 (development version)", "",
             "## Section", "- A new thing.",
             "# nprcgenekeepr 3.0.0 (20260101)", "- The first step older.",
             "# nprcgenekeepr 2.0.0 (20250101)", "- Oldest.")
  block <- newsTopBlock(lines)
  expect_identical(block$start, 4L)
  expect_identical(block$lines, lines[4:7])
})

test_that("newsTopBlock() copes with one heading and with none", {
  one <- c("intro", "# nprcgenekeepr 1.0 (20200101)", "- Only block.")
  expect_identical(newsTopBlock(one)$start, 2L)
  expect_identical(newsTopBlock(one)$lines, one[2:3])
  none <- newsTopBlock(c("no", "headings"))
  expect_identical(none$start, 0L)
  expect_length(none$lines, 0L)
  expect_identical(nrow(newsEntries(none)), 0L)
})

test_that("newsEntries() joins wrapped lines and reports the start line", {
  block <- list(start = 10L,
                lines = c("## Section", "- One entry that wraps",
                          "  onto a second line.", "- Second entry.", "",
                          "Prose that is not a bullet.", "- Third."))
  entries <- newsEntries(block)
  expect_identical(entries$line, c(11L, 13L, 16L))
  expect_identical(entries$text,
                   c("One entry that wraps onto a second line.",
                     "Second entry.", "Third."))
})

test_that("the detector fires on every in-progress milestone phrase", {
  positives <- c(
    "continued)" = paste("Ancestry rules are now enforced (issue #168,",
                         "continued): hand a rules file to group formation."),
    "first/final/next step" =
      "This is the first step toward MHC haplotype frequency reporting.",
    "first/final/next step" =
      "The guardrails are now complete (issue #168, final step): a new tab.",
    "first/final/next step" =
      "Viewing trends in the app arrives in the next step of this work.",
    "later step(s)" =
      "Enforcement during group formation arrives in later steps of this work.",
    "later step(s)" = "It will use the rules in a later step of this work.",
    "groundwork" =
      "A running history file: the groundwork for seeing trends over time.",
    "arrive(s) in" = "The in-app violations view arrive in a later release.",
    "follows below" = "\"Rectilinear\" support follows below.",
    "future pass" =
      "Two rarer cases remain open, disclosed follow-ups for a future pass.",
    "Development continues" = "Development continues here on top of it.",
    "yet" = "Script-callable only; no Shiny screen yet."
  )
  for (i in seq_along(positives)) {
    hits <- findMilestones(asEntry(positives[[i]]))
    expect_true(names(positives)[i] %in% hits$phrase,
                info = paste0("'", names(positives)[i], "' missed in: ",
                              positives[[i]]))
  }
})

test_that("the detector ignores letter case", {
  hits <- findMilestones(asEntry("Groundwork for ancestry guardrails."))
  expect_identical(hits$phrase, "groundwork")
})

test_that("the detector stays silent on release-state wording", {
  controls <- c(
    "Colony managers can now see genetic-health trends directly in the app.",
    "A step-by-step guide walks through each pedigree.",
    "Continued fractions are not used.",
    "The yeti dataset is unrelated.",
    "Ancestry rules are enforced during group formation, in every mode."
  )
  for (txt in controls) {
    expect_identical(nrow(findMilestones(asEntry(txt))), 0L, info = txt)
  }
})

test_that("findMilestones() reports each entry's line and every phrase", {
  entries <- rbind(asEntry("Clean release-state wording.", 20L),
                   asEntry("Groundwork now; arrives in a later step.", 30L))
  hits <- findMilestones(entries)
  expect_identical(hits$line, c(30L, 30L, 30L))
  expect_setequal(hits$phrase,
                  c("groundwork", "arrive(s) in", "later step(s)"))
})

test_that("the newest NEWS.Rmd block has no in-progress milestone phrases", {
  path <- testthat::test_path("..", "..", "NEWS.Rmd")
  skip_if_not(file.exists(path), "NEWS.Rmd not present in this build")
  block <- newsTopBlock(readLines(path, warn = FALSE))
  entries <- newsEntries(block)
  ## A guard that scanned nothing would pass for the wrong reason.
  expect_gt(nrow(entries), 0L)
  hits <- findMilestones(entries)
  found <- sprintf(":%d %s", hits$line, hits$phrase)
  expect_identical(found, character(0L),
                   info = paste("NEWS.Rmd line and phrase:",
                                paste(found, collapse = "; ")))
})

test_that("NEWS.Rmd describes issue #168 (ancestry guardrails) in one entry", {
  path <- testthat::test_path("..", "..", "NEWS.Rmd")
  skip_if_not(file.exists(path), "NEWS.Rmd not present in this build")
  entries <- newsEntries(newsTopBlock(readLines(path, warn = FALSE)))
  mentions <- entries$line[grepl("#168", entries$text, fixed = TRUE)]
  expect_equal(length(mentions), 1L,
               info = paste("entries mentioning #168 start at lines:",
                            paste(mentions, collapse = ", ")))
})
