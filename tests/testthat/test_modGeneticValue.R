# Tests for modGeneticValue.R - Genetic Value Analysis Shiny Module

test_that("modGeneticValueUI returns a shiny.tag object", {
  ui <- modGeneticValueUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modGeneticValueUI contains expected elements", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  # Check for main heading
  expect_true(grepl("Genetic Value Analysis", ui_html))

  # Check for analysis options
  expect_true(grepl("Analysis Options", ui_html))
  expect_true(grepl("nIterations", ui_html))
  expect_true(grepl("calcGenomeUniqueness", ui_html))
  expect_true(grepl("calcMeanKinship", ui_html))
  expect_true(grepl("minAge", ui_html))

  # Check for action button
  expect_true(grepl("runAnalysis", ui_html))

  # Check for tabs
  expect_true(grepl("Rankings", ui_html))
  expect_true(grepl("Visualizations", ui_html))
  expect_true(grepl("Summary", ui_html))
})

test_that("modGeneticValueUI uses correct namespace", {
  ui <- modGeneticValueUI("gvNamespace")
  ui_html <- as.character(ui)

  # Input IDs should be namespaced
  expect_true(grepl("gvNamespace-nIterations", ui_html))
  expect_true(grepl("gvNamespace-runAnalysis", ui_html))
  expect_true(grepl("gvNamespace-topN", ui_html))
})

test_that("modGeneticValueUI has download button", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("downloadRankings", ui_html))
})

test_that("modGeneticValueUI includes informational panel", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  # Check for info panel content
  expect_true(grepl("Mean Kinship", ui_html))
  expect_true(grepl("Genome Uniqueness", ui_html))
})

test_that("modGeneticValueServer returns expected reactive list", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      # Check return value structure
      result <- session$getReturned()
      expect_true(is.list(result))
      expect_true("geneticValues" %in% names(result))
      expect_true("topAnimals" %in% names(result))
      expect_true("nAnalyzed" %in% names(result))

      # Each component should be reactive
      expect_true(is.function(result$geneticValues))
      expect_true(is.function(result$topAnimals))
      expect_true(is.function(result$nAnalyzed))
    }
  )
})

test_that("modGeneticValueServer handles input changes", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = c(rep(NA, 10), paste0("Animal", 1:10)),
    dam = c(rep(NA, 10), paste0("Animal", 11:20)),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      # Set various inputs
      session$setInputs(nIterations = 1000)
      expect_equal(input$nIterations, 1000)

      session$setInputs(calcGenomeUniqueness = FALSE)
      expect_false(input$calcGenomeUniqueness)

      session$setInputs(calcMeanKinship = TRUE)
      expect_true(input$calcMeanKinship)

      session$setInputs(minAge = 3.5)
      expect_equal(input$minAge, 3.5)

      session$setInputs(topN = 15)
      expect_equal(input$topN, 15)
    }
  )
})
