# Tests for modInput.R - Data Input and Quality Control Shiny Module

# Slow shiny-module integration tests (many shiny::testServer() calls); skip on
# CRAN to keep check elapsed time within limits. They still run on CI and
# locally. The analytical functions exercised here have their own unit tests.
testthat::skip_on_cran()

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

# ============================================================================
# Additional Server Tests - activeFile reactive
# ============================================================================

test_that("modInputServer activeFile reactive returns NULL for pedFile with no upload", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileContent = "pedFile")
      # Without file upload, activeFile should return NULL
      file_result <- activeFile()
      expect_null(file_result)
    }
  )
})

test_that("modInputServer activeFile reactive returns NULL for commonPedGenoFile with no upload", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileContent = "commonPedGenoFile")
      file_result <- activeFile()
      expect_null(file_result)
    }
  )
})

test_that("modInputServer activeFile reactive returns NULL for separatePedGenoFile with no upload", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileContent = "separatePedGenoFile")
      file_result <- activeFile()
      expect_null(file_result)
    }
  )
})

test_that("modInputServer activeFile reactive returns NULL for focalAnimals with no upload", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileContent = "focalAnimals")
      file_result <- activeFile()
      expect_null(file_result)
    }
  )
})

# ============================================================================
# Server Tests - minParentAge variations
# ============================================================================

test_that("modInputServer handles default minParentAge value", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "2.0")
      result <- session$getReturned()
      expect_equal(result$minParentAge(), 2.0)
    }
  )
})

test_that("modInputServer handles integer minParentAge", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "5")
      result <- session$getReturned()
      expect_equal(result$minParentAge(), 5)
    }
  )
})

test_that("modInputServer handles zero minParentAge", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "0")
      result <- session$getReturned()
      expect_equal(result$minParentAge(), 0)
    }
  )
})

test_that("modInputServer handles decimal minParentAge", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "1.75")
      result <- session$getReturned()
      expect_equal(result$minParentAge(), 1.75)
    }
  )
})

test_that("modInputServer handles non-numeric minParentAge gracefully", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "invalid")
      result <- session$getReturned()
      # as.numeric("invalid") returns NA with a warning
      expect_warning(
        expect_true(is.na(result$minParentAge())),
        "NAs introduced by coercion"
      )
    }
  )
})

# ============================================================================
# Server Tests - Return value components
# ============================================================================

test_that("modInputServer cleanedStudbook requires qcResults", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      result <- session$getReturned()
      # Before any data is loaded, cleanedStudbook should error
      expect_error(result$cleanedStudbook())
    }
  )
})

test_that("modInputServer genotypeData requires qcResults", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      result <- session$getReturned()
      # Before any data is loaded, genotypeData should error
      expect_error(result$genotypeData())
    }
  )
})

test_that("modInputServer returns all seven expected reactive components", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      result <- session$getReturned()
      expect_equal(length(result), 9)
      expected_names <- c("cleanedStudbook", "genotypeData", "qcSummary",
                          "minParentAge", "isReady", "debugMode", "changedCols",
                          "errorLst", "pedigreeFileName")
      expect_setequal(names(result), expected_names)
    }
  )
})

# ============================================================================
# Server Tests - Debug mode toggle
# ============================================================================

test_that("modInputServer debugMode starts as FALSE by default", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(debugger = FALSE)
      result <- session$getReturned()
      expect_false(result$debugMode())
    }
  )
})

test_that("modInputServer debugMode toggles correctly", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      result <- session$getReturned()

      session$setInputs(debugger = FALSE)
      expect_false(result$debugMode())

      session$setInputs(debugger = TRUE)
      expect_true(result$debugMode())

      session$setInputs(debugger = FALSE)
      expect_false(result$debugMode())
    }
  )
})

# ============================================================================
# Server Tests - File type and separator combinations
# ============================================================================

test_that("modInputServer handles Excel file type with comma separator", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileType = "fileTypeExcel", separator = ",")
      expect_equal(input$fileType, "fileTypeExcel")
      expect_equal(input$separator, ",")
    }
  )
})

