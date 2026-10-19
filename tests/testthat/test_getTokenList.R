## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
lines <- c(
  "center = \"SNPRC\"",
  " baseUrl = \"https://boomer.txbiomed.local:8080/labkey\"",
  " schemaName = \"study\"", " folderPath = \"/SNPRC\"",
  " queryName = \"demographics\"",
  "lkPedColumns = (\"Id\", \"gender\", \"birth\", \"death\",",
  "              \"lastDayAtCenter\", \"dam\", \"sire\")",
  "mapPedColumns = (\"id\", \"sex\", \"birth\", \"death\", ",
  "  \"exit\", \"dam\", \"sire\")"
)
lkVec <- c(
  "Id", "gender", "birth", "death",
  "lastDayAtCenter", "dam", "sire"
)
mapVec <- c("id", "sex", "birth", "death", "exit", "dam", "sire")

test_that("getTokenList returns correct lines and vectors", {
  tokenList <- getTokenList(lines)
  params <- tokenList$param
  tokenVectors <- tokenList$tokenVec
  expect_equal(params, c(
    "center", "baseUrl", "schemaName", "folderPath",
    "queryName", "lkPedColumns", "mapPedColumns"
  ))
  expect_identical(tokenVectors[[1L]], "SNPRC")
  expect_identical(tokenVectors[[2L]], "https://boomer.txbiomed.local:8080/labkey")
  expect_identical(tokenVectors[[3L]], "study")
  expect_identical(tokenVectors[[4L]], "/SNPRC")
  expect_identical(tokenVectors[[5L]], "demographics")
  expect_identical(tokenVectors[[6L]], lkVec)
  expect_identical(tokenVectors[[7L]], mapVec)
})

## S1014 RED (the owner's ruling S1013, option A; evidence in
## docs/audits/CONFIG_FILE_FORMAT_DECISION_2026-10-18.md): the example file's
## notes promise that a double-quoted value is kept whole and that a "#"
## starts a comment, and a blank value is read as the next setting's name.
## The reader deleted every quote before it split, so none of that was true
## (the reader is unchanged since 2017-09-13). The rules below are the ruled
## ones. Blocks marked "pin" pass at HEAD and must keep passing: they hold the
## readings that do not change (the shipped file, semicolons, quoted names).
## A quote not closed on its line ending at the end of that line is a rule the
## RED plan added (the audit's prototype turned 3 settings into 1 on it).

## The value read for setting `name` from `cfgLines`; NULL when the setting is
## not there (a missing setting then fails an assertion, never throws).
readSetting <- function(cfgLines, name) {
  tokenList <- getTokenList(cfgLines)
  tokenList$tokenVec[match(name, tokenList$param)][[1L]]
}

test_that("getTokenList keeps a quoted value that holds a blank whole", {
  cfgLines <- c("folderPath = \"/My Folder/EHR\"", "queryName = \"demographics\"")
  expect_identical(readSetting(cfgLines, "folderPath"), "/My Folder/EHR")
  expect_identical(readSetting(cfgLines, "queryName"), "demographics")
})

test_that("getTokenList keeps a quoted value that holds a comma whole", {
  cfgLines <- "folderPath = \"/Lab, East/EHR\""
  expect_identical(readSetting(cfgLines, "folderPath"), "/Lab, East/EHR")
})

test_that("getTokenList keeps a quoted value that holds an equals sign whole", {
  cfgLines <- c("baseUrl = \"http://h/labkey?a=b\"", "center = \"SNPRC\"")
  expect_identical(getTokenList(cfgLines)$param, c("baseUrl", "center"))
  expect_identical(readSetting(cfgLines, "baseUrl"), "http://h/labkey?a=b")
})

test_that("getTokenList keeps round brackets inside quotes and drops them outside", {
  expect_identical(readSetting("folderPath = \"/Lab (old)/EHR\"", "folderPath"),
                   "/Lab (old)/EHR")
  expect_identical(readSetting("lkPedColumns = (Id, gender)", "lkPedColumns"),
                   c("Id", "gender"))
})

test_that("getTokenList keeps a quoted Windows path with a blank whole", {
  cfgLines <- "speciesOverridesPath = \"C:/Users/Jane Doe/over rides.csv\""
  expect_identical(readSetting(cfgLines, "speciesOverridesPath"),
                   "C:/Users/Jane Doe/over rides.csv")
})

test_that("getTokenList reads a whole list inside one pair of quotes as one value", {
  cfgLines <- "lkPedColumns = \"Id, gender, birth\""
  expect_identical(readSetting(cfgLines, "lkPedColumns"), "Id, gender, birth")
})

