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

first_match <- function(lines, pattern) {
  hit <- grep(pattern, lines)
  if (length(hit) == 0L) NA_integer_ else hit[1]
}

test_that("R-CMD-check.yaml provisions a pinned Chrome via browser-actions/setup-chrome@v2", {
  skip_if_not(file.exists(workflow_path),
              "R-CMD-check.yaml not present in this build")

  lines <- read_workflow_lines(workflow_path)

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

test_that("R-CMD-check.yaml points chromote at the installed Chrome via CHROMOTE_CHROME", {
  skip_if_not(file.exists(workflow_path),
              "R-CMD-check.yaml not present in this build")

  lines <- read_workflow_lines(workflow_path)

  expect_true(
    any(grepl("CHROMOTE_CHROME=.*steps\\.setup-chrome\\.outputs\\.chrome-path", lines)),
    info = "R-CMD-check.yaml does not export CHROMOTE_CHROME from the setup-chrome step's chrome-path output"
  )
  expect_true(
    any(grepl("GITHUB_ENV", lines)),
    info = "CHROMOTE_CHROME must be written to $GITHUB_ENV so it is visible to the later check-r-package step"
  )
})

test_that("R-CMD-check.yaml asserts Chrome is resolvable by chromote before check-r-package runs", {
  skip_if_not(file.exists(workflow_path),
              "R-CMD-check.yaml not present in this build")

  lines <- read_workflow_lines(workflow_path)

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
