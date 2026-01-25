# Tests for App Integration - verifying all modules are properly integrated
# These tests follow TDD - written before implementation

library(testthat)
library(nprcgenekeepr)

# ==============================================================================
# Test appUI contains all expected tabs
# ==============================================================================

test_that("appUI returns a shiny.tag object", {
  ui <- appUI()
  expect_true(inherits(ui, "shiny.tag") || inherits(ui, "shiny.tag.list"))
})

test_that("appUI contains Home tab", {
  ui <- appUI()
  ui_html <- as.character(ui)
  expect_true(grepl("Home", ui_html))
})
test_that("appUI contains Input tab", {
  ui <- appUI()
  ui_html <- as.character(ui)
  expect_true(grepl("Input", ui_html))
})

test_that("appUI contains Pedigree Browser tab", {
  ui <- appUI()
  ui_html <- as.character(ui)
  expect_true(grepl("Pedigree Browser", ui_html))
})

test_that("appUI contains Age-Sex Pyramid tab", {
  ui <- appUI()
  ui_html <- as.character(ui)
  expect_true(grepl("Age-Sex Pyramid", ui_html) ||
                grepl("Pyramid", ui_html))
})

test_that("appUI contains Genetic Value Analysis tab", {
  ui <- appUI()
  ui_html <- as.character(ui)
  expect_true(grepl("Genetic Value", ui_html))
})

test_that("appUI contains Breeding Groups tab", {
  ui <- appUI()
  ui_html <- as.character(ui)
  expect_true(grepl("Breeding Groups", ui_html))
})

# This test will fail until modSummaryStats is integrated
test_that("appUI contains Summary Statistics tab", {
  ui <- appUI()
  ui_html <- as.character(ui)
  expect_true(grepl("Summary Statistics", ui_html))
})

# ==============================================================================
# Test modSummaryStats UI is properly namespaced in appUI
# ==============================================================================

test_that("appUI includes modSummaryStatsUI with correct namespace", {
  ui <- appUI()
  ui_html <- as.character(ui)

  # Should contain the namespaced elements from modSummaryStatsUI
  expect_true(grepl("summaryStats", ui_html))
})

# ==============================================================================
# Test appServer properly initializes all modules
# ==============================================================================

test_that("appServer is a function with correct parameters", {
  expect_true(is.function(appServer))

  # Check function has expected parameters
  params <- names(formals(appServer))
  expect_true("input" %in% params)
  expect_true("output" %in% params)
  expect_true("session" %in% params)
})

# ==============================================================================
# Test that modSummaryStats receives correct reactive inputs
# ==============================================================================

test_that("modSummaryStatsServer exists and is exported", {
  expect_true(exists("modSummaryStatsServer"))
  expect_true(is.function(modSummaryStatsServer))
})

test_that("modSummaryStatsUI exists and is exported", {
  expect_true(exists("modSummaryStatsUI"))
  expect_true(is.function(modSummaryStatsUI))
})

# ==============================================================================
# Test modSummaryStats has founder statistics features
# ==============================================================================

test_that("modSummaryStatsServer handles geneticValues with founder data", {
  skip_if_not_installed("shiny")

  # Create test data matching the expected geneticValues format
  # The module expects a data.frame with meanKinship, genomeUniqueness, zScore
  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(0.1, 0.15, 0.2),
    zScore = c(-1, 0, 1),
    genomeUniqueness = c(0.8, 0.7, 0.6),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = c("A", "B", "C", "M1", "M2", "F1", "F2", "F3"),
    sire = c("M1", "M1", "M2", NA, NA, NA, NA, NA),
    dam = c("F1", "F2", "F3", NA, NA, NA, NA, NA),
    sex = c("M", "F", "M", "M", "M", "F", "F", "F"),
    stringsAsFactors = FALSE
  )

  test_kmat <- matrix(c(1, 0.25, 0.125, 0.25, 1, 0.25, 0.125, 0.25, 1),
                      nrow = 3, dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = function() test_gv,
      pedigree = function() test_ped,
      kinshipMatrix = function() test_kmat
    ),
    {
      # Module should return summary data
      result <- session$getReturned()
      expect_true(is.list(result))
      expect_true("summaryData" %in% names(result))
    }
  )
})

# ==============================================================================
# Test UI elements for founder statistics display
# ==============================================================================

test_that("modSummaryStatsUI has founder statistics output", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  # Should have area for founder stats - check for download buttons as proxy
  expect_true(grepl("downloadMaleFounders", ui_html))
  expect_true(grepl("downloadFemaleFounders", ui_html))
})

# ==============================================================================
# Test proper tab ordering in appUI
# ==============================================================================

test_that("appUI tabs are in logical order", {
  ui <- appUI()
  ui_html <- as.character(ui)

  # Find positions of key tabs
  home_pos <- regexpr("Home", ui_html)
  input_pos <- regexpr("Input", ui_html)
  pedigree_pos <- regexpr("Pedigree", ui_html)
  genetic_pos <- regexpr("Genetic Value", ui_html)

  # Home should come before Input

  expect_true(home_pos < input_pos || home_pos == -1L)
  # Input should come before Pedigree
  expect_true(input_pos < pedigree_pos)
})

# ==============================================================================
# Test appUI uses correct module namespaces
# ==============================================================================

test_that("appUI uses consistent module namespaces", {
  ui <- appUI()
  ui_html <- as.character(ui)

  # Check for expected namespace patterns
  expect_true(grepl("input-", ui_html) || grepl("input", ui_html))
  expect_true(grepl("pedigree", ui_html))
  expect_true(grepl("pyramid", ui_html))
  expect_true(grepl("geneticValue", ui_html))
  expect_true(grepl("breedingGroups", ui_html))
})
