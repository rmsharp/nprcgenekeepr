## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S1008; BACKLOG.md:166, slice 6e findings CJ3 and CJ4, ruled S1004; the
## PRE-RED scope answer: a male with no birth date is left out too). With a sex
## ratio set, a male is placed only if he has a birth date and is at least
## `minAge` years old; a younger male, or one with no birth date, is left out of
## the groups (he ends in "Unused animals"). CJ4, accepted as it is: a group
## stops being filled when it has no such male left, so it can end with fewer
## females than the ratio asks for. The help says both, in the `sexRatio`
## argument of groupAddAssign(), in the description of
## fillGroupMembersWithSexRatio(), and the guide's "Custom" bullet says them
## to the colony manager.
##
## The wording is the owner's to approve (at the RED to GREEN gate, as at S979),
## so each block pins one short phrase and not a sentence; the rest is free.
## The help lives in two places, the generated man page and the roxygen block
## in R/, and both readers need the source tree (man/ and R/ do not exist under
## an installed package): the blocks skip without it. The guide is outside a
## built package too and skips there.

## helpPlaces(), skipUnlessHelpInSourceTree() and pageText() are in
## helper-pageText.R.

groupAddAssignPlaces <- helpPlaces("groupAddAssign", "groupAddAssign.R")
fillSexRatioPlaces <- helpPlaces(
  "fillGroupMembersWithSexRatio", "fillGroupMembersWithSexRatio.R"
)

## The help after the sexRatio argument's first sentence, so a phrase found
## elsewhere on the page cannot make a block pass by accident.
afterNonMalesSentence <- function(text, width = 800L) {
  hit <- regmatches(
    text, regexpr("per male\\.", text)
  )
  if (length(hit) == 0L) {
    return("")
  }
  substr(sub("^.*?per male\\.", "", text, perl = TRUE), 1L, width)
}

## Sanity check on the readers (green at HEAD, and kept by GREEN): they find
## the page and the guide, so a reader that finds nothing cannot pass below.
test_that("the readers find the sexRatio help and the guide's Custom bullet", {
  skipUnlessHelpInSourceTree(groupAddAssignPlaces)
  skipUnlessHelpInSourceTree(fillSexRatioPlaces)
  for (read in groupAddAssignPlaces) {
    expect_match(read(), "non-males (females and animals of other or unknown sex) per male",
                 fixed = TRUE)
  }
  for (read in fillSexRatioPlaces) {
    expect_match(read(), "number of non-males (females and animals of other or unknown sex) per male",
                 fixed = TRUE)
  }
  expect_match(
    pageText("vignettes", "articles", "colony-manager-guide.qmd"),
    "Custom -- a \"Custom ratio (F per M):\" numeric field appears",
    fixed = TRUE
  )
})

## The failing tests (RED at HEAD).
for (place in names(groupAddAssignPlaces)) {
  test_that(paste0("groupAddAssign's ", place,
                   " says a male with no birth date is left out"), {
    skipUnlessHelpInSourceTree(groupAddAssignPlaces)
    text <- afterNonMalesSentence(groupAddAssignPlaces[[place]]())
    expect_match(text, "no birth date", fixed = TRUE, info = text)
    expect_match(text, "left out", fixed = TRUE, info = text)
  })

  test_that(paste0("groupAddAssign's ", place,
                   " says a group can end with fewer females than asked"), {
    skipUnlessHelpInSourceTree(groupAddAssignPlaces)
    text <- afterNonMalesSentence(groupAddAssignPlaces[[place]]())
    expect_match(text, "fewer females", fixed = TRUE, info = text)
  })
}

for (place in names(fillSexRatioPlaces)) {
  test_that(paste0("fillGroupMembersWithSexRatio's ", place,
                   " says a male with no birth date is left out"), {
    skipUnlessHelpInSourceTree(fillSexRatioPlaces)
    text <- fillSexRatioPlaces[[place]]()
    after <- sub("^.*?number of non-males", "", text, perl = TRUE)
    expect_match(substr(after, 1L, 900L), "no birth date", fixed = TRUE,
                 info = text)
  })
}

## The guide's "Custom" bullet: the text from its last sentence up to the
## callout that follows it.
customBulletTail <- function() {
  text <- pageText("vignettes", "articles", "colony-manager-guide.qmd")
  tail <- sub("^.*?females-per-male ratio\\.", "", text, perl = TRUE)
  sub("Fixed before publication.*$", "", tail, perl = TRUE)
}

test_that("the guide's Custom bullet says a male with no birth date is not placed", {
  tail <- customBulletTail()
  expect_match(tail, "no birth date", fixed = TRUE, info = tail)
})

test_that("the guide's Custom bullet says where the left-out males are listed", {
  tail <- customBulletTail()
  expect_match(tail, "Unused animals", fixed = TRUE, info = tail)
})
