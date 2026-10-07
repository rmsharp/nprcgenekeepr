# Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
#
# Shared helper for the two guide-screenshot scripts,
# vignettes/articles/colony-manager-guide-screenshots.R and
# vignettes/articles/pedigree-diagram-screenshots.R (docs-audit slice 2,
# Phase 2; docs/planning/docs-audit-slice2-screenshot-plan.md). Both scripts
# used to carry an identical copy of shot() and do_step(), and both reported
# "81/81 steps succeeded" even when a click or a page-idle wait had timed out.
# Plain function definitions, no testthat dependency, so source()-ing this
# file outside the test harness is safe (same as helper-shinytest2.R).
# tests/testthat/test_captureHarness.R tests it with a stand-in for the
# browser.
#
# Usage in a script:
#   source(file.path("tests", "testthat", "helper-captureHarness.R"))
#   SHOT_DIR <- capture_shot_dir(file.path("vignettes", "articles", "shiny_app_use"))
#   recorder <- new_capture_recorder(SHOT_DIR)
#   shot <- recorder$shot
#   do_step <- recorder$do_step
#   ... shot(app, "x.png", selector = ...); do_step("label", { ... }) ...
#   recorder$summary()

## capture_shot_dir(): the folder the pictures are written to. The environment
## variable NPRC_SHOT_DIR, when set and not empty, names it (for example a
## scratch folder, so a run can be reviewed before it replaces the guide's own
## pictures); otherwise `default`. The folder is created if it is missing.
capture_shot_dir <- function(default) {
  override <- Sys.getenv("NPRC_SHOT_DIR", unset = "")
  dir <- if (nzchar(override)) override else default
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  dir
}

## new_capture_recorder(): the state of one run -- what every picture and step
## did -- and the functions that update it. Returns a list of:
##   shot(app, filename, selector, idle_timeout): capture a screenshot,
##     tolerating failure so one bad step does not abort the whole run.
##     app$wait_for_idle() (the AppDriver built-in) THROWS on timeout, rather
##     than returning FALSE -- observed after breeding-group formation, where
##     a secondary render wave (group tables/selectInput choices updating)
##     can keep Shiny "busy" past the timeout even though the page is already
##     visually complete. That is treated as a soft warning, not a reason to
##     skip the screenshot: the capture is attempted regardless, and the
##     picture is listed in the final summary so the timeout is not silent.
##   do_step(label, expr, allow_false): run a non-screenshot interaction step
##     defensively, logging failure under a step label rather than a
##     filename. A step whose last value is FALSE (a click_element_safe() or
##     a wait that timed out) counts as failed, unless allow_false = TRUE for
##     a step where FALSE is expected (the Genetic Value run click, which
##     times out at 30 s while the run is busy).
##   results(), idle_timeouts(): the recorded state.
##   summary(): print the end-of-run report and return its counts invisibly.
new_capture_recorder <- function(shot_dir) {
  results <- list()
  idle_timeouts <- character(0)

  shot <- function(app, filename, selector = NULL, idle_timeout = 15000) {
    tryCatch(app$wait_for_idle(timeout = idle_timeout), error = function(e) {
      idle_timeouts <<- c(idle_timeouts, filename)
      message("idle-wait timed out before ", filename,
              " -- capturing anyway: ", conditionMessage(e))
    })
    ok <- tryCatch({
      path <- file.path(shot_dir, filename)
      # get_screenshot() refuses to overwrite; the scripts always replace in
      # place.
      if (file.exists(path)) unlink(path)
      app$get_screenshot(path, selector = selector)
      TRUE
    }, error = function(e) {
      message("FAILED: ", filename, " -- ", conditionMessage(e))
      FALSE
    })
    results[[filename]] <<- ok
    cat(if (ok) "captured: " else "FAILED:   ", filename, "\n", sep = "")
    invisible(ok)
  }

  do_step <- function(label, expr, allow_false = FALSE) {
    ok <- tryCatch({
      value <- force(expr)
      if (identical(value, FALSE) && !allow_false) {
        stop("its last action returned FALSE (a click or wait that timed out)")
      }
      TRUE
    }, error = function(e) {
      message("STEP FAILED: ", label, " -- ", conditionMessage(e))
      FALSE
    })
    results[[paste0("[step] ", label)]] <<- ok
    invisible(ok)
  }

  summary <- function() {
    succeeded <- vapply(results, isTRUE, logical(1L))
    n_ok <- sum(succeeded)
    n_total <- length(results)
    failed <- as.character(names(results)[!succeeded])
    cat("\n==================== capture summary ====================\n")
    cat(sprintf("%d/%d steps succeeded\n", n_ok, n_total))
    if (length(failed) > 0L) {
      cat("Failed steps:\n")
      for (nm in failed) cat("  - ", nm, "\n", sep = "")
    }
    if (length(idle_timeouts) > 0L) {
      cat("Pictures taken after a page-idle timeout:\n")
      for (nm in idle_timeouts) cat("  - ", nm, "\n", sep = "")
    }
    if (length(failed) == 0L && length(idle_timeouts) == 0L) {
      cat("All steps and screenshots succeeded.\n")
    }
    invisible(list(n_ok = n_ok, n_total = n_total, failed = failed,
                   idle_timeouts = idle_timeouts))
  }

  list(shot = shot, do_step = do_step, results = function() results,
       idle_timeouts = function() idle_timeouts, summary = summary)
}

## reset_module_ready(): set a module container's data-ready attribute back to
## "false" in the page, just before an action that makes the app set it to
## "true" again when it finishes. The app sets it to "true" after the first
## breeding-group formation and nothing sets it back
## (R/modBreedingGroups.R, inst/www/js/data-ready.js), so without this reset
## wait_for_module_ready() returns at once for every later formation.
reset_module_ready <- function(app, module_id) {
  app$run_js(sprintf(
    paste0("var el = document.querySelector('#%s-moduleContainer'); ",
           "if (el) { el.setAttribute('data-ready', 'false'); }"),
    module_id
  ))
  invisible(NULL)
}

## wait_for_notifications_clear(): wait until no Shiny pop-up notification
## (the toast, e.g. "Updated focal animals: 3 IDs") is on the page, so it
## cannot overlap a picture. TRUE once clear, FALSE if one is still there
## after `timeout` milliseconds.
wait_for_notifications_clear <- function(app, timeout = 10000, interval = 0.2) {
  start <- Sys.time()
  repeat {
    n <- tryCatch(
      app$get_js("document.querySelectorAll('.shiny-notification').length"),
      error = function(e) NA
    )
    if (isTRUE(n == 0)) return(TRUE)
    elapsed <- as.numeric(difftime(Sys.time(), start, units = "secs")) * 1000
    if (elapsed >= timeout) return(FALSE)
    Sys.sleep(interval)
  }
}
