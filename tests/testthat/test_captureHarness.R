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
pictureDir <- file.path(scriptDir, "shiny_app_use")

readScript <- function(path) {
  skip_if_not(file.exists(path),
              "capture script not present (it is build-ignored)")
  readLines(path, warn = FALSE)
}

## The comment-free code of a script.
codeOf <- function(lines) lines[!grepl("^\\s*#", lines)]

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
    lines <- codeOf(readScript(path))
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

## The values a script types into one input, read off its code (comments
## skipped): for app$set_inputs(`<module>-<input>` = <value>) it returns the
## text of <value>. `input` is the part of the id after the module name.
typedValues <- function(lines, input) {
  lines <- codeOf(lines)
  typed <- paste0("-", input, "`\\s*=\\s*")
  hits <- regmatches(lines, regexpr(paste0(typed, "[^,)]+"), lines))
  trimws(sub(paste0("^", typed), "", hits))
}

## The Group Detail box ("Group to view:") lists the groups by number: the app
## builds its choices as setNames(seq_len(n), labels) (R/modBreedingGroups.R,
## the viewGrp observe()), so the value a script types must be that number,
## not the label. "Group 6" matches no choice and leaves the box blank (found
## S940: the committed picture and the retake both showed a blank box).
viewGrpValues <- function(lines) typedValues(lines, "viewGrp")

test_that("viewGrpValues() reads the value a script types into the group box", {
  made <- c(
    "  app$set_inputs(`breedingGroups-viewGrp` = \"6\", wait_ = FALSE)",
    "  app$set_inputs(`breedingGroups-viewGrp` = 2L)",
    "  # app$set_inputs(`breedingGroups-viewGrp` = \"Group 9\")",
    "  app$set_inputs(`breedingGroups-viewGrp` = \"Group 6\", wait_ = FALSE)"
  )
  expect_identical(viewGrpValues(made), c("\"6\"", "2L", "\"Group 6\""))
  expect_identical(viewGrpValues("app$click(\"x\")"), character(0))
})

test_that("the colony script types the group's number, not its label, into the Group Detail box", {
  lines <- readScript(colonyScript)
  values <- viewGrpValues(lines)
  expect_gte(length(values), 1L)
  for (value in values) {
    expect_match(value, "^\"?[0-9]+L?\"?$",
                 info = paste("viewGrp is set to", value))
  }
})

## The Pedigree Browser's default view was captured twice: as
## pb_10_rows_display_unknown_ids.png (the picture the guide shows) and as
## pb_unknown_displayed.png, a same-size twin nothing displays (plan decision
## D2; the owner ruled "delete" in S941).
test_that("the colony script no longer writes the unused pb_unknown_displayed.png", {
  code <- codeOf(readScript(colonyScript))
  expect_false(any(grepl("pb_unknown_displayed", code)))
  expect_length(
    grep('shot\\(app, "pb_10_rows_display_unknown_ids\\.png"', code), 1L)
})

test_that("the unused pb_unknown_displayed.png is gone from the picture folder", {
  skip_if_not(dir.exists(pictureDir),
              "picture folder not present (it is build-ignored)")
  expect_false(file.exists(file.path(pictureDir, "pb_unknown_displayed.png")))
  expect_true(file.exists(
    file.path(pictureDir, "pb_10_rows_display_unknown_ids.png")))
})

## ---- the three Summary Statistics pictures (docs-audit slice 2 follow-up) ----
##
## ss_first_view.png, ss_trimmed_all_plots.png and
## ss_export_mean_kinship_coefficient_histogram.png were one picture three
## times: the script shot the whole #summaryStats-moduleContainer for each
## (1270 x 7598 px, 1.8 MB each; measured S942 and again S945), so the third
## caption's "One exported plot" showed the whole tab. The owner ruled (S945)
## that each picture shows what its caption says: the window as the tab opens,
## the block holding the six plots, and the mean kinship histogram as the
## Export button writes it (the real exported file, fetched with
## app$get_download()).

ssPictures <- c(
  firstView = "ss_first_view.png",
  sixPlots = "ss_trimmed_all_plots.png",
  exported = "ss_export_mean_kinship_coefficient_histogram.png"
)

