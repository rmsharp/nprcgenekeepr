#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Unit tests for the shinytest2 E2E driver helpers (defined in
#' helper-shinytest2.R): create_app_driver(), navigate_to_tab(),
#' get_html_safe(), click_element_safe(), navigate_to_menu_item(),
#' get_values_safe(), the E2E_TIMEOUT constant, and the active-pane helpers
#' get_active_pane_text() / get_active_pane_value() / wait_for_active_pane() /
#' assert_active_pane() (Phase 8e-1, GitHub issue #40).
#'
#' These tests are deliberately BROWSER-FREE: they exercise each helper's
#' existence, signature, and \verb{*_safe} error/success contracts using fake
#' AppDriver stubs (plain lists of functions) -- NOT a real shinytest2
#' AppDriver / Chrome. They therefore always run (no skip), unlike the
#' test-e2e-*/test-app-* files these helpers serve. This mirrors the
#' browser-free unit test of create_test_app() in test_create_test_app.R.
#'
#' Phase 8a of the Shiny-module conversion (GitHub issue #39); see
#' docs/planning/phase8-e2e-harness-subplan.R sections 4-5.
library(testthat)

# ---- Fake AppDriver stubs (no browser) -------------------------------------

# Every method throws -> proves the *_safe helpers swallow errors and return a
# safe default rather than propagating.
fake_app_throwing <- function() {
  boom <- function(...) stop("fake app: method failed")
  list(
    get_html = boom, get_values = boom, click = boom,
    wait_for_idle = boom, set_inputs = boom, get_value = boom,
    get_js = boom, wait_for_js = boom
  )
}

# Records set_inputs() and reflects them through get_value() -> proves the
# success / read-back contracts (navigation that ACTUALLY occurred).
fake_app_ok <- function() {
  state <- new.env(parent = emptyenv())
  state$inputs <- list()
  list(
    set_inputs = function(...) {
      a <- list(...)
      state$inputs[names(a)] <- a
      invisible(TRUE)
    },
    wait_for_idle = function(...) TRUE,
    get_value = function(input) state$inputs[[input]],
    click = function(...) invisible(TRUE),
    get_html = function(selector) "<body>ok</body>",
    get_values = function(...) list(mainNavbar = state$inputs[["mainNavbar"]])
  )
}

# set_inputs() is a silent no-op and get_value() never reflects the requested
# tab -> proves navigate_to_tab()'s read-back catches a silent failed navigation
# (sub-plan finding 15 / section 8.3).
fake_app_noop <- function() {
  list(
    set_inputs = function(...) invisible(TRUE),
    wait_for_idle = function(...) TRUE,
    get_value = function(input) "Home",
    click = function(...) invisible(TRUE),
    get_html = function(selector) "",
    get_values = function(...) list()
  )
}

# Simulates ONE active navbar pane (8e-1). get_js() returns the scripted
# data-value or innerText, discriminated by inspecting the JS expression
# (get_active_pane_value queries '...getAttribute("data-value")'; the text
# helper queries '...innerText'). wait_for_js() "succeeds" only when the JS
# asserts the active pane's OWN data_value (i.e. the requested tab IS active),
# otherwise it throws like a real timeout. This lets assert_active_pane()'s
# discrimination be proven without Chrome (sub-plan section 4 / 2.3).
fake_app_pane <- function(data_value = "Summary Statistics",
                          inner_text = "Export Kinship Matrix") {
  list(
    get_js = function(expr) {
      if (grepl("data-value", expr, fixed = TRUE)) return(data_value)
      if (grepl("innerText", expr, fixed = TRUE)) return(inner_text)
      ""
    },
    wait_for_js = function(expr, ...) {
      if (grepl(encodeString(data_value, quote = "'"), expr, fixed = TRUE)) {
        return(invisible(TRUE))
      }
      stop("fake app: wait_for_js timed out (requested pane not active)")
    }
  )
}

# A "liar": wait_for_js() ALWAYS succeeds, but the active pane's data-value is
# something else -> proves assert_active_pane()'s redundant
# identical(get_active_pane_value(app), tab_label) guard rejects a wait/read
# disagreement (defense beyond wait_for_active_pane alone).
fake_app_pane_liar <- function() {
  list(
    get_js = function(expr) {
      if (grepl("data-value", expr, fixed = TRUE)) return("Home")
      if (grepl("innerText", expr, fixed = TRUE)) return("home content")
      ""
    },
    wait_for_js = function(expr, ...) invisible(TRUE)
  )
}

# Records the upload_file()/click() targets and reports data-ready "true" so
# upload_and_wait()'s wait_for_module_ready() resolves immediately (no browser).
# Used to prove upload_and_wait() targets the correct "dataInput" namespace
# (sub-plan section 2.4; slice 8e-4).
fake_app_upload_recorder <- function() {
  state <- new.env(parent = emptyenv())
  state$upload_name <- NA_character_
  state$click_target <- NA_character_
  list(
    .state = state,
    upload_file = function(...) {
      state$upload_name <- names(list(...))[[1L]]
      invisible(TRUE)
    },
    click = function(selector) {
      state$click_target <- selector
      invisible(TRUE)
    },
    get_js = function(...) "true"
  )
}

