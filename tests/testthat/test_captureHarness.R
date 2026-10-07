## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Tests for the shared screenshot-capture helper
## (tests/testthat/helper-captureHarness.R) that
## vignettes/articles/colony-manager-guide-screenshots.R and
## vignettes/articles/pedigree-diagram-screenshots.R both use -- docs-audit
## slice 2, Phase 2 (docs/planning/docs-audit-slice2-screenshot-plan.md).
##
## Why it exists: both scripts carried an identical copy of shot() and
## do_step(), and both reported "81/81 steps succeeded" even when a click or a
## page-idle wait had timed out (measured S930: the Genetic Value run click
## returns FALSE after 30.0 s; 5 of 6 wait_for_module_ready() calls return in
## 0.0 s, because the flag it waits for is never reset). The helper makes a
## failed step, a timed-out wait and a picture taken after an idle timeout
## show up in the final summary.
##
## Two groups of tests:
##   1. the helper's functions, driven by a stand-in for shinytest2's
##      AppDriver (no browser, about a second);
##   2. pins on the two scripts' own text (they use the helper, no ignored
##      wait results, ...). The scripts live under vignettes/articles, which
##      is build-ignored, so these skip where the scripts are absent.
## What neither group can show: that a real run on a real browser behaves --
## that needs one full run of each script (S930 baseline: 92 s).

## ---- a stand-in for the parts of shinytest2::AppDriver the helper calls ----
fakeApp <- function(idle = "ok", screenshot = "ok", jsValues = NULL) {
  log <- new.env(parent = emptyenv())
  log$shots <- list()
  log$run_js <- character(0)
  log$get_js <- character(0)
  app <- list(
    wait_for_idle = function(timeout = 30000) {
      if (identical(idle, "timeout")) {
        stop("Shiny did not become idle within ", timeout, " ms")
      }
      invisible(NULL)
    },
    get_screenshot = function(file = NULL, ..., selector = NULL) {
      if (identical(screenshot, "error")) stop("screenshot not possible")
      # the real AppDriver refuses to overwrite an existing file
      if (file.exists(file)) stop("refusing to overwrite ", file)
      writeBin(as.raw(1L), file)
      log$shots[[length(log$shots) + 1L]] <- list(file = file,
                                                  selector = selector)
      invisible(file)
    },
    run_js = function(script, ...) {
      log$run_js <- c(log$run_js, script)
      invisible(NULL)
    },
    get_js = function(script, ...) {
      log$get_js <- c(log$get_js, script)
      i <- min(length(log$get_js), length(jsValues))
      jsValues[[i]]
    }
  )
  list(app = app, log = log)
}

## Run an expression with its console output and messages collected, so a
## test stays quiet and can still look at both.
runQuiet <- function(expr) {
  msgs <- character(0)
  out <- utils::capture.output(
    value <- withCallingHandlers(
      expr,
      message = function(m) {
        msgs <<- c(msgs, conditionMessage(m))
        invokeRestart("muffleMessage")
      }
    )
  )
  list(value = value, out = out, messages = msgs)
}

## ---- (d) the output folder ----------------------------------------------

test_that("capture_shot_dir() returns the default folder when NPRC_SHOT_DIR is unset", {
  base <- withr::local_tempdir()
  withr::local_envvar(c(NPRC_SHOT_DIR = NA))
  default <- file.path(base, "guide", "shiny_app_use")
  expect_identical(capture_shot_dir(default), default)
  expect_true(dir.exists(default))
})

test_that("capture_shot_dir() returns NPRC_SHOT_DIR, and creates it, when set", {
  base <- withr::local_tempdir()
  scratch <- file.path(base, "scratch", "deep")
  default <- file.path(base, "guide")
  withr::local_envvar(c(NPRC_SHOT_DIR = scratch))
  expect_identical(capture_shot_dir(default), scratch)
  expect_true(dir.exists(scratch))
  expect_false(dir.exists(default))
})

test_that("capture_shot_dir() treats an empty NPRC_SHOT_DIR as unset", {
  base <- withr::local_tempdir()
  default <- file.path(base, "guide")
  withr::local_envvar(c(NPRC_SHOT_DIR = ""))
  expect_identical(capture_shot_dir(default), default)
  expect_true(dir.exists(default))
})

## ---- shot() ---------------------------------------------------------------

test_that("shot() captures into the recorder's folder with the selector and records TRUE", {
  dir <- withr::local_tempdir()
  rec <- new_capture_recorder(dir)
  fake <- fakeApp()
  res <- runQuiet(rec$shot(fake$app, "a.png", selector = "#x-moduleContainer"))
  expect_true(file.exists(file.path(dir, "a.png")))
  expect_identical(fake$log$shots[[1L]]$selector, "#x-moduleContainer")
  expect_true(rec$results()[["a.png"]])
  expect_true(res$value)
  expect_match(res$out, "captured: a.png", fixed = TRUE)
})

