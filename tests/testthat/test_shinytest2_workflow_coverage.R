# These tests guard .github/workflows/shinytest2.yaml's hand-curated per-module
# "groups" regex array (Phase-8e-7) against silent coverage drift: a new
# test-{app,e2e}-*.R file that matches none of the group regexes runs
# locally/in the fast unit CI but is NEVER executed by the nightly E2E job,
# with no error anywhere (see PROJECT_LEARNINGS.md Learning 312 -- this is the
# concrete case that surfaced it: test-e2e-orip-module.R and
# test-e2e-potential-parents-module.R were added by later sessions and
# matched none of the groups that existed at the time).

workflow_path <- testthat::test_path(
  "..", "..", ".github", "workflows", "shinytest2.yaml"
)

extract_group_regexes <- function(path) {
  lines <- readLines(path, warn = FALSE)
  start <- grep("groups=\\(", lines)
  stopifnot(length(start) == 1L)
  end <- start + which(grepl("^\\s*\\)\\s*$", lines[-seq_len(start)]))[1]
  body <- lines[(start + 1L):(end - 1L)]
  m <- regmatches(body, regexpr('"([^"]*)"', body))
  gsub('^"|"$', "", m)
}

tracked_e2e_files <- function() {
  list.files(
    testthat::test_path(),
    pattern = "^test-(app|e2e)-.*\\.R$"
  )
}

strip_test_name <- function(files) {
  ## Mirrors testthat::test_dir(filter=)'s own match target, per the
  ## workflow's own comment: strip the "test-" prefix and ".R" extension.
  sub("\\.R$", "", sub("^test-", "", files))
}

test_that("every test-{app,e2e}-*.R file is covered by exactly one CI group", {
  skip_if_not(file.exists(workflow_path),
              "shinytest2.yaml not present in this build")

  group_regexes <- extract_group_regexes(workflow_path)
  expect_true(length(group_regexes) > 0,
              info = "failed to parse any group regexes out of shinytest2.yaml")

  stripped <- strip_test_name(tracked_e2e_files())
  expect_true(length(stripped) > 0,
              info = "no test-{app,e2e}-*.R files found under tests/testthat")

  match_counts <- vapply(stripped, function(name) {
    sum(vapply(group_regexes, function(rx) grepl(rx, name), logical(1)))
  }, integer(1))

  uncovered <- stripped[match_counts == 0L]
  expect_true(
    length(uncovered) == 0L,
    info = paste0(
      "test-{app,e2e}-*.R file(s) matched by NONE of the shinytest2.yaml ",
      "group regexes (never run by the opt-in E2E CI job): ",
      paste(uncovered, collapse = ", ")
    )
  )

  overcovered <- stripped[match_counts > 1L]
  expect_true(
    length(overcovered) == 0L,
    info = paste0(
      "test-{app,e2e}-*.R file(s) matched by MORE THAN ONE shinytest2.yaml ",
      "group regex (would run twice, defeating the fresh-process partition): ",
      paste(overcovered, collapse = ", ")
    )
  )
})
