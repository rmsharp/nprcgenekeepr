## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #167 Slice 4: modSnapshotTrends becomes the 16th top-level tab (D7),
# wired from appServer.R off modGeneticValueServer's new snapshotSource
# reactive (S760 catalog amendment,
# docs/planning/issue167-longitudinal-monitoring-plan.md sec 4). D7's "zero
# changes to existing tabs" constraint means these tests assert only
# ADDITIVE structure -- every pre-existing top-level tab label must still be
# present, byte-unchanged.

wiringUiHtml <- as.character(appUI())

test_that("appUI() renders the Genetic-Health Trends tab", {
  expect_true(grepl("Genetic-Health Trends", wiringUiHtml, fixed = TRUE))
})

test_that("appUI() still renders all 15 pre-existing top-level tab labels (D7 zero-changes)", {
  existingLabels <- c(
    "Home", "Input", "Pedigree Browser", "Age-Sex Pyramid",
    "Genetic Value Analysis", "Summary Statistics", "Breeding Groups",
    "Mate Pair Analysis", "Genetic Diversity", "Marker Genetics",
    "Cross-Center Identity", "De-Identified Export", "Potential Parents",
    "Genetic Value Analysis and Breeding Group Description", "More"
  )
  for (label in existingLabels) {
    expect_true(grepl(label, wiringUiHtml, fixed = TRUE),
                info = paste("Missing pre-existing tab label:", label))
  }
})

test_that("appServer() mounts modSnapshotTrendsServer wired from modGeneticValueServer's snapshotSource", {
  appServerText <- paste(deparse(appServer), collapse = "\n")

  expect_true(grepl("modSnapshotTrendsServer", appServerText, fixed = TRUE))
  expect_true(grepl("gvResults$snapshotSource", appServerText, fixed = TRUE))
})

# Issue #170 Slice 3 (S1039): the Build earlier snapshots panel rebuilds past
# populations, so it needs the FULL pedigree. analysisPedigree is trimmed to
# the focal animals when a focal list is entered (R/modPedigree.R:427-430) and
# would silently shrink every past population (design B10, Dragon 2).
test_that("appServer() gives the Trends module the full pedigree, never the focal-trimmed one", {
  appServerText <- paste(deparse(appServer), collapse = "\n")
  start <- regexpr("modSnapshotTrendsServer(", appServerText, fixed = TRUE)
  expect_true(start > 0L)
  call <- substr(appServerText, start, start + 300L)

  expect_true(grepl("fullPedigree = pedigreeResults$processedPedigree", call,
                    fixed = TRUE))
  expect_false(grepl("analysisPedigree", call, fixed = TRUE))
  ## and the analysis still comes from the Genetic Value module
  expect_true(grepl("snapshotSource = gvResults$snapshotSource", call,
                    fixed = TRUE))
})
