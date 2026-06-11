# Tests for modPyramid.R - Age-Sex Pyramid Shiny Module

test_that("modPyramidUI returns a shiny.tag object", {
  ui <- modPyramidUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modPyramidUI contains expected heading", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Age-Sex Pyramid Analysis", ui_html))
})

test_that("modPyramidUI has age unit selector", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("ageUnit", ui_html))
  expect_true(grepl("Years", ui_html))
  expect_true(grepl("Months", ui_html))
})

test_that("modPyramidUI has bin size input", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("ageBin", ui_html))
  expect_true(grepl("Bin Size", ui_html))
})

test_that("modPyramidUI has color scheme selector", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("colorScheme", ui_html))
  expect_true(grepl("Default", ui_html))
  expect_true(grepl("Viridis", ui_html))
})

test_that("modPyramidUI has show counts checkbox", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("showCounts", ui_html))
})

test_that("modPyramidUI has plot height slider", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("plotHeight", ui_html))
  expect_true(grepl("Plot Height", ui_html))
})

test_that("modPyramidUI has age label size slider", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("ageLabelSize", ui_html))
  expect_true(grepl("Age Label Size", ui_html))
})

test_that("modPyramidUI has download button", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("downloadPlot", ui_html))
})

test_that("modPyramidUI has tabs for plot and statistics", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Plot", ui_html))
  expect_true(grepl("Statistics", ui_html))
})

test_that("modPyramidUI uses correct namespace", {
  ui <- modPyramidUI("pyramidNS")
  ui_html <- as.character(ui)

  expect_true(grepl("pyramidNS-ageUnit", ui_html))
  expect_true(grepl("pyramidNS-ageBin", ui_html))
  expect_true(grepl("pyramidNS-colorScheme", ui_html))
  expect_true(grepl("pyramidNS-downloadPlot", ui_html))
})

test_that("modPyramidUI includes guidance HTML", {
  ui <- modPyramidUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("pyramidPlot", ui_html) ||
                grepl("ui_guidance", ui_html))
})

test_that("modPyramidServer returns expected reactive list", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sex = c("M", "F", "F", "M", "F"),
    birth = as.Date(c("2010-01-01", "2011-06-15", "2015-03-20",
                      "2018-09-10", "2020-12-25")),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPyramidServer,
    args = list(
      pedigreeData = shiny::reactive({ test_ped })
    ),
    {
      # Check return value structure
      result <- session$getReturned()
      expect_true(is.list(result))

      expect_true("pedigree" %in% names(result))
      expect_true("animalCount" %in% names(result))

      # Each component should be reactive
      expect_true(is.function(result$pedigree))
      expect_true(is.function(result$animalCount))
    }
  )
})

test_that("modPyramidServer returns correct animal count", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:15),
    sex = rep(c("M", "F", "F"), 5),
    birth = seq.Date(as.Date("2010-01-01"), by = "6 months", length.out = 15),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPyramidServer,
    args = list(
      pedigreeData = shiny::reactive({ test_ped })
    ),
    {
      result <- session$getReturned()
      expect_equal(result$animalCount(), 15)
    }
  )
})

test_that("modPyramidServer handles input changes", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2015-01-01", "2016-06-15", "2018-03-20")),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPyramidServer,
    args = list(
      pedigreeData = shiny::reactive({ test_ped })
    ),
    {
      # Test age unit selection
      session$setInputs(ageUnit = "months")
      expect_equal(input$ageUnit, "months")

      session$setInputs(ageUnit = "years")
      expect_equal(input$ageUnit, "years")

      # Test bin size
      session$setInputs(ageBin = 5L)
      expect_equal(input$ageBin, 5L)

      # Test color scheme
      session$setInputs(colorScheme = "viridis")
      expect_equal(input$colorScheme, "viridis")

      # Test show counts
      session$setInputs(showCounts = FALSE)
      expect_false(input$showCounts)

      # Test plot height
      session$setInputs(plotHeight = 800L)
      expect_equal(input$plotHeight, 800L)

      # Test age label size
      session$setInputs(ageLabelSize = 1.5)
      expect_equal(input$ageLabelSize, 1.5)
    }
  )
})

test_that("modPyramidServer pedigree reactive returns input data", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("X1", "X2", "X3"),
    sex = c("M", "F", "M"),
    birth = as.Date(c("2012-01-01", "2014-06-15", "2016-03-20")),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPyramidServer,
    args = list(
      pedigreeData = shiny::reactive({ test_ped })
    ),
    {
      result <- session$getReturned()
      ped <- result$pedigree()

      expect_equal(nrow(ped), 3)
      expect_true(all(c("X1", "X2", "X3") %in% ped$id))
    }
  )
})
