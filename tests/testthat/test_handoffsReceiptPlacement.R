## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md ("A gate that fails when a receipt sits inside the format-example
## box of `HANDOFFS.md`", found S917; the owner chose a test in the suite, S922):
## from S814 to S917 every new session receipt was written right after the
## four-backtick line that opens the code box holding the format example, so
## `methodology_trim.py` counted them as front matter, saw 1 of 105 receipts
## and could archive nothing. The sentence added to the file's "How to write a
## receipt" is a row, not a gate (Learning 882). This file is the gate: the
## box must hold exactly one `handoff` block, the example.
##
## handoffsBoxReceiptCount() (tests/testthat/helper-handoffsBox.R) counts the
## blocks between the first two lines that are exactly four backticks, so a
## receipt above or below the box is not counted (the first block in the file
## is not the test: the box is). The real-file tests read ../../HANDOFFS.md,
## which .Rbuildignore excludes, so they skip in a built package, under
## `devtools::check()` and under covr; they run from the source tree, which is
## where the close-out suite runs.

pkg_root <- testthat::test_path("..", "..")
handoffs_path <- file.path(pkg_root, "HANDOFFS.md")

## One receipt as the file writes it: a `handoff` fence, key lines, a plain
## closing fence.
receipt <- function(session) {
  c("```handoff", paste0("session: ", session), "status: complete", "```")
}

## The format-example box: opening four-backtick line, the example block, a
## prose line, closing four-backtick line.
exampleBox <- function() {
  c("````", receipt("S<N>"), "free-text prose under the example", "````")
}

test_that("a receipt above the box and receipts below it are not counted", {
  lines <- c("# Handoff Receipts", receipt("S1"), "",
             exampleBox(), "",
             receipt("S3"), "", receipt("S2"))
  expect_equal(handoffsBoxReceiptCount(lines), 1L)
})

test_that("a receipt put right after the opening four-backtick line is counted", {
  ## The S917 shape: the new receipt goes inside the box, above the example.
  box <- exampleBox()
  lines <- c("# Handoff Receipts", "",
             box[1], receipt("S9"), box[-1], "",
             receipt("S3"))
  expect_equal(handoffsBoxReceiptCount(lines), 2L)
})

test_that("a box emptied of its example counts zero", {
  lines <- c("# Handoff Receipts", "", "````", "no example left", "````", "",
             receipt("S3"))
  expect_equal(handoffsBoxReceiptCount(lines), 0L)
})

test_that("a handoff fence named in prose or a bare closing fence is not counted", {
  lines <- c("# Handoff Receipts", "",
             "````",
             "Write a ```handoff block above the newest one.",
             receipt("S<N>"),
             "````")
  expect_equal(handoffsBoxReceiptCount(lines), 1L)
})

test_that("a file without exactly two four-backtick lines is refused", {
  none <- c("# Handoff Receipts", receipt("S1"))
  one <- c("# Handoff Receipts", "````", receipt("S<N>"))
  three <- c(exampleBox(), "````", receipt("S1"))
  for (lines in list(none, one, three)) {
    expect_error(handoffsBoxReceiptCount(lines), "four-backtick")
  }
})

test_that("the real HANDOFFS.md holds exactly one receipt in its example box", {
  skip_if_not(file.exists(handoffs_path), "HANDOFFS.md is not in this build")
  lines <- readLines(handoffs_path, encoding = "UTF-8", warn = FALSE)
  expect_equal(handoffsBoxReceiptCount(lines), 1L)
})

test_that("a receipt inserted after the real box's opening line is caught", {
  skip_if_not(file.exists(handoffs_path), "HANDOFFS.md is not in this build")
  lines <- readLines(handoffs_path, encoding = "UTF-8", warn = FALSE)
  opening <- which(lines == "````")[1L]
  expect_false(is.na(opening))
  slipped <- append(lines, receipt("S0"), after = opening)
  expect_equal(handoffsBoxReceiptCount(slipped), 2L)
})
