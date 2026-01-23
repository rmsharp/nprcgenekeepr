# Tests for modInput.R - Data Input and Quality Control Shiny Module

test_that("modInputUI returns a shiny.tag object", {
  ui <- modInputUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modInputUI contains expected main elements", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  # Check for main heading
  expect_true(grepl("Data Input and Quality Control", ui_html))

  # Check for file type selection
  expect_true(grepl("fileType", ui_html))
  expect_true(grepl("Excel", ui_html))
  expect_true(grepl("Text", ui_html))

  # Check for file content options
  expect_true(grepl("fileContent", ui_html))
  expect_true(grepl("pedFile", ui_html))
})

test_that("modInputUI has file upload inputs", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  # Check for various file inputs
  expect_true(grepl("pedigreeFileOne", ui_html))
  expect_true(grepl("pedigreeFileTwo", ui_html))
  expect_true(grepl("pedigreeFileThree", ui_html))
  expect_true(grepl("genotypeFile", ui_html))
  expect_true(grepl("breederFile", ui_html))
})

test_that("modInputUI has separator options for text files", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("separator", ui_html))
  expect_true(grepl("Comma", ui_html))
  expect_true(grepl("Semicolon", ui_html))
  expect_true(grepl("Tab", ui_html))
})

test_that("modInputUI has minimum parent age input", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("minParentAge", ui_html))
  expect_true(grepl("Minimum Parent Age", ui_html))
})

test_that("modInputUI has action button", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("getData", ui_html))
  expect_true(grepl("Read and Check Pedigree", ui_html))
})

test_that("modInputUI has QC result tabs", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Input Format", ui_html))
  expect_true(grepl("QC Summary", ui_html))
  expect_true(grepl("Errors", ui_html))
  expect_true(grepl("Warnings", ui_html))
  expect_true(grepl("Cleaned Data", ui_html))
})

test_that("modInputUI has download buttons", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("downloadErrors", ui_html))
  expect_true(grepl("downloadWarnings", ui_html))
  expect_true(grepl("downloadCleaned", ui_html))
})

test_that("modInputUI uses correct namespace", {
  ui <- modInputUI("inputNS")
  ui_html <- as.character(ui)

  expect_true(grepl("inputNS-fileType", ui_html))
  expect_true(grepl("inputNS-fileContent", ui_html))
  expect_true(grepl("inputNS-getData", ui_html))
})

test_that("modInputUI has debug checkbox", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("debugger", ui_html))
})

test_that("modInputServer returns expected reactive list", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      # Check return value structure
      result <- session$getReturned()
      expect_true(is.list(result))

      # Check for expected components
      expect_true("cleanedStudbook" %in% names(result))
      expect_true("genotypeData" %in% names(result))
      expect_true("qcSummary" %in% names(result))
      expect_true("minParentAge" %in% names(result))
      expect_true("isReady" %in% names(result))
      expect_true("debugMode" %in% names(result))

      # Each component should be reactive
      expect_true(is.function(result$cleanedStudbook))
      expect_true(is.function(result$genotypeData))
      expect_true(is.function(result$qcSummary))
      expect_true(is.function(result$minParentAge))
      expect_true(is.function(result$isReady))
      expect_true(is.function(result$debugMode))
    }
  )
})

test_that("modInputServer handles file type changes", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      # Test file type selection
      session$setInputs(fileType = "fileTypeExcel")
      expect_equal(input$fileType, "fileTypeExcel")

      session$setInputs(fileType = "fileTypeText")
      expect_equal(input$fileType, "fileTypeText")
    }
  )
})

test_that("modInputServer handles file content selection", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      # Test different file content options
      session$setInputs(fileContent = "pedFile")
      expect_equal(input$fileContent, "pedFile")

      session$setInputs(fileContent = "commonPedGenoFile")
      expect_equal(input$fileContent, "commonPedGenoFile")

      session$setInputs(fileContent = "separatePedGenoFile")
      expect_equal(input$fileContent, "separatePedGenoFile")

      session$setInputs(fileContent = "focalAnimals")
      expect_equal(input$fileContent, "focalAnimals")
    }
  )
})

test_that("modInputServer handles minParentAge input", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "3.5")
      result <- session$getReturned()

      # Check minParentAge reactive returns numeric
      expect_equal(result$minParentAge(), 3.5)
    }
  )
})

test_that("modInputServer handles debug mode", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(debugger = TRUE)
      result <- session$getReturned()
      expect_true(result$debugMode())

      session$setInputs(debugger = FALSE)
      expect_false(result$debugMode())
    }
  )
})

test_that("modInputServer handles separator selection", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileType = "fileTypeText")
      session$setInputs(separator = ",")
      expect_equal(input$separator, ",")

      session$setInputs(separator = ";")
      expect_equal(input$separator, ";")

      session$setInputs(separator = "\t")
      expect_equal(input$separator, "\t")
    }
  )
})

test_that("modInputServer isReady returns FALSE before data processing", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      result <- session$getReturned()
      # Before any data is loaded, isReady should error or return FALSE
      expect_error(result$isReady())
    }
  )
})

test_that("modInputServer qcSummary requires data", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      result <- session$getReturned()
      # Before any data is loaded, qcSummary should error
      expect_error(result$qcSummary())
    }
  )
})

test_that("modInputUI has proper conditional panels", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  # Check that conditional panels reference correct input conditions
  expect_true(grepl("fileType.*fileTypeText", ui_html))
  expect_true(grepl("fileContent.*pedFile", ui_html))
  expect_true(grepl("fileContent.*commonPedGenoFile", ui_html))
  expect_true(grepl("fileContent.*separatePedGenoFile", ui_html))
  expect_true(grepl("fileContent.*focalAnimals", ui_html))
})
