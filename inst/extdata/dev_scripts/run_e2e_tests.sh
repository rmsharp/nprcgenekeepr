#!/bin/bash
#' Run E2E Tests for nprcgenekeepr Shiny Application
#'
#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' This shell script runs all end-to-end (E2E) tests for the Shiny application.
#'
#' Prerequisites:
#'   - R packages: shinytest2, chromote, testthat, devtools
#'   - Chrome/Chromium browser installed (for headless testing)
#'
#' Usage:
#'   ./run_e2e_tests.sh
#'   # or
#'   bash run_e2e_tests.sh

set -e

echo "=== nprcgenekeepr E2E Test Runner ==="
echo ""

# Find the package root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Package root: $PKG_ROOT"
echo ""

# Check for Chrome/Chromium
if command -v google-chrome &> /dev/null; then
    echo "Found: google-chrome"
elif command -v chromium &> /dev/null; then
    echo "Found: chromium"
elif command -v chromium-browser &> /dev/null; then
    echo "Found: chromium-browser"
elif [[ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]]; then
    echo "Found: Google Chrome (macOS)"
else
    echo "WARNING: Chrome/Chromium not found in standard locations."
    echo "E2E tests require Chrome or Chromium for headless browser testing."
    echo ""
fi

# Set environment variable to indicate not running on CRAN
export NOT_CRAN=true

# Change to package root
cd "$PKG_ROOT"

echo "Running E2E tests..."
echo "This may take several minutes as each test launches a browser instance."
echo ""

# Run the tests
time Rscript -e "devtools::test(filter='e2e')"

echo ""
echo "=== E2E Tests Complete ==="
