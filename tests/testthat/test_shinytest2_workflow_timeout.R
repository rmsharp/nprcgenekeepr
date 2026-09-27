# Guards .github/workflows/shinytest2.yaml's job-level `timeout-minutes:`
# against the scheduled nightly job silently outgrowing its cap again.
#
# The job's wall-clock duration has grown from ~20-22 min (early August 2026)
# to consistently 24-30 min (September 2026) as the E2E tier's test coverage
# grew, and was CANCELLED at its 30-minute cap on 2026-09-27 (job duration
# 30.02 min; the prior night, 2026-09-26, succeeded at 29.87 min -- 8 seconds
# under the cap). This is a capacity-growth trend, not a hang: no single
# module group is stuck. See BACKLOG.md's "Up Next" shinytest2 item for the
# measured run-duration history.

workflow_path <- testthat::test_path(
  "..", "..", ".github", "workflows", "shinytest2.yaml"
)

extract_timeout_minutes <- function(path) {
  lines <- readLines(path, warn = FALSE)
  hit <- grep("^\\s*timeout-minutes:\\s*[0-9]+\\s*$", lines)
  stopifnot(length(hit) == 1L)
  as.integer(sub("^\\s*timeout-minutes:\\s*([0-9]+)\\s*$", "\\1", lines[hit]))
}

test_that("shinytest2.yaml's job timeout-minutes has headroom above the observed run-duration trend", {
  skip_if_not(file.exists(workflow_path),
              "shinytest2.yaml not present in this build")

  timeout_minutes <- extract_timeout_minutes(workflow_path)

  expect_equal(
    timeout_minutes, 45L,
    info = paste0(
      "shinytest2.yaml's job timeout-minutes is ", timeout_minutes,
      ", not 45 -- the nightly job has been observed within ~2 minutes of ",
      "its cap (cancelled 2026-09-27 at 30.02 min, succeeded 2026-09-26 at ",
      "29.87 min) on a steady growth trend; see BACKLOG.md's shinytest2 item"
    )
  )
})
