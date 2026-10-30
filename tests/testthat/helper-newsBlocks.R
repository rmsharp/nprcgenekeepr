## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the tests that read the newest version block of NEWS.Rmd or
## NEWS.md (test_newsReleaseState.R, test_newsGeneralFixesGrouped.R,
## test_oneFileGenotypesWording.R): find that block and read its bullets.

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
