#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Unit test: the About tab version string tracks the package DESCRIPTION
#' version rather than a stale hardcoded literal. The app also shows a
#' dynamic version in its title bar (appUI.R:47), so the assertions are
#' scoped to the About panel to avoid a false match on that string.
library(testthat)

test_that("appUI About tab shows the package version, not a stale literal", {
  ui_html <- as.character(appUI())
  expected <- as.character(utils::packageVersion("nprcgenekeepr"))

  # Scope to the About panel: the version paragraph that follows its heading.
  about_idx <- regexpr("About GeneKeepR", ui_html, fixed = TRUE)
  expect_gt(about_idx, 0) # guard: the About panel must be present
  about_region <- substring(ui_html, about_idx, about_idx + 200L)

  # Positive: the About tab carries the current package version.
  expect_true(
    grepl(paste0("Version ", expected), about_region, fixed = TRUE),
    info = paste0("About tab should display 'Version ", expected, "'")
  )

  # Negative (teeth): the stale hardcoded 'Version 1.0.8' is gone.
  expect_false(
    grepl("Version 1.0.8", about_region, fixed = TRUE),
    info = "About tab must not display the stale hardcoded 'Version 1.0.8'"
  )
})
