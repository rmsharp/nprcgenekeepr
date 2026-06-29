## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
test_that("headerDisplayNames makes the correct mapping", {
  expect_identical(
    headerDisplayNames(c("id", "sire", "dam", "gen")),
    c("Ego ID", "Sire ID", "Dam ID", "Generation #")
  )
  expect_identical(
    headerDisplayNames(c("spf", "second_name", "value")),
    c("SPF", "Second Allele", "Value Designation")
  )
})
