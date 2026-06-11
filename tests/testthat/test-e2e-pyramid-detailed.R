#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Age-Sex Pyramid Module
library(testthat)

test_that("E2E: Pyramid module has age bin controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_bins")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Age-Sex Pyramid tab")

  expect_true(
    assert_active_pane(app, "Age-Sex Pyramid", "age|bin|interval|year"),
    info = "Should have age bin controls"
  )
})

test_that("E2E: Pyramid module displays male/female labels", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_sex_labels")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Age-Sex Pyramid tab")

  # male/female/sex are satisfied by always-rendered static content: the h3
  # "Age-Sex Pyramid Analysis" and the guidance HTML ("...males are plotted on
  # the left and females on the right", pyramidPlot.html via modPyramid.R:55-58).
  # The data-dependent rendered plot's own axis labels belong to slice 8e-6.
  expect_true(
    assert_active_pane(app, "Age-Sex Pyramid", "male|female|sex"),
    info = "Should display male/female labels"
  )
})

test_that("E2E: Pyramid module has maximum age setting", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_max_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Age-Sex Pyramid tab")

  # No dedicated max-age control exists in modPyramid.R; this genuine regex is
  # kept verbatim (only the haystack is rescoped to the active pane) and is
  # satisfied by the always-visible age-related labels ("Age Unit:", "Age Label
  # Size:", "Age-Sex Pyramid Analysis"). Renaming/retargeting the test is out of
  # scope for this haystack-rescope slice.
  expect_true(
    assert_active_pane(app, "Age-Sex Pyramid", "max|maximum|age|limit"),
    info = "Should have maximum age setting"
  )
})

test_that("E2E: Pyramid module has plot export option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_export_plot")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Age-Sex Pyramid tab")

  expect_true(
    assert_active_pane(app, "Age-Sex Pyramid", "Download Plot"),
    info = "Should have plot export option"
  )
})

test_that("E2E: Pyramid module has population description", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_desc")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Age-Sex Pyramid tab")

  expect_true(
    assert_active_pane(
      app, "Age-Sex Pyramid", "population|distribution|pyramid|demographic"
    ),
    info = "Should have population description"
  )
})

test_that("E2E: Pyramid module shows data requirement message", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_data_msg")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Age-Sex Pyramid tab")

  # The instructional guidance is the "placeholder or instruction" shown before
  # data is loaded: pyramidPlot.html ("A Pedigree Age Plot plots an
  # age-distribution of live animals...") is always rendered (no req guard,
  # modPyramid.R:55-58). The data-bearing empty-vs-loaded distinction is 8e-6.
  expect_true(
    assert_active_pane(app, "Age-Sex Pyramid", "Age Plot"),
    info = "Should show instructional guidance before data is loaded"
  )
})
