## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S984; BACKLOG.md:156): once a group with no seeded male is given a
## sire (test_haremPartialSeeds.R), five places say what a seeded male means
## with Harem: the help of groupAddAssign() and of makeGroupMembers(), the
## Breeding Group Formation notes of NEWS, the colony manager guide and the
## manual. None says it at HEAD (no page names a group "with no male").
##
## The new sentences are the owner's to approve at the RED to GREEN gate (as at
## S983), so the blocks pin only what a sentence has to carry: in one stretch
## of text around the word "harem" it says "no male" (or "no seeded male") and
## "at random". The rest of the wording is free.
##
## The pages sit outside a built package (man/ and R/ are not installed;
## NEWS.Rmd is .Rbuildignore'd), so each block skips where its page is absent
## and runs from the source tree.

## True when some stretch of `text` around the word "harem" says that a group
## with no (seeded) male gets one, and that the pick is at random.
sayingThePartialSeedRule <- function(text) {
  starts <- gregexpr("harem", text, fixed = FALSE, ignore.case = TRUE)[[1L]]
  starts <- starts[starts > 0L]
  any(vapply(starts, function(p) {
    around <- substr(text, max(1L, p - 300L), p + 500L)
    grepl("(no|without a) (seeded )?male", around) &&
      grepl("at random", around, fixed = TRUE)
  }, logical(1L)))
}

test_that("the partial-seed reader accepts what it must and no other", {
  expect_true(sayingThePartialSeedRule(paste(
    "With Harem selected, a group whose box holds a male keeps him as its",
    "sire; a group with no seeded male is given a sire chosen at random."
  )))
  expect_true(sayingThePartialSeedRule(paste(
    "A male typed into a group's seed box is that group's male, and a harem",
    "whose box holds no male is given one at random."
  )))
  expect_false(sayingThePartialSeedRule(paste(
    "Harem (1M:NF) -- each group is seeded with a single male and filled",
    "with females."
  )))
  expect_false(sayingThePartialSeedRule(paste(
    "A group with no seeded male is left empty of males."
  )))
  expect_false(sayingThePartialSeedRule(paste(
    "The search is run at random; a group with no seeded male is allowed."
  )))
})

groupAddAssignHelp <- helpPlaces("groupAddAssign", "groupAddAssign.R")
makeGroupMembersHelp <- helpPlaces("makeGroupMembers", "makeGroupMembers.R")

test_that("the readers find the help, the NEWS section, the guide and the manual", {
  skipUnlessHelpInSourceTree(groupAddAssignHelp)
  skipUnlessHelpInSourceTree(makeGroupMembersHelp)
  for (place in names(groupAddAssignHelp)) {
    expect_match(groupAddAssignHelp[[place]](), "harem", fixed = TRUE,
                 info = paste("groupAddAssign", place))
  }
  for (place in names(makeGroupMembersHelp)) {
    expect_match(makeGroupMembersHelp[[place]](), "harem", fixed = TRUE,
                 info = paste("makeGroupMembers", place))
  }
  for (page in c("NEWS.Rmd", "NEWS.md")) {
    expect_match(breedingGroupSection(plainSource(page)), "harem",
                 fixed = TRUE, info = page)
  }
  expect_match(
    plainSource("vignettes", "articles", "colony-manager-guide.qmd"),
    "Harem (1M:NF)",
    fixed = TRUE
  )
  expect_match(
    plainSource("vignettes", "manual_components",
                "_breeding_group_formation.Rmd"),
    "Harem (1M:NF)",
    fixed = TRUE
  )
})

test_that("the groupAddAssign help says a group with no seeded male gets one", {
  skipUnlessHelpInSourceTree(groupAddAssignHelp)
  for (place in names(groupAddAssignHelp)) {
    expect_true(sayingThePartialSeedRule(groupAddAssignHelp[[place]]()),
                info = place)
  }
})

test_that("the makeGroupMembers help says a group with no seeded male gets one", {
  skipUnlessHelpInSourceTree(makeGroupMembersHelp)
  for (place in names(makeGroupMembersHelp)) {
    expect_true(sayingThePartialSeedRule(makeGroupMembersHelp[[place]]()),
                info = place)
  }
})

test_that("NEWS says a group with no seeded male gets one with Harem", {
  for (page in c("NEWS.Rmd", "NEWS.md")) {
    expect_true(
      sayingThePartialSeedRule(
        breedingGroupSection(plainSource(page))
      ),
      info = page
    )
  }
})

test_that("the colony manager guide says a group with no seeded male gets one", {
  expect_true(sayingThePartialSeedRule(
    plainSource("vignettes", "articles", "colony-manager-guide.qmd")
  ))
})

test_that("the manual says a group with no seeded male gets one", {
  expect_true(sayingThePartialSeedRule(
    plainSource("vignettes", "manual_components",
                "_breeding_group_formation.Rmd")
  ))
})
