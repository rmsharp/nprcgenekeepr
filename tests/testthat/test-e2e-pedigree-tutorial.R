## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Tests for Pedigree Browser - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
library(testthat)

test_that("E2E: Pedigree Browser has Display Unknown IDs checkbox", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_unknown_ids")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Display Unknown IDs"),
    info = "Should have Display Unknown IDs checkbox"
  )
})

test_that("E2E: Pedigree Browser has row count display options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_row_count")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  # 8e-6a: the DataTables "Show N entries" length menu renders only with loaded
  # data; assert it (and the row-count info) on the real rendered table.
  html <- get_html_safe(app, "#pedigree-pedigreeTable")
  expect_match(
    html, "dataTables_length",
    info = "DataTables 'Show N entries' length menu renders with loaded data"
  )
  expect_match(
    html, "of 375 entries",
    info = "Row-count info reflects all 375 fixture pedigree rows"
  )
})

test_that("E2E: Pedigree Browser has focal animal text input", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_focal_input")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Focal Animals"),
    info = "Should have focal animal text input"
  )
})

test_that("E2E: Pedigree Browser has CSV focal animal upload", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_focal_csv")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Choose CSV file"),
    info = "Should have CSV focal animal upload"
  )
})

test_that("E2E: Pedigree Browser has Trim Pedigree checkbox", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_trim_checkbox")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Trim pedigree"),
    info = "Should have Trim Pedigree checkbox"
  )
})

test_that("E2E: Pedigree Browser has Update Focal Animals button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_update_focal")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Update Focal Animals"),
    info = "Should have Update Focal Animals button"
  )
})

test_that("E2E: Pedigree Browser has Clear Focal Animals option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_clear_focal")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Clear Focal Animals"),
    info = "Should have Clear Focal Animals option"
  )
})

test_that("E2E: Pedigree Browser shows pedigree columns", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_columns")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  # Tutorial mentions these columns: id, sire, dam, sex, gen, birth, exit, age;
  # they are listed in the always-rendered pedigree_browser.html guidance panel.
  expect_true(
    assert_active_pane(
      app, "Pedigree Browser",
      "sire|dam|sex|birth|exit|age|gen|population"
    ),
    info = "Should show pedigree columns"
  )
})

test_that("E2E: Clear Focal Animals resets the file input and typed IDs", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_clear_resets")
  on.exit(app$stop(), add = TRUE)

  # Load a studbook so the Pedigree Browser tab is fully live.
  fixture <- system.file("extdata", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  # The focal file input is rendered server-side (uiOutput); wait for it.
  if (!wait_for_element(app, "#pedigree-focalAnimalFile")) {
    skip("Focal animal file input did not render")
  }

  # A focal-animals CSV to upload.
  focal_csv <- tempfile(fileext = ".csv")
  utils::write.csv(data.frame(id = c("AAA", "BBB")), focal_csv,
                   row.names = FALSE)
  on.exit(unlink(focal_csv), add = TRUE)

  # Reads the file name shown in the file-input widget ("" when none selected).
  display_js <- paste0(
    "(() => { const f = document.querySelector('#pedigree-focalAnimalFile'); ",
    "if (!f) return ''; const g = f.closest('.input-group'); ",
    "const t = g && g.querySelector('input[type=text]'); ",
    "return (t && t.value) || ''; })()"
  )

  # Enter focal IDs by text AND by file, then Update.
  app$set_inputs(`pedigree-focalAnimalIds` = "AAA, BBB")
  do.call(app$upload_file,
          stats::setNames(list(focal_csv), "pedigree-focalAnimalFile"))
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  app$click("pedigree-updateFocalAnimals")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # Sanity: the widget shows the uploaded file name and the textarea holds the
  # typed IDs before clearing.
  expect_match(app$get_js(display_js), "\\.csv$",
               info = "File widget shows the uploaded CSV before clearing")
  expect_identical(app$get_value(input = "pedigree-focalAnimalIds"),
                   "AAA, BBB")

  # Check "Clear Focal Animals" and Update.
  app$set_inputs(`pedigree-clearFocalAnimals` = TRUE)
  app$click("pedigree-updateFocalAnimals")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # Issue #1: the file name display is cleared (fresh re-rendered widget) ...
  expect_identical(app$get_js(display_js), "",
                   info = "File name display clears after Clear Focal Animals")
  # ... and the typed IDs are cleared from the textarea.
  expect_identical(app$get_value(input = "pedigree-focalAnimalIds"), "")
})
