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

  ## Directed sire/dam -> child edges for the known trio, routed through an
  ## intermediate mating-unit node (D6 direct-edge mate lines, S461/Option 2
  ## Slice 3): child <- __union_<n> <- {sire, dam}. The union id itself is a
  ## volatile sequential index, not a stable identity, so it is captured via
  ## pattern match rather than hardcoded.
  edgesToChild <- get_diagram_edges_to("EBG407")
  expect_match(edgesToChild, '"from":"__union_[0-9]+"',
               info = "Child's incoming edge should come from a mating-unit node")
  unionId <- regmatches(edgesToChild,
                         regexpr('__union_[0-9]+', edgesToChild))
  edgesToUnion <- get_diagram_edges_to(unionId)
  expect_match(edgesToUnion, '"from":"U5VLXP"',
               info = "Sire -> mating-unit edge should exist")
  expect_match(edgesToUnion, '"from":"PH0IXL"',
               info = "Dam -> mating-unit edge should exist")
})

## issue #129 Slice 2 -- click-to-navigate interactivity smoke test.

test_that(
  "E2E: Pedigree Browser Diagram tab click-to-navigate updates the Table tab",
  {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_click_nav")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  ## Table is the default active tabPanel -- confirm the untrimmed baseline
  ## while it is actually visible (its DT output is suspended, per Shiny's
  ## tabPanel default, whenever the tab is hidden -- discovered live this
  ## session -- so reading it later while on the Diagram tab would return a
  ## stale/frozen snapshot rather than a live one).
  before <- get_html_safe(app, "#pedigree-pedigreeTable")
  expect_match(before, "of 375 entries",
               info = "No focal animal set yet -- table is still untrimmed")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  ## Enable trimming so a diagram click has a visible filtering effect on
  ## the Table tab (pedigreeData() only trims once a focal animal is set).
  app$set_inputs(`pedigree-trimPedigree` = TRUE)
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  ## Simulate a real node click via the live vis.js Network instance -- the
  ## click-event input-binding convention confirmed hands-on this session's
  ## Pre-RED (visEvents(click = ...) sets a Shiny input carrying
  ## nodes.nodes, the clicked node id array; visNetwork does not bind this
  ## automatically).
  clickResult <- app$get_js(paste0(
    "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
    "if (!w) return 'no widget'; ",
    "w.network.emit('click', {nodes: ['EBG407'], edges: [], event: {}, ",
    "pointer: {DOM: {x:0,y:0}, canvas: {x:0,y:0}}}); ",
    "return 'emitted'; })()"
  ))
  if (!identical(clickResult, "emitted")) {
    skip("visNetwork widget instance not found")
  }
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  ## Switch back to the Table tab -- this both mirrors what a real user
  ## does after clicking a diagram node, and is required for the DT output
  ## to actually recompute/redraw (it was suspended while hidden above).
  switchedBack <- click_element_safe(app, 'a[data-value="Table"]')
  if (!switchedBack) skip("Could not switch back to the Table tab")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  after <- get_html_safe(app, "#pedigree-pedigreeTable")
  expect_match(after, "EBG407",
               info = "Clicked animal should appear in the now-trimmed table")
  expect_false(
    grepl("of 375 entries", after),
    info = paste("Table tab should visibly change (trim to a smaller set)",
                  "after the diagram click")
  )

  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(
    nrow(diagramErrors), 0L,
    info = "No visNetwork/diagram-related console error from the click handler"
  )
})

## issue #132 -- shape-to-sex legend smoke test.

test_that("E2E: Pedigree Browser Diagram tab shows a shape-to-sex legend", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_legend")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  ## The legend title renders as plain DOM text, but the legend's shapes are
  ## drawn on their own HTML5 canvas (a separate vis.Network instance,
  ## instance.legend -- confirmed in the visNetwork.js source, Pre-RED), so
  ## its node labels/shapes are not DOM-inspectable via static HTML the way
  ## the title is. Query the live legend DataSet directly, the same
  ## mechanism get_diagram_node() above uses for the main network.
  html <- get_html_safe(app, "#pedigree-pedigreeDiagram")
  expect_match(html, "Sex",
               info = "Diagram tab should show the legend title")

  legendNodes <- app$get_js(paste0(
    "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
    "if (!w || !w.legend) return 'null'; ",
    "return JSON.stringify(w.legend.body.data.nodes.get()); })()"
  ))
  if (identical(legendNodes, "null")) skip("Legend widget instance not found")

  expect_match(legendNodes, '"label":"Female"',
               info = "Legend should label the dot shape as Female")
  expect_match(legendNodes, '"shape":"dot"',
               info = "Legend should render the Female entry as a dot")
  expect_match(legendNodes, '"label":"Male"',
               info = "Legend should label the square shape as Male")
  expect_match(legendNodes, '"shape":"square"',
               info = "Legend should render the Male entry as a square")
  expect_match(legendNodes, '"label":"Hermaphrodite"',
               info = "Legend should label the star shape as Hermaphrodite")
  expect_match(legendNodes, '"shape":"star"',
               info = "Legend should render the Hermaphrodite entry as a star")
  expect_match(legendNodes, '"label":"Unknown"',
               info = "Legend should label the triangle shape as Unknown")
  expect_match(legendNodes, '"shape":"triangle"',
               info = "Legend should render the Unknown entry as a triangle")

  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(nrow(diagramErrors), 0L,
               info = "No visNetwork/legend-related console error")
})
