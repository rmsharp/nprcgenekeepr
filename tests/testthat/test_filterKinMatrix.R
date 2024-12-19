#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("filterKinMatrix")
library(testthat)

ped <- nprcgenekeepr::qcPed
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen,
                sparse = FALSE)
ids <- ped$id[c(189, 192, 194, 195)]
ncols <- ncol(kmat)
nrows <- nrow(kmat)
kmatFiltered <- filterKinMatrix(ids, kmat)
test_that("filterKinMatrix retains the correct rows and columns", {
  expect_equal(kmatFiltered[1, 2], kmat[189, 192])
  expect_equal(kmatFiltered[1, 3], kmat[189, 194])
  expect_equal(kmatFiltered[1, 4], kmat[189, 195])
  expect_equal(kmatFiltered[2, 3], kmat[192, 194])
})
ids <- c("C1ICXL", "2KULR3", "RI0O7F", "7M51X5", "170ZTZ", "Y7PPEZ",
         "CFPEEU", "ZC5SCR", "218FOV", "2IXJ2N", "CAST4W", "JGPN6K", "HOYW0S",
         "DD1U77", "0DAV0I", "HLI95R", "TZ5NUB", "DR5GXB", "EUG3WE", "FHV13N",
         "OUM6QF", "6Z7MD9", "309VM2", "8KM1MP", "I9TQ0T", "INGWI7")

kmatFiltered <- filterKinMatrix(ids, kmat)
test_that("filterKinMatrix leaves the correct rows", {
  expect_equal(nrow(kmatFiltered), length(ids))
  expect_equal(ncol(kmatFiltered), length(ids))
  expect_equal(kmat[(seq_len(nrow(kmat)))[rownames(kmat) %in% ids[20:23]],
                    (seq_len(ncol(kmat)))[colnames(kmat) %in% ids[20:23]]],
               kmatFiltered[20:23, 20:23])
}
)
