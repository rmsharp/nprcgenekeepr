#' Copyright(c) 2017-2023 R. Mark Sharp
# This file is part of nprcgenekeepr
context("removeDuplicates")
library(testthat)
library(stringi)
ped <- nprcgenekeepr::smallPed
newPed <- cbind(ped, recordStatus = rep("original", nrow(ped)))

test_that("removeDuplicates removes nothing with no duplicates", {
  ped1 <- removeDuplicates(newPed)
  expect_equal(nrow(newPed), nrow(ped1))
  ped <- rbind(newPed, newPed[1:3, ])
  ped1 <- removeDuplicates(ped)
  expect_equal(nrow(ped) - 3, nrow(ped1))
  ped <- newPed
  ped2 <- ped[1:3, ]
  ped2$dam[[1]] <- "B"
  ped <- rbind(ped, ped2)
  expect_error(removeDuplicates(ped))
})
test_that("removeDuplicates detects missing column and stops processing", {
  expect_error(removeDuplicates(ped))
  expect_silent(removeDuplicates(newPed))
})
test_that(stri_c("removeDuplicates returns NULL reportErrors flag == TRUE ",
         "when there are no duplicates"), {
  expect_true(is.null(removeDuplicates(newPed, reportErrors = TRUE)))
  ped <- rbind(newPed, newPed[1:3, ])
  ped1 <- removeDuplicates(ped, reportErrors = TRUE)
  expect_equal(ped1, c("A", "B", "C"))
  ped <- newPed
  ped2 <- ped[1:3, ]
  ped2$dam[[1]] <- "B"
  ped <- rbind(ped, ped2)
  expect_equal(removeDuplicates(ped, reportErrors = TRUE), c("A", "B", "C"))
})