## The top-level do_step( / shot( statement that holds the first line matching
## `pattern`: from its first line to the line before the next top-level call,
## as one string.
blockContaining <- function(code, pattern) {
  at <- grep(pattern, code)
  stopifnot(length(at) >= 1L)
  tops <- grep("^(do_step|shot)\\(", code)
  start <- max(tops[tops <= at[[1L]]])
  nextTop <- tops[tops > start]
  end <- if (length(nextTop)) nextTop[[1L]] - 1L else length(code)
  paste(code[start:end], collapse = "\n")
}

## The line numbers of the `shot(app, "<picture>"` calls in `code`.
shotLineOf <- function(code, picture) {
  grep(paste0('shot\\(app, "', picture, '"'), code)
}

## Width and height of a PNG, from its header (bytes 17 to 24, big-endian).
pngSize <- function(path) {
  header <- readBin(path, "raw", 24L)
  as.integer(c(sum(as.integer(header[17:20]) * 256^(3:0)),
               sum(as.integer(header[21:24]) * 256^(3:0))))
}

test_that("pngSize() reads the width and the height from the PNG header", {
  skip_if_not(capabilities("png"), "no png device here")
  drawn <- tempfile(fileext = ".png")
  grDevices::png(drawn, width = 70L, height = 50L)
  graphics::par(mar = c(0, 0, 0, 0))
  plot.new()
  grDevices::dev.off()
  expect_identical(pngSize(drawn), c(70L, 50L))
})

test_that("no Summary Statistics picture is shot from the whole tab", {
  code <- codeOf(readScript(colonyScript))
  for (name in names(ssPictures)) {
    block <- blockContaining(code, ssPictures[[name]])
    expect_false(grepl("summaryStats-moduleContainer", block, fixed = TRUE),
                 info = ssPictures[[name]])
  }
})

test_that("the first-view picture is a window shot", {
  code <- codeOf(readScript(colonyScript))
  block <- blockContaining(code, "ss_first_view\\.png")
  expect_match(block, 'selector = "viewport"')
})

test_that("the six-plots picture is shot from the block that holds the six plots, after that block is tagged", {
  code <- codeOf(readScript(colonyScript))
  tagAt <- grep("summaryStats-mkHist.*closest\\(", code)
  expect_length(tagAt, 1L)
  tagLine <- if (length(tagAt) == 1L) code[[tagAt]] else ""
  tagId <- sub(".*\\.id *= *['\"]([^'\"]+)['\"].*", "\\1", tagLine)
  expect_false(identical(tagId, tagLine), info = "the tag line assigns an id")
  shotAt <- grep("ss_trimmed_all_plots\\.png", code)
  expect_length(shotAt, 1L)
  expect_true(length(tagAt) == 1L && tagAt < shotAt)
  expect_match(blockContaining(code, "ss_trimmed_all_plots\\.png"),
               paste0('selector = "#', tagId, '"'), fixed = TRUE)
})

test_that("the exported-histogram picture is the file the Export button writes, fetched with get_download()", {
  code <- codeOf(readScript(colonyScript))
  expect_false(any(grepl('shot\\(app, "ss_export_mean_kinship', code)))
  block <- blockContaining(code, "ss_export_mean_kinship_coefficient_histogram\\.png")
  expect_match(block, 'get_download\\(\\s*"summaryStats-downloadMkHist"')
  expect_match(block, "file\\.path\\(SHOT_DIR")
})

test_that("the three Summary Statistics pictures are three different files", {
  skip_if_not(dir.exists(pictureDir),
              "picture folder not present (it is build-ignored)")
  sums <- tools::md5sum(file.path(pictureDir, ssPictures))
  expect_false(anyNA(sums))
  expect_length(unique(unname(sums)), 3L)
})

test_that("the three Summary Statistics pictures have the sizes of what they show", {
  skip_if_not(dir.exists(pictureDir),
              "picture folder not present (it is build-ignored)")
  size <- function(name) pngSize(file.path(pictureDir, ssPictures[[name]]))
  ## the window as the tab opens: 1300 px wide, as tall as the window
  first <- size("firstView")
  expect_identical(first[[1L]], 1300L)
  expect_true(first[[2L]] >= 800L && first[[2L]] <= 1600L)
  ## the block of six plots: far shorter than the whole tab (7,598 px)
  six <- size("sixPlots")
  expect_true(six[[2L]] > 1000L && six[[2L]] < 2000L)
  ## the exported file: ggsave(width = 8, height = 6, dpi = 100)
  ## (R/modSummaryStats.R downloadMkHist)
  expect_identical(size("exported"), c(800L, 600L))
})

