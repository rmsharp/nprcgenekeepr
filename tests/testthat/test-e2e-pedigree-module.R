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

  ## Track 2 flips the default to "rectilinear" -- pin "direct" explicitly:
  ## this test's own edge-structure assertions below are specifically
  ## about the D6 direct-edge mate-line convention (child <- __union_<n>
  ## <- {sire, dam}), not the rectilinear waypoint-routed equivalent.
  app$set_inputs(`pedigree-pedigreeEdgeStyle` = "direct")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

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

## BACKLOG.md Housekeeping -- affected-status shading defect (found S552,
## fixed S554): affected == TRUE renders filled (D8 color); FALSE/NA must
## render open/unfilled (white), matching kinship2's own convention, not
## visNetwork's own default fill.

test_that(
  "E2E: Pedigree Browser Diagram tab shades affected == TRUE individuals
   filled and leaves FALSE/NA individuals open (unfilled), matching
   pedigree drawing convention", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_affected")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples",
                         "obfuscated_rhesus_mhc_ped_affected.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  ## Returns the node's color.background directly (a plain string), not the
  ## full node JSON -- avoids adding a jsonlite dependency just to parse one
  ## field (helper-shinytest2.R's own established precedent: this package
  ## does not depend on jsonlite, matching devtools::check()'s "unstated
  ## dependencies in tests" guard).
  get_node_color <- function(id) {
    app$get_js(sprintf(paste0(
      "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
      "if (!w) return 'null'; ",
      "const n = w.network.body.data.nodes.get('%s'); ",
      "if (!n) return 'null'; ",
      "return (n.color && n.color.background) ? n.color.background : ",
      "'null'; })()"
    ), id))
  }

  ## obfuscated_rhesus_mhc_ped_affected.csv's own known values: 677E7M is
  ## affected == TRUE, BRI2MW is affected == FALSE, MND3AC is affected == NA.
  trueColor <- get_node_color("677E7M")
  if (identical(trueColor, "null")) skip("visNetwork widget instance not found")
  falseColor <- get_node_color("BRI2MW")
  naColor <- get_node_color("MND3AC")

  expect_equal(trueColor, "#CC79A7",
              info = "affected == TRUE should render filled with the D8 color")
  expect_equal(falseColor, "#FFFFFF",
              info = paste(
                "affected == FALSE should render open/unfilled (white), not",
                "visNetwork's own default fill -- the reported defect"
              ))
  expect_equal(naColor, "#FFFFFF",
              info = paste(
                "affected == NA (unknown) should render open/unfilled",
                "(white), matching kinship2's own unfilled convention"
              ))

  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(nrow(diagramErrors), 0L,
               info = "No visNetwork/diagram-related console error")
})

## S1028 -- deceased marker. An animal whose `status` reads DECEASED is drawn
## with a diagonal slash through its symbol, and no other animal is (owner
## ruling S1028: the exit date cannot say, it is filled for a shipment too).
## The slash is stroked on the widget's canvas by an afterDrawing handler, so
## the unit tests can only read the handler's text; the first test below reads
## the node field the handler keys on AND the canvas pixels at each node's
## centre, which the slash crosses and which is otherwise the node's white
## fill. The second test is the legend: a "Deceased" row joins it, and the
## owner (S1028) does not accept a legend whose labels run over the next
## symbol, which the 10-row legend already did before this row existed (each
## row's box touched the next: gap 0).

## Runs `body` in the browser with a pixel reader on the Diagram canvas: `net`
## (the vis.Network), `cv` (its canvas) and `lum(x, y)`, the grey level (0
## black, 255 white) at a position in CSS pixels, and `rgb(x, y)`, its
## [r, g, b]; a pixel off the canvas counts as white, and a see-through or
## partly see-through one is read as it shows on the page's white (S1067:
## Chrome's software drawing, as on CI, draws a 1 px outline almost wholly in
## partly see-through pixels, which this reader used to count as white).
## `body` must `return` its answer.
diagram_pixel_js <- function(body) {
  paste0(
    "(() => { const net = HTMLWidgets.find('#pedigree-pedigreeDiagram')",
    ".network; const cv = net.canvas.frame.canvas; ",
    "const k = cv.width / cv.clientWidth; const ctx = cv.getContext('2d'); ",
    "const lum = (x, y) => { const px = Math.round(x * k), ",
    "py = Math.round(y * k); if (px < 0 || py < 0 || px >= cv.width || ",
    "py >= cv.height) { return 255; } ",
    "const d = ctx.getImageData(px, py, 1, 1).data; ",
    "return 255 - (d[3] / 255) * (255 - (d[0] + d[1] + d[2]) / 3); }; ",
    "const rgb = (x, y) => { const px = Math.round(x * k), ",
    "py = Math.round(y * k); if (px < 0 || py < 0 || px >= cv.width || ",
    "py >= cv.height) { return [255, 255, 255]; } ",
    "const d = ctx.getImageData(px, py, 1, 1).data; ",
    "return [d[0], d[1], d[2]].map(v => ",
    "Math.round(255 - (d[3] / 255) * (255 - v))); }; ",
    body, " })()"
  )
}

