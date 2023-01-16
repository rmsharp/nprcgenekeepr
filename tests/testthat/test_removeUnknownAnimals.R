#' Copyright(c) 2017-2023 R. Mark Sharp
# This file is part of nprcgenekeepr
context("removeUnknownAnimals")
library(testthat)
library(stringi)
ped <- nprcgenekeepr::smallPed
newPed <- cbind(ped, recordStatus = rep("original", nrow(ped)),
                stringsAsFactors = FALSE)
addedPed <- newPed
addedPed[1:3, "recordStatus"] <- "added"
test_that(stri_c("removeUnknownAnimals removes nothing with no \"added\" ",
          "(unknown) animals"), {
  ped1 <- removeUnknownAnimals(newPed)
  expect_true(nrow(ped1) == nrow(newPed))
  expect_true(nrow(ped1) == nrow(addedPed))
})

test_that(stri_c("removeUnknownAnimals removes \"added\" ",
                   "(unknown) animals"), {
  ped2 <- removeUnknownAnimals(addedPed)
  expect_false(nrow(ped2) == nrow(addedPed))
  expect_true(nrow(ped2) + 3 == nrow(addedPed))
})

