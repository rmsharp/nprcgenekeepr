## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S993 (BACKLOG.md docs-audit part 2; S991 finding 1, flag CA2): the help for
## modGeneticDiversityServer(), argument kinshipMatrix, said "In the app this
## is the genetic-value tab's population-filtered matrix, not the full-pedigree
## matrix." The app now hands the Genetic Diversity tab the same full-pedigree
## kinship matrix Summary Statistics and Breeding Groups get
## (test_appServer_server.R, section 7b), so a group may hold any living animal
## of the pedigree and the tab no longer stops for one that is not a focal
## animal. The owner ruled the code S993 (draw the heat map) and approved the
## replacement sentence at the PRE-RED to RED gate.
##
## The help is read whole, in the two places it lives (the roxygen block and
## the regenerated man page), and must hold the approved sentence exactly once
## and the old one nowhere; a sentence this long cannot be matched by accident
## (Learning 89). Both readers need the source tree (man/ and R/ do not exist
## under an installed package) and skip without it.

## helpPlaces(), skipUnlessHelpInSourceTree() and expectWording() are in
## helper-pageText.R.

diversityHelpPlaces <- helpPlaces("modGeneticDiversityServer",
                                  "modGeneticDiversity.R")

diversityHelpNow <- paste(
  "In the app this is the full-pedigree kinship matrix that Summary",
  "Statistics and Breeding Groups also use, so it covers every animal of",
  "the pedigree, not only the Genetic Value population."
)
diversityHelpGone <- paste(
  "In the app this is the genetic-value tab's population-filtered matrix,",
  "not the full-pedigree matrix."
)

## Sanity check on the readers (green at HEAD). It proves the RED failures
## below are about the help text, not about readers that find nothing.
test_that("the readers find the kinshipMatrix help of modGeneticDiversityServer", {
  skipUnlessHelpInSourceTree(diversityHelpPlaces)
  for (read in diversityHelpPlaces) {
    expect_match(read(), "covering every member of every group;", fixed = TRUE)
  }
})

## The failing tests (RED at HEAD): both places still carry the old sentence
## and lack the approved one.
for (place in names(diversityHelpPlaces)) {
  test_that(paste0("the ", place, " of modGeneticDiversityServer has the ",
                   "approved kinshipMatrix sentence only"), {
    skipUnlessHelpInSourceTree(diversityHelpPlaces)
    expectWording(diversityHelpPlaces[[place]](),
                  now = diversityHelpNow, gone = diversityHelpGone)
  })
}
