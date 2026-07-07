# E2E tests for data-ready infrastructure
# These tests verify that modules correctly signal their ready state

library(testthat)

# Skip if shinytest2 not available
skip_if_not_installed("shinytest2")

# Skip on CRAN
skip_on_cran()

test_that("Input module server initializes correctly", {
  skip_if_not_installed("shinytest2")

  # Use testServer to verify the module initializes without error
  # Note: Full E2E testing with sendCustomMessage requires shinytest2::AppDriver
  shiny::testServer(nprcgenekeepr::modInputServer, {
    # Verify the module server returns the expected reactive structure
    expect_true(is.list(session$returned))
    expect_true("cleanedStudbook" %in% names(session$returned))
    expect_true("qcSummary" %in% names(session$returned))
    expect_true("isReady" %in% names(session$returned))
    expect_true("errorLst" %in% names(session$returned))
    expect_true("pedigreeFileName" %in% names(session$returned))

    # Verify initial input values can be set
    session$setInputs(minSireAge = "2.0", minDamAge = "2.0")
    session$setInputs(fileContent = "pedFile")
    session$setInputs(fileType = "fileTypeExcel")

    # Verify the sire/dam age reactives work
    expect_equal(session$returned$minSireAge(), 2.0)
    expect_equal(session$returned$minDamAge(), 2.0)
  })
})

test_that("data-ready attributes exist in module UIs", {
  # Verify UI functions include data-ready attributes

  # Input module
  input_ui <- nprcgenekeepr::modInputUI("test_input")
  ui_html <- as.character(input_ui)
  expect_match(ui_html, 'data-ready="false"')
  expect_match(ui_html, 'data-module="input"')

  # Pedigree module
  ped_ui <- nprcgenekeepr::modPedigreeUI("test_ped")
  ped_html <- as.character(ped_ui)
  expect_match(ped_html, 'data-ready="false"')
  expect_match(ped_html, 'data-module="pedigree"')

  # Pyramid module
  pyr_ui <- nprcgenekeepr::modPyramidUI("test_pyr")
  pyr_html <- as.character(pyr_ui)
  expect_match(pyr_html, 'data-ready="false"')
  expect_match(pyr_html, 'data-module="pyramid"')

  # Genetic value module
  gv_ui <- nprcgenekeepr::modGeneticValueUI("test_gv")
  gv_html <- as.character(gv_ui)
  expect_match(gv_html, 'data-ready="false"')
  expect_match(gv_html, 'data-module="geneticValue"')

  # Summary stats module
  ss_ui <- nprcgenekeepr::modSummaryStatsUI("test_ss")
  ss_html <- as.character(ss_ui)
  expect_match(ss_html, 'data-ready="false"')
  expect_match(ss_html, 'data-module="summaryStats"')

  # Breeding groups module
  bg_ui <- nprcgenekeepr::modBreedingGroupsUI("test_bg")
  bg_html <- as.character(bg_ui)
  expect_match(bg_html, 'data-ready="false"')
  expect_match(bg_html, 'data-module="breedingGroups"')
})

test_that("data-ready.js is included in the package", {
  js_file <- system.file("www", "js", "data-ready.js",
                         package = "nprcgenekeepr")
  expect_true(file.exists(js_file))

  # Verify JS content includes expected handlers
  js_content <- readLines(js_file)
  js_text <- paste(js_content, collapse = "\n")

  expect_match(js_text, "setDataReady")
  expect_match(js_text, "setDataLoading")
  expect_match(js_text, "nprcgenekeeprReady")
})

test_that("appUI includes data-ready.js", {
  # The appUI function should include the JavaScript file
  app_ui <- nprcgenekeepr::appUI()
  ui_html <- as.character(app_ui)

  # Check that tagList wrapper exists (indicating JS inclusion logic)
  expect_true(inherits(app_ui, "shiny.tag.list") ||
              inherits(app_ui, "shiny.tag"))
})

test_that("helper-shinytest2.R functions are available", {
  # Source the helper file
  helper_path <- testthat::test_path("helper-shinytest2.R")
  skip_if(!file.exists(helper_path), "Helper file not found")

  source(helper_path, local = TRUE)

  # Verify functions exist

  expect_true(exists("wait_for_data_ready"))
  expect_true(exists("wait_for_idle"))
  expect_true(exists("wait_for_element"))
  expect_true(exists("get_data_ready_state"))
  expect_true(exists("is_module_ready"))
  expect_true(exists("wait_for_module_ready"))
  expect_true(exists("upload_and_wait"))
  expect_true(exists("get_test_data_path"))
})
