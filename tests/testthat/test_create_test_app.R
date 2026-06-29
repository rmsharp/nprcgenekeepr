## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Unit tests for the create_test_app() E2E test helper (defined in
#' helper-shinytest2.R). These tests are deliberately browser-free: they
#' exercise the helper's opt-in gate and its app-directory contract, NOT the
#' shinytest2 AppDriver. They therefore always run (no skip), unlike the
#' test-e2e-*/test-app-* files create_test_app() serves.
library(testthat)

test_that("create_test_app() returns a runnable Shiny app directory when E2E is opted in", {
  old <- Sys.getenv("NPRC_RUN_E2E", unset = NA)
  on.exit(
    if (is.na(old)) Sys.unsetenv("NPRC_RUN_E2E") else Sys.setenv(NPRC_RUN_E2E = old),
    add = TRUE
  )
  Sys.setenv(NPRC_RUN_E2E = "true")

  app_dir <- create_test_app()

  expect_type(app_dir, "character")
  expect_length(app_dir, 1L)
  expect_true(nzchar(app_dir))
  expect_true(dir.exists(app_dir))
  # shinytest2::AppDriver needs an app.R (or ui.R/server.R) in the directory.
  expect_true(file.exists(file.path(app_dir, "app.R")))
})

test_that("create_test_app() skips (opt-in gate) when NPRC_RUN_E2E is not 'true'", {
  old <- Sys.getenv("NPRC_RUN_E2E", unset = NA)
  on.exit(
    if (is.na(old)) Sys.unsetenv("NPRC_RUN_E2E") else Sys.setenv(NPRC_RUN_E2E = old),
    add = TRUE
  )
  Sys.unsetenv("NPRC_RUN_E2E")

  # Catch the condition so the skip does not propagate to this test; we want to
  # assert that a testthat "skip" condition was raised (which is what makes the
  # 23 test-e2e-*/test-app-* files skip rather than error).
  cnd <- tryCatch(create_test_app(), condition = function(c) c)
  expect_s3_class(cnd, "skip")
})
