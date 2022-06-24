#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getRecordStatusIndex")
library(testthat)
test_that(
  "getRecordStatusIndex handles dataframe without a recordStatus column", {
    data("pedSix")
    expect_equal(nprcgenekeepr:::getRecordStatusIndex(pedSix), integer(0))
    pedSix <- cbind(pedSix, recordStatus = c(rep("original", 5),
                                              rep("added", 3)))
    expect_equal(nprcgenekeepr:::getRecordStatusIndex(pedSix, status = "added"),
                 c(6:8))
    expect_equal(nprcgenekeepr:::getRecordStatusIndex(pedSix,
                                                      status = "original"),
                 c(1:5))

})
