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

# =============================================================================
# Tests for appUI/appServer wiring (Phase 2 - mount the description tab)
# =============================================================================

test_that("appUI mounts the GvAndBgDesc description tab", {
  ui_html <- as.character(appUI())

  # NOTE: the module's H3 heading ("Genetic Value Analysis and Breeding Group
  # Description") is NOT discriminating -- genetic_value.html, already mounted by
  # modGeneticValue, contains that exact phrase. The unique, discriminating
  # marker is gvAndBgDesc.html's own body text: absent from appUI at HEAD,
  # present only once modGvAndBgDescUI's includeHTML runs inside a mounted tab.
  expect_true(grepl("kinship coefficients", ui_html, ignore.case = TRUE) ||
                grepl("genetic value analysis proceeds", ui_html,
                      ignore.case = TRUE))
})

test_that("appServer mounts the GvAndBgDesc description module server", {
  # Structural check (mirrors this suite's dynamic-tab structural idiom):
  # appServer must call modGvAndBgDescServer so the tab's module is mounted.
  appServer_text <- paste(deparse(appServer), collapse = "\n")
  expect_true(grepl("modGvAndBgDescServer", appServer_text))
})