test_that("modInputServer handles Text file type with tab separator", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileType = "fileTypeText", separator = "\t")
      expect_equal(input$fileType, "fileTypeText")
      expect_equal(input$separator, "\t")
    }
  )
})

test_that("modInputServer handles Text file type with semicolon separator", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileType = "fileTypeText", separator = ";")
      expect_equal(input$fileType, "fileTypeText")
      expect_equal(input$separator, ";")
    }
  )
})

# ============================================================================
# Server Tests - activeFile selects correct input based on fileContent
# ============================================================================

test_that("modInputServer activeFile switches based on fileContent pedFile", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      # Set fileContent to pedFile
      session$setInputs(fileContent = "pedFile")
      expect_equal(input$fileContent, "pedFile")
      # activeFile returns pedigreeFileOne for this content type
      # Without upload, should be NULL
      expect_null(activeFile())
    }
  )
})

test_that("modInputServer activeFile switches based on fileContent commonPedGenoFile", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileContent = "commonPedGenoFile")
      expect_equal(input$fileContent, "commonPedGenoFile")
      expect_null(activeFile())
    }
  )
})

test_that("modInputServer activeFile switches based on fileContent separatePedGenoFile", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileContent = "separatePedGenoFile")
      expect_equal(input$fileContent, "separatePedGenoFile")
      expect_null(activeFile())
    }
  )
})

test_that("modInputServer activeFile switches based on fileContent focalAnimals", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileContent = "focalAnimals")
      expect_equal(input$fileContent, "focalAnimals")
      expect_null(activeFile())
    }
  )
})

# ============================================================================
# Server Tests - Input state management
# ============================================================================

test_that("modInputServer maintains input state across multiple changes", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      # Set initial state
      session$setInputs(
        fileType = "fileTypeExcel",
        fileContent = "pedFile",
        minParentAge = "2.0",
        debugger = FALSE
      )

      expect_equal(input$fileType, "fileTypeExcel")
      expect_equal(input$fileContent, "pedFile")
      result <- session$getReturned()
      expect_equal(result$minParentAge(), 2.0)
      expect_false(result$debugMode())

      # Change state
      session$setInputs(
        fileType = "fileTypeText",
        fileContent = "commonPedGenoFile",
        minParentAge = "4.5",
        debugger = TRUE
      )

      expect_equal(input$fileType, "fileTypeText")
      expect_equal(input$fileContent, "commonPedGenoFile")
      expect_equal(result$minParentAge(), 4.5)
      expect_true(result$debugMode())
    }
  )
})

test_that("modInputServer handles rapid input changes", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      result <- session$getReturned()

      # Rapid changes to minParentAge
      session$setInputs(minParentAge = "1.0")
      expect_equal(result$minParentAge(), 1.0)

      session$setInputs(minParentAge = "2.0")
      expect_equal(result$minParentAge(), 2.0)

      session$setInputs(minParentAge = "3.0")
      expect_equal(result$minParentAge(), 3.0)

      session$setInputs(minParentAge = "0.5")
      expect_equal(result$minParentAge(), 0.5)
    }
  )
})

# ============================================================================
# Server Tests - Edge cases for minParentAge
# ============================================================================

test_that("modInputServer handles very small minParentAge", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "0.001")
      result <- session$getReturned()
      expect_equal(result$minParentAge(), 0.001)
    }
  )
})

test_that("modInputServer handles very large minParentAge", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "100")
      result <- session$getReturned()
      expect_equal(result$minParentAge(), 100)
    }
  )
})

test_that("modInputServer handles negative minParentAge", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "-1")
      result <- session$getReturned()
      # Should convert to -1, validation would happen elsewhere
      expect_equal(result$minParentAge(), -1)
    }
  )
})

test_that("modInputServer handles empty minParentAge string", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "")
      result <- session$getReturned()
      # as.numeric("") returns NA
      expect_true(is.na(result$minParentAge()))
    }
  )
})

test_that("modInputServer handles whitespace minParentAge", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "  2.5  ")
      result <- session$getReturned()
      # as.numeric handles whitespace
      expect_equal(result$minParentAge(), 2.5)
    }
  )
})

# ============================================================================
# UI Tests - Additional coverage
# ============================================================================