test_that("shot() replaces a picture that is already there", {
  dir <- withr::local_tempdir()
  writeBin(as.raw(c(1L, 2L, 3L)), file.path(dir, "a.png"))
  rec <- new_capture_recorder(dir)
  fake <- fakeApp()
  runQuiet(rec$shot(fake$app, "a.png"))
  expect_true(rec$results()[["a.png"]])
  expect_identical(file.size(file.path(dir, "a.png")), 1)
})

test_that("shot() records FALSE and carries on when the screenshot itself fails", {
  dir <- withr::local_tempdir()
  rec <- new_capture_recorder(dir)
  fake <- fakeApp(screenshot = "error")
  res <- runQuiet(rec$shot(fake$app, "bad.png"))
  expect_false(rec$results()[["bad.png"]])
  expect_false(res$value)
  expect_match(res$messages, "FAILED: bad.png", fixed = TRUE, all = FALSE)
})

test_that("shot() still captures after a page-idle timeout and remembers the picture", {
  dir <- withr::local_tempdir()
  rec <- new_capture_recorder(dir)
  fake <- fakeApp(idle = "timeout")
  res <- runQuiet(rec$shot(fake$app, "slow.png"))
  expect_true(file.exists(file.path(dir, "slow.png")))
  expect_true(rec$results()[["slow.png"]])
  expect_identical(rec$idle_timeouts(), "slow.png")
  expect_match(res$messages, "idle-wait timed out", fixed = TRUE, all = FALSE)
})

test_that("shot() records no idle timeout when the page went idle", {
  dir <- withr::local_tempdir()
  rec <- new_capture_recorder(dir)
  runQuiet(rec$shot(fakeApp()$app, "fine.png"))
  expect_identical(rec$idle_timeouts(), character(0))
})

## ---- (b) do_step() --------------------------------------------------------

test_that("do_step() records TRUE under the step label when the step completes", {
  rec <- new_capture_recorder(withr::local_tempdir())
  res <- runQuiet(rec$do_step("open the tab", invisible(1)))
  expect_true(rec$results()[["[step] open the tab"]])
  expect_true(res$value)
})

test_that("do_step() records FALSE, says why, and does not stop when the step errors", {
  rec <- new_capture_recorder(withr::local_tempdir())
  res <- runQuiet(rec$do_step("break", stop("no such input")))
  expect_false(rec$results()[["[step] break"]])
  expect_false(res$value)
  expect_match(res$messages, "STEP FAILED: break -- no such input",
               fixed = TRUE, all = FALSE)
})

test_that("do_step() counts a step whose last value is FALSE as failed", {
  rec <- new_capture_recorder(withr::local_tempdir())
  res <- runQuiet(rec$do_step("click that timed out", {
    invisible(1)
    FALSE
  }))
  expect_false(rec$results()[["[step] click that timed out"]])
  expect_false(res$value)
  expect_match(res$messages, "STEP FAILED: click that timed out",
               fixed = TRUE, all = FALSE)
  expect_match(res$messages, "FALSE", fixed = TRUE, all = FALSE)
})

test_that("do_step(allow_false = TRUE) lets a returned FALSE count as success", {
  rec <- new_capture_recorder(withr::local_tempdir())
  res <- runQuiet(rec$do_step("long run", FALSE, allow_false = TRUE))
  expect_true(rec$results()[["[step] long run"]])
  expect_true(res$value)
})

test_that("do_step() does not mistake other return values for a failure", {
  rec <- new_capture_recorder(withr::local_tempdir())
  runQuiet(rec$do_step("returns NULL", NULL))
  runQuiet(rec$do_step("returns a list", list(a = FALSE)))
  runQuiet(rec$do_step("returns text", "FALSE"))
  runQuiet(rec$do_step("returns TRUE", TRUE))
  expect_true(all(unlist(rec$results())))
  expect_length(rec$results(), 4L)
})

## ---- (c) the final summary ------------------------------------------------

test_that("summary() reports how many steps and pictures succeeded", {
  rec <- new_capture_recorder(withr::local_tempdir())
  runQuiet(rec$shot(fakeApp()$app, "a.png"))
  runQuiet(rec$do_step("one", TRUE))
  runQuiet(rec$do_step("two", TRUE))
  res <- runQuiet(rec$summary())
  expect_match(res$out, "3/3 steps succeeded", fixed = TRUE, all = FALSE)
  expect_match(res$out, "All steps and screenshots succeeded",
               fixed = TRUE, all = FALSE)
  expect_false(any(grepl("Failed steps", res$out, fixed = TRUE)))
  expect_false(any(grepl("page-idle", res$out, fixed = TRUE)))
})

