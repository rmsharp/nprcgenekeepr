## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
library(stringi)
ped <- nprcgenekeepr::smallPed
newPed <- cbind(ped,
  recordStatus = rep("original", nrow(ped)),
  stringsAsFactors = FALSE
)
addedPed <- newPed
addedPed[1L:3L, "recordStatus"] <- "added"
test_that(stri_c(
  "removeUnknownAnimals removes nothing with no \"added\" ",
  "(unknown) animals"
), {
  ped1 <- removeUnknownAnimals(newPed)
  expect_identical(nrow(ped1), nrow(newPed))
  expect_identical(nrow(ped1), nrow(addedPed))
})

test_that(stri_c(
  "removeUnknownAnimals removes \"added\" ",
  "(unknown) animals"
), {
  ped2 <- removeUnknownAnimals(addedPed)
  expect_false(nrow(ped2) == nrow(addedPed))
  expect_identical(nrow(ped2) + 3L, nrow(addedPed))
})

test_that(stri_c(
  "removeUnknownAnimals returns a pedigree without a recordStatus column ",
  "unchanged"
), {
  expect_false("recordStatus" %in% names(ped))
  expect_identical(removeUnknownAnimals(ped), ped)
  pedSix <- nprcgenekeepr::pedSix
  expect_false("recordStatus" %in% names(pedSix))
  expect_identical(removeUnknownAnimals(pedSix), pedSix)
})

test_that(stri_c(
  "removeUnknownAnimals keeps the columns when every animal is \"added\""
), {
  allAddedPed <- newPed
  allAddedPed$recordStatus <- "added"
  noneLeft <- removeUnknownAnimals(allAddedPed)
  expect_identical(nrow(noneLeft), 0L)
  expect_identical(names(noneLeft), names(allAddedPed))
})

test_that("removeUnknownAnimals handles zero-row pedigrees", {
  expect_identical(removeUnknownAnimals(ped[0L, ]), ped[0L, ])
  zeroWithStatus <- newPed[0L, ]
  result <- removeUnknownAnimals(zeroWithStatus)
  expect_identical(nrow(result), 0L)
  expect_identical(names(result), names(zeroWithStatus))
})
