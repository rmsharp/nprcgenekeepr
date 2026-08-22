# Helper functions for shinytest2 E2E tests
# These utilities provide reliable waiting mechanisms using data-ready attributes

#' Wait for a module container to signal data-ready state
#'
#' Polls the data-ready attribute of a module container until it becomes "true"
#' or the timeout is reached.
#'
#' @param app ShinyDriver2 app object
#' @param selector CSS selector for the module container (e.g., "#input-moduleContainer")
#' @param timeout Maximum wait time in milliseconds (default 30000)
#' @param poll_interval Polling interval in milliseconds (default 500)
#' @return TRUE if ready, FALSE if timeout
wait_for_data_ready <- function(app, selector, timeout = 30000, poll_interval = 500) {
  start_time <- Sys.time()
  elapsed <- 0

  while (elapsed < timeout) {
    # Check data-ready attribute via JavaScript
    is_ready <- tryCatch({
      result <- app$get_js(sprintf(
        "var el = document.querySelector('%s'); el ? el.getAttribute('data-ready') : null",
        selector
      ))
      identical(result, "true")
    }, error = function(e) FALSE)

    if (is_ready) {
      return(TRUE)
    }

    Sys.sleep(poll_interval / 1000)
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs")) * 1000
  }

  FALSE
}

#' Wait for Shiny to become idle
#'
#' Waits for Shiny's busy indicator to clear, indicating no pending operations.
#'
#' @param app ShinyDriver2 app object
#' @param timeout Maximum wait time in milliseconds (default 10000)
#' @return TRUE if idle, FALSE if timeout
wait_for_idle <- function(app, timeout = 10000) {
  start_time <- Sys.time()
  elapsed <- 0

  while (elapsed < timeout) {
    is_idle <- tryCatch({
      result <- app$get_js(
        "!document.querySelector('html').classList.contains('shiny-busy')"
      )
      isTRUE(result)
    }, error = function(e) FALSE)

    if (is_idle) {
      return(TRUE)
    }

    Sys.sleep(0.2)
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs")) * 1000
  }

  FALSE
}

#' Wait for an element to exist in the DOM
#'
#' @param app ShinyDriver2 app object
#' @param selector CSS selector for the element
#' @param timeout Maximum wait time in milliseconds (default 10000)
#' @return TRUE if element exists, FALSE if timeout
wait_for_element <- function(app, selector, timeout = 10000) {
  start_time <- Sys.time()
  elapsed <- 0

  while (elapsed < timeout) {
    exists <- tryCatch({
      result <- app$get_js(sprintf(
        "document.querySelector('%s') !== null",
        selector
      ))
      isTRUE(result)
    }, error = function(e) FALSE)

    if (exists) {
      return(TRUE)
    }

    Sys.sleep(0.2)
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs")) * 1000
  }

  FALSE
}

#' Get the data-ready attribute value for a module
#'
#' @param app ShinyDriver2 app object
#' @param selector CSS selector for the module container
#' @return The data-ready attribute value or NULL
get_data_ready_state <- function(app, selector) {
  tryCatch({
    app$get_js(sprintf(
      "var el = document.querySelector('%s'); el ? el.getAttribute('data-ready') : null",
      selector
    ))
  }, error = function(e) NULL)
}

#' Check if a module is ready
#'
#' @param app ShinyDriver2 app object
#' @param module_id The module namespace ID (e.g., "input", "pedigree")
#' @return TRUE if the module's data-ready attribute is "true"
is_module_ready <- function(app, module_id) {
  selector <- sprintf("#%s-moduleContainer", module_id)
  state <- get_data_ready_state(app, selector)
  identical(state, "true")
}

