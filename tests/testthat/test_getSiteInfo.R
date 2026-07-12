## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(stringi)
test_that("getSiteInfo at least returns the right elements", {
  expect_equal(
    suppressWarnings(names(getSiteInfo())),
    c(
      "center", "baseUrl", "schemaName", "folderPath", "queryName",
      "lkPedColumns", "mapPedColumns", "sysname", "release",
      "version", "nodename", "machine", "login", "user",
      "effective_user", "homeDir", "configFile",
      "requiredCols", "possibleCols", "includeColumns"
    )
  )
})

test_that("getSiteInfo folds the column-list functions in (no-config)", {
  # XARCH-8 remainder: getRequiredCols()/getPossibleCols()/getIncludeColumns()
  # must be reachable from getSiteInfo() itself, not just as standalone
  # exports, on the no-config (default) branch.
  siteInfo <- getSiteInfo(expectConfigFile = FALSE)
  expect_identical(siteInfo$requiredCols, getRequiredCols())
  expect_identical(siteInfo$possibleCols, getPossibleCols())
  expect_identical(siteInfo$includeColumns, getIncludeColumns())
})

test_that("getSiteInfo folds the column-list functions in (config present)", {
  # Same fields must also be present on the config-file branch -- both
  # return paths in getSiteInfo() must carry the new fields identically.
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  example_cfg <- system.file("extdata", "example_nprcgenekeepr_config",
                              package = "nprcgenekeepr")
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  file.copy(example_cfg, file.path(tmp, cfg_name))

  siteInfo <- getSiteInfo()
  expect_identical(siteInfo$requiredCols, getRequiredCols())
  expect_identical(siteInfo$possibleCols, getPossibleCols())
  expect_identical(siteInfo$includeColumns, getIncludeColumns())
})

test_that("getSiteInfo handled Windows and non-windows opperating systems", {
  siteInfo <- suppressWarnings(getSiteInfo())
  if (stri_detect_fixed(toupper(siteInfo$sysname), "WIND")) {
    expect_equal(
      siteInfo$homeDir,
      file.path(Sys.getenv("HOME"))
    )
    expect_equal(
      siteInfo$configFile,
      file.path(Sys.getenv("HOME"), "_nprcgenekeepr_config")
    )
  } else {
    expect_equal(siteInfo$homeDir, Sys.getenv("HOME"))
    expect_equal(siteInfo$configFile, file.path(Sys.getenv("HOME"),
                                                ".nprcgenekeepr_config"))
  }
})
test_that("getSiteInfo handle expectConfigFile parameter", {
  expect_warning(getSiteInfo())
  expect_warning(getSiteInfo(expectConfigFile = TRUE))
  expect_silent(getSiteInfo(expectConfigFile = FALSE))
})

test_that("getSiteInfo returns default values when no config file", {
  siteInfo <- suppressWarnings(getSiteInfo())
  expect_equal(siteInfo$center, "ONPRC")
  expect_equal(siteInfo$schemaName, "study")
  expect_equal(siteInfo$queryName, "demographics")
})

test_that("getSiteInfo returns system information", {
  siteInfo <- suppressWarnings(getSiteInfo())
  expect_true(!is.null(siteInfo$sysname))
  expect_true(!is.null(siteInfo$release))
  expect_true(!is.null(siteInfo$nodename))
  expect_true(!is.null(siteInfo$machine))
  expect_true(!is.null(siteInfo$login))
  expect_true(!is.null(siteInfo$user))
})

test_that("getSiteInfo returns lkPedColumns and mapPedColumns", {
  siteInfo <- suppressWarnings(getSiteInfo())
  expect_true(length(siteInfo$lkPedColumns) > 0)
  expect_true(length(siteInfo$mapPedColumns) > 0)
  expect_equal(length(siteInfo$lkPedColumns), length(siteInfo$mapPedColumns))
})

test_that("getSiteInfo mapPedColumns contains expected fields", {
  siteInfo <- suppressWarnings(getSiteInfo())
  expect_true("id" %in% siteInfo$mapPedColumns)
  expect_true("sex" %in% siteInfo$mapPedColumns)
  expect_true("birth" %in% siteInfo$mapPedColumns)
  expect_true("sire" %in% siteInfo$mapPedColumns)
  expect_true("dam" %in% siteInfo$mapPedColumns)
})