test_that("modInputUI has custom CSS styles", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("border: 1px solid black", ui_html))
  expect_true(grepl("background-color", ui_html))
})

test_that("modInputUI has sidebar panel styling", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("border-radius", ui_html))
  expect_true(grepl("box-shadow", ui_html))
})

test_that("modInputUI has icons in tabs", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  # Font Awesome 5/6 uses different icon names
  expect_true(grepl("fa-circle-info|info-circle", ui_html))
  expect_true(grepl("fa-circle-check|check-circle", ui_html))
  expect_true(grepl("fa-triangle-exclamation|exclamation-triangle", ui_html))
  expect_true(grepl("fa-circle-exclamation|exclamation-circle", ui_html))
})

test_that("modInputUI has Input Format tab", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  # The Input Format tab exists (the HTML is included at runtime)
  expect_true(grepl("Input Format", ui_html))
  expect_true(grepl("tab-pane", ui_html))
})

test_that("modInputUI getData button has correct class", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("btn-primary", ui_html))
  expect_true(grepl("btn-block", ui_html))
})

test_that("modInputUI has DT table outputs", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("qcErrors", ui_html))
  expect_true(grepl("qcWarnings", ui_html))
  expect_true(grepl("cleanedDataTable", ui_html))
})

test_that("modInputUI has help text for minimum parent age", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Parents must be at least as old", ui_html))
})

test_that("modInputUI has file acceptance types", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("\\.csv", ui_html))
  expect_true(grepl("\\.txt", ui_html))
  expect_true(grepl("\\.xlsx", ui_html))
  expect_true(grepl("\\.xls", ui_html))
})

test_that("modInputUI uses correct tab panel structure", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  # Check for tabsetPanel
  expect_true(grepl("mainTabs", ui_html))
})

test_that("modInputUI has upload icon on action button", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("upload", ui_html))
})

# ============================================================================
# Server Tests - Multiple namespace instances
# ============================================================================

test_that("modInputServer works with different namespaces", {
  skip_if_not_installed("shiny")

  # Test that multiple instances with different IDs work independently
  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(minParentAge = "3.0")
      result <- session$getReturned()
      expect_equal(result$minParentAge(), 3.0)
    }
  )
})

test_that("modInputUI generates unique IDs for different namespaces", {
  ui1 <- modInputUI("instance1")
  ui2 <- modInputUI("instance2")

  ui_html1 <- as.character(ui1)
  ui_html2 <- as.character(ui2)

  expect_true(grepl("instance1-fileType", ui_html1))
  expect_true(grepl("instance2-fileType", ui_html2))
  expect_false(grepl("instance2", ui_html1))
  expect_false(grepl("instance1", ui_html2))
})

# ============================================================================
# Server Tests - All file content type selections
# ============================================================================

test_that("modInputServer cycles through all file content types", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      content_types <- c("pedFile", "commonPedGenoFile",
                        "separatePedGenoFile", "focalAnimals")

      for (content_type in content_types) {
        session$setInputs(fileContent = content_type)
        expect_equal(input$fileContent, content_type)
        # activeFile should return NULL without uploaded files
        expect_null(activeFile())
      }
    }
  )
})

test_that("modInputServer cycles through all separator types", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(fileType = "fileTypeText")
      separators <- c(",", ";", "\t")

      for (sep in separators) {
        session$setInputs(separator = sep)
        expect_equal(input$separator, sep)
      }
    }
  )
})

# ============================================================================
# Server Tests - Config parameter handling
# ============================================================================

test_that("modInputServer handles NULL config", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      result <- session$getReturned()
      expect_true(is.list(result))
      expect_equal(length(result), 9)
    }
  )
})

test_that("modInputServer handles reactive config", {
  skip_if_not_installed("shiny")

  test_config <- shiny::reactive({
    list(setting1 = "value1", setting2 = "value2")
  })

  shiny::testServer(
    modInputServer,
    args = list(config = test_config),
    {
      result <- session$getReturned()
      expect_true(is.list(result))
      expect_equal(length(result), 9)
    }
  )
})

