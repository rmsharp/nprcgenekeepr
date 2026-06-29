## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# Tests for defaultSiteParams(): the single internal source of truth for the
# no-config (ONPRC) fallback returned by getSiteInfo(). LabKey research Rec #2
# -- centralize the hardcoded ONPRC defaults so the fallback has one definition
# (no behavior change to getSiteInfo()'s returned values).

test_that("defaultSiteParams returns the canonical ONPRC fallback values", {
  params <- defaultSiteParams()
  expect_type(params, "list")
  expect_equal(
    names(params),
    c("center", "baseUrl", "schemaName", "folderPath", "queryName",
      "lkPedColumns", "mapPedColumns")
  )
  expect_equal(params$center, "ONPRC")
  expect_equal(params$baseUrl, "https://primeuat.ohsu.edu")
  expect_equal(params$schemaName, "study")
  expect_equal(params$folderPath, "/ONPRC/EHR")
  expect_equal(params$queryName, "demographics")
  expect_equal(
    params$lkPedColumns,
    c("Id", "gender", "birth", "death", "lastDayAtCenter",
      "Id/parents/dam", "Id/parents/sire")
  )
  expect_equal(
    params$mapPedColumns,
    c("id", "sex", "birth", "death", "exit", "dam", "sire")
  )
  # lkPedColumns and mapPedColumns must stay a 1:1 mapping.
  expect_equal(length(params$lkPedColumns), length(params$mapPedColumns))
})

test_that("getSiteInfo no-config fallback is sourced from defaultSiteParams", {
  # Force the no-config path deterministically (the test_loadSiteConfig pattern):
  # point HOME at an empty temp dir so getSiteInfo() finds no config file and
  # returns the fallback regardless of the host machine's real config. This
  # asserts the fallback and the single source of truth never diverge.
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  params <- defaultSiteParams()
  siteInfo <- getSiteInfo(expectConfigFile = FALSE)
  expect_equal(siteInfo$center, params$center)
  expect_equal(siteInfo$baseUrl, params$baseUrl)
  expect_equal(siteInfo$schemaName, params$schemaName)
  expect_equal(siteInfo$folderPath, params$folderPath)
  expect_equal(siteInfo$queryName, params$queryName)
  expect_equal(siteInfo$lkPedColumns, params$lkPedColumns)
  expect_equal(siteInfo$mapPedColumns, params$mapPedColumns)
})
