## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## The patterns in the source tree's .Rbuildignore; skips where it is absent (an
## installed package). Comments start a line with "#"; blank lines carry no
## pattern.
readRbuildignorePatterns <- function() {
  path <- testthat::test_path("..", "..", ".Rbuildignore")
  skip_if_not(file.exists(path), ".Rbuildignore not present")
  lines <- readLines(path, warn = FALSE)
  lines[nzchar(lines) & !grepl("^#", lines)]
}
