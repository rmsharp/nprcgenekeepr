## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:138 (ruled S968, built S970): the Breeding Groups tab's Source
## box offered three choices, "Top ranked", "Upload list" (value "custom") and
## "All available". "Upload list" had no control to give it a list, so it
## returned exactly what "All available" returns. S970 removed it.
##
## BACKLOG.md:149 (owner-requested S970, built S973): the third choice is back
## as "My own list" (value "custom" again), with a paste box, "Animal IDs:",
## that gives it the list "Upload list" never had (the behavior is pinned in
## test_modBreedingGroups_ownList.R; the ID reader in test_parseIdList.R).
## This file pins the places that carry the wording, one block each, with the
## sentences the owner approved at the S973 scope question:
##
##  1. the module's UI offers exactly three Source choices, in the order Top
##     ranked, All available, My own list, with no "Upload list";
##  2. the manual page has the My own list bullet, and its Include-box bullets
##     say "All available" or "My own list" and "for all three Source choices"
##     (they said "both" while there were two);
##  3. the guide's Breeding Groups paragraph names the pasted list;
##  4. the module's roxygen and its man page name the three choices;
##  5. NEWS.Rmd says "Upload list" is now "My own list" in one sentence, under
##     Breeding Group Formation, and the S970 sentence is gone;
##  6. NEWS.md, knitted from it, says the same.
##
## The guide's pictures of the tab (breeding_group_*.png) are retaken with the
## change; a picture cannot be pinned here, so the record is in CHANGELOG.md
## (the new paste-box picture is pinned in test_captureHarness.R). Every page
## read below sits outside a built package, so each block skips where its file
## is absent and runs from the source tree.
##
## pageText(), occurrences() and expectWording() live in helper-pageText.R.

removedSentence <- paste(
  "The Source choice on the Breeding Group Formation tab no longer offers",
  "\"Upload list\". It had no place to give it a list, so it formed groups",
  "from every living animal, exactly as \"All available\" does."
)

ownListSentence <- paste(
  "The Source choice \"Upload list\", which had no place to give it a list,",
  "is now \"My own list\". Paste the animal IDs into the box that appears.",
  "Groups are formed from those that are alive; an ID that is not in the",
  "pedigree stops the run and is named, and an animal that is not alive is",
  "left out and named."
)

manualBullet <- paste(
  "My own list: Use only the animals whose IDs you type or paste into the",
  "Animal IDs box (separated by commas, spaces or new lines). An ID that is",
  "not in the pedigree stops the run and is named; an animal that is not",
  "alive is left out and named."
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

test_that("the Source box offers Top ranked, All available and My own list, in that order", {
  text <- gsub("\\s+", " ",
               paste(as.character(modBreedingGroupsUI("bg")), collapse = " "))
  from <- regexpr("id=\"bg-animalSource\"", text, fixed = TRUE)
  to <- regexpr("id=\"bg-inclusionCriterion\"", text, fixed = TRUE)
  expect_gt(as.integer(from), 0L, label = "the Source radio group")
  expect_gt(as.integer(to), as.integer(from), label = "the box after it")
  box <- substring(text, from, to - 1L)
  expect_equal(occurrences(box, "type=\"radio\""), 3L)
  expectWording(
    box,
    now = c("value=\"topRanked\"", "value=\"all\"", "value=\"custom\"",
            "<span>Top ranked</span>", "<span>All available</span>",
            "<span>My own list</span>"),
    gone = "Upload list"
  )
  at <- vapply(c("value=\"topRanked\"", "value=\"all\"", "value=\"custom\""),
               function(v) as.integer(regexpr(v, box, fixed = TRUE)),
               integer(1L))
  expect_false(is.unsorted(at), info = "choices in the order named")
})

test_that("the manual has the My own list bullet and says the floor applies to all three choices", {
  expectWording(
    pageText("vignettes", "manual_components", "_breeding_group_formation.Rmd"),
    now = c("Top ranked: Use the highest-ranked living animals from the",
            "All available: Use every living animal in the current pedigree",
            manualBullet,
            "Include animals by: Choose how candidates are screened",
            "value screening for \"All available\" or \"My own list\".",
            "for all three Source choices"),
    gone = c("Upload list", "for both Source choices",
             "does not yet provide a way to upload")
  )
})

test_that("the guide's Breeding Groups paragraph names three sources, the third a pasted list", {
  expectWording(
    pageText("vignettes", "articles", "colony-manager-guide.qmd"),
    now = paste("population you choose (top-ranked animals from Genetic Value",
                "Analysis, all available animals, or a list of animal IDs you",
                "paste in)"),
    gone = c("an uploaded list",
             "Analysis or all available animals)")
  )
})

test_that("the module's help names the three choices in the code and man page", {
  choices <- paste("\\strong{Animal source}: \"Top ranked\", \"All available\"",
                   "or \"My own list\" (animal IDs typed or pasted by the",
                   "user)")
  for (page in list(c("R", "modBreedingGroups.R"),
                    c("man", "modBreedingGroupsServer.Rd"))) {
    text <- do.call(pageText, c(as.list(page), roxygen = TRUE))
    expectWording(text, now = choices, gone = "Upload list")
    ## The next bullet of the same list is still there.
    expect_gt(occurrences(text, "Living animals only"), 0L, label = page[[2L]])
  }
})

test_that("NEWS.Rmd says Upload list is now My own list, under Breeding Groups, and the S970 sentence is gone", {
  text <- pageText("NEWS.Rmd")
  expectWording(text, now = ownListSentence, gone = removedSentence)
  section <- sectionOf(text, "## Breeding Group Formation",
                       "## Mate Pair Analysis")
  expect_equal(occurrences(section, ownListSentence), 1L)
})

test_that("NEWS.md says it too", {
  expectWording(pageText("NEWS.md"), now = ownListSentence,
                gone = removedSentence)
})
