## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the tests that pin the wording of one "###" section of the colony
## manager guide (test_guideGroupsOutsidePedigreeWording.R and
## test_earlierSnapshotsDocs.R). The guide is build-ignored, so sourceLines()
## (helper-pageText.R) skips the calling block in a built package and runs it
## from the source tree.

## The paragraphs of one "###" section of the guide, each as one line of text
## with its white space collapsed. Fenced code is blanked first, so a comment
## line inside a chunk cannot end the section. A heading the guide lacks gives
## character(0), so a block fails on its words, not on an error.
guideSectionParagraphs <- function(heading) {
  lines <- sourceLines("vignettes", "articles", "colony-manager-guide.qmd")
  fence <- grepl("^```", lines)
  lines[cumsum(fence) %% 2L == 1L | fence] <- ""
  start <- which(lines == paste("###", heading))
  if (length(start) != 1L) {
    return(character(0))
  }
  later <- which(grepl("^#{2,3} ", lines) & seq_along(lines) > start)
  end <- if (length(later) > 0L) min(later) - 1L else length(lines)
  body <- lines[seq.int(start + 1L, end)]
  blank <- !nzchar(trimws(body))
  if (all(blank)) {
    return(character(0))
  }
  paragraphs <- tapply(body[!blank], cumsum(blank)[!blank], paste,
                       collapse = " ")
  gsub("\\s+", " ", trimws(unname(paragraphs)))
}

## The one paragraph holding a piece of text, or "" when no paragraph or more
## than one holds it, so a missing or doubled sentence fails on its words.
onlyParagraphWith <- function(paragraphs, text) {
  hit <- grep(text, paragraphs, fixed = TRUE)
  if (length(hit) == 1L) paragraphs[hit] else ""
}
