## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:168 (found S995, widened S996; the owner chose "both places, as
## drafted" at the S1017 scope question). The app says one sentence when a
## formed group holds an animal the loaded pedigree no longer has (a new file
## was read, or the view was trimmed, after the groups were formed):
##
##  - the Breeding Groups Groups, Statistics and Group Detail pages say
##    .breedingGroupsOutsidePedigreeNote (R/modBreedingGroups.R);
##  - the Genetic Diversity page says .groupsOutsidePedigreeNote, in place of
##    the heat map (R/modGeneticDiversity.R).
##
## NEWS.Rmd says it, but the colony manager guide named it nowhere, so a reader
## who met the sentence had nowhere to look it up. The guide now carries it in
## the two places the owner chose:
##
##  A. the Breeding Group Formation section, in a paragraph of its own after
##     the Statistics paragraph, quoting the app's whole sentence;
##  B. the Genetic Diversity section, in the paragraph that already says what
##     the tab shows before groups are formed, ending with the app's own
##     closing words.
##
## The guide quotes the app, so a later change to either app sentence fails
## the control block until the guide follows. The blocks that read the guide
## read ../../vignettes/articles/..., which .Rbuildignore excludes: a built
## package holds no copy, so they skip in a built package and under
## `devtools::check()`, and run from the source tree, where the close-out suite
## runs. The "Export Current Group" stop in that state is a code finding, not
## guide wording (BACKLOG.md), so no block here touches it.

## guideSectionParagraphs() and onlyParagraphWith() are in
## helper-guideSections.R (S1040: this file held them until the second test
## file needing them arrived; the helper reads the guide with sourceLines(),
## which skips a block when the guide is absent, as the old copy did).

# The app's two sentences and the closing words place B ends with, each
# written once. The two sections are read inside each block, never at the top
# of the file: the guide may be absent, and that must skip the block, not the
# file.
breedingGroupsNote <- nprcgenekeepr:::.breedingGroupsOutsidePedigreeNote
geneticDiversityNote <- nprcgenekeepr:::.groupsOutsidePedigreeNote
heatMapClosing <- "Form the groups again to see the heat map."

breedingGroupsSection <- function() {
  guideSectionParagraphs("Breeding Group Formation")
}

geneticDiversitySection <- function() {
  guideSectionParagraphs("Genetic Diversity")
}

# ---- controls: they pass before the guide changes -------------------------

test_that("the two app sentences the guide quotes are the ones expected", {
  expect_match(breedingGroupsNote,
               "are not in the pedigree now loaded", fixed = TRUE)
  expect_match(breedingGroupsNote,
               "Form the groups again, or bring back the earlier pedigree",
               fixed = TRUE)
  expect_match(geneticDiversityNote,
               "are not in the pedigree now loaded", fixed = TRUE)
  expect_match(geneticDiversityNote, heatMapClosing, fixed = TRUE)
})

test_that("the section reader returns each section and stops at the next", {
  breedingGroups <- breedingGroupsSection()
  geneticDiversity <- geneticDiversitySection()
  expect_true(any(grepl("^A \\*\\*Statistics\\*\\* sub-tab summarizes",
                        breedingGroups)))
  expect_false(any(grepl("Mate Pair", breedingGroups, fixed = TRUE)))
  expect_true(any(grepl("^The \\*\\*Genetic Diversity\\*\\* tab",
                        geneticDiversity)))
  expect_false(any(grepl("Marker Genetics", geneticDiversity, fixed = TRUE)))
  expect_length(guideSectionParagraphs("A heading the guide lacks"), 0L)
})

# ---- place A: Breeding Group Formation ------------------------------------

test_that("the Breeding Groups section quotes the app's sentence", {
  expect_length(grep(breedingGroupsNote, breedingGroupsSection(),
                     fixed = TRUE), 1L)
})

test_that("that paragraph names the three sub-tabs and what causes it", {
  paragraph <- onlyParagraphWith(breedingGroupsSection(), breedingGroupsNote)
  expect_true(nzchar(paragraph), label = "the paragraph exists")
  expect_match(paragraph, "different pedigree", fixed = TRUE)
  expect_match(paragraph, "trim the pedigree on the Pedigree Browser",
               fixed = TRUE)
  expect_match(paragraph, "no longer has", fixed = TRUE)
  expect_match(
    paragraph,
    "**Groups**, **Statistics** and **Group Detail** sub-tabs",
    fixed = TRUE
  )
  expect_match(paragraph, "in place of their tables", fixed = TRUE)
})

test_that("that paragraph comes after the Statistics paragraph", {
  paragraphs <- breedingGroupsSection()
  here <- grep(breedingGroupsNote, paragraphs, fixed = TRUE)
  statistics <- grep("^A \\*\\*Statistics\\*\\* sub-tab summarizes",
                     paragraphs)
  expect_true(length(here) == 1L && length(statistics) == 1L &&
                here > statistics,
              label = "the sentence follows the Statistics paragraph")
})

# ---- place B: Genetic Diversity -------------------------------------------

test_that("the Genetic Diversity section ends the app's closing words", {
  expect_identical(sub("^.*\\)\\. ", "", geneticDiversityNote), heatMapClosing)
  expect_length(grep(heatMapClosing, geneticDiversitySection(), fixed = TRUE),
                1L)
})

test_that("that paragraph says the sentence takes the heat map's place", {
  paragraph <- onlyParagraphWith(geneticDiversitySection(), heatMapClosing)
  expect_true(nzchar(paragraph), label = "the paragraph exists")
  expect_match(paragraph, "in place of the heat map", fixed = TRUE)
  expect_match(paragraph, "no longer has", fixed = TRUE)
  expect_match(paragraph, "reading a different pedigree or trimming the view",
               fixed = TRUE)
})

test_that("the guidance sentence the paragraph already had stays", {
  paragraph <- onlyParagraphWith(geneticDiversitySection(), heatMapClosing)
  expect_match(
    paragraph,
    paste("Until groups are formed and an analysis has run, the tab shows",
          "guidance instead of an empty plot."),
    fixed = TRUE
  )
})
