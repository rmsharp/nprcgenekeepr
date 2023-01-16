#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)
context("countKinshipValues")
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
extractKValue <- function(kValue, id1, id2, simulation) {
  kValue[id_1 ==  id1 & id_2 == id2, paste0("sim_", simulation), with = FALSE][[1]]
}

set_seed(seed = 1)
n <- 10
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
kValues <- kinshipMatricesToKValues(simKinships)
counts <- countKinshipValues(kValues)
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
kValues <- kinshipMatricesToKValues(simKinships)
cummulatedCounts <- countKinshipValues(kValues, counts)

test_that("countKinshipValues detects contaminated ID list", {
  counts$kIds[[1]] <- c("badID_1", "badID_2")
  suppressWarnings(expect_error(countKinshipValues(kValues, counts),
               "ID pairs in simulated pedigrees do not match:"))
})
test_that("countKinshipValues makes correct structure", {
  expect_equal(length(counts), 3)
  expect_equal(names(counts), c("kIds", "kValues", "kCounts"), with = FALSE)
  expect_equal(length(counts$kIds), 153)
})

test_that("countKinshipValues counts kinship values correctly", {
  expect_equal(counts$kCounts[[10]], c(6, 4))
  expect_equal(counts$kValues[[7]], c(0.125, 0.25))
  expect_equal(as.character(counts$kIds[[3]]), c("A", "C"))
})

test_that("countKinshipValues makes correct structure", {
  expect_equal(length(cummulatedCounts), 3)
  expect_equal(names(cummulatedCounts), c("kIds", "kValues", "kCounts"))
  expect_equal(length(cummulatedCounts$kIds), 153)
})

test_that("countKinshipValues counts kinship values correctly", {
  expect_equal(cummulatedCounts$kCounts[[10]], c(14, 6))
  expect_equal(cummulatedCounts$kValues[[7]], c(0.125, 0.25))
  expect_equal(as.character(cummulatedCounts$kIds[[3]]), c("A", "C"))
})

