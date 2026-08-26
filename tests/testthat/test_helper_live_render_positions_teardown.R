## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Regression guard for the `checking for detritus in the temp directory`
#' NOTE R CMD check flags on all 3 `ubuntu-latest` legs of R-CMD-check.yaml
#' (BACKLOG.md Housekeeping item, found S636, confirmed reproducing S637,
#' root-caused S638). Direct chromote 0.5.1 source inspection confirmed
#' `getLiveRenderedPositions()` (helper-live-render-positions.R) closes only
#' the `ChromoteSession` it creates (`on.exit(b$close(), add = TRUE)`),
#' never the parent `Chromote` object returned by
#' `chromote::default_chromote_object()` -- a process-wide singleton reused
#' across all calls. Because that parent is never gracefully `$close()`-d,
#' the underlying Chrome subprocess is only ever hard-killed by processx's
#' `supervise = TRUE` parent-exit mechanism (`launch_chrome_impl()`) when
#' the R test session ends. A hard-killed Chromium process never runs its
#' own `ProcessSingleton::Cleanup()`, so its per-launch lock directory
#' (`SingletonCookie` + `SingletonSocket`, named `<bundle-id>.<random>` --
#' `org.chromium.Chromium.<random>` on the unbranded Chrome-for-Testing
#' build CI uses) is left behind directly in the shared OS temp directory,
#' which is exactly what R CMD check's detritus step flags. Confirmed by a
#' local repro (S638): a subprocess that creates+closes a ChromoteSession
#' WITHOUT closing the parent leaves a new `<bundle-id>.<random>` lock dir
#' behind after the R process exits; the identical script WITH an explicit
#' `chromeParent$close()` leaves nothing behind. A directly-inspected real
#' leftover directory's contents (`SingletonCookie` symlink +
#' `SingletonSocket` Unix socket) match Chromium's documented
#' `ProcessSingleton` implementation exactly, not some other artifact.
#'
#' The fix: getLiveRenderedPositions() registers a ONE-TIME,
#' session-teardown-scoped graceful close of the shared parent
#' (`withr::defer(chromeParent$close(), envir = testthat::teardown_env())`)
#' on its first call, guarded so it registers exactly once even though the
#' function is called multiple times (test_positionMatingUnitForest.R has 3
#' call sites sharing the one browser) -- no change to Chrome-launch
#' count/timing (still one shared launch, matters given the already-
#' documented macos-latest first-launch timeout sensitivity,
#' test_helper_live_render_positions_timeout.R), just a graceful shutdown
#' instead of a hard kill at the very end of the test suite.
#'
#' Deliberately structural only, matching the sibling
#' test_helper_live_render_positions_timeout.R's own house style: asserts
#' the fix's source pattern is present so a future edit cannot silently
#' drop it. A supplementary live test (a dedicated, non-default
#' `Chromote$new()` instance proving `$close()` removes its own
#' temp-dir process-singleton lock files) was prototyped and worked
#' reliably in every standalone reproduction, but proved flaky
#' specifically inside `devtools::check()`'s sandboxed check subprocess
#' (0 new entries found even after a 5s poll, root cause not pinned down)
#' -- and it never exercised this fix's own code path anyway (it doesn't
#' call `getLiveRenderedPositions()` or touch `chromeParent`). Dropped
#' rather than chased further (S638, owner-directed): the REAL fix is
#' verified empirically instead by running the actual consumer,
#' test_positionMatingUnitForest.R (which calls this helper 3 times, the
#' only real usage in the test suite), as a standalone subprocess and
#' diffing the OS temp root before/after -- 0 leftover entries, confirmed
#' locally -- plus the mandatory live CI push/watch this project requires
#' for CI-infrastructure fixes (see BACKLOG.md / PROJECT_LEARNINGS.md).

helper_src <- deparse(body(getLiveRenderedPositions))

test_that("getLiveRenderedPositions() registers a teardown-scoped close of the parent Chromote object", {
  expect_true(
    any(grepl("teardown_env\\(\\)", helper_src)),
    info = paste(
      "getLiveRenderedPositions() body does not reference",
      "testthat::teardown_env() -- the shared chromote parent is never",
      "closed at session end, only the individual session"
    )
  )
  expect_true(
    any(grepl("withr::defer(", helper_src, fixed = TRUE)),
    info = "getLiveRenderedPositions() body does not register a withr::defer() teardown"
  )
  expect_true(
    any(grepl("chromeParent\\$close\\(\\)", helper_src)),
    info = paste(
      "getLiveRenderedPositions() body does not call chromeParent$close()",
      "-- only the ChromoteSession is closed, never the parent browser",
      "process, so it is only ever hard-killed at R exit, never given a",
      "chance to clean up its own temp-dir process-singleton lock files"
    )
  )
})

test_that("the parent-close registration happens after chromeParent is created, not before", {
  idx_parent <- grep("default_chromote_object\\(\\)", helper_src)
  idx_defer <- grep("withr::defer(", helper_src, fixed = TRUE)
  expect_true(
    length(idx_parent) > 0 && length(idx_defer) > 0,
    info = "one or both anchors (default_chromote_object() / withr::defer()) not found"
  )
  expect_true(
    length(idx_parent) > 0 && length(idx_defer) > 0 &&
      min(idx_parent) < min(idx_defer),
    info = paste(
      "chromeParent must be assigned from default_chromote_object() before",
      "the teardown close is registered on it"
    )
  )
})