test_that("pin: getTokenList keeps each name in its own quotes separate", {
  cfgLines <- "lkPedColumns = (\"Id\", \"gender\", \"birth\")"
  expect_identical(readSetting(cfgLines, "lkPedColumns"),
                   c("Id", "gender", "birth"))
})

test_that("pin: getTokenList reads a quoted setting name", {
  expect_identical(readSetting("\"center\" = \"SNPRC\"", "center"), "SNPRC")
})

test_that("pin: getTokenList does not separate terms at a semicolon", {
  expect_identical(readSetting("lkPedColumns = (Id; gender; birth)", "lkPedColumns"),
                   c("Id;", "gender;", "birth"))
})

test_that("pin: getTokenList separates terms at blanks, commas, tabs and line breaks", {
  expect_identical(
    readSetting(c("lkPedColumns = Id gender,birth\tdeath,", "  dam"), "lkPedColumns"),
    c("Id", "gender", "birth", "death", "dam")
  )
})

test_that("getTokenList ends a setting's line at a comment that follows it", {
  cfgLines <- c("apiKey = realKey # from the LabKey site", "center = SNPRC")
  expect_identical(readSetting(cfgLines, "apiKey"), "realKey")
  expect_identical(readSetting(cfgLines, "center"), "SNPRC")
})

test_that("getTokenList skips a full-line comment itself, setting-looking text included", {
  cfgLines <- c("# apiKey = \"placeholder\"", "center = SNPRC")
  expect_identical(getTokenList(cfgLines)$param, "center")
})

test_that("pin: getTokenList ends a comment at the end of its line, not the end of the file", {
  cfgLines <- c("center = SNPRC # first", "baseUrl = http://x", "schemaName = study")
  expect_identical(getTokenList(cfgLines)$param,
                   c("center", "baseUrl", "schemaName"))
  expect_identical(readSetting(cfgLines, "baseUrl"), "http://x")
})

test_that("pin: getTokenList keeps a # that sits inside a word", {
  expect_identical(readSetting("baseUrl = http://x/labkey#top", "baseUrl"),
                   "http://x/labkey#top")
})

test_that("getTokenList keeps a # that sits inside quotes", {
  expect_identical(readSetting("queryName = \"demo # not a comment\"", "queryName"),
                   "demo # not a comment")
})

test_that("getTokenList gives a blank value in the middle an empty value", {
  cfgLines <- c("apiKey =", "center = \"SNPRC\"")
  expect_identical(getTokenList(cfgLines)$param, c("apiKey", "center"))
  expect_identical(readSetting(cfgLines, "apiKey"), character(0L))
  expect_identical(readSetting(cfgLines, "center"), "SNPRC")
})

test_that("getTokenList gives a blank value on the last setting an empty value", {
  cfgLines <- c("center = \"SNPRC\"", "apiKey =")
  expect_identical(readSetting(cfgLines, "center"), "SNPRC")
  expect_identical(readSetting(cfgLines, "apiKey"), character(0L))
})

test_that("getTokenList reads empty quotes as an empty string", {
  expect_identical(readSetting("apiKey = \"\"", "apiKey"), "")
})

test_that("pin: getTokenList ends a quote not closed on its line at the end of that line", {
  cfgLines <- c("center = \"SNPRC", "baseUrl = \"http://x\"", "schemaName = \"study\"")
  expect_identical(getTokenList(cfgLines)$param,
                   c("center", "baseUrl", "schemaName"))
  expect_identical(readSetting(cfgLines, "center"), "SNPRC")
  expect_identical(readSetting(cfgLines, "baseUrl"), "http://x")
  expect_identical(readSetting(cfgLines, "schemaName"), "study")
})

test_that("pin: getTokenList gives no settings for no lines or only comments", {
  empty <- list(param = character(0L), tokenVec = list())
  expect_identical(getTokenList(character(0L)), empty)
  expect_identical(getTokenList(c("# a", "   # b", "")), empty)
})

## S1014 mutation check: two readings the blocks above left unpinned. A # that
## follows a closing quote does not begin a word, and a quoted equals sign is a
## value, not the sign that names a setting.

test_that("pin: getTokenList keeps a # that follows a closing quote in its term", {
  expect_identical(readSetting("queryName = \"demo\"#tail", "queryName"),
                   "demo#tail")
  expect_identical(readSetting("queryName = \"\"#tail", "queryName"), "#tail")
})

test_that("pin: getTokenList reads a quoted equals sign as a value", {
  cfgLines <- c("separator = \"=\"", "center = SNPRC")
  expect_identical(getTokenList(cfgLines)$param, c("separator", "center"))
  expect_identical(readSetting(cfgLines, "separator"), "=")
})
