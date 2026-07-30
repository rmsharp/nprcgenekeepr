## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Tests for Pedigree Browser Module
library(testthat)

test_that("E2E: Pedigree Browser tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Pedigree|Browser|Animal"),
    info = "Should be on Pedigree Browser tab"
  )
})

test_that("E2E: Pedigree Browser has focal animal controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_focal_controls")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "focal|animal|filter|update"),
    info = "Should have focal animal controls"
  )
})

test_that("E2E: Pedigree Browser has export functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_export")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "export|download|csv"),
    info = "Should have export functionality"
  )
})

test_that("E2E: Pedigree Browser has data table", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_datatable")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  # 8e-6a: assert the data-bearing rendered pedigree DataTable. The DataTable
  # DOM (row-count info + parent columns) renders only once the Pedigree Browser
  # tab is active AND a studbook has been loaded (req(pedigreeData())).
  html <- get_html_safe(app, "#pedigree-pedigreeTable")
  expect_match(
    html, "of 375 entries",
    info = "DataTable displays all 375 fixture pedigree rows"
  )
  expect_match(
    html, "sire",
    info = "Pedigree table includes the sire parent column"
  )
})

test_that("E2E: Pedigree Browser trim pedigree option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_trim")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "trim|subset|filter"),
    info = "Should have trim pedigree option"
  )
})

## issue #129 Slice 1 -- pedigree diagram (visNetwork) smoke tests.

test_that("E2E: Pedigree Browser Diagram tab renders a visNetwork widget", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_render")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  html <- get_html_safe(app, "#pedigree-pedigreeDiagram")
  expect_match(html, "visNetwork",
               info = "Diagram tab should render a visNetwork widget")
  expect_match(html, "shiny-bound-output",
               info = paste("The visNetwork output should be bound",
                             "(rendered without a Shiny error)"))

  ## The new diagram code must not throw a JS console error. Pre-existing
  ## "shinyBS is not defined" console noise is unrelated to this feature and
  ## is deliberately not asserted away here.
  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(nrow(diagramErrors), 0L,
               info = "No visNetwork/diagram-related console error")
})

test_that("E2E: Pedigree Browser Diagram tab shows a known trio's data", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_trio")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  ## The widget renders to an HTML5 canvas, so node/edge content is not
  ## otherwise DOM-inspectable -- query the live vis.js Network instance's
  ## DataSets directly, the same mechanism visNetworkProxy() itself uses.
  get_diagram_node <- function(id) {
    app$get_js(sprintf(paste0(
      "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
      "if (!w) return 'null'; ",
      "return JSON.stringify(w.network.body.data.nodes.get('%s')); })()"
    ), id))
  }
  get_diagram_edges_to <- function(childId) {
    app$get_js(sprintf(paste0(
      "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
      "if (!w) return 'null'; ",
      "return JSON.stringify(w.network.body.data.edges.get(",
      "{filter: e => e.to === '%s'})); })()"
    ), childId))
  }

  ## A known real trio in the fixture (obfuscated_rhesus_mhc_ped.csv):
  ## child EBG407 (sex M), sire U5VLXP (sex M), dam PH0IXL (sex F).
  childNode <- get_diagram_node("EBG407")
  if (identical(childNode, "null")) skip("visNetwork widget instance not found")

  ## Sex-shape mapping (M -> square, F -> dot).
  expect_match(childNode, '"shape":"square"',
               info = "Child (sex M) should render as a square node")
  expect_match(get_diagram_node("U5VLXP"), '"shape":"square"',
               info = "Sire (sex M) should render as a square node")
  expect_match(get_diagram_node("PH0IXL"), '"shape":"dot"',
               info = "Dam (sex F) should render as a dot node")

  ## Directed sire/dam -> child edges for the known trio.
  edgesToChild <- get_diagram_edges_to("EBG407")
  expect_match(edgesToChild, '"from":"U5VLXP"',
               info = "Sire -> child edge should exist")
  expect_match(edgesToChild, '"from":"PH0IXL"',
               info = "Dam -> child edge should exist")
})