# ============================================================================
# Phase 7 - Focal-animal / LabKey "build pedigree from database" path
# ============================================================================
# When fileContent == "focalAnimals", the uploaded file is a LIST OF FOCAL
# ANIMAL IDS (not a pedigree). modInputServer must call getFocalAnimalPed(),
# which builds the pedigree from the ONPRC EHR via getLkDirectRelatives().
# There is no live EHR here, so we mock the getLkDirectRelatives seam (exactly
# as test_getFocalAnimalPed.R does) and let the REAL getFocalAnimalPed body run.

test_that("modInputServer focalAnimals path builds pedigree from the EHR (mocked)", {
  skip_if_not_installed("shiny")
  shortlist <- system.file("extdata", "focalAnimalsShortList.csv",
                           package = "nprcgenekeepr")
  focal_ids <- as.character(read.csv(shortlist, stringsAsFactors = FALSE)[, 1L])

  # Mock the LabKey/EHR seam so the real getFocalAnimalPed body runs. The mock
  # returns getLkDirectRelatives' 7-column positional contract (id, sex, birth,
  # death, departure, dam, sire) for the focal animals as unrelated founders.
  mk_lk <- function(ids, ...) {
    n <- length(ids)
    data.frame(
      ids,
      rep(c("M", "F"), length.out = n),
      as.Date(rep("2010-01-01", n)),
      as.Date(rep(NA, n)),
      as.Date(rep(NA, n)),
      rep(NA_character_, n),
      rep(NA_character_, n),
      stringsAsFactors = FALSE
    )
  }
  testthat::local_mocked_bindings(getLkDirectRelatives = mk_lk,
                                  .package = "nprcgenekeepr")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(
        fileContent = "focalAnimals",
        fileType = "fileTypeText",
        separator = ",",
        minParentAge = "2.0"
      )
      session$setInputs(
        breederFile = list(name = basename(shortlist), datapath = shortlist)
      )
      session$setInputs(getData = 1)

      res <- storedResults()
      # The EHR-built pedigree is QC-cleaned (NOT the raw 1-column focal-id file,
      # which would fail QC for missing sire/dam/sex/birth columns).
      expect_false(is.null(res$cleaned))
      expect_true(is.data.frame(res$cleaned))
      expect_true(all(c("id", "sire", "dam", "sex", "gen") %in% names(res$cleaned)))
      expect_true(all(focal_ids %in% res$cleaned$id))
    }
  )
})

test_that("modInputServer focalAnimals path surfaces the EHR-failure errorLst", {
  skip_if_not_installed("shiny")
  shortlist <- system.file("extdata", "focalAnimalsShortList.csv",
                           package = "nprcgenekeepr")

  # A NULL from the LabKey seam makes getFocalAnimalPed return an
  # nprcgenekeeprErr with failedDatabaseConnection populated
  # (getFocalAnimalPed.R:59-67).
  testthat::local_mocked_bindings(
    getLkDirectRelatives = function(ids, ...) NULL,
    .package = "nprcgenekeepr"
  )

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(
        fileContent = "focalAnimals",
        fileType = "fileTypeText",
        separator = ",",
        minParentAge = "2.0"
      )
      session$setInputs(
        breederFile = list(name = basename(shortlist), datapath = shortlist)
      )
      session$setInputs(getData = 1)

      # The DB-failure errorLst is routed to storedErrorLst() so the
      # already-wired appServer dynamic Error tab surfaces the message.
      el <- storedErrorLst()
      expect_s3_class(el, "nprcgenekeeprErr")
      expect_true(nzchar(el$failedDatabaseConnection))
      # The failure path must NOT produce a (garbage) cleaned pedigree.
      expect_true(is.null(storedResults()$cleaned))
    }
  )
})

# OFFLINE focal-animal path (no EHR): when the user ALSO supplies a pedigree
# file (input$focalPedigreeFile), modInputServer must build the focal animals'
# pedigree from that FILE via getFocalAnimalPedFromFile() instead of calling the
# LabKey/EHR seam. We mock getLkDirectRelatives to STOP so any EHR call is a
# loud test failure -- proving the offline path never touches the database.

