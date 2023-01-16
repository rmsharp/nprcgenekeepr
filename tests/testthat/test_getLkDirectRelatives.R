#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getLkDirectRelatives")

test_that(
  "getLkDirectRelatives throws an error with no LabKey session connection", {
    expect_warning(getLkDirectRelatives(), "The file should be named:")
})
