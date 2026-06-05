#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Unit tests for the shinytest2 E2E driver helpers (defined in
#' helper-shinytest2.R): create_app_driver(), navigate_to_tab(),
#' get_html_safe(), click_element_safe(), navigate_to_menu_item(),
#' get_values_safe(), and the E2E_TIMEOUT constant.
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
    wait_for_idle = boom, set_inputs = boom, get_value = boom
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
