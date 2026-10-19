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

pkg_root <- testthat::test_path("..", "..")
guidePath <- file.path(pkg_root, "vignettes", "articles",
                       "colony-manager-guide.qmd")

# The paragraphs of one "###" section of the guide, each as one line of text
# with its white space collapsed. Fenced code is blanked first, so a comment
# line inside a chunk cannot end the section. A heading the guide lacks gives
# character(0), so a block fails on its words, not on an error.
guideSectionParagraphs <- function(heading) {
  skip_if_not(file.exists(guidePath), "colony manager guide not present")
  lines <- readLines(guidePath, warn = FALSE)
  fence <- grepl("^```", lines)
  lines[cumsum(fence) %% 2L == 1L | fence] <- ""
  start <- which(lines == paste("###", heading))
  if (length(start) != 1L) {
    return(character(0))
  }
  later <- which(grepl("^#{2,3} ", lines) & seq_along(lines) > start)
  end <- if (length(later) > 0L) min(later) - 1L else length(lines)
  body <- lines[seq.int(start + 1L, end)]
  blank <- !nzchar(trimws(body))
  if (all(blank)) {
    return(character(0))
  }
  paragraphs <- tapply(body[!blank], cumsum(blank)[!blank], paste,
                       collapse = " ")
  gsub("\\s+", " ", trimws(unname(paragraphs)))
}

# The one paragraph holding a piece of text, or "" when no paragraph or more
# than one holds it, so a missing or doubled sentence fails on its words.
onlyParagraphWith <- function(paragraphs, text) {
  hit <- grep(text, paragraphs, fixed = TRUE)
  if (length(hit) == 1L) paragraphs[hit] else ""
}

# ---- controls: they pass before the guide changes -------------------------

test_that("the two app sentences the guide quotes are the ones expected", {
  breedingGroupsNote <- nprcgenekeepr:::.breedingGroupsOutsidePedigreeNote
  geneticDiversityNote <- nprcgenekeepr:::.groupsOutsidePedigreeNote
  expect_match(breedingGroupsNote,
               "are not in the pedigree now loaded", fixed = TRUE)
  expect_match(breedingGroupsNote,
               "Form the groups again, or bring back the earlier pedigree",
               fixed = TRUE)
  expect_match(geneticDiversityNote,
               "are not in the pedigree now loaded", fixed = TRUE)
  expect_match(geneticDiversityNote,
               "Form the groups again to see the heat map.", fixed = TRUE)
})

test_that("the section reader returns each section and stops at the next", {
  breedingGroups <- guideSectionParagraphs("Breeding Group Formation")
  geneticDiversity <- guideSectionParagraphs("Genetic Diversity")
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
  note <- nprcgenekeepr:::.breedingGroupsOutsidePedigreeNote
  paragraphs <- guideSectionParagraphs("Breeding Group Formation")
  expect_length(grep(note, paragraphs, fixed = TRUE), 1L)
})

test_that("that paragraph names the three sub-tabs and what causes it", {
  note <- nprcgenekeepr:::.breedingGroupsOutsidePedigreeNote
  paragraph <- onlyParagraphWith(
    guideSectionParagraphs("Breeding Group Formation"), note
  )
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
  note <- nprcgenekeepr:::.breedingGroupsOutsidePedigreeNote
  paragraphs <- guideSectionParagraphs("Breeding Group Formation")
  here <- grep(note, paragraphs, fixed = TRUE)
  statistics <- grep("^A \\*\\*Statistics\\*\\* sub-tab summarizes",
                     paragraphs)
  expect_true(length(here) == 1L && length(statistics) == 1L &&
                here > statistics,
              label = "the sentence follows the Statistics paragraph")
})

# ---- place B: Genetic Diversity -------------------------------------------

test_that("the Genetic Diversity section ends the app's closing words", {
  note <- nprcgenekeepr:::.groupsOutsidePedigreeNote
  closing <- sub("^.*\\)\\. ", "", note)
  expect_identical(closing, "Form the groups again to see the heat map.")
  paragraphs <- guideSectionParagraphs("Genetic Diversity")
  expect_length(grep(closing, paragraphs, fixed = TRUE), 1L)
})

test_that("that paragraph says the sentence takes the heat map's place", {
  paragraph <- onlyParagraphWith(
    guideSectionParagraphs("Genetic Diversity"),
    "Form the groups again to see the heat map."
  )
  expect_true(nzchar(paragraph), label = "the paragraph exists")
  expect_match(paragraph, "in place of the heat map", fixed = TRUE)
  expect_match(paragraph, "no longer has", fixed = TRUE)
  expect_match(paragraph, "reading a different pedigree or trimming the view",
               fixed = TRUE)
})

test_that("the guidance sentence the paragraph already had stays", {
  paragraph <- onlyParagraphWith(
    guideSectionParagraphs("Genetic Diversity"),
    "Form the groups again to see the heat map."
  )
  expect_match(
    paragraph,
    paste("Until groups are formed and an analysis has run, the tab shows",
          "guidance instead of an empty plot."),
    fixed = TRUE
  )
})
