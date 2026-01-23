#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Setup file for shinytest2 tests

# Helper function to create app for testing
create_test_app <- function() {
  # Use the shinytest wrapper app (new modular structure)
  app_dir <- system.file("shinytest", package = "nprcgenekeepr")
  if (!dir.exists(app_dir) || !file.exists(file.path(app_dir, "app.R"))) {
    # Fallback to legacy application
    app_dir <- system.file("application", package = "nprcgenekeepr")
    if (!dir.exists(app_dir)) {
      skip("Shiny app not found")
    }
  }
  app_dir
}

# Helper to check if shinytest2 dependencies are available
shinytest2_available <- function() {
  requireNamespace("shinytest2", quietly = TRUE) &&
    requireNamespace("chromote", quietly = TRUE)
}

# Default timeout for wait operations (ms)
E2E_TIMEOUT <- 10000

# Create an AppDriver with proper initialization wait
create_app_driver <- function(app_dir, name, height = 900, width = 1400,
                               load_timeout = 45000) {
  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = name,
    height = height,
    width = width,
    load_timeout = load_timeout
  )
  # Wait for app to be fully idle after initialization

  app$wait_for_idle(timeout = E2E_TIMEOUT)
  app
}

# Navigate to a tab and wait for it to load
navigate_to_tab <- function(app, tab_value, alt_value = NULL) {
  selector <- paste0('a[data-value="', tab_value, '"]')

  result <- tryCatch({
    app$click(selector = selector)
    app$wait_for_idle(timeout = E2E_TIMEOUT)
    TRUE
  }, error = function(e) {
    if (!is.null(alt_value)) {
      tryCatch({
        app$click(selector = paste0('a[data-value="', alt_value, '"]'))
        app$wait_for_idle(timeout = E2E_TIMEOUT)
        TRUE
      }, error = function(e2) FALSE)
    } else {
      FALSE
    }
  })

  result
}

# Wait for element to exist in DOM
wait_for_element <- function(app, selector, timeout = E2E_TIMEOUT) {
  js_check <- sprintf("document.querySelector('%s') !== null", selector)
  tryCatch({
    app$wait_for_js(js_check, timeout = timeout)
    TRUE
  }, error = function(e) FALSE)
}

# Get HTML with wait for idle first
get_html_safe <- function(app, selector = "body") {
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  app$get_html(selector)
}

# Click an element safely with wait
click_element_safe <- function(app, selector) {
  tryCatch({
    app$click(selector = selector)
    app$wait_for_idle(timeout = E2E_TIMEOUT)
    TRUE
  }, error = function(e) FALSE)
}

# Get values safely with wait
get_values_safe <- function(app) {
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  app$get_values()
}

# Navigate to a menu item (e.g., Settings, About, Help in dropdown)
navigate_to_menu_item <- function(app, item_value) {
  # First try to open dropdown menu if it exists
  tryCatch({
    app$click(selector = 'a[data-toggle="dropdown"]')
    app$wait_for_idle(timeout = E2E_TIMEOUT / 2)
  }, error = function(e) NULL)

  # Then click the item
  tryCatch({
    app$click(selector = paste0('a[data-value="', item_value, '"]'))
    app$wait_for_idle(timeout = E2E_TIMEOUT)
    TRUE
  }, error = function(e) FALSE)
}
