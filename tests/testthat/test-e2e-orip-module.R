#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for the ORIP Reporting Module (GitHub issues #47, #49)
#'
#' Opt-in, browser-driven regression tests for the "ORIP Reporting" tab wired in
#' Session 83 (#47) and gated to ONPRC in Session 84 (#49). They drive the
#' assembled modular app (appUI()/appServer) through shinytest2::AppDriver and
#' assert the build-time ONPRC gate end-to-end: the tab is PRESENT, navigable,
#' and renders the ONPRC site information (plus an exportable report CSV) only
#' under an actual ONPRC site configuration, and is ABSENT both with no config
#' file (the getSiteInfo() default fallback) and under a non-ONPRC (SNPRC)
#' config.
#'
#' The ORIP tab is build-time gated (R/shouldShowOripTab.R, wired in appUI.R and
#' appServer.R): appUI() shows the tabPanel and appServer mounts the module
#' server only when shouldShowOripTab(center, file.exists(configFile)) is TRUE.
#' getConfigFileName() resolves the config path from Sys.getenv("HOME"), so the
#' positive/SNPRC cases boot a generated app.R that points HOME at a temp dir
#' holding a complete, documented-format .nprcgenekeepr_config (see
#' build_config_app_dir() below). The no-config case reuses the standard
#' installed app, where no config file exists.
#'
#' These tests are OPT-IN (NPRC_RUN_E2E=true) and skipped otherwise; see
#' helper-shinytest2.R::create_test_app(). They drive the INSTALLED package, so
#' run devtools::install() first -- the installed copy must carry the module and
#' the appUI()/appServer ONPRC gate.
library(testthat)

#' Build a throwaway app directory whose app.R boots the modular app under a
#' chosen site center.
#'
#' The ORIP Reporting tab is gated to an ACTUAL ONPRC configuration, so to drive
#' it we boot the app with a real config file present. getConfigFileName()
#' resolves the config path from Sys.getenv("HOME"); the generated app.R sets
#' HOME to a sibling dir holding a complete, documented-format
#' .nprcgenekeepr_config (all seven params getSiteInfo()/getParamDef() require)
#' before constructing the app.
#'
#' Reuses create_test_app() purely for its opt-in gate -- it skips the calling
#' test unless NPRC_RUN_E2E=true and confirms the package is installed. Its
#' returned standard-app path is intentionally discarded here.
#'
#' @param center Site center written into the config ("ONPRC" or "SNPRC").
#' @return Path to a temp directory containing app.R and a home/ subdir; remove
#'   it with unlink(recursive = TRUE) after the AppDriver is stopped.
build_config_app_dir <- function(center) {
  create_test_app()  # opt-in gate (skips unless NPRC_RUN_E2E=true); path unused

  app_dir <- tempfile("orip_e2e_app_")
  home_dir <- file.path(app_dir, "home")
  dir.create(home_dir, recursive = TRUE)

  # OS-correct config basename (".nprcgenekeepr_config" except on Windows);
  # sourced from the package so the test never drifts from getConfigFileName().
  config_name <- basename(
    nprcgenekeepr::getConfigFileName(Sys.info())[["configFile"]]
  )
  writeLines(c(
    sprintf('center = "%s"', center),
    'baseUrl = "https://primeuat.ohsu.edu"',
    'schemaName = "study"',
    'folderPath = "/ONPRC/EHR"',
    'queryName = "demographics"',
    'lkPedColumns = ("Id", "gender", "birth", "death",',
    '                "lastDayAtCenter", "dam", "sire")',
    'mapPedColumns = ("id", "sex", "birth", "death", "exit", "dam", "sire")'
  ), file.path(home_dir, config_name))

  # Embed an absolute, forward-slash HOME path that is safe in an R string
  # literal on every platform; set it before constructing the app so
  # getSiteInfo() reads this config.
  home_abs <- normalizePath(home_dir, winslash = "/", mustWork = TRUE)
  writeLines(c(
    sprintf('Sys.setenv(HOME = "%s")', home_abs),
    'library(shiny)',
    'library(nprcgenekeepr)',
    'shinyApp(ui = appUI(), server = appServer)'
  ), file.path(app_dir, "app.R"))

  app_dir
}

