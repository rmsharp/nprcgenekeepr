## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
# Tests for appUI()'s getSiteInfo() default-argument guard (R/appUI.R).
#
# appUI <- function(siteInfo = getSiteInfo(expectConfigFile = FALSE)) evaluates
# its default argument expression on first reference inside the function body,
# which happens on every real call (runGeneKeepR() calls appUI() with no
# argument). A present-but-malformed site-config file (e.g. missing the
# required 'center' key) makes getParamDef() stop(), which previously
# propagated uncaught, crashing app boot via UI construction -- the same
# issue #50 crash class loadSiteConfig() was built to prevent, and the same
# crash class fixed at the ORIP-tab gate in appServer.R (S378), but at this
# independent, unguarded call site. Found by S378's live shinytest2::AppDriver
# boot check -- shiny::testServer(appServer, ...) cannot detect this, since it
# never constructs appUI(). See BACKLOG.md and test_appServer_server.R
# section 6b for the sibling fix this mirrors.
library(testthat)

test_that("appUI() does not crash when the site config file is malformed", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(c("baseUrl = \"http://example\"", "schemaName = \"study\""),
             file.path(tmp, cfg_name))

  expect_no_error(appUI())
})

test_that(paste("appUI() does not render the ORIP Reporting tab when the site",
                 "config file is malformed (fail closed)"), {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(c("baseUrl = \"http://example\"", "schemaName = \"study\""),
             file.path(tmp, cfg_name))

  ui_html <- as.character(appUI())
  expect_false(grepl("ORIP Reporting", ui_html, fixed = TRUE))
})
