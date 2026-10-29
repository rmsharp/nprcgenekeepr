## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Write `text` to a temporary file exactly as given, with no newline added,
## and return its path. Used by test_readWithFinalNewline.R and
## test_muffleIncompleteFinalLine.R for files that end without a newline.
writeExactly <- function(text, ext = ".csv") {
  f <- tempfile(fileext = ext)
  writeBin(charToRaw(text), f)
  f
}
