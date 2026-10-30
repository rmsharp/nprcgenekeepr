## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S1040; issue #170, Slice 4 of the retrospective colony-snapshot
## backfill; design docs/planning/retrospective-snapshot-backfill-plan.md
## sections 5 and 5.3). The feature is built (Slices 1-3); this slice says so in
## the places a colony manager or a script user looks. The owner approved one
## sentence for each place at the S1040 scope question (AskUserQuestion), so each
## block pins what its sentence must carry, not every word:
##
##  - the colony manager guide, section "Genetic-Health Trends": a fourth
##    workflow item, a paragraph on what a rebuilt snapshot cannot tell you
##    (design B12), and one on an animal the studbook lists as neither alive nor
##    departed;
##  - NEWS.Rmd and NEWS.md, part "Longitudinal Monitoring": the button, then the
##    two functions;
##  - the help of backfillColonySnapshots(): its Limits paragraph.
##
## The guide, NEWS.Rmd and NEWS.md are build-ignored and man/ and R/ are not in
## an installed package, so each block skips outside the source tree.
## guideSectionParagraphs() is in helper-guideSections.R; sourceLines(),
## plainText(), expectNames(), helpPlaces() and skipUnlessHelpInSourceTree() are
## in helper-pageText.R; newsSectionLines() and newsEntries() are in
## helper-newsBlocks.R. The release-state guard (test_newsReleaseState.R) reads
## the new NEWS entries without a line of its own here.

library(testthat)

trendsParagraphs <- function() guideSectionParagraphs("Genetic-Health Trends")

limitsStart <- "A rebuilt snapshot looks back with today's records"
unknownFate <- "neither alive nor departed"

# ---- the guide: controls pass before the guide changes ---------------------

test_that("the reader finds the Genetic-Health Trends section and stops before the Conclusion", {
  paragraphs <- trendsParagraphs()
  expect_true(any(grepl("^The \\*\\*Genetic-Health Trends\\*\\* tab",
                        paragraphs)))
  expect_true(any(grepl("**Generate Snapshot.**", paragraphs, fixed = TRUE)))
  expect_false(any(grepl("This article covered", paragraphs, fixed = TRUE)))
})

test_that("the three items that were there and the text-only note stay", {
  paragraphs <- trendsParagraphs()
  workflow <- onlyParagraphWith(paragraphs, "**Generate Snapshot.**")
  expect_true(nzchar(workflow), label = "the workflow list exists")
  expectNames(workflow, c("1. **Snapshot history.**",
                          "2. **Generate Snapshot.**",
                          "3. **Trends and comparisons.**"))
  expect_length(grep("This section is text-only", paragraphs, fixed = TRUE),
                1L)
})

# ---- the guide: the failing blocks -----------------------------------------

test_that("the guide says the workflow has four parts", {
  paragraphs <- trendsParagraphs()
  expect_true(nzchar(onlyParagraphWith(paragraphs,
                                       "The workflow has four parts:")))
  expect_length(grep("The workflow has three parts", paragraphs, fixed = TRUE),
                0L)
})

test_that("the fourth item is Build Earlier Snapshots, after Trends and comparisons", {
  workflow <- onlyParagraphWith(trendsParagraphs(), "**Generate Snapshot.**")
  expect_true(nzchar(workflow), label = "the workflow list exists")
  expectNames(workflow, c(
    "4. **Build Earlier Snapshots.**",
    "Once you have run Genetic Value Analysis",
    "one snapshot for each past 1 January",
    "birth and exit dates already in the studbook",
    "instead of after seasons of recording",
    "drawn as a dashed line",
    "apart from snapshots recorded at the time"
  ))
  fourth <- as.integer(regexpr("4. **Build Earlier Snapshots.**", workflow,
                               fixed = TRUE))
  third <- as.integer(regexpr("3. **Trends and comparisons.**", workflow,
                              fixed = TRUE))
  expect_gt(fourth, third)
})

test_that("a paragraph says what a rebuilt snapshot cannot tell you", {
  paragraph <- onlyParagraphWith(trendsParagraphs(), limitsStart)
  expect_true(nzchar(paragraph), label = "the paragraph exists")
  expectNames(paragraph, c(
    "a parent identified later counts as known earlier",
    "today's genotypes are used for every date",
    "only animals with a birth date, or with an offspring that has one, are placed",
    "when few sires were recorded",
    "random sampling every snapshot has",
    "beside the counts on the **Earlier Snapshots** tab"
  ))
})

test_that("a paragraph says how an animal of unknown fate is counted", {
  paragraph <- onlyParagraphWith(trendsParagraphs(), unknownFate)
  expect_true(nzchar(paragraph), label = "the paragraph exists")
  expectNames(paragraph, c(
    "is left out of the count of animals",
    "still treat it as living when it is a recorded parent",
    "as they do for the snapshot recorded today"
  ))
})

