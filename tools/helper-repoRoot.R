## testthat loads this file for each guard in tools/. test_file() runs a guard
## with tools/ as the working directory, so the guards walk up to find the
## repository's top folder.
findRepoRoot <- function() {
  dir <- getwd()
  while (!file.exists(file.path(dir, "DESCRIPTION")) && dirname(dir) != dir) {
    dir <- dirname(dir)
  }
  dir
}