## Opens the Diagram tab on a 5-animal pedigree: A (a male, drawn as a square)
## and E (a female, drawn as a circle) are DECEASED, B is ALIVE, C is SHIPPED,
## D is UNKNOWN; as in the example pedigree, only the DECEASED and SHIPPED
## animals have an exit date. `birth` is required (see the
## isolated-individual test below). Returns "" once the widget is drawn, else
## the reason to skip. The caller owns `app` and stops it.
open_deceased_diagram <- function(app) {
  ped <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "A"),
    dam = c(NA, NA, "B", "B", "B"),
    sex = c("M", "F", "F", "M", "F"),
    birth = c("1990-01-01", "1990-01-01", "1995-01-01", "1996-01-01",
              "1997-01-01"),
    exit = c("2005-06-01", NA, "2001-03-01", NA, "2010-02-01"),
    status = c("DECEASED", "ALIVE", "SHIPPED", "UNKNOWN", "DECEASED"),
    stringsAsFactors = FALSE
  )
  open_diagram_with(app, ped)
}

## Opens the Diagram tab on `ped` (written to a CSV and uploaded through the
## Input tab). Returns "" once the widget is drawn, else the reason to skip.
open_diagram_with <- function(app, ped) {
  ped_csv <- tempfile(fileext = ".csv")
  utils::write.csv(ped, ped_csv, row.names = FALSE)
  on.exit(unlink(ped_csv), add = TRUE)

  if (!upload_and_wait(app, ped_csv)) return("Upload/QC did not complete")
  if (!navigate_to_tab(app, "Pedigree Browser", "Pedigree")) {
    return("Could not navigate to Pedigree tab")
  }
  if (!click_element_safe(app, 'a[data-value="Diagram"]')) {
    return("Could not switch to the Diagram tab")
  }
  widgetReady <- paste0(
    "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
    "return !!w && !!w.network && !!w.legend && ",
    "w.network.body.data.nodes.length > 0; })()"
  )
  ready <- tryCatch({
    app$wait_for_js(widgetReady, timeout = E2E_TIMEOUT)
    TRUE
  }, error = function(e) FALSE)
  if (!ready) return("visNetwork widget instance not found")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  ""
}

test_that(
  "E2E: Pedigree Browser Diagram tab draws a slash through the symbol of a
   DECEASED animal and through no other", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_deceased")
  on.exit(app$stop(), add = TRUE)

  skipReason <- open_deceased_diagram(app)
  if (nzchar(skipReason)) skip(skipReason)

  ## The node's deceased field as the string "true", "false" or "undefined"
  ## (a plain string, not JSON: this package does not depend on jsonlite).
  get_deceased <- function(id) {
    app$get_js(sprintf(paste0(
      "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
      "const n = w.network.body.data.nodes.get('%s'); ",
      "return n ? String(n.deceased) : 'null'; })()"
    ), id))
  }

  ## The darkest grey level (0 black, 255 white) in the 5 x 5 canvas pixels
  ## around the node's centre. An unmarked node's centre is its white fill; a
  ## marked node's centre lies on the black slash.
  get_centre_darkest <- function(id) {
    app$get_js(sprintf(diagram_pixel_js(paste0(
      "const p = net.canvasToDOM(net.getPosition('%s')); let lo = 255; ",
      "for (let i = -2; i <= 2; i++) { for (let j = -2; j <= 2; j++) { ",
      "lo = Math.min(lo, lum(p.x + i, p.y + j)); } } return lo;"
    )), id))
  }

  for (id in c("A", "E")) {
    expect_equal(get_deceased(id), "true",
                 info = sprintf("%s's status is DECEASED, so its node is flagged",
                                id))
  }
  for (id in c("B", "C", "D")) {
    expect_equal(get_deceased(id), "false",
                 info = sprintf("%s is not DECEASED, so its node is not flagged",
                                id))
  }

  for (id in c("A", "E")) {
    expect_lt(get_centre_darkest(id), 100,
              label = sprintf("darkest pixel at %s's centre", id))
  }
  for (id in c("B", "C", "D")) {
    expect_gt(get_centre_darkest(id), 200,
              label = sprintf("darkest pixel at %s's centre", id))
  }

  ## How far the slash runs past the symbol's outline, as a multiple of the
  ## outline's own distance from the centre, both along the diagonal. The
  ## slash is walked outwards from the centre up-right until the black stops
  ## (3 px of non-black); the outline is the first outline-coloured pixel
  ## walking out up-left from 5 px (clear of the slash's own width), where
  ## nothing else is drawn: the darkest pixel of the 3 x 3 around the sample
  ## below 194, half way from white (255) to the outline's blue #2B7CE9
  ## (grey 133), so at least half covered, as "black" (below 120) is half
  ## way to black (S1067; 250, any trace of colour, let the circle read up
  ## to 1.39). A circle's outline is 1 px wide at 45 degrees, and a ray
  ## along the other diagonal can pass between its pixels (the first
  ## version missed it and found the sibship bar 85 px out instead). The legend's picture runs 19
  ## of a radius of 22 out along each axis: 1.22 times the circle's outline
  ## along the diagonal. Owner, S1028: the diagram's slash must overhang its
  ## symbol by that same amount whatever the shape, a square (A) as well as
  ## a circle (E) -- a circle-sized slash stays inside a square's corners.
  ## The measurement above as browser code for diagram_pixel_js(): it
  ## defines overhang(id), the ratio for node `id` (-1 when no outline is
  ## found), for the single reading and the shifted ones below.
  overhang_js <- paste0(
    "const q = Math.SQRT1_2; ",
    "const near = (x, y) => { let lo = 255; for (let i = -1; i <= 1; i++) { ",
    "for (let j = -1; j <= 1; j++) { lo = Math.min(lo, lum(x + i, y + j)); } } ",
    "return lo; }; ",
    "const overhang = (id) => { ",
    "const c = net.canvasToDOM(net.getPosition(id)); ",
    "let lastBlack = 0; for (let t = 0; t < 300; t += 0.5) { ",
    "if (lum(c.x + t * q, c.y - t * q) < 120) { lastBlack = t; } ",
    "else if (t - lastBlack > 3) { break; } } ",
    "let outline = -1; for (let t = 5; t < 300; t += 0.5) { ",
    "if (near(c.x - t * q, c.y - t * q) < 194) { outline = t; break; } } ",
    "return outline > 0 ? lastBlack / outline : -1; }; "
  )
  get_overhang <- function(id) {
    app$get_js(diagram_pixel_js(paste0(
      overhang_js, sprintf("return overhang('%s');", id)
    )))
  }
  squareOverhang <- get_overhang("A")
  circleOverhang <- get_overhang("E")
  expect_gt(squareOverhang, 1.10, label = "slash past a square's outline")
  expect_lt(squareOverhang, 1.40, label = "slash past a square's outline")
  expect_gt(circleOverhang, 1.10, label = "slash past a circle's outline")
  expect_lt(circleOverhang, 1.40, label = "slash past a circle's outline")
  expect_lt(abs(squareOverhang - circleOverhang), 0.12,
            label = "square and circle overhang difference")

  ## S1067: the nightly run of 2026-10-26 (40286217416) read 0.37 for the
  ## circle where this Mac read 1.27. CI's Chrome draws the canvas in
  ## software, and there every pixel the reading above looks at on the
  ## circle's outline is partly see-through, which diagram_pixel_js() then
  ## counted as white, so it missed the outline and found the sibship bar
  ## 83.5 px out; this Mac read 0.37 too with Chrome started with
  ## --disable-accelerated-2d-canvas. Where a symbol falls within a pixel
  ## changes which pixels are partly see-through, so the view is moved by
  ## fifths of a pixel each way and redrawn (vis-network's redraw() paints at
  ## once), and both overhangs are read again at each of the 25 positions,
  ## as "square,circle".
  view0 <- as.numeric(strsplit(app$get_js(paste0(
    "(() => { const v = HTMLWidgets.find('#pedigree-pedigreeDiagram')",
    ".network.getViewPosition(); return v.x + ',' + v.y; })()"
  )), ",", fixed = TRUE)[[1L]])
  get_overhangs_moved <- function(dx, dy) {
    app$get_js(diagram_pixel_js(paste0(
      sprintf(paste0(
        "net.moveTo({position: {x: %f, y: %f}, scale: net.getScale(), ",
        "animation: false}); net.redraw(); "
      ), view0[[1L]] + dx, view0[[2L]] + dy),
      overhang_js, "return overhang('A') + ',' + overhang('E');"
    )))
  }
  shifts <- expand.grid(dx = seq(0, 0.8, by = 0.2), dy = seq(0, 0.8, by = 0.2))
  moved <- vapply(seq_len(nrow(shifts)), function(i) {
    as.numeric(strsplit(get_overhangs_moved(shifts$dx[[i]], shifts$dy[[i]]),
                        ",", fixed = TRUE)[[1L]])
  }, numeric(2L))
  readings <- paste0("square/circle at each view shift (dx, dy) px: ",
                     paste(sprintf("(%.1f, %.1f) %.2f/%.2f", shifts$dx,
                                   shifts$dy, moved[1L, ], moved[2L, ]),
                           collapse = "; "))
  expect_true(all(moved[1L, ] > 1.10 & moved[1L, ] < 1.40),
              label = "slash past a square's outline at every view shift",
              info = readings)
  expect_true(all(moved[2L, ] > 1.10 & moved[2L, ] < 1.40),
              label = "slash past a circle's outline at every view shift",
              info = readings)
  expect_true(all(abs(moved[1L, ] - moved[2L, ]) < 0.12),
              label = "square and circle overhang difference at every shift",
              info = readings)

  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(nrow(diagramErrors), 0L,
               info = "No visNetwork/diagram-related console error")
})

