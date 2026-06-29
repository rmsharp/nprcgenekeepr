## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
pedOne <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
  stringsAsFactors = FALSE
)
pedTwo <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
  stringsAsFactors = FALSE
)

pedThree <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c("s0", "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
  stringsAsFactors = FALSE
)

test_that("addUIds modifies the correct IDs in the right way", {
  newPed <- addUIds(pedOne)
  expect_equal(newPed, pedOne)
  newPed <- addUIds(pedTwo)
  expect_equal(newPed$sire[newPed$id == "s1"], "U0001")
  newPed <- addUIds(pedThree)
  expect_equal(newPed$dam[newPed$id == "s1"], "U0001")
})

## NEW-45 guarantee: auto-generated placeholder IDs (U####) must never contain
## a period ('.'). pedTwo/pedThree force U-id generation. This property holds on
## current code and must continue to hold (characterization guard).
test_that("addUIds generates period-free IDs (NEW-45 guarantee)", {
  npTwo <- addUIds(pedTwo)
  npThree <- addUIds(pedThree)
  expect_false(any(grepl(".", npTwo$sire[!is.na(npTwo$sire)], fixed = TRUE)))
  expect_false(any(grepl(".", npThree$dam[!is.na(npThree$dam)], fixed = TRUE)))
})
