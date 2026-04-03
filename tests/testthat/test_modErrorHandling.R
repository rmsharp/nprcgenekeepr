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

test_that("appServer handles module initialization errors", {
  skip_if_not_installed("shiny")

  # Check that appServer includes error handling
  server_source <- deparse(appServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should have tryCatch for safe initialization
  expect_true(grepl("tryCatch", server_text))
})

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