## Reads the Diagram's legend rows off the running widget.
## The legend is its own vis.Network (the widget's `legend`). A row runs
## from its symbol's top to its label's bottom, and one row's label runs
## over the next row's symbol exactly when the next row's top is above this
## one's bottom. The row's bottom is the label's own (`labelModule.size`
## top + height), NOT getBoundingBox(): that box ends 11 world units short
## of the label, so the first version of this check passed while every
## label still touched the next symbol (found S1028 in a real-app picture).
## The widget's script returns
## "scale|label;top;bottom|label;top;bottom" with the rows ordered top to
## bottom (world units, a plain string, not JSON: this package does not
## depend on jsonlite). Returns list(scale, labels, tops, bottoms).
read_legend_rows <- function(app) {
  legendRows <- app$get_js(paste0(
    "(() => { const L = HTMLWidgets.find('#pedigree-pedigreeDiagram').legend; ",
    "const rows = L.body.nodeIndices.filter(id => ",
    "L.body.nodes[id].options.label).map(id => { const n = L.body.nodes[id]; ",
    "return { label: n.options.label, top: L.getBoundingBox(id).top, ",
    "bottom: n.labelModule.size.top + n.labelModule.size.height }; }).sort(",
    "(a, b) => a.top - b.top); ",
    "return [L.getScale()].concat(rows.map(r => [r.label, r.top, ",
    "r.bottom].join(';'))).join('|'); })()"
  ))
  parts <- strsplit(legendRows, "|", fixed = TRUE)[[1L]]
  scale <- as.numeric(parts[[1L]])
  cells <- strsplit(parts[-1L], ";", fixed = TRUE)
  labels <- vapply(cells, `[[`, character(1L), 1L)
  tops <- as.numeric(vapply(cells, `[[`, character(1L), 2L))
  bottoms <- as.numeric(vapply(cells, `[[`, character(1L), 3L))
  list(scale = scale, labels = labels, tops = tops, bottoms = bottoms)
}

