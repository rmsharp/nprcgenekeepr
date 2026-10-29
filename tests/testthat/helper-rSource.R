## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## TRUE when `rDir` holds an R source file (`.R` or `.r`, not in a subfolder).
## A test that scans R/ skips unless this is TRUE: under covr the tests run from
## an installed copy of the package, whose R/ holds only `.rdb`/`.rdx` files
## (test_rSourceAvailable.R).
rSourceAvailable <- function(rDir) {
  length(list.files(rDir, pattern = "\\.[Rr]$")) > 0L
}
