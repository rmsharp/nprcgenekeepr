## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Test-harness support (S922, BACKLOG "A gate that fails when a receipt sits
## inside the format-example box of `HANDOFFS.md`"): what
## test_handoffsReceiptPlacement.R uses to count the receipts in that box.

## How many `handoff` blocks sit between the two lines that are exactly four
## backticks (the code box that holds the format example). `lines` is the file
## as readLines() gives it. A receipt above or below the box is not counted.
## Stops unless the file has exactly two four-backtick lines.
handoffsBoxReceiptCount <- function(lines) {
  fences <- which(lines == "````")
  if (length(fences) != 2L) {
    stop("expected exactly two four-backtick lines, found ", length(fences),
         call. = FALSE)
  }
  inside <- lines[fences[1L] + seq_len(fences[2L] - fences[1L] - 1L)]
  sum(inside == "```handoff")
}
