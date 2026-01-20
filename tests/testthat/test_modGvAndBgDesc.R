# Tests for modGvAndBgDesc.R - Genetic Value and Breeding Group Description Module

test_that("modGvAndBgDescUI returns a shiny.tag object", {
  ui <- modGvAndBgDescUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modGvAndBgDescUI contains expected heading", {
  ui <- modGvAndBgDescUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Genetic Value Analysis and Breeding Group Description",
                    ui_html))
})

test_that("modGvAndBgDescUI has styled container", {
  ui <- modGvAndBgDescUI("test")
  ui_html <- as.character(ui)

  # Check for styling elements
  expect_true(grepl("border", ui_html))
  expect_true(grepl("border-radius", ui_html))
  expect_true(grepl("box-shadow", ui_html))
})

test_that("modGvAndBgDescUI includes HTML documentation content", {
  ui <- modGvAndBgDescUI("test")
  ui_html <- as.character(ui)

  # Check for actual content from the guidance HTML
  expect_true(grepl("kinship coefficients", ui_html, ignore.case = TRUE) ||
                grepl("genetic value analysis proceeds", ui_html, ignore.case = TRUE))
})

test_that("modGvAndBgDescServer returns NULL", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGvAndBgDescServer,
    {
      # This module is informational only - no reactive logic
      result <- session$getReturned()
      expect_null(result)
    }
  )
})

test_that("modGvAndBgDescServer can be called without error", {
  skip_if_not_installed("shiny")

  # Simply verify the module server doesn't error
  expect_silent({
    shiny::testServer(
      modGvAndBgDescServer,
      {
        # No inputs to test - this is a display-only module
        TRUE
      }
    )
  })
})
