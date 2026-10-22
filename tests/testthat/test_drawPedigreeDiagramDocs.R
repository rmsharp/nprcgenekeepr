## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## The S1029 BACKLOG item "Scripted Diagram rendering lacks the deceased slash
## and the condition sections" (owner ruling S1030, "One function draws it
## all"; see test_drawPedigreeDiagram.R). Five sentences in two pages say a script draws
## what the Diagram tab draws:
##
##  - vignettes/a2interactive.Rmd: the functions "work identically outside the
##    Shiny application", and the walkthrough "reproduces the Diagram tab's
##    rendering exactly";
##  - vignettes/articles/pedigree-diagram.qmd: the vignette "shows the same
##    rendering built entirely from R", the functions "work identically outside
##    the Shiny application", and the walkthrough is "reproducing this tab's
##    rendering exactly".
##
## They were untrue: the walkthrough's two chunks built a 5-row legend by
## hand, and the article itself said visNetwork() alone does not draw the
## condition sections. Each sentence now names drawPedigreeDiagram(), both
## chunks call it, and the function is in the reference index and NEWS. The
## pages sit outside a built package, so these blocks skip there and run from
## the source tree (sourceLines(), helper-pageText.R).

## The prose paragraphs of `lines` as plain text (see plainText()), one string
## each: a fenced chunk is blanked first, so its code is never a paragraph.
## A function is named bare: the vignette writes __name__, the article `name()`.
proseParagraphs <- function(lines) {
  inChunk <- FALSE
  for (i in seq_along(lines)) {
    if (startsWith(trimws(lines[[i]]), "```")) {
      inChunk <- !inChunk
      lines[[i]] <- ""
    } else if (inChunk) {
      lines[[i]] <- ""
    }
  }
  blank <- !nzchar(trimws(lines))
  paragraph <- cumsum(blank)
  pieces <- split(lines[!blank], paragraph[!blank])
  unname(vapply(pieces, plainText, character(1L)))
}

## Each sentence that says a script draws what the tab draws, by page.
matchClaims <- list(
  "a2interactive.Rmd" = list(
    path = c("vignettes", "a2interactive.Rmd"),
    phrases = c("work identically outside the Shiny application",
                "rendering exactly")
  ),
  "pedigree-diagram.qmd" = list(
    path = c("vignettes", "articles", "pedigree-diagram.qmd"),
    phrases = c("same rendering built entirely from R",
                "work identically outside the Shiny application",
                "rendering exactly")
  )
)

test_that(
  "every sentence that says a script draws what the Diagram tab draws stands
   in a paragraph that names drawPedigreeDiagram()", {
  for (page in names(matchClaims)) {
    paragraphs <- proseParagraphs(do.call(sourceLines,
                                          as.list(matchClaims[[page]]$path)))
    for (phrase in matchClaims[[page]]$phrases) {
      holding <- paragraphs[grepl(phrase, paragraphs, fixed = TRUE)]
      expect_gte(length(holding), 1L,
                 label = paste(page, "paragraphs saying", dQuote(phrase)))
      for (paragraph in holding) {
        expect_true(grepl("drawPedigreeDiagram", paragraph, fixed = TRUE),
                    info = paste(page, "-", substr(paragraph, 1L, 160L)))
      }
    }
  }
})

test_that(
  "the a2interactive walkthrough draws both Diagram examples with
   drawPedigreeDiagram(), not a hand-built legend", {
  lines <- sourceLines("vignettes", "a2interactive.Rmd")
  for (label in c("pedigree-diagram-render",
                  "pedigree-diagram-rectilinear-render")) {
    code <- chunkCode(lines, label)
    expect_false(is.null(code), info = paste("chunk", label))
    expect_true(any(grepl("drawPedigreeDiagram(", code, fixed = TRUE)),
                info = paste("chunk", label))
    expect_false(any(grepl("visLegend(", code, fixed = TRUE)),
                 info = paste("chunk", label))
  }
  rectilinear <- chunkCode(lines, "pedigree-diagram-rectilinear-render")
  expect_true(any(grepl('edgeStyle = "rectilinear"', rectilinear,
                        fixed = TRUE)))
})

test_that(
  "the Diagram article no longer says visNetwork() alone leaves the sections
   undrawn; it names drawPedigreeDiagram() where it says who draws them", {
  paragraphs <- proseParagraphs(
    sourceLines("vignettes", "articles", "pedigree-diagram.qmd")
  )
  text <- paste(paragraphs, collapse = " ")
  expect_equal(occurrences(text, "alone does not draw them"), 0L)
  sections <- paragraphs[grepl("affectedSections", paragraphs, fixed = TRUE)]
  expect_gte(length(sections), 1L)
  expect_true(any(grepl("drawPedigreeDiagram", sections, fixed = TRUE)))
})

test_that("_pkgdown.yml lists drawPedigreeDiagram in its reference index", {
  lines <- sourceLines("_pkgdown.yml")
  expect_true(any(grepl("`drawPedigreeDiagram`", lines, fixed = TRUE)))
})

test_that("NEWS.Rmd names drawPedigreeDiagram() in its Pedigree Diagram part", {
  lines <- sourceLines("NEWS.Rmd")
  start <- which(lines == "## Pedigree Diagram")
  expect_length(start, 1L)
  following <- which(startsWith(lines, "## ") & seq_along(lines) > start[1L])
  part <- lines[seq(start[1L], following[1L] - 1L)]
  expect_true(any(grepl("drawPedigreeDiagram()", part, fixed = TRUE)))
})