## ---- the Diagram article's edge-style picture (BACKLOG.md:30, found S941) ----
##
## The app opens on the Rectilinear edge style (R/modPedigree.R, the default
## since S574), so the diagram script's step "select Rectilinear edge style"
## changed nothing: diagram_rectilinear_edge_style.png was the same file, byte
## for byte, as pb_diagram_legend.png (measured S949; S941 found 0 of 2,007,870
## pixels differing). The article's section "Diagram Edge Style: Direct vs.
## Rectilinear" therefore showed one style twice and never showed Direct. The
## owner ruled (S949): show Direct instead -- the section's picture is the
## Direct style, and the article's first picture stays the Rectilinear default.

diagramArticle <- file.path(scriptDir, "pedigree-diagram.qmd")
directPicture <- "diagram_direct_edge_style.png"
oldRectilinearPicture <- "diagram_rectilinear_edge_style.png"

## The values a script types into the Diagram Edge Style buttons.
edgeStyleValues <- function(lines) typedValues(lines, "pedigreeEdgeStyle")

readArticle <- function() {
  skip_if_not(file.exists(diagramArticle),
              "article not present (it is build-ignored)")
  readLines(diagramArticle, warn = FALSE)
}

test_that("edgeStyleValues() reads the value a script types into the edge-style buttons", {
  made <- c(
    "    app$set_inputs(`pedigree-pedigreeEdgeStyle` = \"direct\")",
    "  # app$set_inputs(`pedigree-pedigreeEdgeStyle` = \"rectilinear\")",
    "    app$set_inputs(`pedigree-pedigreeEdgeStyle` = \"rectilinear\", wait_ = FALSE)"
  )
  expect_identical(edgeStyleValues(made), c("\"direct\"", "\"rectilinear\""))
  expect_identical(edgeStyleValues("app$click(\"x\")"), character(0))
})

test_that("the Diagram script never types Rectilinear into the edge-style buttons (the app opens on it)", {
  values <- edgeStyleValues(readScript(diagramScript))
  expect_gte(length(values), 1L)
  expect_false("\"rectilinear\"" %in% values)
})

test_that("the Diagram script's edge-style step picks Direct and shoots diagram_direct_edge_style.png from the container", {
  code <- codeOf(readScript(diagramScript))
  expect_identical(edgeStyleValues(code), "\"direct\"")
  setAt <- grep("-pedigreeEdgeStyle`", code)
  shotAt <- shotLineOf(code, directPicture)
  expect_length(setAt, 1L)
  expect_length(shotAt, 1L)
  expect_true(length(setAt) == 1L && length(shotAt) == 1L && setAt < shotAt)
  if (length(shotAt) == 1L) {
    ## the call runs on to the next line; blockContaining() does not apply
    ## here (it wants column-0 calls, and this script indents its shots
    ## inside `if (ok) {`)
    call <- paste(code[shotAt:(shotAt + 1L)], collapse = " ")
    expect_match(call, "#pedigree-moduleContainer", fixed = TRUE)
  }
  expect_false(any(grepl(oldRectilinearPicture, code, fixed = TRUE)))
})

test_that("the Diagram script's comments do not call Direct the default", {
  lines <- readScript(diagramScript)
  comments <- sub("^\\s*#\\s*", "", lines[grepl("^\\s*#", lines)])
  expect_false(grepl('default "direct"', paste(comments, collapse = " "),
                     fixed = TRUE))
})

test_that("the Diagram article cites the Direct picture and no longer cites the old Rectilinear one", {
  text <- paste(readArticle(), collapse = "\n")
  expect_match(text, paste0("shiny_app_use/", directPicture), fixed = TRUE)
  expect_false(grepl(oldRectilinearPicture, text, fixed = TRUE))
})

