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
#
# The cap was raised from 30 to 45 minutes on 2026-09-27 (S794). The
# scheduled run of 2026-10-23 was then CANCELLED at 45 min although the
# tests ran at their usual pace: apt downloads in setup ran at about 52
# kB/s (309 to 1,328 kB/s the night before), so setup alone took
# 31 min 47 s. That night needed about 55 min in all (an estimate), so
# the cap is now 75. See
# docs/audits/SHINYTEST2_TIMEOUT_DIAGNOSIS_2026-10-23.md.

workflow_path <- shinytest2WorkflowPath()

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
    timeout_minutes, 75L,
    info = paste0(
      "shinytest2.yaml's job timeout-minutes is ", timeout_minutes,
      ", not 75 -- the nightly job was cancelled at 45 min on 2026-10-23 ",
      "because package downloads in setup ran slow (setup took 31 min 47 s; ",
      "the tests then ran at their usual pace); see ",
      "docs/audits/SHINYTEST2_TIMEOUT_DIAGNOSIS_2026-10-23.md"
    )
  )
})
