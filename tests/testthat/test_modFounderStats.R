# Tests for Founder Statistics HTML Table Display
# Task #12: Add founder statistics HTML table display

# =============================================================================
# Tests for makeFounderStatsTable helper function
# =============================================================================

test_that("makeFounderStatsTable function exists", {
  expect_true(exists("makeFounderStatsTable"))
})

test_that("makeFounderStatsTable returns HTML string", {
  skip_if_not(exists("makeFounderStatsTable"))

  # Create test data
  founderStats <- list(
    total = 50,
    nMaleFounders = 20,
    nFemaleFounders = 30,
    fe = 25.5,
    fg = 22.3
  )

  result <- makeFounderStatsTable(founderStats)

  # Should return character string with HTML
  expect_true(is.character(result))
  expect_true(grepl("<table", result, ignore.case = TRUE))
})

test_that("makeFounderStatsTable includes all founder counts", {
  skip_if_not(exists("makeFounderStatsTable"))

  founderStats <- list(
    total = 50,
    nMaleFounders = 20,
    nFemaleFounders = 30,
    fe = 25.5,
    fg = 22.3
  )

  result <- makeFounderStatsTable(founderStats)

  # Should include all key values
  expect_true(grepl("50", result))  # total founders
  expect_true(grepl("20", result))  # male founders
  expect_true(grepl("30", result))  # female founders
})

test_that("makeFounderStatsTable includes FE and FG", {
  skip_if_not(exists("makeFounderStatsTable"))

  founderStats <- list(
    total = 50,
    nMaleFounders = 20,
    nFemaleFounders = 30,
    fe = 25.5,
    fg = 22.3
  )

  result <- makeFounderStatsTable(founderStats)

  # Should include founder equivalents
  expect_true(grepl("25\\.5|25.5", result))  # FE
  expect_true(grepl("22\\.3|22.3", result))  # FG
})

test_that("makeFounderStatsTable handles NULL gracefully", {
  skip_if_not(exists("makeFounderStatsTable"))

  result <- makeFounderStatsTable(NULL)

  # Should return some placeholder or empty string
  expect_true(is.character(result))
})

# =============================================================================
# Tests for makeGeneticSummaryTable helper function
# =============================================================================

test_that("makeGeneticSummaryTable function exists", {
  expect_true(exists("makeGeneticSummaryTable"))
})

test_that("makeGeneticSummaryTable returns HTML string", {
  skip_if_not(exists("makeGeneticSummaryTable"))

  gv <- data.frame(
    meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
    genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5),
    stringsAsFactors = FALSE
  )

  result <- makeGeneticSummaryTable(gv)

  expect_true(is.character(result))
  expect_true(grepl("<table|<tr|<td", result, ignore.case = TRUE))
})

test_that("makeGeneticSummaryTable includes summary statistics", {
  skip_if_not(exists("makeGeneticSummaryTable"))

  gv <- data.frame(
    meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
    genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5),
    stringsAsFactors = FALSE
  )

  result <- makeGeneticSummaryTable(gv)

  # Should include Min, Mean, Max labels
  expect_true(grepl("Min|Minimum", result, ignore.case = TRUE))
  expect_true(grepl("Mean|Average", result, ignore.case = TRUE))
  expect_true(grepl("Max|Maximum", result, ignore.case = TRUE))
})

test_that("makeGeneticSummaryTable includes quartiles", {
  skip_if_not(exists("makeGeneticSummaryTable"))

  gv <- data.frame(
    meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
    genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5),
    stringsAsFactors = FALSE
  )

  result <- makeGeneticSummaryTable(gv)

  # Should include quartile information
  expect_true(grepl("Quartile|Q1|1st|25", result, ignore.case = TRUE) ||
                grepl("Median|Q2|50", result, ignore.case = TRUE))
})

# =============================================================================
# Tests for modSummaryStatsServer founder display
# =============================================================================

test_that("modSummaryStatsServer includes founder statistics output", {
  skip_if_not_installed("shiny")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should have founder-related output
  expect_true(grepl("founder|Founder", server_text, ignore.case = TRUE))
})

test_that("modSummaryStatsUI has founder statistics display area", {
  skip_if_not_installed("shiny")

  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  # Should have summary statistics output
  expect_true(grepl("summaryStats|founderStats", ui_html))
})

# =============================================================================
# Tests for founder statistics data retrieval
# =============================================================================

test_that("modSummaryStatsServer computes founder counts", {
  skip_if_not_installed("shiny")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should reference founder calculations
  expect_true(grepl("is\\.na.*sire.*dam|founder", server_text, ignore.case = TRUE))
})

# =============================================================================
# Tests for table styling
# =============================================================================

test_that("makeFounderStatsTable uses proper table classes", {
  skip_if_not(exists("makeFounderStatsTable"))

  founderStats <- list(
    total = 50,
    nMaleFounders = 20,
    nFemaleFounders = 30,
    fe = 25.5,
    fg = 22.3
  )

  result <- makeFounderStatsTable(founderStats)

  # Should have table class for Bootstrap styling
  expect_true(grepl("class=", result, ignore.case = TRUE))
})

test_that("makeGeneticSummaryTable uses proper table classes", {
  skip_if_not(exists("makeGeneticSummaryTable"))

  gv <- data.frame(
    meanKinship = c(0.1, 0.2, 0.3),
    genomeUniqueness = c(0.9, 0.8, 0.7),
    stringsAsFactors = FALSE
  )

  result <- makeGeneticSummaryTable(gv)

  # Should have table class for Bootstrap styling
  expect_true(grepl("class=", result, ignore.case = TRUE))
})