test_that("the edge-style section captions its picture as Direct and points to the first picture for Rectilinear", {
  lines <- readArticle()
  start <- grep("^## Diagram Edge Style", lines)
  expect_length(start, 1L)
  heads <- grep("^## ", lines)
  end <- min(c(heads[heads > start[[1L]]] - 1L, length(lines)))
  section <- lines[start[[1L]]:end]
  picture <- grep("shiny_app_use/", section, value = TRUE)
  expect_length(picture, 1L)
  if (length(picture) == 1L) {
    expect_match(picture, "Diagram Edge Style set to Direct", fixed = TRUE)
    alt <- sub('.*fig-alt="([^"]*)".*', "\\1", picture)
    expect_match(alt, "Direct")
    expect_false(grepl("Rectilinear edge style selected", alt, fixed = TRUE))
  }
  expect_match(paste(section, collapse = "\n"), "Node shapes and the legend",
               fixed = TRUE)
})

test_that("the Diagram article's pictures are all different files", {
  skip_if_not(dir.exists(pictureDir),
              "picture folder not present (it is build-ignored)")
  text <- readArticle()
  cited <- unique(unlist(regmatches(
    text, gregexpr("shiny_app_use/[A-Za-z0-9_.-]+\\.png", text))))
  expect_gte(length(cited), 5L)
  sums <- tools::md5sum(file.path(scriptDir, cited))
  expect_false(anyNA(sums))
  expect_identical(anyDuplicated(unname(sums)), 0L)
})

test_that("diagram_direct_edge_style.png is in the picture folder and the old Rectilinear copy is gone", {
  skip_if_not(dir.exists(pictureDir),
              "picture folder not present (it is build-ignored)")
  expect_true(file.exists(file.path(pictureDir, directPicture)))
  expect_false(file.exists(file.path(pictureDir, oldRectilinearPicture)))
})

test_that("the Direct picture is as wide as the legend picture (the same container in the same window)", {
  skip_if_not(dir.exists(pictureDir),
              "picture folder not present (it is build-ignored)")
  direct <- file.path(pictureDir, directPicture)
  expect_true(file.exists(direct))
  if (file.exists(direct)) {
    expect_identical(
      pngSize(direct)[[1L]],
      pngSize(file.path(pictureDir, "pb_diagram_legend.png"))[[1L]])
  }
})

## ---- the guide's Warnings sub-tab picture (BACKLOG.md:8, raised S936) ----
##
## The guide's Read and Check Pedigree paragraph says in words that, when the
## check finds only warnings, the app opens the "Warnings" sub-tab and shows a
## yellow notice, "QC found 2 warning(s). Check the Warnings tab.", but it had
## no picture of either. The one picture it has, read_and_check_pedigree.png,
## is the QC Summary sub-tab cropped to the module container, taken after the
## notice has closed (S936). The new picture is the whole 1300 x 900 window
## right after the check, with the Warnings sub-tab open and the notice still
## on screen (it stays 8 s; measured S963: 1.9 s after the click, 1.3 s of it
## the check itself). The owner approved the sentence, the caption and the
## place (after the QC Summary picture) in S963.

guideFile <- file.path(scriptDir, "colony-manager-guide.qmd")
warningsPicture <- "read_and_check_pedigree_warnings.png"
qcSummaryPicture <- "read_and_check_pedigree.png"

readGuide <- function() {
  skip_if_not(file.exists(guideFile),
              "guide not present (it is build-ignored)")
  readLines(guideFile, warn = FALSE)
}

## The guide line that cites `picture` (the picture's own markdown line).
guideLineOf <- function(lines, picture) {
  grep(paste0("shiny_app_use/", picture), lines, fixed = TRUE)
}

test_that("the colony script shoots the Warnings sub-tab as a window picture, between the Read and Check click and the switch to QC Summary", {
  code <- codeOf(readScript(colonyScript))
  shotAt <- shotLineOf(code, warningsPicture)
  clickAt <-grep('app\\$click\\("dataInput-getData"\\)', code)
  switchAt <- grep('`dataInput-mainTabs` = "QC Summary"', code)
  expect_length(shotAt, 1L)
  expect_length(clickAt, 1L)
  expect_length(switchAt, 1L)
  if (length(shotAt) == 1L && length(clickAt) == 1L && length(switchAt) == 1L) {
    expect_true(clickAt < shotAt && shotAt < switchAt)
    expect_match(blockContaining(code, "read_and_check_pedigree_warnings\\.png"),
                 'selector = "viewport"')
  }
})

