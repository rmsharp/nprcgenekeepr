## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Chunk-aware scan backing test_vignettes_no_deprecated_minParentAge.R.
## Only lines inside an executed R code chunk (between ```{r...}/```{R...}
## and its closing ```) are checked for a deprecated `minParentAge=` call;
## prose and inline backtick code spans outside chunks are ignored.

findDeprecatedMinParentAgeOffenders <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE)
  in_chunk <- FALSE
  offenders <- integer(0)
  for (i in seq_along(lines)) {
    line <- lines[[i]]
    if (!in_chunk && grepl("^```\\{[rR][ ,}]", line)) {
      in_chunk <- TRUE
    } else if (in_chunk && grepl("^```\\s*$", line)) {
      in_chunk <- FALSE
    } else if (in_chunk &&
               grepl("minParentAge[[:space:]]*=[^=]", line)) {
      offenders <- c(offenders, i)
    }
  }
  offenders
}
