## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:150-159 (ruled S968, built S969): the Genetic Value Analysis tab
## had two check boxes, "Calculate Genome Uniqueness" and "Calculate Mean
## Kinship" (ids calcGenomeUniqueness and calcMeanKinship), that nothing read:
## reportGV() works out both numbers whatever the boxes say, and the tier
## ranking needs both. They are removed. This file pins the four places that
## carry the change, one block each:
##
##  1. the module's UI has neither id nor label, and keeps the controls that do
##     something (a removal that took the whole Analysis Options panel would
##     otherwise pass);
##  2. the manual page's bullet about them ("They currently have no effect") is
##     gone and its neighbouring bullets stay;
##  3. NEWS.Rmd says so in one sentence, under Genetic Value Analysis (the
##     owner approved the sentence at the S969 scope question);
##  4. NEWS.md, knitted from it, says the same.
##
## The guide's three pictures of the tab (gva_*.png) were retaken in the same
## session; a picture cannot be pinned here, so the record is in CHANGELOG.md.
## Every page read below sits outside a built package, so each block skips
## where its file is absent and runs from the source tree.
##
## pageText(), occurrences(), expectWording() and sectionOf() live in
## helper-pageText.R.

removedSentence <- paste(
  "The Genetic Value Analysis tab no longer shows the",
  "\"Calculate Genome Uniqueness\" and \"Calculate Mean Kinship\" check boxes.",
  "They did nothing: the analysis works out both numbers whether or not they",
  "were ticked."
)

test_that("the Genetic Value screen has no check box that nothing reads", {
  text <- gsub("\\s+", " ",
               paste(as.character(modGeneticValueUI("gv")), collapse = " "))
  expectWording(
    text,
    now = character(0L),
    gone = c("calcGenomeUniqueness", "calcMeanKinship",
             "Calculate Genome Uniqueness", "Calculate Mean Kinship")
  )
  ## The controls that do something are still there.
  for (stays in c("Analysis Options", "gv-nIterations", "gv-threshold",
                  "gv-rankScheme", "gv-runAnalysis")) {
    expect_gt(occurrences(text, stays), 0L, label = stays)
  }
})

test_that("the manual no longer describes the two check boxes", {
  expectWording(
    pageText("vignettes", "manual_components", "_genetic_value_analysis.Rmd"),
    now = c("Ranking Scheme: \"Combined (kinship - uniqueness)\"",
            "Kinship Overrides (optional): Upload a CSV or Excel file"),
    gone = c("Calculate Genome Uniqueness", "Calculate Mean Kinship",
             "They currently have no effect")
  )
})

test_that("NEWS.Rmd says the two check boxes are gone, under Genetic Value Analysis", {
  text <- pageText("NEWS.Rmd")
  expectWording(text, now = removedSentence, gone = character(0L))
  section <- sectionOf(text, "## Genetic Value Analysis",
                       "## Breeding Group Formation")
  expect_equal(occurrences(section, removedSentence), 1L)
})

test_that("NEWS.md says it too", {
  expectWording(pageText("NEWS.md"), now = removedSentence,
                gone = character(0L))
})