test_that(
  "E2E: Pedigree Browser Diagram legend has a 'Deceased' row after the
   six older ones, leaves a gap between every two labelled rows, and keeps
   its text readable", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_legend_rows")
  on.exit(app$stop(), add = TRUE)

  skipReason <- open_deceased_diagram(app)
  if (nzchar(skipReason)) skip(skipReason)

  rows <- read_legend_rows(app)
  scale <- rows$scale
  labels <- rows$labels
  tops <- rows$tops
  bottoms <- rows$bottoms

  expect_equal(labels, c("Female", "Male", "Hermaphrodite", "Unknown",
                         "Other / Unrecorded", "Affected", "Deceased"))
  ## At least 6 world units clear between one row's label and the next
  ## row's symbol.
  expect_true(length(tops) > 1L &&
                all(tops[-1L] - bottoms[-length(bottoms)] >= 6),
              info = paste("legend row gaps:",
                           toString(tops[-1L] - bottoms[-length(bottoms)])))
  ## The legend shrinks to fit its canvas; 10 rows fit at 0.68 in a 400 px
  ## diagram. Spacing the rows out must not buy the gap by making the labels
  ## smaller than that (the owner took a 500 px diagram for 11 rows, S1028).
  expect_gte(scale, 0.65)
})

## S549 Finding #2 (BACKLOG.md Housekeeping, fixed S555): consanguineous-
## mating visual marker -- kinship2's own doubled/thickened mate-line
## convention for a blood-related couple, ported to makePedigreeMatingLayout()
## as a distinct edge color/width (Okabe-Ito vermillion #D55E00, width 4).

test_that(
  "E2E: Pedigree Browser Diagram tab renders every consanguineous mating
   unit's 2 mate-line edges with the distinct #D55E00/width-4 marker,
   and no other edge", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_consanguineous")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  ## S622 fix: a raw DOM edge-count is not a stable proxy once
  ## .addRectilinearWaypoints()/.resolveEdgeNodeCollisions() route a
  ## marked edge through 1+ __proj_/__jog_ waypoint nodes -- both
  ## deliberately preserve color/width onto every resulting segment
  ## (unit-tested directly, test_makePedigreeMatingLayout.R:1360-1362),
  ## so a raw row count inflates by however many marked edges happen to
  ## be routed through waypoints on this fixture, a number with no reason
  ## to stay fixed release to release (measured this session: 82 -> 101
  ## on this exact fixture, purely from the Walker/BJL cutover
  ## reshuffling which edges collide -- neither value is 56, and this
  ## bug PRE-DATES Walker/BJL: confirmed present, same shape, on the
  ## pre-cutover 08-18 nightly CI run). count_colored_edge_lines()
  ## (helper-shinytest2.R) collapses __jog_/__proj_ waypoint chains back
  ## into the single logical line each represents, which stays exactly
  ## 56 regardless of how the positioning engine routes them (re-derived
  ## directly against the live production code this session, not
  ## hand-derived: raw 103 rows collapse to exactly 56 components once
  ## both waypoint prefixes are treated as pass-through).
  marked <- count_colored_edge_lines(app, "pedigree-pedigreeDiagram", "#D55E00")
  if (is.null(marked)) skip("visNetwork widget instance not found")

  ## obfuscated_rhesus_mhc_ped.csv has 28 genuinely consanguineous mating
  ## units (confirmed directly via kinship(sire, dam) > 0 on the raw
  ## fixture, independent of the app) -- each contributes exactly 2
  ## marked mate-line edges.
  expect_equal(marked$count, 56L,
               info = "every consanguineous union's 2 mate edges marked")
  expect_equal(marked$uniform_width, "4")

  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(nrow(diagramErrors), 0L,
               info = "No visNetwork/diagram-related console error")
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

## issue #136 Slice 2 -- "Show Names on Diagram" toggle.

test_that(
  "E2E: Pedigree Browser Diagram tab's show-names toggle augments a real
   individual's label with its name, off by default", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_names")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples",
                         "obfuscated_rhesus_mhc_ped_name.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  get_diagram_node <- function(id) {
    app$get_js(sprintf(paste0(
      "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
      "if (!w) return 'null'; ",
      "return JSON.stringify(w.network.body.data.nodes.get('%s')); })()"
    ), id))
  }

  ## BRI2MW is the fixture's row-1 individual, deliberately given a name
  ## long enough to exercise D10's truncation (D9's geometry stress case).
  before <- get_diagram_node("BRI2MW")
  if (identical(before, "null")) skip("visNetwork widget instance not found")
  expect_match(before, '"label":"BRI2MW"',
               info = "Off by default -- id-only label with a name column present")

  app$set_inputs(`pedigree-pedigreeShowNames` = TRUE)
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  after <- get_diagram_node("BRI2MW")
  expect_match(after, "BRI2MW", fixed = TRUE,
               info = "Toggled on -- label still carries the id")
  expect_match(after, "Grand-Champion-\\.\\.\\.",
               info = "Toggled on -- augmented, truncated label (D3/D10)")
  expect_match(after, "Name:</b> Grand-Champion-Xerxes-Constantinopolous",
               info = "Tooltip carries the full, un-truncated name (D10)")

  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(nrow(diagramErrors), 0L,
               info = "No visNetwork/diagram-related console error")
})

