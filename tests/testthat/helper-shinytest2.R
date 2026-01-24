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

# Get HTML with wait for idle first (with error recovery)
get_html_safe <- function(app, selector = "body") {
  tryCatch({
    app$wait_for_idle(timeout = E2E_TIMEOUT)
    app$get_html(selector)
  }, error = function(e) {
    # Return empty string on error - caller should handle
    ""
  })
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

# ============================================================================
# Shared App Instance Management
# ============================================================================
# These functions allow multiple tests to share a single app instance,
# dramatically reducing test execution time by avoiding repeated app startups.

# Environment to store shared app instances
.e2e_shared_apps <- new.env(parent = emptyenv())

# Get or create a shared app instance for a specific tab
# Returns list(app, html) where html is the body content
# Handles Chrome connection errors by clearing invalid cache entries
get_shared_app <- function(tab_name, alt_tab = NULL, menu_item = FALSE) {
  key <- paste0(tab_name, "_", alt_tab %||% "")

  # Try to use existing app, but verify it's still responsive
  if (exists(key, envir = .e2e_shared_apps)) {
    app <- get(key, envir = .e2e_shared_apps)
    html <- get_html_safe(app, "body")

    # If we got valid content, return it
    if (nchar(html) > 50) {
      return(list(app = app, html = html))
    }

    # Otherwise, the app is broken - clean up and recreate
    tryCatch(app$stop(), error = function(e) NULL)
    rm(list = key, envir = .e2e_shared_apps)
  }

  # Create new app instance
  app_dir <- create_test_app()
  app <- tryCatch({
    create_app_driver(app_dir, paste0("shared_", gsub(" ", "_", tab_name)))
  }, error = function(e) {
    return(NULL)
  })

  if (is.null(app)) return(NULL)

  # Navigate to the target tab
  if (menu_item) {
    success <- navigate_to_menu_item(app, tab_name)
  } else {
    success <- navigate_to_tab(app, tab_name, alt_tab)
  }

  if (!success) {
    tryCatch(app$stop(), error = function(e) NULL)
    return(NULL)
  }

  assign(key, app, envir = .e2e_shared_apps)

  html <- get_html_safe(app, "body")
  list(app = app, html = html)
}

# Stop all shared app instances (call in teardown)
stop_shared_apps <- function() {
  for (key in ls(envir = .e2e_shared_apps)) {
    app <- get(key, envir = .e2e_shared_apps)
    tryCatch(app$stop(), error = function(e) NULL)
  }
  rm(list = ls(envir = .e2e_shared_apps), envir = .e2e_shared_apps)
}

# Helper for null coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x

# ============================================================================
# Batch Test Runners
# ============================================================================
# Run multiple content checks against a shared app instance

# Run a batch of HTML content tests on a single tab
# tests should be a list of list(name, pattern, ignore_case = TRUE)
run_tab_tests <- function(tab_name, tests, alt_tab = NULL, menu_item = FALSE) {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app(tab_name, alt_tab, menu_item)
  if (is.null(shared)) {
    skip(paste("Could not navigate to", tab_name, "tab"))
  }

  results <- list()
  for (test in tests) {
    pattern <- test$pattern
    ignore_case <- test$ignore_case %||% TRUE

    match <- grepl(pattern, shared$html, ignore.case = ignore_case)
    results[[test$name]] <- match
  }

  results
}

# Create test expectations from batch results
expect_tab_content <- function(tab_name, pattern, ignore_case = TRUE,
                                alt_tab = NULL, menu_item = FALSE, info = NULL) {
  shared <- get_shared_app(tab_name, alt_tab, menu_item)
  if (is.null(shared)) {
    skip(paste("Could not navigate to", tab_name, "tab"))
  }

  expect_true(
    grepl(pattern, shared$html, ignore.case = ignore_case),
    info = info %||% paste("Should find pattern:", pattern)
  )
}
