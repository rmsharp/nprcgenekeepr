## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the tests that pin a page's wording (test_originFundingWording.R,
## test_defaultPopulationWording.R, test_oneFileGenotypesWording.R,
## test_genotypeTutorialsWording.R, test_markerBlankAlleleHelp.R,
## test_genomicRohLocusDocs.R): read a page of the source tree as lines or
## as one line of text, count a phrase in it, say which phrases a page now holds
## and which it no longer holds, pull a code chunk out of a .qmd or .Rmd, and
## read a function's help in the two places it lives (manText(), roxygenText(),
## helpPlaces(), skipUnlessHelpInSourceTree()), and read the example of a man
## page (exampleLinesOf(); test_examples_invoke_documented_fn.R and
## test_docsAuditLeftoverWording.R), and tell a section of a tutorial's code
## chunks from its prose and read a chunk's option lines (insideChunk(),
## sectionProse(), chunkOptionText(); test_snapshotTutorialSection.R and
## test_inventoryTutorialSections.R), and read the column headings of a DT
## table the app shows (dtHeadings(); test_modGeneticValue.R and
## test_modMarkerGenetics.R).

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

## A function's help, in the two places it lives: the generated man page
## and the roxygen block in R/. Both read the source tree (man/ and R/ do not
## exist under an installed package) and give NA there, so the caller skips.

manText <- function(topic) {
  path <- testthat::test_path("..", "..", "man", paste0(topic, ".Rd"))
  if (!file.exists(path)) {
    return(NA_character_)
  }
  collapseSpace(paste(unlist(tools::parse_Rd(path)), collapse = ""))
}

## The example code of one man page (the file `rd`), one string per line, as
## tools::Rd2ex() writes it: a \dontrun part stays in as "## Not run:" and
## "##D" comment lines. A page with no example gives character(0).
exampleLinesOf <- function(rd) {
  out <- tempfile(fileext = ".R")
  on.exit(unlink(out), add = TRUE)
  suppressMessages(tools::Rd2ex(rd, out))
  if (file.exists(out)) readLines(out, warn = FALSE) else character(0L)
}

## Every roxygen line of R/<file>.R with the `#'` prefix and the \code{}
## markup removed, white space collapsed.
roxygenText <- function(file) {
  path <- testthat::test_path("..", "..", "R", file)
  if (!file.exists(path)) {
    return(NA_character_)
  }
  lines <- readLines(path, warn = FALSE)
  text <- sub("^#' ?", "", lines[startsWith(lines, "#'")])
  collapseSpace(gsub("\\\\code\\{([^}]*)\\}", "\\1", paste(text, collapse = " ")))
}

## The two readers of one function's help, as the help tests name them: the
## generated man page (man/<topic>.Rd) and the roxygen block in R/<file>.
helpPlaces <- function(topic, file) {
  force(topic)
  force(file)
  list(
    "man page" = function() manText(topic),
    "roxygen block" = function() roxygenText(file)
  )
}

## Skip unless every reader in `places` (see helpPlaces()) finds its source.
skipUnlessHelpInSourceTree <- function(places) {
  testthat::skip_if(
    any(vapply(places, function(read) is.na(read()), logical(1L))),
    "man/*.Rd or R/*.R not available (installed package)"
  )
}

collapseSpace <- function(x) trimws(gsub("\\s+", " ", x))

## Which lines of a .qmd or .Rmd sit inside a code chunk, its opening fence
## included (test_snapshotTutorialSection.R, test_inventoryTutorialSections.R).
insideChunk <- function(lines) {
  cumsum(grepl("^```", lines)) %% 2L == 1L
}

## A section's text outside its code chunks and without its inline R code.
sectionProse <- function(section) {
  prose <- section[!insideChunk(section) & !grepl("^```", section)]
  gsub("`r [^`]*`", "", prose)
}

## A chunk's header line and its "#|" option lines.
chunkOptionText <- function(section, label) {
  start <- grep(paste0("^```\\{r ", label, "[,}]"), section)
  if (length(start) != 1L) return(character(0L))
  body <- section[-seq_len(start)]
  options <- body[cumsum(!startsWith(body, "#|")) == 0L]
  c(section[start], options)
}

## The heading text of every <th> in a DT table's widget container, in order.
## Under testServer() a DT output comes back as serialized widget JSON whose
## container holds the column headings (the rows themselves stay on the
## server); DT shows a data frame's row names as an unlabeled first column, an
## empty heading, unless told not to.
dtHeadings <- function(widgetJson) {
  json <- as.character(widgetJson)
  cells <- regmatches(json, gregexpr("<th>[^<]*<\\\\/th>", json))[[1L]]
  trimws(sub("<\\\\/th>$", "", sub("^<th>", "", cells)))
}
