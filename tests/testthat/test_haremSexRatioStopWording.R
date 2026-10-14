## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S985; BACKLOG.md:156): once groupAddAssign() stops for harem = TRUE with
## a non-zero sexRatio (test_haremSexRatioStop.R), four places say so: the help
## of the harem argument, the help of the sexRatio argument (each in the man
## page and in the roxygen block), the Breeding Group Formation notes of NEWS
## (NEWS.Rmd and NEWS.md), and the Breeding Group Formation article. None says
## it at HEAD; the article only says the two "are alternative strategies".
##
## The sentences are the ones the owner approved at the RED to GREEN gate
## (S985), so each block pins its sentence word for word. Emphasis marks, code
## quotes and line breaks do not count as a difference (plainSource(),
## roxygenText(), manText()).
##
## The pages sit outside a built package (man/ and R/ are not installed;
## NEWS.Rmd is .Rbuildignore'd), so each block skips where its page is absent
## and runs from the source tree.

haremHelpSentence <- paste(
  "It cannot be combined with a non-zero sexRatio; the call stops with a",
  "message naming both settings."
)
sexRatioHelpSentence <- paste(
  "A non-zero sexRatio cannot be combined with harem = TRUE; the call stops",
  "with a message."
)
newsSentence <- paste(
  "A script that passes harem = TRUE and a non-zero sexRatio to",
  "groupAddAssign() now stops with a message naming both settings, instead",
  "of returning groups of one or two animals; use one or the other. The",
  "Breeding Groups tab was never affected, since its radio takes Harem or",
  "Custom, not both."
)
articleSentence <- paste(
  "harem and sexRatio are alternative strategies -- use one or the other;",
  "passing both to groupAddAssign() stops with a message."
)

breedingGroupFormationSection <- function(text) {
  begin <- regexpr("## Breeding Group Formation", text, fixed = TRUE)
  end <- regexpr("## Mate Pair Analysis", text, fixed = TRUE)
  expect_true(begin > 0L && end > begin)
  substr(text, begin, end - 1L)
}

groupAddAssignHelp <- helpPlaces("groupAddAssign", "groupAddAssign.R")

test_that("the readers find the help, the NEWS section and the article", {
  skipUnlessHelpInSourceTree(groupAddAssignHelp)
  for (place in names(groupAddAssignHelp)) {
    expect_match(groupAddAssignHelp[[place]](), "harem", fixed = TRUE,
                 info = place)
  }
  for (page in c("NEWS.Rmd", "NEWS.md")) {
    expect_match(breedingGroupFormationSection(plainSource(page)), "harem",
                 fixed = TRUE, info = page)
  }
  expect_match(
    plainSource("vignettes", "articles", "breeding-group-formation.qmd"),
    "alternative strategies",
    fixed = TRUE
  )
})

test_that("the groupAddAssign help says a harem cannot take a sex ratio", {
  skipUnlessHelpInSourceTree(groupAddAssignHelp)
  for (place in names(groupAddAssignHelp)) {
    text <- groupAddAssignHelp[[place]]()
    expect_equal(occurrences(text, haremHelpSentence), 1L,
                 info = paste(place, "- harem argument"))
    expect_equal(occurrences(text, sexRatioHelpSentence), 1L,
                 info = paste(place, "- sexRatio argument"))
  }
})

test_that("NEWS says a script that passes harem and a sex ratio now stops", {
  for (page in c("NEWS.Rmd", "NEWS.md")) {
    section <- breedingGroupFormationSection(plainSource(page))
    expect_equal(occurrences(section, newsSentence), 1L, info = page)
  }
})

test_that("the article says passing both harem and sexRatio stops", {
  text <- plainSource("vignettes", "articles", "breeding-group-formation.qmd")
  expect_equal(occurrences(text, articleSentence), 1L)
})
