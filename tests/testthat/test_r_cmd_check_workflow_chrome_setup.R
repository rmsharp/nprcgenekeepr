# These tests guard .github/workflows/R-CMD-check.yaml against the intermittent
# chromote Chrome-launch failure documented in BACKLOG.md Housekeeping (found
# S616, 2026-08-20): chromote::find_chrome() falls back to whatever browser
# happens to be ambiently discoverable on each of the 5 matrix runners
# (macos-latest, windows-latest, ubuntu-latest x3), with no pinning and no
# pre-flight health check -- observed failing as "launch_chrome() -> Chrome$new()
# -> startup() abort" on ubuntu-latest and "Chrome debugging port not open
# after 10 seconds" on windows-latest (S618). .github/workflows/shinytest2.yaml
# already solved an analogous flake (docs/planning/phase8-e2e-harness-subplan.md
# Risk R5, snap-chromium on ubuntu) via a 3-step pattern: provision a pinned
# Chrome-for-Testing binary, point CHROMOTE_CHROME at it explicitly, and assert
# chromote::find_chrome() resolves before any test runs. These tests assert
# R-CMD-check.yaml carries the same 3-step pattern, in the same order, ahead of
# the check-r-package step -- so a future session cannot silently drop or
# reorder it (the same regression class test_shinytest2_workflow_coverage.R
# guards for the sibling workflow's own group partition).

workflow_path <- testthat::test_path(
  "..", "..", ".github", "workflows", "R-CMD-check.yaml"
)

read_workflow_lines <- function(path) {
  readLines(path, warn = FALSE)
}

## Drops full-line YAML comments before matching, so a comment that merely
## *mentions* a step (e.g. explaining WHY CHROMOTE_CHROME is set) can't be
## mistaken for the step itself -- this file's own comments do exactly that
## (see the "chromote::find_chrome() honours CHROMOTE_CHROME first" comment
## directly above the real Point-chromote step).
drop_comment_lines <- function(lines) {
  lines[!grepl("^\\s*#", lines)]
}

first_match <- function(lines, pattern) {
  hit <- grep(pattern, lines)
  if (length(hit) == 0L) NA_integer_ else hit[1]
}

test_that("R-CMD-check.yaml provisions a pinned Chrome via browser-actions/setup-chrome@v2", {
  skip_if_not(file.exists(workflow_path),
              "R-CMD-check.yaml not present in this build")

  lines <- drop_comment_lines(read_workflow_lines(workflow_path))

  expect_true(
    any(grepl("uses:\\s*browser-actions/setup-chrome@v2", lines)),
    info = "R-CMD-check.yaml does not provision Chrome via browser-actions/setup-chrome@v2 (the shinytest2.yaml-proven pattern)"
  )
  expect_true(
    any(grepl("^\\s*id:\\s*setup-chrome\\s*$", lines)),
    info = "the setup-chrome step needs `id: setup-chrome` so a later step can reference steps.setup-chrome.outputs.chrome-path"
  )
  expect_true(
    any(grepl("install-dependencies:\\s*true", lines)),
    info = "setup-chrome should install Chrome's required system libraries (install-dependencies: true), matching shinytest2.yaml"
  )
})

## Extracts the lines belonging to the FIRST step whose block (from its own
## "- name:"/"- uses:" line up to, but not including, the next step at the
## same nesting) matches `pattern` -- used to check a step's own `shell:`
## override without accidentally matching a different step's `shell:` line.
step_block_containing <- function(lines, pattern) {
  step_starts <- grep("^\\s*-\\s+(name:|uses:)", lines)
  hit <- grep(pattern, lines)
  if (length(hit) == 0L || length(step_starts) == 0L) return(character(0))
  start_idx <- max(step_starts[step_starts <= hit[1]])
  later_starts <- step_starts[step_starts > start_idx]
  end_idx <- if (length(later_starts) == 0L) length(lines) else later_starts[1] - 1L
  lines[start_idx:end_idx]
}