# ---- E2E_TIMEOUT constant --------------------------------------------------

test_that("E2E_TIMEOUT is a single positive numeric timeout (ms)", {
  expect_true(exists("E2E_TIMEOUT"))
  expect_true(is.numeric(E2E_TIMEOUT))
  expect_length(E2E_TIMEOUT, 1L)
  expect_gt(E2E_TIMEOUT, 0)
})

# ---- Existence + signatures ------------------------------------------------

test_that("all six E2E driver helpers exist as functions", {
  for (h in c("create_app_driver", "navigate_to_tab", "get_html_safe",
              "click_element_safe", "navigate_to_menu_item", "get_values_safe")) {
    expect_true(exists(h, mode = "function"), info = h)
  }
})

test_that("create_app_driver exposes app_dir, name, overridable height/width, and ...", {
  fm <- formals(create_app_driver)
  # height/width MUST be named formals (not just absorbed by ...), so a caller's
  # height=/width= binds here instead of duplicating the AppDriver defaults
  # (boundary-conditions.R passes height=/width=). ... still absorbs other args
  # (e.g. seed=).
  expect_true(all(c("app_dir", "name", "height", "width", "...") %in% names(fm)))
  expect_equal(fm$height, 800)
  expect_equal(fm$width, 1200)
})

test_that("navigate_to_tab accepts the 3-arg (app, tab_label, fallback) call form", {
  fm <- formals(navigate_to_tab)
  expect_true(all(c("app", "tab_label", "fallback") %in% names(fm)))
  # 109 of 137 call sites pass a 3rd positional arg; fallback must default so the
  # 28 two-arg calls also work.
  expect_null(fm$fallback)
})

test_that("the remaining helpers have their call-site-derived signatures", {
  expect_equal(names(formals(get_html_safe)), c("app", "selector"))
  expect_equal(names(formals(click_element_safe)), c("app", "selector"))
  expect_equal(names(formals(navigate_to_menu_item)), c("app", "item"))
  expect_equal(names(formals(get_values_safe)), "app")
})

# ---- *_safe error contracts (throwing stub) --------------------------------

test_that("get_html_safe returns \"\" when get_html throws", {
  res <- get_html_safe(fake_app_throwing(), "body")
  expect_type(res, "character")
  expect_length(res, 1L)
  expect_identical(res, "")
})

test_that("get_values_safe returns list() when get_values throws", {
  expect_identical(get_values_safe(fake_app_throwing()), list())
})

test_that("click_element_safe returns FALSE when click throws", {
  expect_false(click_element_safe(fake_app_throwing(), "#input-getData"))
})

test_that("navigate_to_tab returns FALSE when the driver throws", {
  # 3-arg call form (positional fallback) must not error on the signature.
  expect_false(navigate_to_tab(fake_app_throwing(), "Input", "fallback"))
})

# ---- success / read-back contracts (working + no-op stubs) -----------------

test_that("navigate_to_tab returns TRUE only when navigation actually occurred", {
  expect_true(navigate_to_tab(fake_app_ok(), "Input"))
  # 3-arg form with a working app still confirms via read-back.
  expect_true(navigate_to_tab(fake_app_ok(), "Genetic Value Analysis", "Genetic Value"))
})

test_that("navigate_to_tab returns FALSE on a silent no-op navigation", {
  # The driver accepts set_inputs() but get_value() never reflects the tab ->
  # the read-back must catch it (a bare set_inputs-then-TRUE impl would wrongly
  # pass here).
  expect_false(navigate_to_tab(fake_app_noop(), "Input"))
})

test_that("click_element_safe returns TRUE on a successful click", {
  expect_true(click_element_safe(fake_app_ok(), "#goto_input"))
})

test_that("get_html_safe / get_values_safe return the driver's values on success", {
  expect_identical(get_html_safe(fake_app_ok(), "body"), "<body>ok</body>")
  expect_identical(get_values_safe(fake_app_ok()), list(mainNavbar = NULL))
})

test_that("navigate_to_menu_item returns TRUE when the menu item is reached", {
  # Provisional 8a contract: delegates to navigate_to_tab (finalized in 8d after
  # the navbarMenu spike, sub-plan section 8.2).
  expect_true(navigate_to_menu_item(fake_app_ok(), "Settings"))
})

# ---- Active-pane helpers (8e-1, GitHub issue #40) --------------------------
# get_active_pane_text / get_active_pane_value / wait_for_active_pane /
# assert_active_pane: assert against the SINGLE visible navbar pane instead of
# the whole hidden-DOM body. Browser-free here via the recording stubs above;
# the live-Chrome behavior is confirmed by the 8e-1 spike (sub-plan section 2.3).

