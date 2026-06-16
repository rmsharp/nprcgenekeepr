# Tests for appUI/appServer wiring of the ORIP Reporting module (#47, #49).
#
# The module pair modORIPReportingUI / modORIPReportingServer
# (R/modORIPReporting.R) is complete, documented, and unit-tested (see
# test_modSiteConfig.R "Tests for ORIP Reporting Module"). It was mounted as a
# top-level tab in #47. ORIP grant reporting is Oregon (ONPRC)-specific, so #49
# gates the tab to show ONLY when an ACTUAL ONPRC site configuration is active:
# appUI includes the ORIP tabPanel only when shouldShowOripTab() is TRUE, and
# appServer mounts the module server under the same gate. These tests inject a
# siteInfo list so the gating is deterministic (independent of the host's
# ~/.nprcgenekeepr_config); appUI checks file.exists(siteInfo$configFile), so an
# existing file path means "a config file is present" (its contents are
# irrelevant to the gate).

# A real, existing file standing in for "a config file is present".
oripConfigPresent <- tempfile("orip_config_present_")
writeLines("center = ONPRC", oripConfigPresent)

test_that("appUI shows the ORIP Reporting tab under an actual ONPRC config", {
  ui_html <- as.character(
    appUI(siteInfo = list(center = "ONPRC", configFile = oripConfigPresent))
  )

  # Two discriminating markers, present only when modORIPReportingUI(
  # "oripReporting") is mounted in a tabPanel:
  #   1. the "oripReporting-" namespace prefix on the module's output/button IDs
  #   2. "Office of Research Infrastructure Programs" -- the module's body text
  expect_true(grepl("oripReporting-", ui_html))
  expect_true(grepl("Office of Research Infrastructure Programs", ui_html))
})

test_that("appUI hides the ORIP Reporting tab under a non-ONPRC config", {
  ui_html <- as.character(
    appUI(siteInfo = list(center = "SNPRC", configFile = oripConfigPresent))
  )

  # A SNPRC deployment must NOT see the Oregon-specific ORIP tab.
  expect_false(grepl("oripReporting-", ui_html))
  expect_false(grepl("Office of Research Infrastructure Programs", ui_html))
})

test_that("appUI hides the ORIP Reporting tab when no config file is present", {
  # getSiteInfo()'s default fallback yields center = "ONPRC" with a config-file
  # path that does NOT exist; that fallback must hide the tab.
  missingConfig <- tempfile("no_such_config_")
  ui_html <- as.character(
    appUI(siteInfo = list(center = "ONPRC", configFile = missingConfig))
  )

  expect_false(grepl("oripReporting-", ui_html))
  expect_false(grepl("Office of Research Infrastructure Programs", ui_html))
})

test_that("appServer mounts the ORIP Reporting module server under the ONPRC gate", {
  # Structural check (mirrors this codebase's appServer wiring idiom in
  # test_modGvAndBgDesc.R and test_appServer_dynamicTabs.R): appServer must call
  # modORIPReportingServer using the "oripReporting" namespace, AND gate that
  # mount on shouldShowOripTab so the server is not initialized off-ONPRC.
  appServer_text <- paste(deparse(appServer), collapse = "\n")
  expect_true(grepl("modORIPReportingServer", appServer_text))
  expect_true(grepl("oripReporting", appServer_text))
  expect_true(grepl("shouldShowOripTab", appServer_text))
})
