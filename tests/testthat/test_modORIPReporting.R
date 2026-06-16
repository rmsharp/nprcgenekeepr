# Tests for appUI/appServer wiring of the ORIP Reporting module (#47)
#
# The module pair modORIPReportingUI / modORIPReportingServer (R/modORIPReporting.R)
# is complete, documented, and unit-tested (see test_modSiteConfig.R "Tests for
# ORIP Reporting Module"), but was never mounted in the application. This file
# covers the mount-only wire-in: appUI must render the ORIP tab and appServer
# must initialize its module server. Mirrors the Phase-2 wiring idiom in
# test_modGvAndBgDesc.R.

test_that("appUI mounts the ORIP Reporting tab", {
  ui_html <- as.character(appUI())

  # Two discriminating markers, both absent from appUI at HEAD and present only
  # once modORIPReportingUI("oripReporting") is mounted in a tabPanel:
  #   1. The "oripReporting-" namespace prefix appears on the module's output
  #      and download-button IDs (e.g. oripReporting-siteInfo,
  #      oripReporting-downloadORIPReport) -- it can only be emitted by mounting
  #      the module UI under that exact id, so it proves the mount AND the id.
  #   2. "Office of Research Infrastructure Programs" is the module's own body
  #      text (R/modORIPReporting.R) and appears nowhere else in appUI -- it
  #      proves the ORIP module's content (not some other tab) rendered.
  expect_true(grepl("oripReporting-", ui_html))
  expect_true(grepl("Office of Research Infrastructure Programs", ui_html))
})

test_that("appServer mounts the ORIP Reporting module server", {
  # Structural check (mirrors this codebase's appServer wiring idiom in
  # test_modGvAndBgDesc.R and test_modSiteConfig.R): appServer must call
  # modORIPReportingServer so the tab's module is initialized, and it must use
  # the same "oripReporting" namespace the UI mounts under.
  appServer_text <- paste(deparse(appServer), collapse = "\n")
  expect_true(grepl("modORIPReportingServer", appServer_text))
  expect_true(grepl("oripReporting", appServer_text))
})