test_that(
  "E2E: Pedigree Browser Diagram tab's show-names toggle SURVIVES a later,
   unrelated pedigreeDiagramUI re-render (switching edgeStyle) -- a real
   defect found via live verification this session: renderUI() rebuilds
   the checkboxInput from scratch on every re-render (any dependency
   change, not just its own), so a hardcoded default would silently
   discard an already-on toggle; the fix mirrors the pre-existing
   edgeStyle radioButtons' own self-referential 'selected = style'
   pattern. A shiny::testServer() unit test cannot pin this regression --
   it never simulates the real client round-trip that is the actual
   failure mechanism -- so this live AppDriver test is the permanent
   coverage for it (see test_modPedigree.R's NOTE alongside the
   useLabels-pin test for the full explanation).", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_names_survive")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples",
                         "obfuscated_rhesus_mhc_ped_name.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  get_diagram_node <- function(id) {
    app$get_js(sprintf(paste0(
      "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
      "if (!w) return 'null'; ",
      "return JSON.stringify(w.network.body.data.nodes.get('%s')); })()"
    ), id))
  }

  app$set_inputs(`pedigree-pedigreeShowNames` = TRUE)
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  onDirect <- get_diagram_node("BRI2MW")
  if (identical(onDirect, "null")) skip("visNetwork widget instance not found")
  expect_match(onDirect, "Grand-Champion",
               info = "Name shown once toggled on (direct style)")

  ## The regression: switching edgeStyle re-triggers pedigreeDiagramUI's
  ## renderUI(), which must NOT silently reset the toggle.
  app$set_inputs(`pedigree-pedigreeEdgeStyle` = "rectilinear")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  onRectilinear <- get_diagram_node("BRI2MW")
  expect_match(onRectilinear, "Grand-Champion",
               info = paste(
                 "Name must still show after switching edgeStyle -- this is",
                 "the exact defect found live: the toggle silently reset"
               ))

  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(nrow(diagramErrors), 0L,
               info = "No visNetwork/diagram-related console error")
})

## Issue #137 Slice 3 -- twin/zygosity connectors, uploaded via the
## twinRelationsFile sidecar (modPedigreeUI's static UI) and gated by the
## "Show Twin Connectors" toggle.

test_that(
  "E2E: Pedigree Browser Diagram tab renders twin connector edges once a
   twinRelations sidecar file is uploaded and the toggle is switched on", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_twins")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples",
                         "obfuscated_rhesus_mhc_ped_twins.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  ## twinRelationsFile lives in modPedigreeUI's STATIC UI (never inside the
  ## Diagram tab's dynamic renderUI block -- Learning 490's file-input
  ## corollary: a fileInput has no value= a fresh render could read back),
  ## so it can be uploaded before or after switching to the Diagram tab.
  twinRelationsFixture <- system.file(
    "extdata", "examples", "obfuscated_rhesus_mhc_twin_relations.csv",
    package = "nprcgenekeepr"
  )
  app$upload_file(`pedigree-twinRelationsFile` = twinRelationsFixture)
  app$set_inputs(`pedigree-pedigreeShowTwinConnectors` = TRUE)
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  get_diagram_edges_touching <- function(id) {
    app$get_js(sprintf(paste0(
      "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
      "if (!w) return 'null'; ",
      "return JSON.stringify(w.network.body.data.edges.get(",
      "{filter: e => e.from === '%s' || e.to === '%s'})); })()"
    ), id, id))
  }

  ## E06FRB/HV7LZ3, 8GSXTQ/P844CW, BRI2MW/677E7M are the sidecar fixture's
  ## MZ/DZ/UZ pairs (obfuscated_rhesus_mhc_twin_relations.csv). A connector
  ## always targets the two individuals' REAL nodes (D7) -- confirmed here
  ## against the live widget, not just unit-asserted.
  mzEdges <- get_diagram_edges_touching("E06FRB")
  if (identical(mzEdges, "null")) skip("visNetwork widget instance not found")
  expect_match(mzEdges, '"label":"MZ"',
               info = "MZ twin connector should carry the 'MZ' label")

  ## S622 fix: a connector that .resolveEdgeNodeCollisions() reroutes
  ## around a same-row obstacle is deliberately split across 1+ __jog_
  ## waypoint nodes while every segment still carries the SAME "MZ" label
  ## (same preserve-on-split mechanism as the consanguineous-marker test
  ## above) -- so the single edge directly touching E06FRB can
  ## legitimately target a waypoint node instead of HV7LZ3, with HV7LZ3
  ## reached 1+ hops further along the SAME "MZ"-labeled chain (confirmed
  ## this session against the live production code: E06FRB -> __jog_23_a
  ## -> __jog_23_b -> HV7LZ3, all 3 segments labeled "MZ"). This bug
  ## PRE-DATES Walker/BJL too (same shape on the pre-cutover 08-18
  ## nightly CI run, just a different jog counter).
  ## get_edge_chain_terminus() (helper-shinytest2.R) follows the "MZ"
  ## chain to its real end instead of asserting a direct single-hop
  ## target.
  mzTerminus <- get_edge_chain_terminus(app, "pedigree-pedigreeDiagram",
                                         "MZ", "E06FRB")
  if (is.null(mzTerminus)) skip("visNetwork widget instance not found")
  expect_equal(mzTerminus, "HV7LZ3",
               info = "MZ connector should target the co-twin's real node")

  dzEdges <- get_diagram_edges_touching("8GSXTQ")
  expect_match(dzEdges, '"label":"DZ"',
               info = "DZ twin connector should carry the 'DZ' label")

  uzEdges <- get_diagram_edges_touching("BRI2MW")
  expect_match(uzEdges, '"label":"?"', fixed = TRUE,
               info = "UZ twin connector should carry the '?' label")

  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(nrow(diagramErrors), 0L,
               info = "No visNetwork/diagram-related console error")
})

