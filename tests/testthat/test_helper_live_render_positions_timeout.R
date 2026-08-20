## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Structural test guarding getLiveRenderedPositions() (helper-live-render-
#' positions.R) against the macos-latest chromote CDP-timeout CI failure in
#' R-CMD-check.yaml (BACKLOG.md Housekeeping item, found S618, diagnosed
#' S619). Direct chromote 0.5.1 source inspection (rstudio/chromote,
#' R/chromote_session.R) confirmed ChromoteSession$new() unconditionally
#' issues an internal Runtime.evaluate command during its own bootstrap
#' (private$get_pixel_ratio(), reading window.devicePixelRatio for
#' Emulation$setDeviceMetricsOverride) -- not a call this helper makes
#' itself -- governed by a 10-second default_timeout field on the parent
#' Chromote object, with no constructor argument to raise it. Confirmed
#' failing 3/3 real CI pushes as "Chromote: timed out waiting for response
#' to command Runtime.evaluate" inside ChromoteSession$new() itself, always
#' on macos-latest -- GitHub's most resource-constrained hosted-runner class
#' (3 vCPU/7GB vs. 4 vCPU/16GB on Linux) -- on the run's first-ever
#' chromote-driven Chrome launch (this test file's chromote calls are the
#' ONLY chromote usage anywhere in tests/testthat/, confirmed by grep), late
#' in an already-loaded R CMD check run, immediately after a freshly-
#' downloaded, never-before-executed Chrome-for-Testing binary was
#' provisioned. Same pinned binary is green on ubuntu-latest/windows-latest,
#' and a same-day A/B in this project's own CI history (S616's ambient-
#' Chrome green run vs. S618's pinned-Chrome red runs) rules out a test/code
#' regression as the cause -- see BACKLOG.md's chromote item and
#' PROJECT_LEARNINGS.md for the full ranked-hypothesis diagnosis.
#'
#' These tests assert the helper raises
#' chromote::default_chromote_object()$default_timeout to >= 60s BEFORE
#' creating its first ChromoteSession, so a future edit cannot silently drop
#' the fix.
#'
#' Deliberately BROWSER-FREE / source-structural, not a live chromote test:
#' the bug this guards against manifests only under macos-latest's specific
#' CI resource constraints on a freshly-provisioned Chrome binary, which a
#' local run cannot reproduce either way (matching this project's own
#' precedent for CI-only regressions, e.g. test_r_cmd_check_workflow_
#' chrome_setup.R's structural, non-live house style). A live assertion here
#' could only ever confirm the timeout VALUE took effect -- source
#' inspection proves that deterministically, without launching Chrome.

helper_src <- deparse(body(getLiveRenderedPositions))

test_that("getLiveRenderedPositions() references chromote's default_timeout / default_chromote_object()", {
  expect_true(
    any(grepl("default_timeout", helper_src, fixed = TRUE)),
    info = "getLiveRenderedPositions() body does not reference default_timeout at all"
  )
  expect_true(
    any(grepl("default_chromote_object\\(\\)", helper_src)),
    info = paste(
      "getLiveRenderedPositions() body does not reference",
      "chromote::default_chromote_object() (the process-wide singleton",
      "ChromoteSession$new() reuses on every call with no parent arg)"
    )
  )
})

test_that("the default_timeout raise happens BEFORE ChromoteSession$new(), not after", {
  idx_timeout <- grep("default_timeout", helper_src)
  idx_new <- grep("ChromoteSession\\$new\\(\\)", helper_src)
  expect_true(
    length(idx_timeout) > 0 && length(idx_new) > 0,
    info = paste(
      "one or both anchors (default_timeout / ChromoteSession$new())",
      "not found in the helper body"
    )
  )
  expect_true(
    length(idx_timeout) > 0 && length(idx_new) > 0 &&
      min(idx_timeout) < min(idx_new),
    info = paste(
      "default_timeout must be raised BEFORE ChromoteSession$new() is",
      "called -- ChromoteSession$new() itself is what times out, so",
      "raising the timeout after creating the session is too late"
    )
  )
})

test_that("the raised default_timeout is at least 60 seconds", {
  ## chromote's own 10s default was observed insufficient for the run's
  ## FIRST chromote-driven Chrome launch on macos-latest (3/3 real CI
  ## failures, S618/S619). 60s gives real headroom above the ~240s-into-a-
  ## loaded-run cold-start cost this diagnosis measured, while remaining a
  ## bounded ceiling (not Inf) so a genuinely wedged session still fails
  ## the test suite rather than hanging indefinitely.
  timeout_lines <- helper_src[grepl("default_timeout\\s*<-\\s*[0-9]+", helper_src)]
  expect_true(
    length(timeout_lines) > 0,
    info = "no line assigns a numeric literal to default_timeout"
  )
  raised_value <- if (length(timeout_lines) > 0) {
    as.numeric(sub(".*default_timeout\\s*<-\\s*([0-9]+).*", "\\1", timeout_lines[1]))
  } else {
    NA_real_
  }
  expect_gte(raised_value, 60)
})
