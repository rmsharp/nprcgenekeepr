# Tests for Error Handling and Logging System
# Task #9: Implement error handling and logging system

# =============================================================================
# Tests for centralized logging helper
# =============================================================================

test_that("logModuleEvent function exists", {
  # Check that the logging helper function is available
  expect_true(exists("logModuleEvent"))
})
test_that("logModuleEvent logs with correct format", {
  skip_if_not(exists("logModuleEvent"))

  # Should return invisibly (no error)
  expect_no_error(logModuleEvent("testModule", "Test message"))
})

test_that("logModuleEvent handles different log levels", {
  skip_if_not(exists("logModuleEvent"))

  expect_no_error(logModuleEvent("test", "Debug message", level = "DEBUG"))
  expect_no_error(logModuleEvent("test", "Info message", level = "INFO"))
  expect_no_error(logModuleEvent("test", "Warning message", level = "WARN"))
  expect_no_error(logModuleEvent("test", "Error message", level = "ERROR"))
})

# =============================================================================
# Tests for safeExecute wrapper function
# =============================================================================

test_that("safeExecute function exists", {
  expect_true(exists("safeExecute"))
})

test_that("safeExecute returns result on success", {
  skip_if_not(exists("safeExecute"))

  result <- safeExecute({
    1 + 1
  }, module = "test")

  expect_equal(result, 2)
})

test_that("safeExecute returns default on error", {
  skip_if_not(exists("safeExecute"))

  result <- safeExecute({
    stop("Intentional error")
  }, module = "test", default = NULL)

  expect_null(result)
})

test_that("safeExecute captures error message", {
  skip_if_not(exists("safeExecute"))

  result <- safeExecute({
    stop("Custom error message")
  }, module = "test", default = "fallback")

  expect_equal(result, "fallback")
})

# =============================================================================
# Issue #111 coverage backfill: logModuleEvent level/format/output branches
# =============================================================================

test_that("logModuleEvent falls back to INFO for an unrecognized level", {
  ## An unknown level is coerced to "INFO"; with verbose on, the default
  ## switch branch prints the [INFO]-tagged line.
  withr::local_options(list(nprcgenekeepr.verbose = TRUE))
  expect_output(
    logModuleEvent("mod", "hello", level = "BOGUS"),
    "\\[INFO\\].*hello"
  )
})

test_that("logModuleEvent applies sprintf-style formatting with extra args", {
  withr::local_options(list(nprcgenekeepr.verbose = TRUE))
  expect_output(
    logModuleEvent("mod", "Processing %d animals", level = "INFO", 100L),
    "Processing 100 animals"
  )
})

test_that("logModuleEvent prints DEBUG output only when debug is enabled", {
  withr::local_options(list(nprcgenekeepr.debug = TRUE))
  expect_output(logModuleEvent("mod", "dbg msg", level = "DEBUG"), "dbg msg")
})

test_that("logModuleEvent prints INFO output only when verbose is enabled", {
  withr::local_options(list(nprcgenekeepr.verbose = TRUE))
  expect_output(logModuleEvent("mod", "info msg", level = "INFO"), "info msg")
})

# =============================================================================
# Issue #111 coverage backfill: safeExecute warning-recovery and notify paths
# =============================================================================

test_that("safeExecute logs a warning and returns the expression result", {
  ## The warning handler logs then re-evaluates the expression under
  ## suppressWarnings, so the value survives the warning.
  result <- suppressMessages(
    safeExecute({
      warning("a warning")
      42L
    }, module = "test")
  )
  expect_equal(result, 42L)
})

test_that("safeExecute with notify does nothing outside a Shiny session", {
  ## notify = TRUE but no reactive domain: the is.null(session) guard is taken
  ## and showNotification is never reached; the default is still returned.
  result <- suppressMessages(
    safeExecute(stop("e"), module = "test", notify = TRUE, default = "d")
  )
  expect_identical(result, "d")
})

test_that("safeExecute with notify shows a notification inside a Shiny session", {
  called <- FALSE
  testthat::local_mocked_bindings(
    getDefaultReactiveDomain = function() {
      structure(list(), class = "ShinySession")
    },
    showNotification = function(...) {
      called <<- TRUE
      invisible(NULL)
    },
    .package = "shiny"
  )
  result <- suppressMessages(
    safeExecute(stop("boom"), module = "test", notify = TRUE, default = "d")
  )
  expect_true(called)
  expect_identical(result, "d")
})

# =============================================================================
# Tests for module-specific error handling
# =============================================================================

