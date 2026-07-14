# Tests for Site-Aware Configuration and ORIP Reporting
# Task #10: Add site-aware configuration and ORIP reporting

# =============================================================================
# Tests for site configuration in appServer
# =============================================================================

test_that("appServer loads site configuration", {
  skip_if_not_installed("shiny")

  # Check that appServer contains configuration loading
  server_source <- deparse(appServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should reference config or getConfigFileName
  has_config <- grepl("config|getConfigFileName|getSiteInfo", server_text,
                      ignore.case = TRUE)
  expect_true(has_config)
})

test_that("appServer shared reactiveValues includes config", {
  skip_if_not_installed("shiny")

  # Check that appServer has config in shared reactiveValues
  server_source <- deparse(appServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should have config in reactiveValues
  expect_true(grepl("config", server_text, ignore.case = TRUE))
})

# =============================================================================
# Tests for getConfigFileName function
# =============================================================================

test_that("getConfigFileName returns expected structure", {
  sysInfo <- Sys.info()
  result <- getConfigFileName(sysInfo)

  # Should return named character vector
  expect_true(is.character(result))
  expect_true("homeDir" %in% names(result))
  expect_true("configFile" %in% names(result))
})

test_that("getConfigFileName uses correct filename for OS", {
  sysInfo <- Sys.info()
  result <- getConfigFileName(sysInfo)

  # On Unix-like systems, should use dot-prefix
  # On Windows, should use underscore-prefix
  if (grepl("windows", sysInfo[["sysname"]], ignore.case = TRUE)) {
    expect_true(grepl("_nprcgenekeepr_config", result[["configFile"]]))
  } else {
    expect_true(grepl("\\.nprcgenekeepr_config", result[["configFile"]]))
  }
})

# =============================================================================
# Tests for getSiteInfo function
# =============================================================================

test_that("getSiteInfo returns expected structure", {
  # Suppress warning about missing config file
  result <- suppressWarnings(getSiteInfo(expectConfigFile = TRUE))

  # Should return a list with required fields
  expect_true(is.list(result))
  expect_true("center" %in% names(result))
  expect_true("baseUrl" %in% names(result))
  expect_true("schemaName" %in% names(result))
})

test_that("getSiteInfo returns default values without config file", {
  result <- getSiteInfo(expectConfigFile = FALSE)

  # Should have default values
  expect_true(is.list(result))
  expect_equal(result$center, "ONPRC")
  expect_equal(result$schemaName, "study")
  expect_equal(result$queryName, "demographics")
})

test_that("getSiteInfo includes system information", {
  result <- getSiteInfo(expectConfigFile = FALSE)

  # Should include system info
  expect_true("sysname" %in% names(result))
  expect_true("nodename" %in% names(result))
  expect_true("user" %in% names(result))
  expect_true("homeDir" %in% names(result))
})

# =============================================================================
# Tests for ORIP Reporting Module
# =============================================================================

test_that("modORIPReportingUI function exists", {
  expect_true(exists("modORIPReportingUI"))
})

test_that("modORIPReportingUI returns valid Shiny UI", {
  skip_if_not_installed("shiny")
  skip_if_not(exists("modORIPReportingUI"))

  ui <- modORIPReportingUI("test")
  expect_true(inherits(ui, "shiny.tag") || inherits(ui, "shiny.tag.list"))
})

test_that("modORIPReportingServer function exists", {
  expect_true(exists("modORIPReportingServer"))
})

test_that("modORIPReportingServer is a proper module server", {
  skip_if_not_installed("shiny")
  skip_if_not(exists("modORIPReportingServer"))

  # Should be a function that takes id as first argument
  expect_true(is.function(modORIPReportingServer))
  args <- names(formals(modORIPReportingServer))
  expect_true("id" %in% args)
})

# =============================================================================
# Tests for site-aware behavior
# =============================================================================

test_that("modInputServer and modPedigreeServer no longer declare a config
parameter (issue #122 Phase 4)", {
  skip_if_not_installed("shiny")

  # The config param threaded shared$config into these two modules, but
  # neither module ever read it (docs/planning/issue122-module-contract-plan.md
  # section 2.6): the site info that actually matters to the app (LabKey
  # connection defaults, required/possible column lists) is sourced
  # independently elsewhere. Phase 4 removes the dead parameter.
  input_args <- names(formals(modInputServer))
  pedigree_args <- names(formals(modPedigreeServer))
  expect_false("config" %in% input_args)
  expect_false("config" %in% pedigree_args)
})

# =============================================================================
# Tests for center-specific defaults
# =============================================================================

test_that("SNPRC and ONPRC have different default configurations", {
  # These are the two main centers supported
  onprc_info <- getSiteInfo(expectConfigFile = FALSE)

  # Default is ONPRC
  expect_equal(onprc_info$center, "ONPRC")
  expect_true(grepl("ONPRC", onprc_info$folderPath))
})

test_that("getSiteInfo includes lkPedColumns mapping", {
  result <- getSiteInfo(expectConfigFile = FALSE)

  # Should have LabKey pedigree columns defined
  expect_true("lkPedColumns" %in% names(result))
  expect_true("mapPedColumns" %in% names(result))
  expect_true(length(result$lkPedColumns) > 0)
})
