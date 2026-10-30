## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the tests that read the newest version block of NEWS.Rmd or
## NEWS.md (test_newsReleaseState.R, test_newsGeneralFixesGrouped.R,
## test_oneFileGenotypesWording.R, test_earlierSnapshotsDocs.R,
## test_drawPedigreeDiagramDocs.R, the test_harem*Wording.R files): find that
## block, read one of its sections and read its bullets.

## The newest version block: from the first "# nprcgenekeepr" heading up to
## (not including) the second one. Returns the heading's 1-based line number
## in the file and the block's lines; an empty block if no heading exists.
newsTopBlock <- function(lines) {
  heads <- grep("^# nprcgenekeepr", lines)
  if (length(heads) == 0L) {
    return(list(start = 0L, lines = character(0L)))
  }
  end <- if (length(heads) > 1L) heads[2L] - 1L else length(lines)
  list(start = heads[1L], lines = lines[heads[1L]:end])
}

## The positions in `blockLines` of the lines under one "## <heading>": after
## the heading, up to (not including) the next "## ". Empty if it is absent.
newsSectionSpan <- function(blockLines, heading) {
  from <- which(trimws(blockLines) == paste("##", heading))
  if (length(from) == 0L) {
    return(integer(0L))
  }
  later <- grep("^## ", blockLines)
  later <- later[later > from[1L]]
  to <- if (length(later) > 0L) later[1L] - 1L else length(blockLines)
  if (to > from[1L]) seq(from[1L] + 1L, to) else integer(0L)
}

## The lines of one section of the newest version block of a NEWS file.
newsSectionLines <- function(lines, heading) {
  block <- newsTopBlock(lines)$lines
  block[newsSectionSpan(block, heading)]
}

## The Breeding Group Formation part of a NEWS file read as one string (see
## sectionOf() in helper-pageText.R).
breedingGroupSection <- function(text) {
  sectionOf(text, "## Breeding Group Formation", "## Mate Pair Analysis")
}

## The bullet entries of a block. An entry starts at a line beginning "- " and
## runs over the indented lines that follow it; `line` is the file line the
## entry starts on and `text` its wrapped lines joined into one string.
newsEntries <- function(block) {
  ls <- block$lines
  starts <- grep("^- ", ls)
  entries <- lapply(starts, function(i) {
    j <- i
    while (j < length(ls) && grepl("^ {2,}\\S", ls[j + 1L])) {
      j <- j + 1L
    }
    text <- paste(trimws(ls[i:j]), collapse = " ")
    data.frame(line = block$start + i - 1L, text = sub("^- ", "", text),
               stringsAsFactors = FALSE)
  })
  if (length(entries) == 0L) {
    return(data.frame(line = integer(0L), text = character(0L),
                      stringsAsFactors = FALSE))
  }
  do.call(rbind, entries)
}