test_that("summary() lists each failed step and picture, and returns the counts", {
  rec <- new_capture_recorder(withr::local_tempdir())
  runQuiet(rec$shot(fakeApp(screenshot = "error")$app, "bad.png"))
  runQuiet(rec$do_step("breaks", stop("x")))
  runQuiet(rec$do_step("fine", TRUE))
  res <- runQuiet(rec$summary())
  expect_match(res$out, "1/3 steps succeeded", fixed = TRUE, all = FALSE)
  expect_match(res$out, "Failed steps:", fixed = TRUE, all = FALSE)
  expect_match(res$out, "  - bad.png", fixed = TRUE, all = FALSE)
  expect_match(res$out, "  - [step] breaks", fixed = TRUE, all = FALSE)
  expect_false(any(grepl("All steps and screenshots succeeded", res$out,
                         fixed = TRUE)))
  expect_identical(res$value$n_ok, 1L)
  expect_identical(res$value$n_total, 3L)
  expect_identical(res$value$failed, c("bad.png", "[step] breaks"))
})

test_that("summary() lists pictures taken after a page-idle timeout", {
  rec <- new_capture_recorder(withr::local_tempdir())
  runQuiet(rec$shot(fakeApp(idle = "timeout")$app, "slow.png"))
  runQuiet(rec$shot(fakeApp()$app, "fine.png"))
  res <- runQuiet(rec$summary())
  expect_match(res$out, "Pictures taken after a page-idle timeout:",
               fixed = TRUE, all = FALSE)
  expect_match(res$out, "  - slow.png", fixed = TRUE, all = FALSE)
  expect_false(any(grepl("  - fine.png", res$out, fixed = TRUE)))
  expect_identical(res$value$idle_timeouts, "slow.png")
  # a picture taken after an idle timeout is not a failed step
  expect_match(res$out, "2/2 steps succeeded", fixed = TRUE, all = FALSE)
})

test_that("summary() does not claim success when a picture followed an idle timeout", {
  rec <- new_capture_recorder(withr::local_tempdir())
  runQuiet(rec$shot(fakeApp(idle = "timeout")$app, "slow.png"))
  res <- runQuiet(rec$summary())
  expect_false(any(grepl("All steps and screenshots succeeded", res$out,
                         fixed = TRUE)))
})

## ---- (a) resetting the "ready" marker -------------------------------------

test_that("reset_module_ready() sets the module container's data-ready to false", {
  fake <- fakeApp()
  reset_module_ready(fake$app, "breedingGroups")
  js <- fake$log$run_js
  expect_length(js, 1L)
  expect_match(js, "#breedingGroups-moduleContainer", fixed = TRUE)
  expect_match(js, "data-ready", fixed = TRUE)
  expect_match(js, "false", fixed = TRUE)
})

test_that("reset_module_ready() builds its selector from the module id and tolerates a missing container", {
  fake <- fakeApp()
  reset_module_ready(fake$app, "matePair")
  js <- fake$log$run_js
  expect_match(js, "#matePair-moduleContainer", fixed = TRUE)
  expect_false(grepl("breedingGroups", js, fixed = TRUE))
  # the page-side code must not throw when the container is absent
  expect_match(js, "if (el)", fixed = TRUE)
})

## ---- (f) waiting for pop-ups to clear -------------------------------------

test_that("wait_for_notifications_clear() returns TRUE at once when there is no pop-up", {
  fake <- fakeApp(jsValues = list(0L))
  expect_true(wait_for_notifications_clear(fake$app, timeout = 2000,
                                           interval = 0.01))
  expect_length(fake$log$get_js, 1L)
  expect_match(fake$log$get_js, ".shiny-notification", fixed = TRUE)
})

test_that("wait_for_notifications_clear() waits until the pop-ups are gone", {
  fake <- fakeApp(jsValues = list(2L, 1L, 0L))
  expect_true(wait_for_notifications_clear(fake$app, timeout = 2000,
                                           interval = 0.01))
  expect_length(fake$log$get_js, 3L)
})

test_that("wait_for_notifications_clear() returns FALSE when a pop-up outlasts the timeout", {
  fake <- fakeApp(jsValues = list(1L))
  started <- Sys.time()
  expect_false(wait_for_notifications_clear(fake$app, timeout = 300,
                                            interval = 0.01))
  expect_lt(as.numeric(difftime(Sys.time(), started, units = "secs")), 5)
})

## ---- start_capture_run() (REFACTOR: the setup both scripts repeated) --------

