## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
tokens <- list(
  param = c(
    "center", "baseUrl", "schemaName", "folderPath", "queryName",
    "lkPedColumns", "mapPedColumns", "sqlServerDSN", "sqlServerPed",
    "cd.at_sfbr", "m.id"
  ),
  tokenVec = list(
    "SNPRC", "http://vger/labkey", "study", "/SNPRC", "demographics",
    c("Id", "gender", "birth", "death", "lastDayAtCenter", "dam", "sire"),
    c("id", "sex", "birth", "death", "exit", "dam", "sire"),
    "frogstar-vortex-animal-msharp",
    c(
      "select", "m.id", "m.sex", "convertchar12", "m.birth_date", "110",
      "as", "birth", "convertchar12", "m.death_date", "110", "as", "death",
      "CASE", "WHEN"
    ),
    c(
      "'Y'", "THEN", "NULL", "ELSE", "cd.disp_date_tm_max", "END", "AS",
      "lastDayAtCenter", "m.dam_id", "as", "dam", "m.sire_id", "as", "sire",
      "from", "master", "m", "inner", "join", "current_data", "cd", "on"
    ),
    c("cd.id", "where", "m.id", "in", "'", "ids_str", "'")
  )
)
test_that("getParamDef returns the correct values", {
  expect_identical(getParamDef(tokens, "baseUrl"), "http://vger/labkey")
  expect_identical(getParamDef(tokens, "center"), "SNPRC")
  expect_identical(getParamDef(tokens, "queryName"), "demographics")
  expect_error(getParamDef(tokens, "thisIsNotAParam"))
})

## S1012 (docs-audit part 2 CI3): the presence check ignored case but the read
## did not, so a setting written "Center" stopped with "subscript out of
## bounds" instead of being read (or refused with the "Could not find" text).
caseTokens <- list(
  param = c("Center", "baseUrl"),
  tokenVec = list("SNPRC", "http://vger/labkey")
)

test_that("getParamDef reads a setting whose name differs only in case", {
  expect_identical(
    tryCatch(getParamDef(caseTokens, "center"),
             error = function(e) conditionMessage(e)),
    "SNPRC"
  )
  expect_identical(
    tryCatch(getParamDef(caseTokens, "baseurl"),
             error = function(e) conditionMessage(e)),
    "http://vger/labkey"
  )
})

test_that("getParamDef reads a lowercase setting asked for in camel case", {
  # getSiteInfo() asks for "baseUrl", "schemaName" and so on; a file may spell
  # them in lowercase.
  lowerTokens <- list(
    param = c("center", "baseurl"),
    tokenVec = list("SNPRC", "http://vger/labkey")
  )
  expect_identical(
    tryCatch(getParamDef(lowerTokens, "baseUrl"),
             error = function(e) conditionMessage(e)),
    "http://vger/labkey"
  )
})

test_that("getParamDef prefers the exact-case name when both cases exist", {
  both <- list(param = c("Center", "center"), tokenVec = list("AAA", "BBB"))
  expect_identical(getParamDef(both, "center"), "BBB")
  expect_identical(getParamDef(both, "Center"), "AAA")
})

test_that("getParamDef stops naming the setting when it is absent", {
  expect_error(getParamDef(caseTokens, "queryName"),
               "Could not find queryName in configuration file")
})
