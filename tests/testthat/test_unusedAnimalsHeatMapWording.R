## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S1000, CA3 of docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md):
## the Genetic Diversity heat map now names the row of the animals that fit no
## group "Unused animals", as the three Breeding Groups pages do, because the
## Breeding Groups module returns one more item, groupLabels (the name of each
## element of groups(); groups() itself stays unnamed). The owner approved the
## six sentences below (S1000). The pages are read in the source tree (they do
## not exist under an installed package) and skip without it.
##
## pageText(), helpPlaces() and skipUnlessHelpInSourceTree() are in
## helper-pageText.R. The sixth place, the guide's Breeding Groups paragraph, is
## pinned in test_guideBreedingGroupsWording.R.

## (4) and (5): the two modules' help, each in the man page and the roxygen block.
bgHelp <- helpPlaces("modBreedingGroupsServer", "modBreedingGroups.R")
gdHelp <- helpPlaces("modGeneticDiversityServer", "modGeneticDiversity.R")

bgItem <- paste(
  "groupLabels - Character vector with one name per element of groups:",
  "\"Group 1\", \"Group 2\" and so on, and \"Unused animals\" for the final",
  "\"Unused\" element when there is one; groups itself is not named"
)
gdSentence <- paste(
  "If the list is named, the names are the heat map's row labels (the app",
  "passes the names that the Breeding Groups module returns as groupLabels,",
  "so the last row reads \"Unused animals\"); an unnamed list gives",
  "\"Group 1\", \"Group 2\" and so on."
)

## Sanity check on the readers (green at HEAD): they find the sentences the
## RED tests below sit beside, so a reader that finds nothing cannot pass.
test_that("the readers find the sentences the new help and pages sit beside", {
  skipUnlessHelpInSourceTree(c(bgHelp, gdHelp))
  for (read in bgHelp) {
    expect_match(read(), paste("nGroups - Number of elements of groups,",
                               "counting the \"Unused\" element when present"),
                 fixed = TRUE)
  }
  for (read in gdHelp) {
    expect_match(read(), "and the heat map scores it as another group.",
                 fixed = TRUE)
  }
})

## The failing tests (RED at HEAD).
for (place in names(bgHelp)) {
  test_that(paste0("the Breeding Groups module's ", place,
                   " lists the groupLabels item"), {
    skipUnlessHelpInSourceTree(bgHelp)
    text <- bgHelp[[place]]()
    expect_match(text, bgItem, fixed = TRUE, info = text)
  })
}

for (place in names(gdHelp)) {
  test_that(paste0("the Genetic Diversity module's ", place,
                   " says how its row labels are chosen"), {
    skipUnlessHelpInSourceTree(gdHelp)
    text <- gdHelp[[place]]()
    expect_match(text, gdSentence, fixed = TRUE, info = text)
  })
}

test_that("the manual's Module Interface list names groupLabels", {
  text <- pageText("vignettes", "manual_components",
                   "_breeding_group_formation.Rmd")
  expect_match(
    text,
    paste("groupLabels: The name of each element of groups: \"Group 1\",",
          "\"Group 2\" and so on, and \"Unused animals\" for the \"Unused\"",
          "group when there is one"),
    fixed = TRUE
  )
})

test_that("the guide's Genetic Diversity paragraph names the leftover row", {
  text <- pageText("vignettes", "articles", "colony-manager-guide.qmd")
  expect_match(
    text,
    paste("When some animals fit no group, the last row is that box of",
          "animals, named Unused animals as on the Breeding Groups tab, and it",
          "is scored like a group."),
    fixed = TRUE
  )
})

test_that("NEWS says the heat map uses the Unused animals name too", {
  sentence <- paste("The Statistics table, the Group Detail list and the",
                    "Genetic Diversity heat map use the same name.")
  expect_match(pageText("NEWS.Rmd"), sentence, fixed = TRUE)
  expect_match(pageText("NEWS.md"), sentence, fixed = TRUE)
})