#' Wait for a specific module to be ready
#'
#' Convenience wrapper that constructs the selector from module ID.
#'
#' @param app ShinyDriver2 app object
#' @param module_id The module namespace ID (e.g., "input", "pedigree")
#' @param timeout Maximum wait time in milliseconds (default 30000)
#' @return TRUE if ready, FALSE if timeout
wait_for_module_ready <- function(app, module_id, timeout = 30000) {
  selector <- sprintf("#%s-moduleContainer", module_id)
  wait_for_data_ready(app, selector, timeout = timeout)
}

#' Upload a file and wait for QC processing to complete
#'
#' Helper function that handles file upload and waits for the input module
#' to signal data-ready.
#'
#' @param app ShinyDriver2 app object
#' @param file_path Path to the file to upload
#' @param file_input_id The file input ID (without namespace prefix)
#' @param button_id The action button ID to trigger processing (without namespace prefix)
#' @param module_id The module namespace ID (default "dataInput", the namespace
#'   under which appUI.R mounts modInputUI)
#' @param timeout Maximum wait time in milliseconds (default 30000)
#' @return TRUE if upload and processing succeeded, FALSE otherwise
upload_and_wait <- function(app, file_path, file_input_id = "pedigreeFileOne",
                             button_id = "getData", module_id = "dataInput",
                             timeout = 30000) {
  tryCatch({
    # Upload the file to the namespaced file input (e.g. dataInput-pedigreeFileOne),
    # deriving the id from module_id/file_input_id rather than hardcoding it.
    upload_args <- stats::setNames(
      list(file_path), sprintf("%s-%s", module_id, file_input_id)
    )
    do.call(app$upload_file, upload_args)

    # Click the process button
    app$click(sprintf("%s-%s", module_id, button_id))

    # Wait for processing to complete
    wait_for_module_ready(app, module_id, timeout = timeout)
  }, error = function(e) {
    FALSE
  })
}

#' Get standard test data file path
#'
#' Returns the path to a test data file in inst/extdata/examples.
#'
#' @param filename The name of the test file
#' @return Full path to the test file
get_test_data_path <- function(filename) {
  system.file("extdata", "examples", filename, package = "nprcgenekeepr")
}

#' Locate the Shiny app directory for the shinytest2 E2E tests
#'
#' The end-to-end tests drive the modular GeneKeepR app (appUI()/appServer)
#' through shinytest2::AppDriver, which needs a directory containing an
#' `app.R`. That app lives at inst/shinytest/app.R.
#'
#' These browser-based tests are slow, require Chrome, and have not yet been
#' validated end to end (their completion depends on the modular-vs-monolith
#' app consolidation; see the project backlog / GitHub issues). They are
#' therefore OPT-IN: unless the environment variable NPRC_RUN_E2E is set to
#' "true", this helper skips the calling test. That keeps `devtools::test()`
#' and CI green while leaving the E2E suite one environment variable away from
#' running. Note the per-test `skip_if_not_installed("shinytest2")` /
#' `skip_if_not_installed("chromote")` / `skip_on_cran()` guards remain in
#' force; this helper adds the opt-in gate on top of them.
#'
#' @return Path to the directory containing the app's `app.R`. Only returned
#'   when E2E tests are opted in via NPRC_RUN_E2E="true"; otherwise the calling
#'   test is skipped (this function does not return).
create_test_app <- function() {
  if (!identical(Sys.getenv("NPRC_RUN_E2E"), "true")) {
    testthat::skip(
      "End-to-end Shiny tests are opt-in; set NPRC_RUN_E2E=true to run them."
    )
  }
  system.file("shinytest", package = "nprcgenekeepr")
}

# ---------------------------------------------------------------------------
# AppDriver construction + navigation helpers (Phase 8a, GitHub issue #39)
#
# These drive the modular GeneKeepR app through shinytest2::AppDriver in the
# opt-in E2E suite (test-e2e-*/test-app-*). Signatures are derived from the call
# sites across tests/testthat (docs/planning/phase8-e2e-harness-subplan.md sec 4).
# The *_safe helpers never throw: they return a safe default so a missing
# selector self-skips rather than erroring (matching the test code's
# `if (!success) skip(...)` idiom).
# ---------------------------------------------------------------------------

