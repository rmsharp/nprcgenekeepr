## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
test_that(
  "getRecordStatusIndex handles dataframe without a recordStatus column",
  {
    data("pedSix")
    expect_identical(nprcgenekeepr:::getRecordStatusIndex(pedSix), integer(0L))
    pedSix <- cbind(pedSix, recordStatus = c(
      rep("original", 5L),
      rep("added", 3L)
    ))
    expect_identical(
      nprcgenekeepr:::getRecordStatusIndex(pedSix, status = "added"),
      6L:8L
    )
    expect_identical(
      nprcgenekeepr:::getRecordStatusIndex(pedSix,
        status = "original"
      ),
      1L:5L
    )
  }
)

## A missing (NA) or unrecognized status is neither "added" nor "original", so
## it must never appear in either index (an NA index breaks a later subscript).
test_that(paste0(
  "getRecordStatusIndex never matches an NA or unrecognized recordStatus"
), {
  ped <- data.frame(
    id = letters[1L:6L],
    recordStatus = c("original", "added", NA, "weird", "added", "original"),
    stringsAsFactors = FALSE
  )
  expect_identical(
    nprcgenekeepr:::getRecordStatusIndex(ped, status = "added"),
    c(2L, 5L)
  )
  expect_identical(
    nprcgenekeepr:::getRecordStatusIndex(ped, status = "original"),
    c(1L, 6L)
  )
})

test_that("getRecordStatusIndex returns no records when every status is NA", {
  ped <- data.frame(
    id = letters[1L:3L], recordStatus = NA_character_,
    stringsAsFactors = FALSE
  )
  expect_identical(
    nprcgenekeepr:::getRecordStatusIndex(ped, status = "added"),
    integer(0L)
  )
  expect_identical(
    nprcgenekeepr:::getRecordStatusIndex(ped, status = "original"),
    integer(0L)
  )
})
