## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S987; BACKLOG.md:141-156, S986 flag PB11): the help of
## getDateErrorsAndConvertDatesInPed() says "If there are no errors that
## prevent the calculation of exit dates, they are calculated and added to the
## pedigree otherwise the pedigree is not updated." The code converts the
## pedigree even when some dates are invalid (the invalid ones become NA) and
## leaves it unchanged only when every original record has an invalid date
## (test_getDateErrorsAndConvertDatesInPed.R, the last block of the first
## group). The owner approved one sentence in its place at the PRE-RED
## question (S987), pinned word for word below. Emphasis marks, code quotes and
## line breaks do not count as a difference (roxygenText(), manText()).
##
## The help sits outside a built package (man/ and R/ are not installed), so
## each block skips where its source is absent and runs from the source tree.

dateHelpSentence <- paste(
  "Every date column is checked on its own and each invalid date is listed by",
  "row; the invalid dates become NA in the converted pedigree, and exit dates",
  "are calculated and added, unless every original record has an invalid",
  "date, in which case the pedigree is returned unchanged."
)
oldDateHelpSentence <- "otherwise the pedigree is not updated"

dateHelp <- helpPlaces(
  "getDateErrorsAndConvertDatesInPed", "getDateErrorsAndConvertDatesInPed.R"
)

test_that("the readers find the help of getDateErrorsAndConvertDatesInPed", {
  skipUnlessHelpInSourceTree(dateHelp)
  for (place in names(dateHelp)) {
    expect_match(dateHelp[[place]](),
                 "Find date errors and convert dates in a pedigree",
                 fixed = TRUE, info = place)
  }
})

test_that("the help says the pedigree is converted, with invalid dates as NA", {
  skipUnlessHelpInSourceTree(dateHelp)
  for (place in names(dateHelp)) {
    text <- dateHelp[[place]]()
    expect_equal(occurrences(text, dateHelpSentence), 1L, info = place)
    expect_equal(occurrences(text, oldDateHelpSentence), 0L, info = place)
  }
})
