# Phase 9 (shiny-module conversion): runGeneKeepR() becomes a
# lifecycle::deprecate_soft() alias that launches the MODULAR app
# (runModularApp), and the legacy monolith (inst/application) no longer
# ships. These tests are RED until Phase 9 is implemented.
#
# Both code paths are mocked so no real Shiny server is ever launched:
#   - shiny::runApp  -> the legacy monolith launch (current body)
#   - runModularApp  -> the modular launch (alias body, same package)

test_that("runGeneKeepR() signals a lifecycle deprecation", {
  testthat::local_mocked_bindings(runModularApp = function(...) "MODULAR_SENTINEL")
  testthat::local_mocked_bindings(
    runApp = function(...) "MONOLITH_SENTINEL", .package = "shiny"
  )
  lifecycle::expect_deprecated(runGeneKeepR())
})

test_that("runGeneKeepR() delegates to the modular app, not the monolith", {
  testthat::local_mocked_bindings(runModularApp = function(...) "MODULAR_SENTINEL")
  testthat::local_mocked_bindings(
    runApp = function(...) "MONOLITH_SENTINEL", .package = "shiny"
  )
  expect_identical(suppressWarnings(runGeneKeepR()), "MODULAR_SENTINEL")
})

test_that("runGeneKeepR() accepts and forwards port / launch.browser", {
  expect_true(all(c("port", "launch.browser") %in% names(formals(runGeneKeepR))))

  captured <- NULL
  testthat::local_mocked_bindings(
    runModularApp = function(port, launch.browser) {
      captured <<- list(port = port, launch.browser = launch.browser)
      "MODULAR_SENTINEL"
    }
  )
  testthat::local_mocked_bindings(
    runApp = function(...) "MONOLITH_SENTINEL", .package = "shiny"
  )
  suppressWarnings(runGeneKeepR(port = 7123L, launch.browser = FALSE))
  expect_identical(captured$port, 7123L)
  expect_identical(captured$launch.browser, FALSE)
})
