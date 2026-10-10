## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:65-82 (ruled S954, built S955): with no focal animals entered the
## Pedigree Browser flags the living animals as the population, every animal
## only when nobody is alive. test_modPedigree_defaultPopulation.R pins the
## behavior; this file pins the seven sentences the owner approved at S955, one
## per place, so no page keeps saying "all individuals" or "a population must
## be defined":
##
##  1. the Focal Animals help text in the app,
##  2. the manual's Pedigree Browser workflow, step 2,
##  3. the guide's sentence about clearing the focal animals,
##  4. the guide's paragraph on the population the other tabs analyze,
##  5. the manual's Genetic Value performance note,
##  6. the guide's Genetic-Health Trends membership rule,
##  7. NEWS.Rmd and NEWS.md (a release-state entry), and the module's roxygen
##     and the man page generated from it.
##
## The guide pictures that predate the change were retaken in S956 (the record
## is in CHANGELOG.md); the last two blocks pin the numbers the widened Genetic
## Value picture's caption and alt text quote. The Breeding Groups caption's
## "seven animals" is pinned in test_guideBreedingGroupsWording.R.
##
## Every page read here sits outside a built package (.Rbuildignore'd or not
## installed), so each block skips where its file is absent and runs from the
## source tree, where the close-out suite runs. Emphasis marks (`, *, _), roxygen
## comment marks and line breaks do not count as a difference.

## pageText(), occurrences() and expectWording() live in helper-pageText.R.

guideText <- function() {
  pageText("vignettes", "articles", "colony-manager-guide.qmd")
}

## The example pedigree's living animals as the app's QC step leaves it (the
## block near the end checks this count against the app's own code). With no
## focal animals they are the population, so they are the animals ranked.
exampleLiving <- 332L

test_that("the Focal Animals help says the living animals are analyzed when none are entered", {
  html <- paste(as.character(modPedigreeUI("pb")), collapse = " ")
  text <- gsub("\\s+", " ", gsub("<[^>]+>", " ", html))
  expectWording(
    text,
    now = c(
      paste("Enter focal animal IDs here to analyze them instead of the",
            "living animals; with none entered, the living animals are",
            "analyzed (every animal if none is alive)."),
      "IDs may be pasted from Excel"
    ),
    gone = "if analysis of all individuals is not needed"
  )
})

test_that("the manual's Pedigree Browser workflow says who the population is with no focal animals", {
  expectWording(
    pageText("vignettes", "manual_components", "_pedigree_browser.Rmd"),
    now = paste("Optionally specify focal animals; with none entered, the",
                "living animals are the population (every animal if none is",
                "alive)."),
    gone = "Optionally specify focal animals to narrow your analysis."
  )
})

test_that("the guide says clearing the focal animals makes the living animals the population again", {
  expectWording(
    guideText(),
    now = paste("reads an empty ID list, restoring the full, untrimmed",
                "pedigree and making the living animals the population",
                "again."),
    gone = "restoring the full, untrimmed pedigree."
  )
})

test_that("the guide says the other tabs analyze the living animals when no focal animals are entered", {
  expectWording(
    guideText(),
    now = c(
      paste("With no focal animals entered, the population the other tabs",
            "analyze is the living animals (every animal if none is alive)."),
      paste("continues with the full, untrimmed example pedigree and no",
            "focal animals, so its population is the 332 living animals")
    ),
    gone = paste("A population must be defined here before proceeding to",
                 "Genetic Value Analysis.")
  )
})

test_that("the manual's Genetic Value note names the focal animals, then the living animals", {
  expectWording(
    pageText("vignettes", "manual_components", "_genetic_value_analysis.Rmd"),
    now = paste("(the focal animals you entered in the Pedigree Browser,",
                "otherwise the living animals; every animal when the pedigree",
                "says nobody is alive)"),
    gone = paste("(the living animals, or every animal when the pedigree has",
                 "no exit column)")
  )
})

test_that("the guide's Genetic-Health Trends membership rule names the living animals", {
  expectWording(
    guideText(),
    now = paste("(the whole pedigree, or a smaller population: the living",
                "animals, or the focal animals you entered)"),
    gone = "(the whole pedigree, or a designated focal population)"
  )
})

newsEntry <- paste(
  "With no focal animals entered, the Pedigree Browser now takes the living",
  "animals as the population instead of every animal ever recorded, so the",
  "default Genetic Value rankings and founder measures describe the living",
  "colony. A pedigree with no living animal still uses every animal. Script",
  "users: setPopulation() still flags every animal when given no IDs."
)

test_that("NEWS.Rmd carries the default-population entry once", {
  expectWording(pageText("NEWS.Rmd"), now = newsEntry, gone = character(0L))
})

test_that("NEWS.md, knitted from NEWS.Rmd, carries it too", {
  expectWording(pageText("NEWS.md"), now = newsEntry, gone = character(0L))
})

test_that("the module's roxygen and man page say the population is the focal or the living animals", {
  now <- paste("Adding a \\code{population} column via \\code{setPopulation()}:",
               "the focal animals, or the living animals when none are",
               "entered")
  expectWording(pageText("R", "modPedigree.R", roxygen = TRUE), now,
                character(0L))
  expectWording(pageText("man", "modPedigreeServer.Rd"), now, character(0L))
})

test_that("the guide's 332 is the example pedigree's living count as the app's QC step leaves it", {
  exampleFile <- makeExamplePedigreeFile(
    file.path(tempdir(), "Example_Pedigree.csv"), fileType = "csv"
  )
  cleaned <- runQcStudbook(
    read.csv(exampleFile, stringsAsFactors = FALSE, na.strings = c("", "NA")),
    minSireAge = 2, minDamAge = 2, reportChanges = TRUE
  )$cleaned
  expect_equal(sum(isLivingAnimal(cleaned)), exampleLiving)
})

## Show top N is widened to 500, more than the living animals the default
## ranks, so the table lists every ranked animal, ten rows to a page.
rankedPages <- ceiling(exampleLiving / 10L)

test_that("the guide's widened Genetic Value caption counts the pages of the living animals", {
  expectWording(
    guideText(),
    now = paste0("widened to 500: the results table now has ", rankedPages,
                 " pages of 10 rows, and the first page is shown."),
    gone = "now has 50 pages of 10 rows"
  )
})

test_that("the guide's widened Genetic Value alt text counts the entries and the last page", {
  expectWording(
    guideText(),
    now = paste0("the results table reads Showing 1 to 10 of ", exampleLiving,
                 " entries and its pager runs to page ", rankedPages, "."),
    gone = c("of 500 entries", "its pager runs to page 50")
  )
})