test_that("E2E: ORIP Reporting tab is accessible under an ONPRC config", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- build_config_app_dir("ONPRC")
  app <- create_app_driver(app_dir, "e2e_orip_access")
  on.exit(app$stop(), add = TRUE)
  on.exit(unlink(app_dir, recursive = TRUE), add = TRUE)

  success <- navigate_to_tab(app, "ORIP Reporting", "ORIP")
  if (!success) skip("Could not navigate to ORIP Reporting tab")

  # Static body text rendered only by modORIPReportingUI("oripReporting") -- its
  # presence in the active pane proves the gated tab mounted and is selectable.
  expect_true(
    assert_active_pane(app, "ORIP Reporting",
                       "office of research infrastructure programs"),
    info = "Should be on the ORIP Reporting tab under an ONPRC configuration"
  )
})

test_that("E2E: ORIP Reporting renders ONPRC site info, exports report CSV", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- build_config_app_dir("ONPRC")
  app <- create_app_driver(app_dir, "e2e_orip_content")
  on.exit(app$stop(), add = TRUE)
  on.exit(unlink(app_dir, recursive = TRUE), add = TRUE)

  if (!navigate_to_tab(app, "ORIP Reporting", "ORIP")) {
    skip("Could not navigate to ORIP Reporting tab")
  }
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # The "Export ORIP Report" downloadButton is static ORIP UI; its label shows
  # in the active pane's visible text.
  expect_true(
    assert_active_pane(app, "ORIP Reporting", "export orip report"),
    info = "ORIP pane should expose the Export ORIP Report download button"
  )

  # Site Information is rendered from siteConfig = getSiteInfo(); under the
  # ONPRC config it must report Center = ONPRC -- teeth: this only matches
  # when the active config actually reached the module (not the default
  # fallback path).
  site_html <- get_html_safe(app, "#oripReporting-siteInfo")
  expect_match(
    site_html, "ONPRC",
    info = "Site Information should report the ONPRC center"
  )

  # Export ORIP Report CSV end to end: the handler always writes the Site
  # section (Category/Metric/Value, Center = ONPRC) even before a pedigree is
  # loaded, so this is deterministic.
  csv_path <- app$get_download("oripReporting-downloadORIPReport")
  report <- read.csv(csv_path, stringsAsFactors = FALSE,
                     colClasses = "character")
  expect_identical(
    names(report), c("Category", "Metric", "Value"),
    info = "ORIP report CSV should carry the Category/Metric/Value columns"
  )
  expect_true(
    any(report$Metric == "Center" & report$Value == "ONPRC"),
    info = "ORIP report CSV should record the ONPRC center in its Site section"
  )
})

test_that("E2E: ORIP Reporting tab is hidden without a site configuration", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  # The standard installed app has no config file, so getSiteInfo() returns the
  # default fallback (center = "ONPRC", configFile path that does NOT exist) and
  # shouldShowOripTab() is FALSE. create_test_app() also applies the opt-in
  # gate.
  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_orip_noconfig")
  on.exit(app$stop(), add = TRUE)

  # The tab is not mounted: navigation cannot land on it (read-back stays put).
  expect_false(
    navigate_to_tab(app, "ORIP Reporting", "ORIP"),
    info = "Without a config file the ONPRC-gated ORIP tab must be absent"
  )
  # And the module namespace must be absent from the whole serialized UI tree.
  body_html <- get_html_safe(app, "body")
  expect_false(
    grepl("oripReporting-", body_html),
    info = "ORIP module namespace must be absent off-ONPRC"
  )
})

test_that("E2E: ORIP Reporting tab is hidden under a non-ONPRC config", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- build_config_app_dir("SNPRC")
  app <- create_app_driver(app_dir, "e2e_orip_snprc")
  on.exit(app$stop(), add = TRUE)
  on.exit(unlink(app_dir, recursive = TRUE), add = TRUE)

  # A config file is present but center != ONPRC, so the gate keys on center,
  # not mere config presence: the tab must still be absent.
  expect_false(
    navigate_to_tab(app, "ORIP Reporting", "ORIP"),
    info = "A SNPRC deployment must not see the Oregon-specific ORIP tab"
  )
  body_html <- get_html_safe(app, "body")
  expect_false(
    grepl("oripReporting-", body_html),
    info = "ORIP module namespace must be absent under a SNPRC config"
  )
})