test_that("modInputServer handles file upload errors gracefully", {
  skip_if_not_installed("shiny")

  # The module should not crash on invalid file uploads
  expect_true(is.function(modInputServer))

  # Check that module includes tryCatch for file operations
  server_source <- deparse(modInputServer)
  server_text <- paste(server_source, collapse = "\n")
  expect_true(grepl("tryCatch", server_text))
})

test_that("modPedigreeServer handles invalid pedigree gracefully", {
  skip_if_not_installed("shiny")

  # Check that module includes error handling
  server_source <- deparse(modPedigreeServer)
  server_text <- paste(server_source, collapse = "\n")
  expect_true(grepl("tryCatch|validate", server_text))
})

test_that("modGeneticValueServer handles missing data gracefully", {
  skip_if_not_installed("shiny")

  # Check that module includes error handling
  server_source <- deparse(modGeneticValueServer)
  server_text <- paste(server_source, collapse = "\n")
  expect_true(grepl("tryCatch|req", server_text))
})

test_that("modBreedingGroupsServer handles formation errors gracefully", {
  skip_if_not_installed("shiny")

  # Check that module includes error handling and notifications
  server_source <- deparse(modBreedingGroupsServer)
  server_text <- paste(server_source, collapse = "\n")
  expect_true(grepl("tryCatch", server_text))
  expect_true(grepl("showNotification", server_text))
})

test_that("modSummaryStatsServer handles kinship calculation errors", {
  skip_if_not_installed("shiny")

  # Check that module includes error handling
  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")
  expect_true(grepl("tryCatch", server_text))
})

# =============================================================================
# Tests for user notification patterns
# =============================================================================

test_that("modules use showNotification for user-facing errors", {
  skip_if_not_installed("shiny")

  # Check that key modules have showNotification imported
  input_source <- deparse(modInputServer)
  input_text <- paste(input_source, collapse = "\n")

  pedigree_source <- deparse(modPedigreeServer)
  pedigree_text <- paste(pedigree_source, collapse = "\n")

  breeding_source <- deparse(modBreedingGroupsServer)
  breeding_text <- paste(breeding_source, collapse = "\n")

  # At least one module should use showNotification
  has_notifications <- grepl("showNotification", input_text) ||
    grepl("showNotification", pedigree_text) ||
    grepl("showNotification", breeding_text)

  expect_true(has_notifications)
})

# =============================================================================
# Tests for Shiny validation patterns
# =============================================================================

test_that("modules use req() for reactive dependencies", {
  skip_if_not_installed("shiny")

  # Check that modules use req() for data dependencies
  summary_source <- deparse(modSummaryStatsServer)
  summary_text <- paste(summary_source, collapse = "\n")

  expect_true(grepl("req\\(", summary_text))
})

# =============================================================================
# Tests for appServer error handling
# =============================================================================
# "appServer handles module initialization errors" (a deparse(appServer) grep
# for the literal string "tryCatch") was replaced by
# test_appServer_server.R's "a genuine error from a child module surfaces
# instead of being silently swallowed" (issue #122 Phase 4): the old test
# passed merely because SOME tryCatch existed in appServer's source, never
# because it verified a shape-mismatch bug actually surfaces rather than being
# masqueraded as "no data yet" -- the actual contract this phase establishes.

test_that("appServer handles QC errors with dynamic tabs", {
  skip_if_not_installed("shiny")

  # Check that appServer handles QC error display
  server_source <- deparse(appServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should check for errors and display appropriately
  expect_true(grepl("error|Error", server_text))
})

# =============================================================================
# Tests for error message quality
# =============================================================================

test_that("error messages are user-friendly", {
  # Error notifications should be informative
  # This tests the pattern of error message strings

  # Check modBreedingGroupsServer for good error messages
  breeding_source <- deparse(modBreedingGroupsServer)
  breeding_text <- paste(breeding_source, collapse = "\n")

  # Should have descriptive error messages, not just technical errors
  has_user_message <- grepl("Could not|Unable to|Please|Error:", breeding_text)
  expect_true(has_user_message)
})

# =============================================================================
# Tests for logging integration
# =============================================================================

test_that("appServer initializes logging", {
  skip_if_not_installed("shiny")

  # Check if appServer sets up logging
  server_source <- deparse(appServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should reference logging in some form
  # This may be flog, logModuleEvent, or cat for debug output
  has_logging <- grepl("log|cat|debug|info", server_text, ignore.case = TRUE)
  expect_true(has_logging)
})