# Shared AppDriver load/idle timeout budget (milliseconds).
E2E_TIMEOUT <- 30000L

#' Construct an AppDriver for the modular app
#'
#' height/width are named parameters (not just absorbed by `...`) so a per-test
#' override (e.g. boundary-conditions.R passing height=/width=) binds here
#' instead of duplicating the defaults in the AppDriver$new() call. `...`
#' forwards any other AppDriver argument (e.g. seed).
#'
#' @param app_dir Directory containing the app's app.R (from create_test_app()).
#' @param name AppDriver instance name (used for logs).
#' @param height,width Viewport size; defaults 800x1200, overridable per test.
#' @param ... Further arguments passed to shinytest2::AppDriver$new().
#' @return A shinytest2::AppDriver object.
create_app_driver <- function(app_dir, name, height = 800, width = 1200, ...) {
  shinytest2::AppDriver$new(
    app_dir,
    name = name,
    height = height,
    width = width,
    load_timeout = E2E_TIMEOUT,
    screenshot_args = FALSE,
    ...
  )
}

#' Switch the navbarPage tab and confirm the switch actually occurred
#'
#' tab_label is the tabPanel title, which equals the mainNavbar input value
#' (appUI.R). `fallback` is accepted for call-site compatibility (109 of 137
#' calls pass a 3rd argument) but is a no-op given titles == values.
#'
#' @param app AppDriver object.
#' @param tab_label Tab title to switch to.
#' @param fallback Accepted for call-site compatibility; unused.
#' @return TRUE only if mainNavbar reads back as tab_label after the switch;
#'   FALSE on any error or a silent no-op navigation.
navigate_to_tab <- function(app, tab_label, fallback = NULL) {
  tryCatch({
    app$set_inputs(mainNavbar = tab_label)
    app$wait_for_idle(timeout = E2E_TIMEOUT)
    identical(app$get_value(input = "mainNavbar"), tab_label)
  }, error = function(e) FALSE)
}

#' Get the HTML of a selector, returning "" on error
#'
#' @param app AppDriver object.
#' @param selector CSS selector.
#' @return The element HTML, or "" if the lookup errors.
get_html_safe <- function(app, selector) {
  tryCatch(app$get_html(selector), error = function(e) "")
}

#' Click an element, returning TRUE/FALSE for success
#'
#' @param app AppDriver object.
#' @param selector CSS selector of the element to click.
#' @return TRUE if the click + idle wait succeed, FALSE on error.
click_element_safe <- function(app, selector) {
  tryCatch({
    app$click(selector = selector)
    app$wait_for_idle(timeout = E2E_TIMEOUT)
    TRUE
  }, error = function(e) FALSE)
}

#' Navigate to a navbarMenu ("More") child item (Settings/About/Help)
#'
#' The navbarMenu dropdown-navigation spike (sub-plan sec 8.2) was resolved in
#' Phase 8d: set_inputs(mainNavbar = item) DOES reach a navbarMenu("More")
#' child, i.e. app$get_value(input = "mainNavbar") reads back the child label
#' (Settings/About/Help) after the switch -- no DOM dropdown-open + click is
#' required. Delegating to navigate_to_tab() is therefore the final body.
#' Finalized in 8e-3 (issue #40): a live-DOM spike confirmed the navbarMenu
#' child becomes the lone active top-level .tab-pane (data-value == child label,
#' innerText == child content), so test-e2e-settings-about now asserts the
#' visible-pane switch via assert_active_pane(). The sub-plan sec 2.3 / 8.3
#' shallow-coverage caveat is resolved; navigate_to_tab() remains the correct
#' delegate body (no DOM dropdown-open + click needed).
#'
#' @param app AppDriver object.
#' @param item Menu item label (e.g. "Settings").
#' @return TRUE if the item is reached (per navigate_to_tab's read-back).
navigate_to_menu_item <- function(app, item) {
  navigate_to_tab(app, item)
}

