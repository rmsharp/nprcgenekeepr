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
