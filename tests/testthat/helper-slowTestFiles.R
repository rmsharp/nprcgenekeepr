## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## The test files a CRAN check leaves out, named in `dir`'s slowTestFiles.txt
## (one a line; `#` starts a comment). tests/testthat.R sources this file and
## hands cranTestFilter() to test_check() with invert = TRUE, so a CRAN check
## runs every other file (test_slowTestFiles.R).
slowTestFiles <- function(dir) {
  listFile <- file.path(dir, "slowTestFiles.txt")
  if (!file.exists(listFile)) {
    return(character(0))
  }
  listed <- trimws(sub("#.*$", "", readLines(listFile)))
  listed[nzchar(listed)]
}

## A test_dir() filter matching the listed files, or NULL (every file runs)
## when NOT_CRAN is "true", as on CI and in local runs, or when none is listed.
cranTestFilter <- function(dir, notCran = Sys.getenv("NOT_CRAN")) {
  listed <- slowTestFiles(dir)
  if (isTRUE(as.logical(notCran)) || length(listed) == 0L) {
    return(NULL)
  }
  paste0("^(", paste(sub("\\.[Rr]$", "", sub("^test[-_]", "", listed)),
                     collapse = "|"), ")$")
}