test_that(
  "E2E: Pedigree Browser Diagram tab's twin-connector toggle SURVIVES a
   later, unrelated pedigreeDiagramUI re-render (switching edgeStyle) --
   same defect class Learning 490 found for pedigreeShowNames; the fix is
   the same self-referential-value pattern, applied to
   pedigreeShowTwinConnectors. A shiny::testServer() unit test cannot pin
   this regression for the same reason Learning 490 documents (it never
   simulates the real client round-trip that is the actual failure
   mechanism) -- this live AppDriver test is the permanent coverage.", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_twins_survive")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples",
                         "obfuscated_rhesus_mhc_ped_twins.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  twinRelationsFixture <- system.file(
    "extdata", "examples", "obfuscated_rhesus_mhc_twin_relations.csv",
    package = "nprcgenekeepr"
  )
  app$upload_file(`pedigree-twinRelationsFile` = twinRelationsFixture)
  app$set_inputs(`pedigree-pedigreeShowTwinConnectors` = TRUE)
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  get_diagram_edges_touching <- function(id) {
    app$get_js(sprintf(paste0(
      "(() => { const w = HTMLWidgets.find('#pedigree-pedigreeDiagram'); ",
      "if (!w) return 'null'; ",
      "return JSON.stringify(w.network.body.data.edges.get(",
      "{filter: e => e.from === '%s' || e.to === '%s'})); })()"
    ), id, id))
  }

  onDirect <- get_diagram_edges_touching("E06FRB")
  if (identical(onDirect, "null")) skip("visNetwork widget instance not found")
  expect_match(onDirect, '"label":"MZ"',
               info = "MZ connector visible once toggled on (direct style)")

  ## The regression: switching edgeStyle re-triggers pedigreeDiagramUI's
  ## renderUI(), which must NOT silently reset the toggle.
  app$set_inputs(`pedigree-pedigreeEdgeStyle` = "rectilinear")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  onRectilinear <- get_diagram_edges_touching("E06FRB")
  expect_match(onRectilinear, '"label":"MZ"',
               info = paste(
                 "MZ connector must still show after switching edgeStyle --",
                 "same defect class as Learning 490's pedigreeShowNames case"
               ))

  logs <- app$get_logs()
  diagramErrors <- logs[logs$level == "throw" &
                          grepl("vis|network|pedigreeDiagram", logs$message,
                                ignore.case = TRUE), ]
  expect_equal(nrow(diagramErrors), 0L,
               info = "No visNetwork/diagram-related console error")
})

## Phase 3 (Shiny UX messaging), docs/planning/pedigree-diagram-isolated-
## individual-suppression-plan.md Sec 3 Dragon 4 / Sec 4 Phase 3: confirms the
## empty-state message actually renders live in the running app -- a
## shiny::testServer() unit test (test_modPedigree.R) proves the reactive
## computes the right HTML string, but not that a real client round-trip
## (file upload -> focal-animal trim -> re-render) produces it (Phase 3E,
## SESSION_RUNNER.md).

test_that(
  "E2E: Pedigree Browser Diagram tab shows the singular empty-state
   message, not a blank widget, when focal-trimming to one isolated
   individual", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_isolated_focal")
  on.exit(app$stop(), add = TRUE)

  ## A small custom studbook: A/B/C are a connected trio, ISO is a fully
  ## isolated individual (no sire, no dam, no mate, no children). `birth` is
  ## one of getRequiredCols()'s 5 required columns -- omitting it makes
  ## qcStudbook() reject the upload and every downstream tab (Table AND
  ## Diagram) renders empty, unrelated to isolation-suppression (confirmed
  ## via a standalone diagnostic AppDriver run before adding this column).
  ped_csv <- tempfile(fileext = ".csv")
  utils::write.csv(
    data.frame(
      id = c("A", "B", "C", "ISO"),
      sire = c(NA, NA, "A", NA),
      dam = c(NA, NA, "B", NA),
      sex = c("M", "F", "F", "F"),
      birth = c("1990-01-01", "1990-01-01", "1995-01-01", "1990-01-01"),
      stringsAsFactors = FALSE
    ),
    ## na = "NA" (the default), NOT "" -- read.csv()'s default na.strings is
    ## "NA"; writing NA as an empty string round-trips as sire/dam == "" (a
    ## literal blank id), which qcStudbook() then rejects as "both a sire
    ## and a dam" (every empty-sire/-dam row collides on ""), not as
    ## unknown-parent -- confirmed directly against runQcStudbook() before
    ## settling on this fix.
    ped_csv, row.names = FALSE
  )
  on.exit(unlink(ped_csv), add = TRUE)

  loaded <- upload_and_wait(app, ped_csv)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  ## Focal-trim to the isolated individual -- the exact regression scenario
  ## named in the plan's Sec 1.2 second trigger.
  app$set_inputs(`pedigree-focalAnimalIds` = "ISO")
  app$set_inputs(`pedigree-trimPedigree` = TRUE)
  app$click("pedigree-updateFocalAnimals")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  html <- get_html_safe(app, "#pedigree-pedigreeDiagramUI")
  expect_match(html, "alert-info",
               info = "Empty-state message should use the alert-info styling")
  expect_match(html, "ISO",
               info = "Empty-state message should name the isolated individual")
  expect_match(
    html, "no pedigree relationship to diagram",
    info = "Should show the singular empty-state copy, not a blank widget"
  )
})

