## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the tests that pin a page's wording (test_originFundingWording.R,
## test_defaultPopulationWording.R, test_oneFileGenotypesWording.R,
## test_genotypeTutorialsWording.R): read a page of the source tree as lines or
## as one line of text, count a phrase in it, say which phrases a page now holds
## and which it no longer holds, and pull a code chunk out of a .qmd or .Rmd.

## The lines of one tracked file of the source tree. The file sits outside a
## built package (.Rbuildignore'd or not installed), so the block skips where
## the file is absent and runs from the source tree.
sourceLines <- function(...) {
  path <- file.path(testthat::test_path("..", ".."), ...)
  skip_if_not(file.exists(path), paste(basename(path), "not present"))
  readLines(path, warn = FALSE)
}

## Lines as one line of text: backticks and asterisks dropped, underscores kept
## (first_name and allele_1 need their own), line breaks collapsed. `html` drops
## the tags too.
plainText <- function(lines, html = FALSE) {
  text <- paste(lines, collapse = " ")
  if (html) text <- gsub("<[^>]+>", "", text)
  text <- gsub("[`*]", "", text)
  gsub("\\s+", " ", text)
}

## One tracked page as plain text, underscores kept (see plainText()).
plainSource <- function(..., html = FALSE) {
  plainText(sourceLines(...), html = html)
}

## One tracked page as plain text. Emphasis marks (`, *, _) and line breaks do
## not count as a difference. `unquote` drops a leading ">" (a block quote);
## `roxygen` drops a leading "#'" (roxygen comments).
pageText <- function(..., unquote = FALSE, roxygen = FALSE) {
  lines <- sourceLines(...)
  if (unquote) lines <- sub("^\\s*>\\s?", "", lines)
  if (roxygen) lines <- sub("^#'\\s?", "", lines)
  text <- paste(lines, collapse = " ")
  text <- gsub("[`*_]", "", text)
  gsub("\\s+", " ", text)
}

## The R code of the chunk labelled `label` in a .qmd or .Rmd, without its `#|`
## option lines: the label is either the chunk's own ("```{r label, ...}") or a
## "#| label: label" line inside it. NULL when no chunk carries the label (an
## unclosed chunk is skipped); character(0) for a chunk with no code.
chunkCode <- function(lines, label) {
  fence <- "```"
  for (start in grep(paste0("^", fence, "\\{r"), lines)) {
    closing <- which(lines == fence & seq_along(lines) > start)
    if (length(closing) == 0L) next
    body <- lines[seq_len(closing[1L] - start - 1L) + start]
    headerLabel <- sub("[,}].*$", "",
                       sub("^```\\{r\\s*", "", lines[start]))
    if (identical(headerLabel, label) ||
          any(body == paste0("#| label: ", label))) {
      return(body[!startsWith(body, "#|")])
    }
  }
  NULL
}

## Each phrase stands in `text` (`where` names the page in a failure).
expectNames <- function(text, phrases, where = "") {
  for (phrase in phrases) {
    expect_true(grepl(phrase, text, fixed = TRUE),
                info = trimws(paste(where, phrase)))
  }
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
