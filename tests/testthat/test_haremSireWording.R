## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S983; BACKLOG.md:156): groupAddAssign()'s help (the `ancestryRules`
## paragraph) says "Known limitation (shared with the kinship machinery): a
## harem's sampled sire is seeded into the group before the fill loop, so
## conflicts against the sire himself are not enforced", and the Breeding
## Group Formation section of NEWS says "Caveat: in harem formation the
## automatically chosen sire is not checked against the rules". Once the sire
## is held to the same rule as every other animal (test_haremSireConflicts.R)
## both statements are false.
##
## The new sentences are the owner's to approve at the RED to GREEN gate (as at
## S971, S977 to S982), so the blocks pin only what a sentence has to carry:
## in one stretch of text around the word "sire" it says "harem" and one of
## "relative", "related" or "kinship", and says none of "not enforced", "not
## checked", "Known limitation" or "Caveat". The rest of the wording is free.
## At HEAD the only stretches around "sire" are the two statements above, so
## no positive block passes before the sentences are written.
##
## The pages sit outside a built package (man/ and R/ are not installed;
## NEWS.Rmd is .Rbuildignore'd), so each block skips where its page is absent
## and runs from the source tree.

staleStatements <- c(
  "Known limitation", "are not enforced", "is not checked against the rules",
  "Caveat: in harem formation"
)

## True when some stretch of `text` around the word "sire" names the harem,
## names relatives (or kinship) and carries none of the stale phrases.
sayingTheSireRule <- function(text) {
  starts <- gregexpr("sire", text, fixed = TRUE)[[1L]]
  starts <- starts[starts > 0L]
  any(vapply(starts, function(p) {
    around <- substr(text, max(1L, p - 300L), p + 400L)
    grepl("harem", around, fixed = TRUE) &&
      grepl("relative|related|kinship", around) &&
      !any(vapply(staleStatements, grepl, logical(1L), x = around,
                  fixed = TRUE)) &&
      !grepl("not enforced|not checked", around)
  }, logical(1L)))
}

## The reader accepts a sentence that carries what it must and no other
## (green at HEAD).
test_that("the sire-rule reader accepts what it must and no other", {
  expect_true(sayingTheSireRule(paste(
    "In harem formation the automatically chosen sire is kept apart from his",
    "relatives, like every other animal."
  )))
  expect_false(sayingTheSireRule(paste(
    "Caveat: in harem formation the automatically chosen sire is not checked",
    "against the rules."
  )))
  expect_false(sayingTheSireRule("A sire is chosen for each group."))
  expect_false(sayingTheSireRule(paste(
    "Known limitation: a harem's sampled sire is seeded into the group, so",
    "conflicts against the sire himself are not enforced; relatives join."
  )))
})

breedingGroupSection <- function(text) {
  begin <- regexpr("## Breeding Group Formation", text, fixed = TRUE)
  end <- regexpr("## Mate Pair Analysis", text, fixed = TRUE)
  expect_true(begin > 0L && end > begin)
  substr(text, begin, end - 1L)
}

helpReaders <- helpPlaces("groupAddAssign", "groupAddAssign.R")

test_that("the readers find the help and the Breeding Group Formation notes", {
  skipUnlessHelpInSourceTree(helpReaders)
  for (place in names(helpReaders)) {
    expect_match(helpReaders[[place]](), "ancestryRules", fixed = TRUE,
                 info = place)
  }
  for (page in c("NEWS.Rmd", "NEWS.md")) {
    expect_match(breedingGroupSection(plainSource(page)), "harem",
                 fixed = TRUE, info = page)
  }
})

test_that("the groupAddAssign help no longer says the sire is not checked", {
  skipUnlessHelpInSourceTree(helpReaders)
  for (place in names(helpReaders)) {
    text <- helpReaders[[place]]()
    for (phrase in c("Known limitation", "conflicts against the sire himself",
                     "are not enforced")) {
      expect_equal(occurrences(text, phrase), 0L,
                   info = paste(place, phrase))
    }
  }
})

test_that("the groupAddAssign help says the harem sire keeps his relatives out", {
  skipUnlessHelpInSourceTree(helpReaders)
  for (place in names(helpReaders)) {
    expect_true(sayingTheSireRule(helpReaders[[place]]()), info = place)
  }
})

test_that("NEWS drops the harem-sire caveat", {
  for (page in c("NEWS.Rmd", "NEWS.md")) {
    section <- breedingGroupSection(plainSource(page))
    expect_equal(occurrences(section, "automatically chosen sire is not"),
                 0L, info = page)
    expect_equal(occurrences(section, "Caveat: in harem formation"), 0L,
                 info = page)
  }
})

test_that("NEWS says the harem sire keeps his relatives out", {
  for (page in c("NEWS.Rmd", "NEWS.md")) {
    expect_true(
      sayingTheSireRule(breedingGroupSection(plainSource(page))),
      info = page
    )
  }
})