## S1029 -- more than one affected condition. With two or more columns whose
## names start "affected", an animal's symbol is split into equal sections,
## one per condition in file order, counter-clockwise from the top (so the
## first of two is the left half), and a section is filled with its
## condition's color where the animal is affected and left open where it is
## not or is unknown. The sections are stroked on the widget's canvas by the
## afterDrawing handler, so only the canvas pixels can say what is drawn.
## Colors: the affected pink #CC79A7, then #E69F00, #56B4E9 and #009E73.

## A (a male, a square) is affected by both conditions, B (a circle) by
## neither (both unknown), C (a circle) by the second only, D (a square) by
## neither, E (a circle) by the first only. `birth` is required (see the
## isolated-individual test below).
conditions_pedigree <- function(extra = list()) {
  ped <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "A"),
    dam = c(NA, NA, "B", "B", "B"),
    sex = c("M", "F", "F", "M", "F"),
    birth = c("1990-01-01", "1990-01-01", "1995-01-01", "1996-01-01",
              "1997-01-01"),
    affected = c(TRUE, NA, FALSE, FALSE, TRUE),
    affected2 = c(TRUE, NA, TRUE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  for (name in names(extra)) ped[[name]] <- extra[[name]]
  ped
}

## The body, for diagram_pixel_js(), that reads the colors of the pixels half a
## radius left and right of node `id`'s centre, as "r,g,b|r,g,b" (a plain
## string, not JSON).
halves_js <- function(id) {
  sprintf(paste0(
    "const p = net.canvasToDOM(net.getPosition('%s')); ",
    "const n = net.body.data.nodes.get('%s'); ",
    "const r = (n.size || 25) * net.getScale(); ",
    "return rgb(p.x - 0.5 * r, p.y).join(',') + '|' + ",
    "rgb(p.x + 0.5 * r, p.y).join(','); "
  ), id, id)
}

## Whether a pixel's "r,g,b" is within 16 of a color on every channel.
is_color <- function(rgbText, hex) {
  got <- as.numeric(strsplit(rgbText, ",", fixed = TRUE)[[1L]])
  want <- as.numeric(grDevices::col2rgb(hex))
  length(got) == 3L && all(abs(got - want) <= 16)
}

## Each animal in `expected` (id = its left and right half's colors) has those
## colors, as `read_halves(id)` reads them with halves_js().
expect_halves <- function(read_halves, expected) {
  for (id in names(expected)) {
    got <- strsplit(read_halves(id), "|", fixed = TRUE)[[1L]]
    expect_length(got, 2L)
    if (length(got) == 2L) {
      expect_true(is_color(got[[1L]], expected[[id]][[1L]]),
                  info = sprintf("%s's left half is %s, read %s", id,
                                 expected[[id]][[1L]], got[[1L]]))
      expect_true(is_color(got[[2L]], expected[[id]][[2L]]),
                  info = sprintf("%s's right half is %s, read %s", id,
                                 expected[[id]][[2L]], got[[2L]]))
    }
  }
}

test_that(
  "E2E: Pedigree Browser Diagram tab fills each section of a two-condition
   animal's circle and square with its condition's color, and leaves an
   unaffected or unknown section open", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_conditions")
  on.exit(app$stop(), add = TRUE)

  skipReason <- open_diagram_with(app, conditions_pedigree())
  if (nzchar(skipReason)) skip(skipReason)

  pink <- "#CC79A7"
  orange <- "#E69F00"
  white <- "#FFFFFF"
  expected <- list(
    A = c(pink, orange), B = c(white, white), C = c(white, orange),
    D = c(white, white), E = c(pink, white)
  )
  expect_halves(function(id) app$get_js(diagram_pixel_js(halves_js(id))),
                expected)
})

## S1029 mutation gaps (found with the mutants of the section painter): a
## painter that forgot to clip would still pass the half-colour check above,
## which reads inside the symbols, and one that forgot the section lines would
## pass it too. The sections must stay inside the outline, and the lines
## between sections are drawn for every animal, an unaffected one included.

test_that(
  "E2E: Pedigree Browser Diagram tab keeps the sections inside each symbol's
   outline and draws the section line on an unaffected animal", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_conditions_edges")
  on.exit(app$stop(), add = TRUE)

  skipReason <- open_diagram_with(app, conditions_pedigree())
  if (nzchar(skipReason)) skip(skipReason)

  ## The darkest grey level (0 black, 255 white) of the 3 pixels across at
  ## (`dx`, `dy`) from a node's centre, in units of the node's radius on
  ## screen.
  darkest_at <- function(id, dx, dy) {
    app$get_js(sprintf(diagram_pixel_js(paste0(
      "const p = net.canvasToDOM(net.getPosition('%s')); ",
      "const n = net.body.data.nodes.get('%s'); ",
      "const r = (n.size || 25) * net.getScale(); let lo = 255; ",
      "for (let i = -1; i <= 1; i++) { lo = Math.min(lo, ",
      "lum(p.x + %f * r + i, p.y + %f * r)); } return lo; "
    )), id, id, dx, dy))
  }

  ## E is a circle affected by the first condition (the left half is pink);
  ## A is a square affected by both. Just outside the left edge, where an
  ## unclipped wedge would still paint, the canvas is white.
  for (id in c("E", "A")) {
    expect_gt(darkest_at(id, -1.3, 0), 240,
              label = sprintf("darkest pixel just left of %s's outline", id))
  }
  ## D (a square) and B (a circle) are affected by nothing; the line between
  ## their two sections runs down the middle, in the outline's color.
  for (id in c("D", "B")) {
    expect_lt(darkest_at(id, 0, 0.4), 235,
              label = sprintf("darkest pixel on %s's section line", id))
  }
})

