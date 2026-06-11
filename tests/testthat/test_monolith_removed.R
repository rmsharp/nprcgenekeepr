# Phase 9 (shiny-module conversion): the legacy monolithic Shiny application
# (inst/application) has been retired and must no longer ship with the
# package. This test is RED until inst/application/ is deleted (it is paired
# with that deletion commit).

test_that("the legacy monolith application directory no longer ships", {
  expect_identical(system.file("application", package = "nprcgenekeepr"), "")
})