test_that("the four active-pane helpers exist as functions", {
  for (h in c("get_active_pane_text", "get_active_pane_value",
              "wait_for_active_pane", "assert_active_pane")) {
    expect_true(exists(h, mode = "function"), info = h)
  }
})

test_that("active-pane helpers have their planned signatures", {
  expect_equal(names(formals(get_active_pane_text)), "app")
  expect_equal(names(formals(get_active_pane_value)), "app")
  expect_equal(names(formals(wait_for_active_pane)),
               c("app", "tab_label", "timeout"))
  expect_equal(names(formals(assert_active_pane)),
               c("app", "tab_label", "pattern", "ignore.case"))
  # pattern defaults to NULL (pane-only assertion); ignore.case defaults TRUE.
  expect_null(formals(assert_active_pane)$pattern)
  expect_true(isTRUE(formals(assert_active_pane)$ignore.case))
})

# -- never-throw contracts (throwing stub: get_js / wait_for_js both error) --

test_that("get_active_pane_text returns \"\" when get_js throws", {
  res <- get_active_pane_text(fake_app_throwing())
  expect_type(res, "character")
  expect_identical(res, "")
})

test_that("get_active_pane_value returns \"\" when get_js throws", {
  expect_identical(get_active_pane_value(fake_app_throwing()), "")
})

test_that("wait_for_active_pane returns FALSE when wait_for_js throws", {
  expect_false(wait_for_active_pane(fake_app_throwing(), "Input"))
})

test_that("assert_active_pane returns FALSE when the driver throws", {
  expect_false(assert_active_pane(fake_app_throwing(), "Input", "anything"))
})

# -- discrimination contracts (recording stub) ------------------------------

test_that("get_active_pane_text / get_active_pane_value read the active pane", {
  app <- fake_app_pane(data_value = "Summary Statistics",
                       inner_text = "Export Kinship Matrix")
  expect_identical(get_active_pane_value(app), "Summary Statistics")
  expect_identical(get_active_pane_text(app), "Export Kinship Matrix")
})

test_that("wait_for_active_pane is TRUE for the active pane, FALSE otherwise", {
  app <- fake_app_pane(data_value = "Summary Statistics")
  expect_true(wait_for_active_pane(app, "Summary Statistics"))
  expect_false(wait_for_active_pane(app, "Genetic Value Analysis"))
})

test_that("assert_active_pane passes only for the right pane AND right content", {
  app <- fake_app_pane(data_value = "Summary Statistics",
                       inner_text = "Export Kinship Matrix")
  # right pane + matching pattern
  expect_true(assert_active_pane(app, "Summary Statistics", "Export.*Kinship"))
  # right pane, no pattern -> pane-only assertion passes
  expect_true(assert_active_pane(app, "Summary Statistics"))
  # right pane, NON-matching pattern -> FALSE (content discrimination)
  expect_false(assert_active_pane(app, "Summary Statistics", "NoSuchText"))
  # WRONG pane (the wrong-tab defect this whole slice targets) -> FALSE
  expect_false(
    assert_active_pane(app, "Genetic Value Analysis", "Export.*Kinship"))
})

test_that("assert_active_pane catches a wait/read disagreement (identical guard)", {
  # wait_for_js 'succeeds' but the active pane's data-value is something else ->
  # the redundant identical(get_active_pane_value, tab_label) guard must reject.
  liar <- fake_app_pane_liar()
  expect_false(assert_active_pane(liar, "Summary Statistics", "anything"))
  expect_false(assert_active_pane(liar, "Summary Statistics"))
})

test_that("assert_active_pane honors ignore.case", {
  app <- fake_app_pane(data_value = "Summary Statistics",
                       inner_text = "Export Kinship Matrix")
  # default ignore.case = TRUE -> lowercase pattern matches mixed-case text
  expect_true(assert_active_pane(app, "Summary Statistics", "export kinship"))
  # ignore.case = FALSE -> case-sensitive miss
  expect_false(assert_active_pane(app, "Summary Statistics", "export kinship",
                                  ignore.case = FALSE))
})

# ---- upload_and_wait namespace (8e-4, sub-plan section 2.4) ----------------
# The input module is mounted under the "dataInput" namespace
# (appUI.R:123 modInputUI("dataInput")), so the real ids are
# #dataInput-pedigreeFileOne / #dataInput-getData -- NOT "input-*"
# (data-module="input" in modInput.R:31 is a label, not the namespace). These
# prove upload_and_wait() targets that namespace, browser-free via the recording
# stub (the helper serves the real upload flow wired in 8e-6).

test_that("upload_and_wait defaults module_id to the dataInput namespace", {
  expect_identical(formals(upload_and_wait)$module_id, "dataInput")
})

test_that("upload_and_wait uploads to and clicks the dataInput- namespaced ids", {
  rec <- fake_app_upload_recorder()
  ok <- upload_and_wait(rec, "/tmp/ped.csv")
  expect_true(ok)
  expect_identical(rec$.state$upload_name, "dataInput-pedigreeFileOne")
  expect_identical(rec$.state$click_target, "dataInput-getData")
})