#' Get all input/output values, returning list() on error
#'
#' @param app AppDriver object.
#' @return app$get_values(), or list() if it errors.
get_values_safe <- function(app) {
  tryCatch(app$get_values(), error = function(e) list())
}

# ---------------------------------------------------------------------------
# Active-pane assertion helpers (Phase 8e-1, GitHub issue #40)
#
# appUI() builds navbarPage(id = "mainNavbar",
# theme = bslib::bs_theme(version = 4L, ...)) -> Bootstrap 4. get_html/get_text
# serialize the ENTIRE hidden tree, so the dominant
# `grepl(keyword, get_html(app, "body"))` idiom passes once the app boots
# regardless of the selected tab. These helpers instead read the single VISIBLE
# top-level navbar pane via get_js against the LIVE DOM, catching a wrong-tab or
# silent-no-op navigation that the body-grepl idiom cannot. They follow the
# *_safe never-throw convention.
#
# Mechanism (8e-1 spike-confirmed; sub-plan section 2.3 + Session 37 notes): the
# modules nest their OWN tabsetPanels, so `.tab-content` is NOT unique -- there
# are ~5, one per nested tabset, each with its own active pane (so the naive
# `.tab-content > .tab-pane.active` matches ~5 and a first-match querySelector
# latches onto a nested pane). The top-level navbar tab-content is the only
# `.tab-content` that is not itself inside a `.tab-pane`; we resolve it
# structurally (no dependence on the dynamic data-tabsetid) and take its
# direct-child `.tab-pane.active`. Scoped this way, data-value tracks every
# navbar selection (incl. navbarMenu("More") children) and innerText honors CSS
# visibility (a hidden pane returns ""). See
# docs/planning/phase8e-assertion-strengthening-subplan.md sections 2.3 / 4.
# ---------------------------------------------------------------------------

# Build a self-contained JS expression that resolves the top-level navbar pane
# element `p` (the active direct child of the only non-nested .tab-content, or
# null) and returns the `read` sub-expression's value. Uses only
# closest()/children/classList/find + an arrow IIFE -- all 8e-1-spike-confirmed
# in chromote.
.active_pane_js <- function(read) {
  sprintf(paste0(
    "(() => { ",
    "const tc = Array.from(document.querySelectorAll('.tab-content'))",
    ".find(t => !t.closest('.tab-pane')); ",
    "const p = tc && Array.from(tc.children).find(",
    "c => c.classList.contains('tab-pane') && c.classList.contains('active')); ",
    "return %s; })()"), read)
}

#' innerText of the active/visible top-level navbar pane ("" on error/none)
#'
#' innerText (NOT get_html/textContent) honors CSS visibility, so hidden panes
#' contribute nothing -- this is the REAL active-pane content.
#'
#' @param app AppDriver object.
#' @return The visible active pane's innerText, or "" on error/none.
get_active_pane_text <- function(app) {
  tryCatch(app$get_js(.active_pane_js("(p && p.innerText) || ''")),
           error = function(e) "")
}

#' data-value (== tabPanel title) of the active top-level pane ("" if none/error)
#'
#' @param app AppDriver object.
#' @return The active pane's data-value attribute, or "" on error/none.
get_active_pane_value <- function(app) {
  tryCatch(
    app$get_js(.active_pane_js("(p && p.getAttribute('data-value')) || ''")),
    error = function(e) ""
  )
}

