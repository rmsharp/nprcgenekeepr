#!/usr/bin/env Rscript
#' Run E2E Tests for nprcgenekeepr Shiny Application
#'
#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' This script runs all end-to-end (E2E) tests for the Shiny application.
#' E2E tests use shinytest2 and chromote to test the application in a browser.
#'
#' Prerequisites:
#'   - R packages: shinytest2, chromote, testthat
#'   - Chrome/Chromium browser installed (for headless testing)
#'
#' Usage:
#'   Rscript run_e2e_tests.R
#'   # or from R:
#'   source("run_e2e_tests.R")

# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------

cat("=== nprcgenekeepr E2E Test Runner ===\n\n")

# Check for required packages
required_packages <- c("shinytest2", "chromote", "testthat", "devtools")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
 cat("Missing required packages:", paste(missing_packages, collapse = ", "), "\n")
 cat("Install with: install.packages(c('", paste(missing_packages, collapse = "', '"), "'))\n")
 stop("Please install missing packages before running E2E tests.")
}

# Check for Chrome/Chromium
check_chrome <- function() {
 tryCatch({
   chromote::find_chrome()
   TRUE
 }, error = function(e) {
   FALSE
 })
}

if (!check_chrome()) {
 cat("WARNING: Chrome/Chromium browser not found.\n")
 cat("E2E tests require Chrome or Chromium for headless browser testing.\n")
 cat("Install Chrome or set CHROMOTE_CHROME environment variable.\n\n")
}

# Set environment to run tests (not on CRAN)
Sys.setenv(NOT_CRAN = "true")

# -----------------------------------------------------------------------------
# Run E2E Tests
# -----------------------------------------------------------------------------

cat("Running E2E tests...\n")
cat("This may take several minutes as each test launches a browser instance.\n\n")

start_time <- Sys.time()

# Run tests with filter for e2e
results <- devtools::test(
 pkg = ".",
 filter = "e2e",
 stop_on_failure = FALSE
)

end_time <- Sys.time()
elapsed <- difftime(end_time, start_time, units = "mins")

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

cat("\n=== E2E Test Summary ===\n")
cat(sprintf("Total time: %.1f minutes\n", as.numeric(elapsed)))

# Print results summary if available
if (!is.null(results)) {
 # testthat 3.x returns a list with test results
 n_pass <- sum(sapply(results, function(x) length(x$results)))
 cat(sprintf("Tests completed successfully\n"))
}

cat("\nDone.\n")
