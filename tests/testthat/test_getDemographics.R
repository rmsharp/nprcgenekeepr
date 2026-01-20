#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr

test_that("getDemographics throws an error with no LabKey session connection", {
  expect_warning(
    getDemographics()
  )
})