test_that(
  "E2E: Pedigree Browser Diagram tab with four conditions lists four legend
   rows in place of 'Affected', grows the canvas to 635 px, and keeps the
   legend text readable with a gap under every label", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if_not_installed("visNetwork")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_diagram_four_conditions")
  on.exit(app$stop(), add = TRUE)

  ped <- conditions_pedigree(list(
    affected3 = c(FALSE, FALSE, TRUE, TRUE, FALSE),
    affected4 = c(TRUE, FALSE, FALSE, TRUE, TRUE)
  ))
  skipReason <- open_diagram_with(app, ped)
  if (nzchar(skipReason)) skip(skipReason)

  height <- app$get_js(
    "document.querySelector('#pedigree-pedigreeDiagram').clientHeight"
  )
  expect_equal(height, 635, tolerance = 0.01)

  rows <- read_legend_rows(app)
  expect_equal(rows$labels,
               c("Female", "Male", "Hermaphrodite", "Unknown",
                 "Other / Unrecorded", "Affected", "Affected 2", "Affected 3",
                 "Affected 4", "Deceased"))
  expect_true(length(rows$tops) > 1L &&
                all(rows$tops[-1L] - rows$bottoms[-length(rows$bottoms)] >= 6),
              info = paste("legend row gaps:",
                           toString(rows$tops[-1L] -
                                      rows$bottoms[-length(rows$bottoms)])))
  expect_gte(rows$scale, 0.65)
})

## S1030 -- a script draws what the Diagram tab draws. drawPedigreeDiagram()
## returns the widget the app shows (owner ruling S1030, "One function draws
## it all"), so a page a script saves paints the same slash and sections. The
## unit tests (test_drawPedigreeDiagram.R) compare the widget text; only the
## canvas pixels can say the saved page paints them. The page is saved with
## htmlwidgets::saveWidget() and opened in headless Chrome, with no Shiny app.

test_that(
  "E2E: a page a script saves from drawPedigreeDiagram() draws the deceased
   slash and fills each condition's section, as the Diagram tab does", {
  skip_if_not_installed("chromote")
  skip_if_not_installed("htmlwidgets")
  skip_if_not_installed("visNetwork")
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_E2E"), "true"),
              "End-to-end tests are opt-in; set NPRC_RUN_E2E=true to run them.")

  ## conditions_pedigree() with E DECEASED. A (a square) is affected by both
  ## conditions, D (a square) by neither, E (a circle) by the first only, so
  ## E's right half is open and its slash runs across white.
  ped <- conditions_pedigree(list(
    status = c("ALIVE", "ALIVE", "ALIVE", "ALIVE", "DECEASED")
  ))
  ped$gen <- c(0L, 0L, 1L, 1L, 1L)
  layout <- suppressMessages(nprcgenekeepr::makePedigreeMatingLayout(ped))
  page <- tempfile(fileext = ".html")
  on.exit(unlink(page), add = TRUE)
  htmlwidgets::saveWidget(nprcgenekeepr::drawPedigreeDiagram(layout), page,
                          selfcontained = TRUE)

  ## The first Chrome launch can be slow (see getLiveRenderedPositions(),
  ## helper-live-render-positions.R).
  chromeParent <- chromote::default_chromote_object()
  if (chromeParent$default_timeout < 60) chromeParent$default_timeout <- 60
  b <- chromote::ChromoteSession$new(width = 1000L, height = 700L)
  on.exit(b$close(), add = TRUE)
  b$go_to(paste0("file://", page), timeout_ = 30, delay = 1.5)

  evaluate <- function(js) {
    b$Runtime$evaluate(js, returnByValue = TRUE)$result$value
  }
  ## diagram_pixel_js() reads the app's widget; the saved page has one widget.
  page_pixel_js <- function(body) {
    sub("#pedigree-pedigreeDiagram", ".visNetwork", diagram_pixel_js(body),
        fixed = TRUE)
  }
  drawn <- FALSE
  for (attempt in seq_len(40L)) {
    drawn <- isTRUE(evaluate(paste0(
      "(() => { const w = HTMLWidgets.find('.visNetwork'); ",
      "return !!w && !!w.network && ",
      "w.network.body.data.nodes.length > 0; })()"
    )))
    if (drawn) break
    Sys.sleep(0.25)
  }
  if (!drawn) skip("The saved page's diagram was not drawn")

  ## The darkest grey level (0 black, 255 white) of the 3 pixels across at
  ## (`dx`, `dy`) from a node's centre, in units of its radius on screen.
  darkest_at <- function(id, dx, dy) {
    evaluate(sprintf(page_pixel_js(paste0(
      "const p = net.canvasToDOM(net.getPosition('%s')); ",
      "const n = net.body.data.nodes.get('%s'); ",
      "const r = (n.size || 25) * net.getScale(); let lo = 255; ",
      "for (let i = -1; i <= 1; i++) { lo = Math.min(lo, ",
      "lum(p.x + %f * r + i, p.y + %f * r)); } return lo; "
    )), id, id, dx, dy))
  }
  ## The slash runs from bottom left to top right through the centre, so it
  ## crosses the point a third of a radius up and right of it.
  expect_lt(darkest_at("E", 0.35, -0.35), 100,
            label = "darkest pixel on E's slash (DECEASED)")
  expect_gt(darkest_at("D", 0.35, -0.35), 200,
            label = "darkest pixel at the same point of D (ALIVE)")

  pink <- "#CC79A7"
  orange <- "#E69F00"
  white <- "#FFFFFF"
  expect_halves(function(id) evaluate(page_pixel_js(halves_js(id))),
                list(A = c(pink, orange), D = c(white, white),
                     E = c(pink, white)))
})
