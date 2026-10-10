## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the tests that pin a page's wording (test_originFundingWording.R,
## test_defaultPopulationWording.R): read a page of the source tree as one line
## of text, count a phrase in it, and say which phrases a page now holds and
## which it no longer holds.

## One tracked page as plain text. Emphasis marks (`, *, _) and line breaks do
## not count as a difference. `unquote` drops a leading ">" (a block quote);
## `roxygen` drops a leading "#'" (roxygen comments). The page sits outside a
## built package (.Rbuildignore'd or not installed), so the block skips where
## the file is absent and runs from the source tree.
pageText <- function(..., unquote = FALSE, roxygen = FALSE) {
  path <- file.path(testthat::test_path("..", ".."), ...)
  skip_if_not(file.exists(path), paste(basename(path), "not present"))
  lines <- readLines(path, warn = FALSE)
  if (unquote) lines <- sub("^\\s*>\\s?", "", lines)
  if (roxygen) lines <- sub("^#'\\s?", "", lines)
  text <- paste(lines, collapse = " ")
  text <- gsub("[`*_]", "", text)
  gsub("\\s+", " ", text)
}

occurrences <- function(text, phrase) {
  hits <- gregexpr(phrase, text, fixed = TRUE)[[1L]]
  sum(hits > 0L)
}

## Each phrase in `now` stands exactly once in `text`; each in `gone` nowhere.
expectWording <- function(text, now, gone) {
  for (phrase in now) expect_equal(occurrences(text, phrase), 1L, info = phrase)
  for (phrase in gone) expect_equal(occurrences(text, phrase), 0L, info = phrase)
}
