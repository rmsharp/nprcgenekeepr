## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S1014 RED (the owner's ruling S1013, option A; evidence in
## docs/audits/CONFIG_FILE_FORMAT_DECISION_2026-10-18.md): the notes at the top
## of the shipped example configuration file said terms may be separated by
## semicolons and that a value must be in quotes to hold a blank or a comma, and
## that http://deepthought:8080/labkey "would become a meaningless collection of
## four terms". The reader (getTokenList(), unchanged since 2017-09-13) deleted
## every quote before it split on blanks and commas, split on no semicolon, and
## did not split that address: all three sentences were wrong the day they were
## written. The reader now keeps a quoted value whole, so the notes are rewritten
## to the ruled rules, and the rest of the pages that describe the format agree:
##
##  * the notes (inst/extdata/examples/example_nprcgenekeepr_config);
##  * the loadable copy data/exampleNprcgenekeeprConfig.RData, which README.md and
##    the manual tell users to open with View(), was an older 34-line file with
##    the same wrong sentences against the shipped 87 lines, and no script built
##    it (this file is the gate that it equals the shipped file);
##  * the help of getTokenList() (named no rules) and of getSiteInfo() (one
##    pointer to the notes), read in the two places each lives;
##  * the comment of readConfigLines(), which said getTokenList() does not strip
##    comments and a comment after a setting is not removed.
##
## The assertions name the false sentences that must be gone and the short
## phrases that state the ruled rules; the rest of each sentence is free. The
## help and R/ assertions need the source tree and skip without it.

## helpPlaces(), skipUnlessHelpInSourceTree(), expectWording(), expectNames()
## and collapseSpace() are in helper-pageText.R; exampleConfigPath() is in
## helper-exampleConfig.R.

## The comment lines of the shipped example file as one line of text: the
## leading "#" dropped, white space collapsed, so a sentence that wraps over
## lines is found whole.
configNotes <- function() {
  path <- exampleConfigPath()
  skip_if_not(nzchar(path), "example configuration file not available")
  cfgLines <- readLines(path, warn = FALSE)
  noteLines <- cfgLines[startsWith(trimws(cfgLines), "#")]
  collapseSpace(paste(sub("^\\s*#\\s?", "", noteLines), collapse = " "))
}

test_that("the reader of the notes finds the notes (it cannot pass by finding nothing)", {
  expectNames(configNotes(), c(
    "Empty lines are ignored",
    "It is critical to have the term being defined immediately before an equals"
  ), where = "example config notes")
})

test_that("the example file's notes no longer say what the reader never did", {
  expectWording(configNotes(), now = character(0L), gone = c(
    "commas, semicolons, or newline characters",
    "would become a meaningless collection of four terms",
    "unquoted-friendly",
    "no spaces or commas in the path"
  ))
})

test_that("the example file's notes state the rules the reader keeps", {
  expectWording(configNotes(), now = c(
    "Terms are separated by blanks, commas, tabs or line breaks",
    "a semicolon does not separate terms",
    "Put a value in double quotes when it holds a blank, a comma, an equals sign or round brackets",
    "a whole list inside one pair of quotes is read as a single name",
    "A # that begins a word starts a comment that runs to the end of the line",
    "Put the CSV path in double quotes if it holds a blank or a comma"
  ), gone = character(0L))
})

test_that("the loadable example configuration is the shipped example file", {
  path <- exampleConfigPath()
  skip_if_not(nzchar(path), "example configuration file not available")
  expect_identical(nprcgenekeepr::exampleNprcgenekeeprConfig,
                   readLines(path, warn = FALSE))
})

tokenListPlaces <- helpPlaces("getTokenList", "getTokenList.R")
siteInfoPlaces <- helpPlaces("getSiteInfo", "getSiteInfo.R")

## Sanity checks on the four readers (green at HEAD): they find each page, so
## a reader that finds nothing cannot pass the assertions below.
test_that("the readers find the help of getTokenList() and getSiteInfo()", {
  skipUnlessHelpInSourceTree(c(tokenListPlaces, siteInfoPlaces))
  for (read in tokenListPlaces) {
    expect_match(read(), "Get tokens from a character vector of lines", fixed = TRUE)
  }
  for (read in siteInfoPlaces) {
    expect_match(read(), "Get site information", fixed = TRUE)
  }
})

for (place in names(tokenListPlaces)) {
  test_that(paste0("the getTokenList ", place, " names the rules of the file"), {
    skipUnlessHelpInSourceTree(tokenListPlaces)
    expectNames(tokenListPlaces[[place]](), c(
      "terms are separated by blanks, commas or line breaks",
      "a term in double quotes is kept whole",
      "a quote not closed on its line ends at the end of that line",
      "a # that begins a word starts a comment"
    ), where = place)
  })
}

for (place in names(siteInfoPlaces)) {
  test_that(paste0("the getSiteInfo ", place, " points to the notes of the example file"), {
    skipUnlessHelpInSourceTree(siteInfoPlaces)
    expectNames(siteInfoPlaces[[place]](), c(
      "described in the notes at the top of the example file",
      "example_nprcgenekeepr_config",
      "extdata/examples"
    ), where = place)
  })
}

test_that("the comment of readConfigLines() agrees with the reader", {
  text <- roxygenText("readConfigLines.R")
  skip_if(is.na(text), "R/readConfigLines.R not available (installed package)")
  expectWording(text,
    now = "A comment that follows a setting on the same line is kept here",
    gone = c("does not itself strip", "is not removed")
  )
})
