## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## NEW-42 (PED_GV audit, Decision record 13): getParents() and getOffspring()
## take the pedigree first, while four related exported functions take the
## animal ids first. The owner kept the order and chose to say so in the two
## help pages. These tests read the generated man/*.Rd (source/dev context;
## under an installed package there is no man/ directory and they skip). Each
## help assertion is scoped to the one \item{pedSourceDf} entry, so a mention
## elsewhere on the page (getOffspring()'s \value already says "second
## argument") cannot make it pass by accident (Learning 89).

idsFirstFunctions <- c(
  "getProbandPedigree", "getDescendantPedigree", "getPedDirectRelatives",
  "findOffspring"
)

helpPagePath <- function(fn) {
  testthat::test_path("..", "..", "man", paste0(fn, ".Rd"))
}

skipUnlessHelpPage <- function(fn) {
  testthat::skip_if(
    !file.exists(helpPagePath(fn)),
    "man/*.Rd not available (installed package)"
  )
}

## Text of one \item in the \arguments section of man/<fn>.Rd with white space
## collapsed; NA_character_ when the page has no such argument entry.
argumentHelpText <- function(fn, arg) {
  parsed <- tools::parse_Rd(helpPagePath(fn))
  tags <- vapply(parsed, function(x) attr(x, "Rd_tag"), character(1))
  argSection <- which(tags == "\\arguments")
  if (length(argSection) == 0L) {
    return(NA_character_)
  }
  for (item in parsed[[argSection[1L]]]) {
    if (!identical(attr(item, "Rd_tag"), "\\item")) {
      next
    }
    if (identical(trimws(paste(unlist(item[[1L]]), collapse = "")), arg)) {
      return(trimws(gsub("\\s+", " ", paste(unlist(item[[2L]]), collapse = ""))))
    }
  }
  NA_character_
}

## Sanity checks on the reader (green at HEAD). They prove the RED failures
## below are about the help text, not about a reader that finds nothing.
test_that("the help-page reader returns the pedSourceDf entry of getParents", {
  skipUnlessHelpPage("getParents")
  text <- argumentHelpText("getParents", "pedSourceDf")
  expect_false(is.na(text))
  expect_match(text, "pedigree structure", fixed = TRUE)
})

test_that("the help-page reader returns NA for an undocumented argument", {
  skipUnlessHelpPage("getParents")
  expect_true(is.na(argumentHelpText("getParents", "noSuchArgument")))
})

## The failing tests (RED at HEAD): the entry says nothing about argument order.
for (fn in c("getParents", "getOffspring")) {
  test_that(paste0("help for ", fn, " says the pedigree is the first argument"), {
    skipUnlessHelpPage(fn)
    text <- argumentHelpText(fn, "pedSourceDf")
    expect_false(is.na(text))
    expect_match(text, "\\bfirst\\b", info = text)
  })

  test_that(paste0("help for ", fn, " names the functions that take ids first"), {
    skipUnlessHelpPage(fn)
    text <- argumentHelpText(fn, "pedSourceDf")
    expect_false(is.na(text))
    for (other in idsFirstFunctions) {
      expect_match(text, other, fixed = TRUE, info = text)
    }
  })
}

## Contract lock (green at HEAD, not the RED driver): the help sentence is only
## true while these orders hold, so a future reorder fails here and sends the
## author to the two help pages.
test_that("getParents() and getOffspring() take the pedigree first, then ids", {
  expect_identical(names(formals(getParents))[1:2], c("pedSourceDf", "ids"))
  expect_identical(names(formals(getOffspring))[1:2], c("pedSourceDf", "ids"))
})

test_that("the four functions the help names take the ids first, then the pedigree", {
  expect_identical(names(formals(getProbandPedigree))[1:2], c("probands", "ped"))
  expect_identical(names(formals(getDescendantPedigree))[1:2], c("probands", "ped"))
  expect_identical(names(formals(findOffspring))[1:2], c("probands", "ped"))
  expect_identical(names(formals(getPedDirectRelatives))[1:2], c("ids", "ped"))
})
