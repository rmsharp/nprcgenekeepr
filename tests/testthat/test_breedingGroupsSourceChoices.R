## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:138 (ruled S968, built S970): the Breeding Groups tab's Source
## box offered three choices, "Top ranked", "Upload list" (value "custom") and
## "All available". "Upload list" had no control to give it a list, so it
## returned exactly what "All available" returns. It is removed; the server's
## pool code is left alone (the owner took "treat any other value as All
## available, change nothing" at the S970 scope question). This file pins the
## places that carry the change, one block each:
##
##  1. the module's UI offers exactly two Source choices, Top ranked and All
##     available, with no "Upload list" and no "custom" value;
##  2. the manual page drops the Upload-list bullet and no longer counts three
##     Source choices;
##  3. the guide's Breeding Groups paragraph no longer names an uploaded list;
##  4. the module's roxygen and its man page name the two choices only;
##  5. NEWS.Rmd says so in one sentence, under Breeding Group Formation (the
##     owner approved the sentence at the S970 scope question);
##  6. NEWS.md, knitted from it, says the same.
##
## The guide's six pictures of the tab (breeding_group_*.png) were retaken in
## the same session; a picture cannot be pinned here, so the record is in
## CHANGELOG.md. Every page read below sits outside a built package, so each
## block skips where its file is absent and runs from the source tree.
##
## pageText(), occurrences() and expectWording() live in helper-pageText.R.

removedSentence <- paste(
  "The Source choice on the Breeding Group Formation tab no longer offers",
  "\"Upload list\". It had no place to give it a list, so it formed groups",
  "from every living animal, exactly as \"All available\" does."
)

## The text of one "## " section: from `heading` up to (not including) the next
## section heading `after`. Both must be present.
sectionOf <- function(text, heading, after) {
  from <- regexpr(heading, text, fixed = TRUE)
  expect_gt(as.integer(from), 0L, label = heading)
  rest <- substring(text, from)
  to <- regexpr(after, rest, fixed = TRUE)
  expect_gt(as.integer(to), 0L, label = after)
  substring(rest, 1L, to - 1L)
}

test_that("the Source box offers Top ranked and All available, nothing else", {
  text <- gsub("\\s+", " ",
               paste(as.character(modBreedingGroupsUI("bg")), collapse = " "))
  from <- regexpr("id=\"bg-animalSource\"", text, fixed = TRUE)
  to <- regexpr("id=\"bg-inclusionCriterion\"", text, fixed = TRUE)
  expect_gt(as.integer(from), 0L, label = "the Source radio group")
  expect_gt(as.integer(to), as.integer(from), label = "the box after it")
  box <- substring(text, from, to - 1L)
  expect_equal(occurrences(box, "type=\"radio\""), 2L)
  expectWording(
    box,
    now = c("value=\"topRanked\"", "value=\"all\"",
            "<span>Top ranked</span>", "<span>All available</span>"),
    gone = c("value=\"custom\"", "Upload list")
  )
})

test_that("the manual no longer describes an Upload list choice", {
  expectWording(
    pageText("vignettes", "manual_components", "_breeding_group_formation.Rmd"),
    now = c("Top ranked: Use the highest-ranked living animals from the",
            "All available: Use every living animal in the current pedigree",
            "Include animals by: Choose how candidates are screened",
            "value screening for \"All available\".",
            "for both Source choices"),
    gone = c("Upload list", "all three Source choices",
             "does not yet provide a way to upload")
  )
})

test_that("the guide's Breeding Groups paragraph names two sources", {
  expectWording(
    pageText("vignettes", "articles", "colony-manager-guide.qmd"),
    now = paste("population you choose (top-ranked animals from Genetic Value",
                "Analysis or all available animals)"),
    gone = "an uploaded list"
  )
})

test_that("the module's help names the two choices in the code and man page", {
  choices <- "\\strong{Animal source}: \"Top ranked\" or \"All available\""
  for (page in list(c("R", "modBreedingGroups.R"),
                    c("man", "modBreedingGroupsServer.Rd"))) {
    text <- do.call(pageText, c(as.list(page), roxygen = TRUE))
    expectWording(text, now = choices, gone = "Upload list")
    ## The next bullet of the same list is still there.
    expect_gt(occurrences(text, "Living animals only"), 0L, label = page[[2L]])
  }
})

test_that("NEWS.Rmd says the Upload list choice is gone, under Breeding Groups", {
  text <- pageText("NEWS.Rmd")
  expectWording(text, now = removedSentence, gone = character(0L))
  section <- sectionOf(text, "## Breeding Group Formation",
                       "## Mate Pair Analysis")
  expect_equal(occurrences(section, removedSentence), 1L)
})

test_that("NEWS.md says it too", {
  expectWording(pageText("NEWS.md"), now = removedSentence,
                gone = character(0L))
})
