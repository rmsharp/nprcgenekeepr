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
  example_cfg <- exampleConfigPath()
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

## S1012 (docs-audit part 2 CI1, the shared cause): getSiteInfo() read every
## line of the configuration file, comments included, so a commented-out
## setting above the real one won and a comment after the last setting was
## glued onto that setting's value. The helper puts a configuration file in a
## temporary home directory under the name getConfigFileName() expects.
write_home_config <- function(lines, env = parent.frame()) {
  tmp <- withr::local_tempdir(.local_envir = env)
  withr::local_envvar(c(HOME = tmp), .local_envir = env)
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(lines, file.path(tmp, cfg_name))
  invisible(tmp)
}

required_config_lines <- c(
  "center = \"SNPRC\"",
  "baseUrl = \"http://deepthought:8080/labkey\"",
  "schemaName = \"study\"",
  "folderPath = \"/snprcEHR\"",
  "queryName = \"demographics\"",
  "lkPedColumns = (\"Id\", \"gender\", \"birth\", \"death\",",
  "                \"lastDayAtCenter\", \"dam\", \"sire\")",
  "mapPedColumns = (\"id\", \"sex\", \"birth\", \"death\",",
  "                \"exit\", \"dam\", \"sire\")"
)

test_that("getSiteInfo ignores a commented-out setting above the real one", {
  write_home_config(c("# center = \"OLD\"", required_config_lines))
  expect_identical(getSiteInfo()$center, "SNPRC")
})

test_that("getSiteInfo keeps a comment after the last setting out of its value", {
  write_home_config(c(required_config_lines, "# the last column is optional"))
  expect_identical(
    getSiteInfo()$mapPedColumns,
    c("id", "sex", "birth", "death", "exit", "dam", "sire")
  )
})

test_that("getSiteInfo reads a setting written with a capital first letter", {
  write_home_config(sub("^center", "Center", required_config_lines))
  expect_identical(
    tryCatch(getSiteInfo()$center, error = function(e) conditionMessage(e)),
    "SNPRC"
  )
})

test_that("getSiteInfo reads the shipped example config unchanged", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  example_cfg <- exampleConfigPath()
  file.copy(example_cfg,
            file.path(tmp, basename(getConfigFileName(Sys.info())[["configFile"]])))
  siteInfo <- getSiteInfo()
  expect_identical(siteInfo$center, "SNPRC")
  expect_identical(siteInfo$baseUrl, "http://deepthought:8080/labkey")
  expect_identical(siteInfo$schemaName, "study")
  expect_identical(siteInfo$folderPath, "/snprcEHR")
  expect_identical(siteInfo$queryName, "demographics")
  expect_identical(
    siteInfo$lkPedColumns,
    c("Id", "gender", "birth", "death", "lastDayAtCenter", "dam", "sire")
  )
  expect_identical(
    siteInfo$mapPedColumns,
    c("id", "sex", "birth", "death", "exit", "dam", "sire")
  )
})

## S1014 RED (BACKLOG.md:168, the owner's ruling S1013, option A): the reader
## keeps a quoted value whole, ends a line at a "#" that starts a word, and
## gives a blank value an empty value. The blocks reach it through
## getSiteInfo() (readConfigLines() then getTokenList()), with the setting
## under test swapped into required_config_lines. A thrown error is turned
## into its message so a failing block fails an assertion.

swap_config_line <- function(name, newLine) {
  hit <- startsWith(required_config_lines, name)
  stopifnot(sum(hit) == 1L)
  replace(required_config_lines, hit, newLine)
}

site_value <- function(field) {
  tryCatch(getSiteInfo()[[field]], error = function(e) conditionMessage(e))
}

test_that("getSiteInfo reads a quoted folder path with a blank as one value", {
  write_home_config(swap_config_line("folderPath", "folderPath = \"/My Folder/EHR\""))
  expect_identical(site_value("folderPath"), "/My Folder/EHR")
  expect_identical(site_value("queryName"), "demographics")
})

test_that("getSiteInfo reads a quoted address with an equals sign as one value", {
  write_home_config(swap_config_line(
    "baseUrl", "baseUrl = \"http://deepthought:8080/labkey?a=b\""))
  expect_identical(site_value("baseUrl"), "http://deepthought:8080/labkey?a=b")
  expect_identical(site_value("center"), "SNPRC")
})

test_that("getSiteInfo keeps a comment after a setting out of its value", {
  write_home_config(swap_config_line(
    "queryName", "queryName = \"demographics\" # the LabKey table"))
  expect_identical(site_value("queryName"), "demographics")
})

test_that("getSiteInfo reads each list written in one pair of quotes as one name", {
  write_home_config(c(
    required_config_lines[1:5],
    "lkPedColumns = \"Id, gender, birth, death, lastDayAtCenter, dam, sire\"",
    "mapPedColumns = \"id, sex, birth, death, exit, dam, sire\""
  ))
  expect_identical(site_value("lkPedColumns"),
                   "Id, gender, birth, death, lastDayAtCenter, dam, sire")
  expect_identical(site_value("mapPedColumns"),
                   "id, sex, birth, death, exit, dam, sire")
})

test_that("getSiteInfo gives a blank setting an empty value and keeps the next one", {
  write_home_config(swap_config_line("center", "center ="))
  expect_identical(site_value("center"), character(0L))
  expect_identical(site_value("baseUrl"), "http://deepthought:8080/labkey")
})