test_that("the step before the Warnings picture waits for the notice and checks the Warnings sub-tab is the open one", {
  code <- codeOf(readScript(colonyScript))
  shotAt <- shotLineOf(code, warningsPicture)
  expect_length(shotAt, 1L)
  if (length(shotAt) == 1L) {
    tops <-grep("^(do_step|shot)\\(", code)
    before <- tops[tops < shotAt]
    expect_gte(length(before), 1L)
    block <- paste(code[max(before):(shotAt - 1L)], collapse = "\n")
    expect_match(block, "^do_step\\(")
    ## the notice must be on screen when the picture is taken (it closes
    ## after 8 s), and the picture is of the Warnings sub-tab
    expect_match(block, 'wait_for_element\\(app, "\\.shiny-notification"')
    expect_match(block, 'get_value\\(input = "dataInput-mainTabs"\\)')
    expect_match(block, '"Warnings"', fixed = TRUE)
  }
})

test_that("the guide cites the Warnings picture once, after the QC Summary picture, with the sentence between them and the approved caption", {
  lines <- readGuide()
  warningsAt <- guideLineOf(lines, warningsPicture)
  qcAt <- guideLineOf(lines, qcSummaryPicture)
  expect_length(warningsAt, 1L)
  expect_length(qcAt, 1L)
  if (length(warningsAt) == 1L && length(qcAt) == 1L) {
    expect_true(qcAt < warningsAt)
    inBetween <- lines[seq_len(warningsAt - 1L)][-seq_len(qcAt)]
    between <- gsub("\\s+", " ", paste(inBetween, collapse = " "))
    expect_match(
      between,
      paste("The picture below shows the Warnings sub-tab as the app opens it",
            "for this file: one row for each of the two warnings, with the",
            "yellow notice still on screen in the lower right corner."),
      fixed = TRUE)
    expect_match(
      lines[[warningsAt]],
      paste0("![The Warnings sub-tab as the app opens it after reading and ",
             "checking the example pedigree.](shiny_app_use/"),
      fixed = TRUE)
  }
})

test_that("the Warnings picture's alt text names the open sub-tab, both warnings and the notice", {
  lines <- readGuide()
  warningsAt <- guideLineOf(lines, warningsPicture)
  expect_length(warningsAt, 1L)
  if (length(warningsAt) == 1L) {
    alt <- sub('.*\\{fig-alt="([^"]*)"\\}.*', "\\1", lines[[warningsAt]])
    expect_false(identical(alt, lines[[warningsAt]]), info = "has fig-alt")
    expect_match(alt, "Warnings sub-tab", fixed = TRUE)
    expect_match(alt, "Column name case changed", fixed = TRUE)
    expect_match(alt, "Animals with no birth date", fixed = TRUE)
    expect_match(alt, "QC found 2 warning(s). Check the Warnings tab.",
                 fixed = TRUE)
    expect_match(alt, "lower right corner", fixed = TRUE)
  }
})

test_that("the Warnings picture is in the picture folder, is a window shot, and is not a copy of another picture", {
  skip_if_not(dir.exists(pictureDir),
              "picture folder not present (it is build-ignored)")
  path <- file.path(pictureDir, warningsPicture)
  expect_true(file.exists(path))
  if (file.exists(path)) {
    ## the window the script opens: 1300 px wide, 900 px tall
    size <- pngSize(path)
    expect_identical(size[[1L]], 1300L)
    expect_true(size[[2L]] >= 800L && size[[2L]] <= 1000L)
    others <- setdiff(list.files(pictureDir, pattern = "\\.png$",
                                 full.names = TRUE), path)
    expect_gt(length(others), 40L)
    expect_false(unname(tools::md5sum(path)) %in%
                   unname(tools::md5sum(others)))
  }
})

