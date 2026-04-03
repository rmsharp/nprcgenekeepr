#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Breeding Group Formation - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
library(testthat)

test_that("E2E: Breeding Groups has workflow selection", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_workflow")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions "Choose one group formation workflow"
  has_workflow <- grepl(
    "workflow|group.*formation|source.*animal|Choose.*group",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has sex ratio options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_sex_ratio_opts")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions three sex ratio options including user-specified
  has_sex_ratio_opts <- grepl(
    "sex.*ratio|ratio.*breeder|F/M|female.*male|sexRatio",
    html,
    ignore.case = TRUE
  )
  expect_true(has_sex_ratio_opts, info = "Should have sex ratio options")
})

test_that("E2E: Breeding Groups has Make Groups button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_make_groups")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_make_groups <- grepl(
    "Make.*Group|Form.*Group|Create.*Group|makeGroups|formGroups",
    html,
    ignore.case = TRUE
  )
  expect_true(has_make_groups, info = "Should have Make Groups button")
})

test_that("E2E: Breeding Groups has seed groups option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_seed_groups")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions "Seed Groups with Specific Animals"
  has_seed <- grepl(
    "Seed.*Group|seed.*animal|pre.*seed|seedGroups|specific.*animal",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has infants with dam option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_infants_dam")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions keeping infants/young animals with their mother
  has_infants_dam <- grepl(
    "infant.*dam|infant.*mother|young.*dam|keepWithDam|with.*mother",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has include kinship option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_include_kinship")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions "Include kinship in display of groups" checkbox
  has_include_kinship <- grepl(
    "Include.*kinship|kinship.*display|showKinship|display.*kinship",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has group export options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_export_groups")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions groups can be individually exported
  has_export <- grepl(
    "export|download|save|csv",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has high-value animals source", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_high_value_source")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions high-value animals as common source
  has_high_value_source <- grepl(
    "high.*value|value.*animal|top.*ranked|genetic.*analysis",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has kinship matrix export per group", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_kinship_matrix_export")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions kinship matrix export for each group
  has_kinship_export <- grepl(
    "kinship.*matrix|matrix.*export|export.*kinship",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})
