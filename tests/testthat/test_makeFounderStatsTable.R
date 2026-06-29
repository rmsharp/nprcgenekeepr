## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)

# Issue #82 Slice 3: makeFounderStatsTable() shows the founder-genome-equivalent
# sampling SE inline ("FG +/- SE") in its FG cell when the founderStats list
# carries a finite fgSE, and degrades to the bare FG when fgSE is absent or NA
# (additive -- the SE rides next to the existing FG value, formatted to two
# decimals to match the chosen "FG +/- SE" rendering).

baseStats <- list(
  total = 50L, nMaleFounders = 20L, nFemaleFounders = 30L,
  fe = 25.5, fg = 22.3
)

test_that("makeFounderStatsTable renders FG +/- SE when fgSE present (issue #82 Slice 3)", {
  html <- makeFounderStatsTable(c(baseStats, list(fgSE = 0.4)))
  expect_true(grepl("22.30 \\+/- 0.40", html))
})

test_that("makeFounderStatsTable shows bare FG when fgSE absent or NA (issue #82 Slice 3)", {
  htmlNo <- makeFounderStatsTable(baseStats)
  expect_true(grepl(">22.3<", htmlNo)) # bare FG cell, no SE appended
  expect_false(grepl("\\+/-", htmlNo))

  htmlNa <- makeFounderStatsTable(c(baseStats, list(fgSE = NA_real_)))
  expect_false(grepl("\\+/-", htmlNa))
})

test_that("makeFounderStatsTable still reports N/A FG and handles NULL (regression)", {
  expect_match(makeFounderStatsTable(NULL), "No founder statistics")
  htmlNaFg <- makeFounderStatsTable(list(total = 1L, fe = 1.0, fg = NA))
  expect_true(grepl("N/A", htmlNaFg))
})
