# Tests for shouldShowOripTab() -- the pure predicate gating the ORIP Reporting
# tab to ONPRC deployments (#49).
#
# The ORIP Reporting tab (wired in #47) is Oregon (ONPRC)-specific grant
# reporting. It must be shown ONLY when the active site configuration indicates
# ONPRC via an ACTUAL config file -- not the getSiteInfo() default fallback,
# which returns center = "ONPRC" when NO config file exists. The predicate
# therefore requires BOTH a real config file (hasConfigFile = TRUE) AND
# center == "ONPRC". Mirrors the pure-predicate idiom of
# shouldShowChangedColsTab() (R/shouldShowChangedColsTab.R).

test_that("shouldShowOripTab is TRUE only for an actual ONPRC config", {
  expect_true(shouldShowOripTab("ONPRC", TRUE))
})

test_that("shouldShowOripTab is FALSE for a non-ONPRC (SNPRC) config", {
  expect_false(shouldShowOripTab("SNPRC", TRUE))
})

test_that("shouldShowOripTab is FALSE for the no-config ONPRC default fallback", {
  # getSiteInfo() returns center = "ONPRC" by default when NO config file
  # exists; that fallback must NOT show the tab (gate on a real Oregon config,
  # not the default).
  expect_false(shouldShowOripTab("ONPRC", FALSE))
})

test_that("shouldShowOripTab is FALSE for SNPRC with no config file", {
  expect_false(shouldShowOripTab("SNPRC", FALSE))
})

test_that("shouldShowOripTab is FALSE for a NULL center", {
  # Defensive: a missing/NULL center must not show the tab.
  expect_false(shouldShowOripTab(NULL, TRUE))
})