test_that("R-CMD-check.yaml points chromote at the installed Chrome via CHROMOTE_CHROME", {
  skip_if_not(file.exists(workflow_path),
              "R-CMD-check.yaml not present in this build")

  lines <- drop_comment_lines(read_workflow_lines(workflow_path))

  expect_true(
    any(grepl("CHROMOTE_CHROME=.*steps\\.setup-chrome\\.outputs\\.chrome-path", lines)),
    info = "R-CMD-check.yaml does not export CHROMOTE_CHROME from the setup-chrome step's chrome-path output"
  )
  expect_true(
    any(grepl("GITHUB_ENV", lines)),
    info = "CHROMOTE_CHROME must be written to $GITHUB_ENV so it is visible to the later check-r-package step"
  )

  ## The matrix includes windows-latest, whose run: default shell is
  ## PowerShell, not bash -- unlike shinytest2.yaml (ubuntu-only, where bash
  ## is the OS default). The `echo ... >> "$GITHUB_ENV"` line is bash syntax
  ## and silently no-ops under PowerShell (CHROMOTE_CHROME reads back empty,
  ## chromote falls back to whatever Chrome is ambiently on PATH -- exactly
  ## the failure this whole fix exists to prevent). Confirmed live on a real
  ## windows-latest CI run (S618): CHROMOTE_CHROME = "" .
  block <- step_block_containing(lines, "CHROMOTE_CHROME=.*steps\\.setup-chrome\\.outputs\\.chrome-path")
  expect_true(
    length(block) > 0 && any(grepl("shell:\\s*bash", block)),
    info = "the CHROMOTE_CHROME-exporting step must declare `shell: bash` explicitly -- its bash-syntax `>> \"$GITHUB_ENV\"` silently no-ops under windows-latest's default PowerShell shell"
  )
})

test_that("R-CMD-check.yaml asserts Chrome is resolvable by chromote before check-r-package runs", {
  skip_if_not(file.exists(workflow_path),
              "R-CMD-check.yaml not present in this build")

  lines <- drop_comment_lines(read_workflow_lines(workflow_path))

  expect_true(
    any(grepl("chromote::find_chrome\\(\\)", lines)),
    info = "R-CMD-check.yaml does not assert chromote::find_chrome() resolves before tests run"
  )

  idx_setup <- first_match(lines, "uses:\\s*browser-actions/setup-chrome@v2")
  idx_env <- first_match(lines, "CHROMOTE_CHROME=.*steps\\.setup-chrome\\.outputs\\.chrome-path")
  idx_assert <- first_match(lines, "chromote::find_chrome\\(\\)")
  idx_check <- first_match(lines, "uses:\\s*r-lib/actions/check-r-package@v2")

  expect_true(
    all(!is.na(c(idx_setup, idx_env, idx_assert, idx_check))),
    info = "one or more of the 4 ordering anchors (setup-chrome / CHROMOTE_CHROME / find_chrome() / check-r-package) is missing"
  )
  expect_true(
    isTRUE(idx_setup < idx_env) && isTRUE(idx_env < idx_assert) && isTRUE(idx_assert < idx_check),
    info = paste0(
      "Chrome provisioning steps are not in the required order ",
      "(setup-chrome < CHROMOTE_CHROME export < find_chrome() assertion < check-r-package): ",
      "got line numbers ", paste(idx_setup, idx_env, idx_assert, idx_check, collapse = ", ")
    )
  )
})

test_that("the Chrome-provisioning steps are skipped on macos-latest (S619 CDP-timeout fallback)", {
  ## macos-latest reverts to ambient/unpinned Chrome discovery (S616's own
  ## proven-green behavior for that leg) rather than the pinned
  ## Chrome-for-Testing binary the other 4 legs use. Root cause: the pinned
  ## binary's freshly-launched ChromoteSession hangs on its internal
  ## Runtime.evaluate bootstrap probe on macos-latest specifically -- NOT a
  ## simple "10s wasn't long enough" cold-start latency issue, since raising
  ## default_timeout to 60s (helper-live-render-positions.R) did NOT resolve
  ## it on a real CI push (run 32417985922, still timed out after the full
  ## 60s, 3/3 identical failures) -- confirmed live, S619, 2026-08-20.
  ## ubuntu-latest/windows-latest keep the pin; only macos-latest is
  ## excluded, matching the pin's own original committed rationale, which
  ## never named macos-latest as needing it in the first place.
  skip_if_not(file.exists(workflow_path),
              "R-CMD-check.yaml not present in this build")

  lines <- drop_comment_lines(read_workflow_lines(workflow_path))

  chrome_step_patterns <- c(
    "uses:\\s*browser-actions/setup-chrome@v2",
    "CHROMOTE_CHROME=.*steps\\.setup-chrome\\.outputs\\.chrome-path",
    "chromote::find_chrome\\(\\)"
  )

  for (pattern in chrome_step_patterns) {
    block <- step_block_containing(lines, pattern)
    expect_true(
      length(block) > 0 &&
        any(grepl("if:.*matrix\\.config\\.os\\s*!=\\s*'macos-latest'", block)),
      info = paste0(
        "the step matching '", pattern, "' must carry an `if:` guard ",
        "excluding matrix.config.os == 'macos-latest' -- macos-latest ",
        "reverts to ambient Chrome (S619 fallback), the pinned binary hangs ",
        "there even with a raised timeout"
      )
    )
  }
})