test_that("modInputServer focalAnimals path builds pedigree from a FILE (offline, no EHR)", {
  skip_if_not_installed("shiny")
  shortlist <- system.file("extdata", "focalAnimalsShortList.csv",
                           package = "nprcgenekeepr")
  focal_ids <- as.character(read.csv(shortlist, stringsAsFactors = FALSE)[, 1L])
  pedFile <- system.file("extdata", "ExamplePedigree.csv",
                         package = "nprcgenekeepr")

  testthat::local_mocked_bindings(
    getLkDirectRelatives = function(ids, ...)
      stop("EHR must not be called on the offline file path"),
    .package = "nprcgenekeepr"
  )

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(
        fileContent = "focalAnimals",
        fileType = "fileTypeText",
        separator = ",",
        minParentAge = "2.0"
      )
      session$setInputs(
        breederFile = list(name = basename(shortlist), datapath = shortlist),
        focalPedigreeFile = list(name = basename(pedFile), datapath = pedFile)
      )
      session$setInputs(getData = 1)

      res <- storedResults()
      # The FILE-built pedigree is QC-cleaned and contains the focal animals'
      # connected component -- built entirely offline (getLkDirectRelatives,
      # mocked to stop(), is never reached).
      expect_false(is.null(res$cleaned))
      expect_true(is.data.frame(res$cleaned))
      expect_true(all(c("id", "sire", "dam", "sex", "gen") %in%
                        names(res$cleaned)))
      expect_true(all(focal_ids %in% res$cleaned$id))
    }
  )
})

test_that("modInputServer offline focal-file path surfaces a File Read Error on a bad pedigree file", {
  skip_if_not_installed("shiny")
  shortlist <- system.file("extdata", "focalAnimalsShortList.csv",
                           package = "nprcgenekeepr")
  badPed <- file.path(tempdir(), "no_such_pedigree.csv")

  testthat::local_mocked_bindings(
    getLkDirectRelatives = function(ids, ...)
      stop("EHR must not be called on the offline file path"),
    .package = "nprcgenekeepr"
  )

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(
        fileContent = "focalAnimals",
        fileType = "fileTypeText",
        separator = ",",
        minParentAge = "2.0"
      )
      session$setInputs(
        breederFile = list(name = basename(shortlist), datapath = shortlist),
        focalPedigreeFile = list(name = "no_such_pedigree.csv",
                                 datapath = badPed)
      )
      session$setInputs(getData = 1)

      # A bad pedigree file makes getFocalAnimalPedFromFile() return a classed
      # nprcgenekeeprFileErr; modInput surfaces it as a "File Read Error" whose
      # Details name WHY -- the SPECIFIC reason, not the old generic message.
      res <- storedResults()
      expect_true(is.null(res$cleaned))
      expect_true(any(grepl("File Read Error", res$errors$Error)))
      expect_true(any(grepl("not found", res$errors$Details, ignore.case = TRUE)))
      expect_false(any(grepl("Could not read the uploaded file",
                             res$errors$Details)))
    }
  )
})

test_that("modInputServer offline focal-file path reports a missing-column pedigree file", {
  skip_if_not_installed("shiny")
  shortlist <- system.file("extdata", "focalAnimalsShortList.csv",
                           package = "nprcgenekeepr")
  badPed <- tempfile(fileext = ".csv")
  utils::write.csv(data.frame(id = c("A", "B"), stringsAsFactors = FALSE),
                   badPed, row.names = FALSE)
  on.exit(unlink(badPed), add = TRUE)

  testthat::local_mocked_bindings(
    getLkDirectRelatives = function(ids, ...)
      stop("EHR must not be called on the offline file path"),
    .package = "nprcgenekeepr"
  )

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(
        fileContent = "focalAnimals",
        fileType = "fileTypeText",
        separator = ",",
        minParentAge = "2.0"
      )
      session$setInputs(
        breederFile = list(name = basename(shortlist), datapath = shortlist),
        focalPedigreeFile = list(name = basename(badPed), datapath = badPed)
      )
      session$setInputs(getData = 1)

      # The specific reason -- a wrong-column pedigree file -- reaches the UI
      # Details column, not the old generic "Could not read the uploaded file."
      res <- storedResults()
      expect_true(is.null(res$cleaned))
      expect_true(any(grepl("File Read Error", res$errors$Error)))
      expect_true(any(grepl("id, sire, and dam", res$errors$Details)))
    }
  )
})