#' Block until the top-level pane with data-value == tab_label is the active one
#'
#' Resolves the BS4 fade-transition race before asserting. wait_for_js aborts on
#' timeout, so this wraps it in tryCatch to honor the never-throw convention.
#'
#' @param app AppDriver object.
#' @param tab_label Tab title (== data-value) to wait for.
#' @param timeout Maximum wait in milliseconds (default E2E_TIMEOUT).
#' @return TRUE on success, FALSE on timeout/error (never throws).
wait_for_active_pane <- function(app, tab_label, timeout = E2E_TIMEOUT) {
  # Quote the (safe, literal) title with base-R encodeString -- NOT jsonlite
  # (jsonlite is not a package dependency; do not add one just to quote a label).
  q <- encodeString(tab_label, quote = "'")
  js <- .active_pane_js(sprintf("!!p && p.getAttribute('data-value') === %s", q))
  tryCatch({
    app$wait_for_js(js, timeout = timeout)
    TRUE
  }, error = function(e) FALSE)
}

#' Assert the EXPECTED pane is active+visible AND (optionally) contains pattern
#'
#' Drop-in replacement for the get_html(app, "body") + grepl(...) tautology: it
#' asserts the NAMED pane is the active/visible one (catching a wrong-tab or
#' silent-no-op navigation) and, if pattern is supplied, that the pane's visible
#' innerText matches it. The redundant identical(get_active_pane_value, ...)
#' guard re-confirms with a direct read in case wait_for_js resolves on a
#' transitional state.
#'
#' @param app AppDriver object.
#' @param tab_label Expected active tab title (== data-value).
#' @param pattern Optional regex matched against the active pane's innerText.
#' @param ignore.case Passed to grepl (default TRUE).
#' @return TRUE iff the named pane is active/visible and (if given) its visible
#'   innerText matches pattern; FALSE otherwise. Never throws.
assert_active_pane <- function(app, tab_label, pattern = NULL,
                               ignore.case = TRUE) {
  if (!wait_for_active_pane(app, tab_label)) return(FALSE)
  if (!identical(get_active_pane_value(app), tab_label)) return(FALSE)
  if (is.null(pattern)) return(TRUE)
  grepl(pattern, get_active_pane_text(app), ignore.case = ignore.case)
}

## ---- Pedigree Diagram edge/waypoint-chain helpers (S622) ----------------
##
## Both helpers below exist because a raw DOM edge is not a stable proxy for
## "one logical line" in the pedigree diagram widget: R/makePedigreeDiagramData.R's
## .addRectilinearWaypoints() (D2 anchor/non-anchor dogleg routing, __proj_
## nodes) and .resolveEdgeNodeCollisions() (Track 2 same-row-collision
## jogging, __jog_ nodes) both deliberately REROUTE a single logical edge
## through 1+ waypoint nodes while preserving that edge's own color/width/
## label on every resulting segment (D10's "preserve, never blanket-reset"
## rule, unit-tested directly in test_makePedigreeMatingLayout.R). A test
## that counts raw rows or checks a single direct hop therefore overcounts
## or mistargets by however many of the edges it cares about happen to be
## routed through waypoints on the fixture in question -- a count with no
## reason to stay fixed release to release (found S622: a real-fixture
## raw count went 82 -> 101 across the Walker/BJL positioning-engine
## cutover purely from it reshuffling which edges collide, while the true
## logical-line count, 56, was unchanged throughout and pre-dated the
## cutover). Both helpers collapse __jog_/__proj_ waypoint hops back into
## the single logical line/chain they represent.