test_that("start_capture_run() installs shot() and do_step() in the given environment and returns the same recorder", {
  dir <- withr::local_tempdir()
  scriptEnv <- new.env()
  rec <- start_capture_run(dir, envir = scriptEnv)
  expect_true(is.function(scriptEnv$shot))
  expect_true(is.function(scriptEnv$do_step))
  runQuiet(scriptEnv$do_step("from the script", TRUE))
  runQuiet(scriptEnv$shot(fakeApp()$app, "a.png"))
  expect_identical(names(rec$results()), c("[step] from the script", "a.png"))
  expect_true(file.exists(file.path(dir, "a.png")))
})

test_that("start_capture_run() installs into the calling environment by default", {
  dir <- withr::local_tempdir()
  installedHere <- function() {
    start_capture_run(dir)
    c(exists("shot", inherits = FALSE), exists("do_step", inherits = FALSE))
  }
  expect_identical(installedHere(), c(TRUE, TRUE))
})

## ---- pins on the two scripts' own text ------------------------------------

scriptDir <- testthat::test_path("..", "..", "vignettes", "articles")
colonyScript <- file.path(scriptDir, "colony-manager-guide-screenshots.R")
diagramScript <- file.path(scriptDir, "pedigree-diagram-screenshots.R")

readScript <- function(path) {
  skip_if_not(file.exists(path),
              "capture script not present (it is build-ignored)")
  readLines(path, warn = FALSE)
}

## The lines of one top-level step: from the line matching `startPattern` to
## the line before the next top-level do_step( / shot( call.
stepBlock <- function(lines, startPattern) {
  start <- grep(startPattern, lines)
  stopifnot(length(start) == 1L)
  tops <- grep("^(do_step|shot)\\(", lines)
  nextTop <- tops[tops > start]
  end <- if (length(nextTop)) nextTop[[1L]] - 1L else length(lines)
  lines[start:end]
}

test_that("both scripts use the shared helper and carry no copy of shot() or do_step()", {
  for (path in c(colonyScript, diagramScript)) {
    lines <- readScript(path)
    info <- basename(path)
    expect_true(any(grepl("helper-captureHarness\\.R", lines)), info = info)
    expect_false(any(grepl("^(shot|do_step) <- function", lines)), info = info)
  }
})

test_that("both scripts take the picture folder from capture_shot_dir() and end with the recorder's summary", {
  for (path in c(colonyScript, diagramScript)) {
    lines <- readScript(path)
    info <- basename(path)
    expect_true(any(grepl("capture_shot_dir\\(", lines)), info = info)
    expect_true(any(grepl("\\$summary\\(\\)", lines)), info = info)
  }
})

test_that("every Form Groups click in the colony script resets the ready marker in the same step", {
  lines <- readScript(colonyScript)
  clickAt <- grep('click_element_safe\\(app, "#breedingGroups-formGroups"\\)',
                  lines)
  expect_length(clickAt, 4L)
  stepStarts <- grep("^do_step\\(", lines)
  resetAt <- grep('reset_module_ready\\(app, "breedingGroups"\\)', lines)
  for (i in clickAt) {
    start <- max(stepStarts[stepStarts < i])
    expect_true(any(resetAt > start & resetAt < i),
                info = paste("Form Groups click at line", i))
  }
})

test_that("only the Genetic Value run step may return FALSE", {
  lines <- readScript(colonyScript)
  expect_length(grep("allow_false = TRUE", lines), 1L)
  runStep <- stepBlock(lines, '^do_step\\("run Genetic Value Analysis')
  expect_true(any(grepl("allow_false = TRUE", runStep)))
})

test_that("no wait_for_element() or wait_for_module_ready() result is ignored", {
  for (path in c(colonyScript, diagramScript)) {
    lines <- readScript(path)
    lines <- lines[!grepl("^\\s*#", lines)]
    calls <- grep("wait_for_(element|module_ready)\\(", lines, value = TRUE)
    for (call in calls) {
      expect_match(call, "^\\s*if \\(!wait_for_(element|module_ready)\\(",
                   info = paste(basename(path), ":", trimws(call)))
    }
  }
})

test_that("'select group 6' returns its click so a timed-out click counts as failed", {
  lines <- readScript(colonyScript)
  block <- paste(stepBlock(lines, '^do_step\\("select group 6 in Group Detail'),
                 collapse = "\n")
  expect_match(block, "clicked <- click_element_safe\\(")
  expect_match(block, "\n\\s+clicked\\s*\n\\s*\\}\\)")
})

test_that("the Diagram legend picture waits for the pop-up to clear first", {
  lines <- readScript(diagramScript)
  focalAt <- grep('set_focal\\(app, c\\("8LKBV9"', lines)
  waitAt <- grep("wait_for_notifications_clear\\(", lines)
  shotAt <- grep('shot\\(app, "pb_diagram_legend\\.png"', lines)
  expect_length(focalAt, 1L)
  expect_length(shotAt, 1L)
  expect_true(any(waitAt > focalAt & waitAt < shotAt))
})