test_that("the new paragraphs follow the workflow list, in that order, before the note", {
  paragraphs <- trendsParagraphs()
  at <- function(text) {
    hit <- grep(text, paragraphs, fixed = TRUE)
    if (length(hit) == 1L) hit else NA_integer_
  }
  positions <- c(workflow = at("**Generate Snapshot.**"),
                 limits = at(limitsStart),
                 unknown = at(unknownFate),
                 note = at("This section is text-only"))
  expect_false(anyNA(positions))
  expect_identical(unname(order(positions)), 1:4)
})

test_that("the guide names the box and the tab as the app does", {
  html <- as.character(modSnapshotTrendsUI("t"))
  for (name in c("Build Earlier Snapshots", "Earlier Snapshots")) {
    expect_true(grepl(name, html, fixed = TRUE), info = paste("app:", name))
  }
  paragraphs <- trendsParagraphs()
  expect_length(grep("**Build Earlier Snapshots.**", paragraphs, fixed = TRUE),
                1L)
  expect_length(grep("**Earlier Snapshots** tab", paragraphs, fixed = TRUE), 1L)
})

# ---- NEWS.Rmd and NEWS.md ----------------------------------------------------

## The plain text of each bullet of the "## Longitudinal Monitoring" part of the
## newest version block of one NEWS file: backticks and asterisks dropped, and
## the backslash NEWS.md puts before a "#" too. One string per bullet; none when
## the part is missing, so a block fails on its words.
longitudinalEntries <- function(file) {
  part <- newsSectionLines(sourceLines(file), "Longitudinal Monitoring")
  entries <- newsEntries(list(start = 1L, lines = part))
  gsub("\\\\", "", vapply(entries$text, plainText, character(1L),
                          USE.NAMES = FALSE))
}

test_that("the two functions the NEWS entries name are exported", {
  expect_true(all(c("backfillColonySnapshots", "previewBackfillSupport") %in%
                    getNamespaceExports("nprcgenekeepr")))
})

for (file in c("NEWS.Rmd", "NEWS.md")) {
  local({
    newsFile <- file

    test_that(paste(newsFile, "keeps the Longitudinal Monitoring entries it had"), {
      entries <- longitudinalEntries(newsFile)
      expect_length(grep("Script users: readSnapshotHistory()", entries,
                         fixed = TRUE), 1L)
      expect_length(grep("New Genetic-Health Trends tab: upload or start a history",
                         entries, fixed = TRUE), 1L)
    })

    test_that(paste(newsFile, "says what Build Earlier Snapshots does, once, under Longitudinal Monitoring"), {
      entries <- longitudinalEntries(newsFile)
      hit <- grep("Build Earlier Snapshots", entries, fixed = TRUE, value = TRUE)
      expect_length(hit, 1L)
      expectNames(paste(hit, collapse = " "), c(
        "Genetic-Health Trends tab",
        "rebuilds a yearly history from the birth and exit dates in the studbook",
        "without waiting for new snapshots",
        "drawn dashed",
        "kept apart from recorded ones",
        "(issue #170)"
      ), where = newsFile)
    })

    test_that(paste(newsFile, "names the two functions in a Script users entry"), {
      entries <- longitudinalEntries(newsFile)
      hit <- grep("backfillColonySnapshots()", entries, fixed = TRUE,
                  value = TRUE)
      expect_length(hit, 1L)
      text <- paste(hit, collapse = " ")
      expect_true(startsWith(text, "Script users:"), info = newsFile)
      expectNames(text, c(
        "previewBackfillSupport()",
        "does the same from a script",
        "how many animals each date rests on",
        "without the long calculation"
      ), where = newsFile)
    })
  })
}

# ---- the help of backfillColonySnapshots() ------------------------------------

backfillHelpPlaces <- helpPlaces("backfillColonySnapshots",
                                 "backfillColonySnapshots.R")

for (place in names(backfillHelpPlaces)) {
  local({
    helpPlace <- place

    test_that(paste0("backfillColonySnapshots's ", helpPlace,
                     " keeps the limits it had"), {
      skipUnlessHelpInSourceTree(backfillHelpPlaces)
      text <- backfillHelpPlaces[[helpPlace]]()
      expectNames(text, c("a parent identified later is treated as known earlier",
                          "calcNeSexRatio"), where = helpPlace)
    })

    test_that(paste0("backfillColonySnapshots's ", helpPlace,
                     " names today's genotypes and gene-drop sampling as limits"), {
      skipUnlessHelpInSourceTree(backfillHelpPlaces)
      text <- backfillHelpPlaces[[helpPlace]]()
      expectNames(text, c(
        "Limits: today's parentage and today's genotypes are used for every date,",
        "two close dates can differ only by gene-drop sampling"
      ), where = helpPlace)
    })
  })
}
