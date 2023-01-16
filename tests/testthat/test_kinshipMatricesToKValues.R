#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)
context("kinshipMatricesToKValues")

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
  kValue[id_1 ==  id1 & id_2 == id2, paste0("sim_", simulation), with = FALSE][[1]]
}

set_seed(seed = 1)
n <- 10
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
kValue <- kinshipMatricesToKValues(simKinships)
test_that("kinshipMatricesToKValues gets correct kinship values", {
  expect_equal(extractKinship(simKinships, "A", "B", 2),
    extractKValue(kValue, id1 = "A", id2 = "B", simulation = 2))
  expect_equal(extractKinship(simKinships, "A", "C", 2),
               extractKValue(kValue, id1 = "A", id2 = "C", simulation = 2))
  expect_equal(extractKinship(simKinships, "A", "D", 2),
               extractKValue(kValue, id1 = "A", id2 = "D", simulation = 2))
  expect_equal(extractKinship(simKinships, "A", "E", 2),
               extractKValue(kValue, id1 = "A", id2 = "E", simulation = 2))
  expect_equal(extractKinship(simKinships, "A", "B", 3),
               extractKValue(kValue, id1 = "A", id2 = "B", simulation = 3))
})
