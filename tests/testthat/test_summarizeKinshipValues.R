#' Copyright(c) 2017-2021 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)
context("summarizeKinshipValues")
ped <- nprcgenekeepr::smallPed
simParent_1 <- list(id = "A",
                   sires = c("s1_1", "s1_2", "s1_3"),
                   dams = c("d1_1", "d1_2", "d1_3", "d1_4"))
simParent_2 <- list(id = "B",
                   sires = c("s1_1", "s1_2", "s1_3"),
                   dams = c("d1_1", "d1_2", "d1_3", "d1_4"))
simParent_3 <- list(id = "E",
                   sires = c("A", "C", "s1_1"),
                   dams = c("d3_1", "B"))
simParent_4 <- list(id = "J",
                   sires = c("A", "C", "s1_1"),
                   dams = c("d3_1", "B"))
simParent_5 <- list(id = "K",
                   sires = c("A", "C", "s1_1"),
                   dams = c("d3_1", "B"))
simParent_6 <- list(id = "N",
                   sires = c("A", "C", "s1_1"),
                   dams = c("d3_1", "B"))
allSimParents <- list(simParent_1, simParent_2, simParent_3,
                     simParent_4, simParent_5, simParent_6)

extractKinship <- function(simKinships, id1, id2, simulation) {
 ids <- dimnames(simKinships[[simulation]])[[1]]
 simKinships[[simulation]][seq_along(ids)[ids == id1],
                           seq_along(ids)[ids == id2]]
}

extractKValue <- function(kValue, id1, id2, simulation) {
 kValue[kValue$id_1 ==  id1 & kValue$id_2 == id2, paste0("sim_", simulation)]
}

set_seed(seed = 1)
n <- 10
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
kValues <- kinshipMatricesToKValues(simKinships)
counts <- countKinshipValues(kValues)
stats <- summarizeKinshipValues(counts)

test_that("summarizeKinshipValues makes correct structure", {
  expect_equal(length(stats), 9)
  expect_equal(names(stats), c("id_1", "id_2", "min", "secondQuartile",
                               "mean", "median", "thirdQuartile", "max", "sd"))

  expect_equal(length(stats$id_1), 289)
})

test_that("summarizeKinshipValues summarizes kinship values correctly", {
  expect_equal(stats$id_1[10], "J")
  expect_equal(stats$id_2[10], "A")
  expect_equal(stats$min[10], 0)
  expect_equal(stats$secondQuartile[10], 0)
  expect_equal(stats$mean[10], 0,01)
  expect_equal(stats$median[10], 0)
  expect_equal(stats$thirdQuartile[10], 0.25)
  expect_equal(stats$max[10], 0.25)
  expect_equal(stats$sd[10], 0.1290994, tolerance = 0.00001)
})