#' Count DISTINCT logical edge "lines" of a given color in the live
#' pedigree diagram widget, collapsing any __jog_/__proj_ waypoint chain
#' back into the ONE logical line it represents.
#'
#' Groups same-colored edges that share a waypoint endpoint (a __jog_ or
#' __proj_ node is always degree-2 within a single color-filtered chain,
#' by construction of how each is spliced in) -- so 2 logical lines that
#' happen to share a NON-waypoint endpoint (e.g. a mating unit's 2 mate
#' edges converging on the same __union_ node, or one individual sitting
#' in 2 different consanguineous unions) are correctly kept distinct,
#' since union-ing only ever happens through a waypoint node.
#'
#' @param app AppDriver object.
#' @param widget_id CSS id of the visNetwork htmlwidget container (no
#'   leading '#').
#' @param color The vis.js edge `color` value to match (e.g. "#D55E00").
#' @return A list(count = integer, uniform_width = the single width value
#'   shared by every matched edge, or "mixed" if they differ) -- or NULL
#'   if the widget instance was not found (caller should skip()).
count_colored_edge_lines <- function(app, widget_id, color) {
  js <- sprintf(paste0(
    "(() => { const w = HTMLWidgets.find('#%s'); ",
    "if (!w) return 'null'; ",
    "const edges = w.network.body.data.edges.get(); ",
    "const marked = edges.filter(e => e.color === '%s'); ",
    "const isWaypoint = id => typeof id === 'string' && ",
    "  (id.indexOf('__jog_') === 0 || id.indexOf('__proj_') === 0); ",
    "const parent = {}; ",
    "const find = x => { if (!(x in parent)) parent[x] = x; ",
    "  return parent[x] === x ? x : (parent[x] = find(parent[x])); }; ",
    "const unite = (a, b) => { const ra = find(a), rb = find(b); ",
    "  if (ra !== rb) parent[ra] = rb; }; ",
    "const byWaypoint = {}; ",
    "marked.forEach((e, i) => { find(i); ",
    "  [e.from, e.to].forEach(n => { if (isWaypoint(n)) { ",
    "    (byWaypoint[n] = byWaypoint[n] || []).push(i); } }); }); ",
    "Object.values(byWaypoint).forEach(idxs => { ",
    "  for (let k = 1; k < idxs.length; k++) unite(idxs[0], idxs[k]); }); ",
    "const roots = new Set(marked.map((_, i) => find(i))); ",
    "const widths = new Set(marked.map(e => e.width)); ",
    "return roots.size + ':' + (widths.size === 1 ? [...widths][0] : 'mixed'); })()"
  ), widget_id, color)
  result <- app$get_js(js)
  if (identical(result, "null")) return(NULL)
  parts <- strsplit(result, ":", fixed = TRUE)[[1L]]
  list(count = as.integer(parts[1L]), uniform_width = parts[2L])
}

#' Walk a labeled edge chain in the live pedigree diagram widget from a
#' starting node to its real terminus, collapsing any __jog_/__proj_
#' waypoint hops along the way.
#'
#' @param app AppDriver object.
#' @param widget_id CSS id of the visNetwork htmlwidget container (no
#'   leading '#').
#' @param label The vis.js edge `label` value to follow (e.g. "MZ").
#' @param start_id The real node id to start the walk from.
#' @return The terminal (non-waypoint) node id reached by following
#'   label-matching edges from start_id -- returns start_id unchanged if
#'   no label-matching edge touches it -- or NULL if the widget instance
#'   was not found (caller should skip()).
get_edge_chain_terminus <- function(app, widget_id, label, start_id) {
  js <- sprintf(paste0(
    "(() => { const w = HTMLWidgets.find('#%s'); ",
    "if (!w) return 'null'; ",
    "const edges = w.network.body.data.edges.get(); ",
    "const chain = edges.filter(e => e.label === '%s'); ",
    "const isWaypoint = id => typeof id === 'string' && ",
    "  (id.indexOf('__jog_') === 0 || id.indexOf('__proj_') === 0); ",
    "let cur = '%s', prevIdx = -1; ",
    "while (true) { ",
    "  const opts = chain.map((e, i) => ({e: e, i: i})).filter(o => ",
    "    o.i !== prevIdx && (o.e.from === cur || o.e.to === cur)); ",
    "  if (opts.length === 0) break; ",
    "  const next = opts[0].e.from === cur ? opts[0].e.to : opts[0].e.from; ",
    "  prevIdx = opts[0].i; cur = next; ",
    "  if (!isWaypoint(cur)) break; ",
    "} ",
    "return cur; })()"
  ), widget_id, label, start_id)
  result <- app$get_js(js)
  if (identical(result, "null")) return(NULL)
  result
}