## ---- pop-ups must be gone before a picture is taken (S964) -----------------
##
## A step that sets a focal-animals list makes the app show a pop-up in the
## lower right corner ("Updated focal animals: N IDs", "Focal animals cleared",
## the orange "No focal animal IDs found") and it stays 8 s. Nine pictures
## were taken while one was up and it hid part of the "Twin/Zygosity Relations
## (optional)" heading; age_plot.png had three over the pyramid's right axis
## and gva_calculating.png two over blank space (BACKLOG.md:8, found S941).
## A picture is taken right after a step that waits for them to clear. The
## Warnings picture is the one that keeps its pop-up on purpose (S963).

## TRUE when the last statement before the `picture` shot() call is a
## do_step() whose last line is the pop-up wait; blank lines and comments in
## between do not count. `code` is the script's comment-free lines.
waitsRightBeforeShot <- function(code, picture) {
  at <- shotLineOf(code, picture)
  if (length(at) != 1L) return(FALSE)
  before <- code[seq_len(at - 1L)]
  before <- before[nzchar(trimws(before))]
  n <- length(before)
  n >= 2L &&
    grepl("^\\s*\\}\\)\\s*$", before[[n]]) &&
    grepl("^\\s*wait_for_notifications_clear\\(", before[[n - 1L]])
}

test_that("waitsRightBeforeShot() is TRUE only when the pop-up wait is the last step before the picture", {
  waited <- c('do_step("wait", {',
              "  wait_for_notifications_clear(app)",
              "})",
              "",
              "# a comment between the wait and the picture",
              'shot(app, "a.png", selector = "#x")')
  expect_true(waitsRightBeforeShot(codeOf(waited), "a.png"))
  ## the same, indented inside `if (ok) {`, as in the Diagram script
  indented <- paste0("  ", waited)
  expect_true(waitsRightBeforeShot(codeOf(indented), "a.png"))
  ## another step between the wait and the picture
  later <- append(waited, c('do_step("toggle", {', "  app$click(\"b\")", "})"),
                  after = 3L)
  expect_false(waitsRightBeforeShot(codeOf(later), "a.png"))
  ## the wait is not the step's last line
  notLast <- append(waited, "  TRUE", after = 2L)
  expect_false(waitsRightBeforeShot(codeOf(notLast), "a.png"))
  ## a wait that is only mentioned in a comment
  commented <- sub("wait_for_notifications_clear",
                   "# wait_for_notifications_clear", waited, fixed = TRUE)
  expect_false(waitsRightBeforeShot(codeOf(commented), "a.png"))
  ## no wait at all, a picture that is not shot, a picture shot twice
  expect_false(waitsRightBeforeShot(c('shot(app, "a.png")'), "a.png"))
  expect_false(waitsRightBeforeShot(codeOf(waited), "other.png"))
  expect_false(waitsRightBeforeShot(c(waited, waited), "a.png"))
})

test_that("the colony script waits for the pop-ups to clear right before each Pedigree Browser picture taken after a focal-animals step", {
  code <- codeOf(readScript(colonyScript))
  for (picture in c("pb_5_focal_animals_small.png",
                    "pb_selection_large_focal_group.png",
                    "pb_select_trim_for_focal_animals.png",
                    "pb_trimmed_for_focal_animals.png",
                    "pb_focal_animals_before_clear.png",
                    "pb_focal_animals_after_clear.png")) {
    expect_true(waitsRightBeforeShot(code, picture), info = picture)
  }
})

test_that("the colony script waits for the pop-ups to clear right before the Age-Sex Pyramid and Genetic Value pictures", {
  code <- codeOf(readScript(colonyScript))
  for (picture in c("age_plot.png", "gva_calculating.png")) {
    expect_true(waitsRightBeforeShot(code, picture), info = picture)
  }
})

test_that("the Diagram script waits for the pop-ups to clear right before each picture taken after a focal-animals step", {
  code <- codeOf(readScript(diagramScript))
  for (picture in c("diagram_show_names.png", "diagram_affected_shading.png",
                    "diagram_twin_connectors.png")) {
    expect_true(waitsRightBeforeShot(code, picture), info = picture)
  }
})

test_that("the pictures that already waited for a pop-up still do, in the form the new pins read", {
  expect_true(waitsRightBeforeShot(codeOf(readScript(colonyScript)),
                                   "read_and_check_pedigree.png"))
  expect_true(waitsRightBeforeShot(codeOf(readScript(diagramScript)),
                                   "pb_diagram_legend.png"))
})
