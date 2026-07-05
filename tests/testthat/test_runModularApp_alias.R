# Issue #110: the canonical Shiny entry point is now runGeneKeepR() -- a name
# that says what it does. runModularApp() is retained as a
# lifecycle::deprecate_soft() alias that forwards to runGeneKeepR(), so existing
# runModularApp() callers keep working (with a soft-deprecation warning).
#
# These tests pin the REVERSED contract (mirror image of the pre-#110 state):
#   - runGeneKeepR() is NOT deprecated and launches the app via shiny::runApp().
#   - runModularApp() IS soft-deprecated and delegates to runGeneKeepR().
# Every Shiny launch is mocked so no real server is ever started.

test_that("runGeneKeepR() does not signal a lifecycle deprecation", {
  withr::local_options(lifecycle_verbosity = "warning")
  testthat::local_mocked_bindings(
    shinyApp = function(...) "APP", .package = "shiny"
  )
  testthat::local_mocked_bindings(
    runApp = function(...) "RUNAPP_SENTINEL", .package = "shiny"
  )
  expect_no_warning(runGeneKeepR(), class = "lifecycle_warning_deprecated")
})

test_that("runGeneKeepR() launches the app via shiny::runApp()", {
  testthat::local_mocked_bindings(
    shinyApp = function(...) "APP", .package = "shiny"
  )
  testthat::local_mocked_bindings(
    runApp = function(...) "RUNAPP_SENTINEL", .package = "shiny"
  )
  expect_identical(runGeneKeepR(), "RUNAPP_SENTINEL")
})

test_that("runGeneKeepR() forwards port / launch.browser to shiny::runApp()", {
  captured <- NULL
  testthat::local_mocked_bindings(
    shinyApp = function(...) "APP", .package = "shiny"
  )
  testthat::local_mocked_bindings(
    runApp = function(...) {
      args <- list(...)
      captured <<- list(port = args$port, launch.browser = args$launch.browser)
      "RUNAPP_SENTINEL"
    },
    .package = "shiny"
  )
  runGeneKeepR(port = 7123L, launch.browser = FALSE)
  expect_identical(captured$port, 7123L)
  expect_identical(captured$launch.browser, FALSE)
})

test_that("runModularApp() signals a lifecycle deprecation", {
  testthat::local_mocked_bindings(runGeneKeepR = function(...) "GENEKEEPR_SENTINEL")
  testthat::local_mocked_bindings(
    shinyApp = function(...) "APP", .package = "shiny"
  )
  testthat::local_mocked_bindings(
    runApp = function(...) "RUNAPP_SENTINEL", .package = "shiny"
  )
  lifecycle::expect_deprecated(runModularApp())
})

test_that("runModularApp() delegates to runGeneKeepR(), not shiny directly", {
  testthat::local_mocked_bindings(runGeneKeepR = function(...) "GENEKEEPR_SENTINEL")
  testthat::local_mocked_bindings(
    shinyApp = function(...) "APP", .package = "shiny"
  )
  testthat::local_mocked_bindings(
    runApp = function(...) "RUNAPP_SENTINEL", .package = "shiny"
  )
  expect_identical(suppressWarnings(runModularApp()), "GENEKEEPR_SENTINEL")
})

test_that("runModularApp() forwards port / launch.browser to runGeneKeepR()", {
  captured <- NULL
  testthat::local_mocked_bindings(
    runGeneKeepR = function(...) {
      args <- list(...)
      captured <<- list(port = args$port, launch.browser = args$launch.browser)
      "GENEKEEPR_SENTINEL"
    }
  )
  testthat::local_mocked_bindings(
    shinyApp = function(...) "APP", .package = "shiny"
  )
  testthat::local_mocked_bindings(
    runApp = function(...) "RUNAPP_SENTINEL", .package = "shiny"
  )
  suppressWarnings(runModularApp(port = 7123L, launch.browser = FALSE))
  expect_identical(captured$port, 7123L)
  expect_identical(captured$launch.browser, FALSE)
})
