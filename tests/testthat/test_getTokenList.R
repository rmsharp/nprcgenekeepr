#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getTokenList")
library(testthat)
lines <- c("center = \"SNPRC\"",
           " baseUrl = \"https://boomer.txbiomed.local:8080/labkey\"",
           " schemaName = \"study\"", " folderPath = \"/SNPRC\"",
           " queryName = \"demographics\"",
           "lkPedColumns = (\"Id\", \"gender\", \"birth\", \"death\",",
           "              \"lastDayAtCenter\", \"dam\", \"sire\")",
           "mapPedColumns = (\"id\", \"sex\", \"birth\", \"death\", ",
           "  \"exit\", \"dam\", \"sire\")")
lkVec <- c("Id", "gender", "birth", "death",
           "lastDayAtCenter", "dam", "sire")
mapVec <- c("id", "sex", "birth", "death", "exit", "dam", "sire")

test_that("getTokenList returns correct lines and vectors", {
  tokenList <- getTokenList(lines)
  params <- tokenList$param
  tokenVectors <- tokenList$tokenVec
  expect_equal(params, c("center", "baseUrl", "schemaName", "folderPath",
                         "queryName", "lkPedColumns", "mapPedColumns"))
  expect_equal(tokenVectors[[1]], "SNPRC")
  expect_equal(tokenVectors[[2]], "https://boomer.txbiomed.local:8080/labkey")
  expect_equal(tokenVectors[[3]], "study")
  expect_equal(tokenVectors[[4]],"/SNPRC")
  expect_equal(tokenVectors[[5]], "demographics")
  expect_equal(tokenVectors[[6]], lkVec)
  expect_equal(tokenVectors[[7]], mapVec)
})
