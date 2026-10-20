## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Full-stack E2E for the Changed Columns tab (S1020, BACKLOG.md:168) -- the tab
#' must open only for a header QC really changed, and must say what it changed.
#'
#' This drives the assembled modular app (appUI()/appServer) through
#' shinytest2::AppDriver and uploads the shipped example pedigree four ways:
#'   (1) every header spelled right (recordStatus, fromCenter, geographicOrigin)
#'       -> no Changed Columns tab (QC lower-cases each header and restores
#'       these three, which used to be reported as a case change);
#'   (2) an all-lowercase `recordstatus` header, (3) an all-lowercase
#'       `fromcenter` header and (4) an added all-lowercase `geographicorigin`
#'       header -> the tab opens and its page holds one sentence that names the
#'       rename (the first two used to open the tab with a heading and no list,
#'       the third did not open it).
#' The unit tests (test_fixColumnNames.R, test_summary.nprcgenekeeprErr.R,
#' test_shouldShowChangedColsTab.R, test_runQcStudbook.R) own the records and
#' the wording; this file owns what the running app shows.
#'
#' OPT-IN (NPRC_RUN_E2E=true); skipped otherwise via create_test_app(). Drives
#' the INSTALLED package, so run devtools::install() first.
library(testthat)

# The title of every tab in the navbar, as one string.
navbar_tabs <- function(app) {
  app$get_js(paste0(
    "Array.from(document.querySelectorAll('#mainNavbar li a'))",
    ".map(a => a.getAttribute('data-value')).join(' | ')"
  ))
}

# TRUE once the Changed Columns tab is in the navbar, FALSE if it never comes.
wait_for_changed_columns_tab <- function(app, timeout = 10000) {
  tryCatch({
    app$wait_for_js(
      "document.querySelector(\"#mainNavbar a[data-value='Changed Columns']\") !== null",
      timeout = timeout
    )
    TRUE
  }, error = function(e) FALSE)
}

# The shipped example pedigree as a CSV file. `rename` maps old to new header;
# `add` is a named list of columns to append.
write_header_fixture <- function(rename = character(0L), add = list()) {
  ped <- nprcgenekeepr::examplePedigree
  for (old in names(rename)) {
    names(ped)[names(ped) == old] <- rename[[old]]
  }
  for (nm in names(add)) {
    ped[[nm]] <- add[[nm]]
  }
  fixture <- tempfile(fileext = ".csv")
  utils::write.csv(ped, fixture, row.names = FALSE, na = "")
  fixture
}

# Upload `fixture`, wait for QC and for the page to settle.
upload_fixture <- function(app, fixture) {
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC of the header fixture did not complete")
  wait_for_idle(app)
}

# The text of the Changed Columns page, squashed to single spaces ("" when the
# tab never opened).
changed_columns_text <- function(app) {
  if (!wait_for_changed_columns_tab(app)) return("")
  if (!navigate_to_tab(app, "Changed Columns")) return("")
  wait_for_active_pane(app, "Changed Columns")
  squash_whitespace(get_active_pane_text(app))
}

test_that("E2E: headers spelled recordStatus, fromCenter and geographicOrigin open no Changed Columns tab", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app <- create_app_driver(create_test_app(), "e2e_changed_cols_right")
  on.exit(app$stop(), add = TRUE)

  ped <- nprcgenekeepr::examplePedigree
  upload_fixture(app, write_header_fixture(
    add = list(geographicOrigin = rep("India", nrow(ped)))
  ))

  tabs <- navbar_tabs(app)
  expect_match(tabs, "Pedigree Browser", fixed = TRUE)
  expect_false(grepl("Changed Columns", tabs, fixed = TRUE),
               info = paste("tabs:", tabs))
})

test_that("E2E: an all-lowercase recordstatus header opens the tab with one sentence", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app <- create_app_driver(create_test_app(), "e2e_changed_cols_recordstatus")
  on.exit(app$stop(), add = TRUE)

  upload_fixture(app, write_header_fixture(
    rename = c(recordStatus = "recordstatus")
  ))

  text <- changed_columns_text(app)
  expect_match(text,
               "Change: The column changed from: recordstatus to recordStatus.",
               fixed = TRUE)
  # fromCenter is spelled right, so the page does not mention it.
  expect_false(grepl("fromcenter", text, ignore.case = TRUE), info = text)
})

test_that("E2E: an all-lowercase fromcenter header opens the tab with one sentence", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app <- create_app_driver(create_test_app(), "e2e_changed_cols_fromcenter")
  on.exit(app$stop(), add = TRUE)

  upload_fixture(app, write_header_fixture(
    rename = c(fromCenter = "fromcenter")
  ))

  text <- changed_columns_text(app)
  expect_match(text,
               "Change: The column changed from: fromcenter to fromCenter.",
               fixed = TRUE)
  expect_false(grepl("recordstatus", text, ignore.case = TRUE), info = text)
})

test_that("E2E: an all-lowercase geographicorigin header opens the tab with one sentence", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app <- create_app_driver(create_test_app(), "e2e_changed_cols_geographic")
  on.exit(app$stop(), add = TRUE)

  ped <- nprcgenekeepr::examplePedigree
  upload_fixture(app, write_header_fixture(
    add = list(geographicorigin = rep("India", nrow(ped)))
  ))

  text <- changed_columns_text(app)
  expect_match(
    text,
    "Change: The column changed from: geographicorigin to geographicOrigin.",
    fixed = TRUE
  )
})
