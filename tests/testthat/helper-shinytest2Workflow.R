## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Test-harness support (S1047, GREEN-to-REFACTOR gate): the one place that
## names the nightly browser-test workflow file, which
## test_shinytest2_workflow_timeout.R and test_shinytest2_workflow_coverage.R
## both read.

## The path from the tests directory to .github/workflows/shinytest2.yaml. It
## is built when called, not when this file is loaded, so it follows the
## directory the test run is in. The file may be absent from a built package;
## the tests skip when `file.exists()` is FALSE.
shinytest2WorkflowPath <- function() {
  testthat::test_path("..", "..", ".github", "workflows", "shinytest2.yaml")
}
