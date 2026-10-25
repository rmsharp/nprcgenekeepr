## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Test for the performance and memory campaign's Phase 4, group
#' formation (owner pick S1056; plan docs/planning/performance-memory-
#' campaign-plan.md, Phase 4, "Surface: ... the Breeding Groups tab in the
#' browser tier for a run at 1,000 trials"). groupAddAssign()'s help asks for
#' at least 1,000 trials. On ExamplePedigree.csv with "All available" (332
#' living animals) and the tab's other defaults (3 groups, kinship threshold
#' 0.25), groupAddAssign() took 24.8 s for 1,000 trials with today's code and
#' 5.9 s with a prototype of the new code (S1056, fresh processes, this Mac).
#' In this tab, from the Form Groups click until the groups were ready, today's
#' code took 25.9 s at 1,000 trials and 1.0 s at 10 (S1056, this Mac).
#'
#' The run must take under 15 s off CI. A CI runner is slower and shared, so
#' there the limit is 120 s: the test then checks only that 1,000 trials finish
#' and the groups are shown.
library(testthat)

test_that(
  "E2E: Breeding Groups forms groups from 1,000 trials on the example
   pedigree in time", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_1000_trials")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples", "ExamplePedigree.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture, timeout = 120000)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  app$set_inputs(`breedingGroups-animalSource` = "all",
                 `breedingGroups-nIterations` = 1000, wait_ = FALSE)
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  ## The wait polls the page, but a poll waits while the app's R process is
  ## busy (S1056: one poll lasted the whole 25.9 s run on today's code), so
  ## the wait cannot enforce the limit: the time is measured and compared.
  limit <- if (identical(Sys.getenv("CI"), "true")) 120 else 15
  started <- proc.time()[["elapsed"]]
  if (!click_element_safe(app, "#breedingGroups-formGroups")) {
    skip("Form Groups click failed")
  }
  finished <- wait_for_module_ready(app, "breedingGroups", timeout = 300000L)
  elapsed <- proc.time()[["elapsed"]] - started
  expect_true(finished, info = "1,000 trials finish")
  if (!finished) {
    return(invisible())
  }
  expect_lt(elapsed, limit, label = sprintf(
    "seconds from the click until the groups are ready, %.1f,", elapsed
  ))

  if (!click_element_safe(app, "a[data-value='Group Detail']")) {
    skip("Group Detail tab activation failed")
  }
  expect_true(
    grepl("Age in Years", get_html_safe(app, "#breedingGroups-groupMemberTable")),
    info = "the formed groups are shown"
  )

  logs <- app$get_logs()
  errors <- logs[logs$level == "throw", ]
  expect_equal(nrow(errors), 0L, info = "No console errors")
})
