#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)
library(stringi)
qcPed <- nprcgenekeepr::qcPed

qcPed <- qcPed[order(qcPed$id), ]
ped <- qcPed
genotype <- data.frame(
  id = ped$id[50L + 1L:20L],
  first_name = stri_c("first", 1L:20L),
  second_name = stri_c("second", 1L:20L),
  stringsAsFactors = FALSE
)

test_that("addGenotype forms correct dataframe", {
  newPed <- addGenotype(ped, genotype)
  newPed <- newPed[order(newPed$id), ]
  expect_identical(as.character(newPed$first[newPed$id == ped$id[50L + 1L]]),
                   "10001")
  expect_identical(
    as.character(newPed$second[newPed$id == ped$id[50L + 1L]]),
    "10021"
  )
  expect_identical(
    as.character(newPed$first[newPed$id == ped$id[50L + 2L]]),
    "10012"
  )
  expect_identical(
    as.character(newPed$second[newPed$id == ped$id[50L + 2L]]),
    "10032"
  )
})

test_that("addGenotype encodes factor allele columns identically to character", {
  # Minimal case where each column's factor levels diverge from the global
  # sorted allele order: globally a->10001, b->10002, c->10003. With factor
  # columns, per-column integer codes (a,b -> 1,2 and b,c -> 1,2) would mis-key
  # the name-keyed genoDict, so 'second' would be mis-encoded. Character columns
  # key by label and are the oracle for correct behavior.
  pedX <- data.frame(id = c("A", "B"), stringsAsFactors = FALSE)
  genoChar <- data.frame(
    id = c("A", "B"),
    first_name = c("a", "b"),
    second_name = c("b", "c"),
    stringsAsFactors = FALSE
  )
  genoFac <- genoChar
  genoFac$first_name <- factor(genoFac$first_name)
  genoFac$second_name <- factor(genoFac$second_name)

  outChar <- addGenotype(pedX, genoChar)
  outChar <- outChar[order(outChar$id), ]
  outFac <- addGenotype(pedX, genoFac)
  outFac <- outFac[order(outFac$id), ]

  expect_identical(outFac$first, outChar$first)
  expect_identical(outFac$second, outChar$second)
})

test_that("addGenotype gives a consistent allele encoding with factor columns", {
  pedX <- data.frame(id = c("A", "B"), stringsAsFactors = FALSE)
  genoFac <- data.frame(
    id = c("A", "B"),
    first_name = c("a", "b"),
    second_name = c("b", "c"),
    stringsAsFactors = FALSE
  )
  genoFac$first_name <- factor(genoFac$first_name)
  genoFac$second_name <- factor(genoFac$second_name)

  out <- addGenotype(pedX, genoFac)
  out <- out[order(out$id), ]
  # Allele "b" appears as first_name (row B) and as second_name (row A);
  # it must receive the same integer code in both places.
  bAsFirst <- out$first[out$id == "B"]
  bAsSecond <- out$second[out$id == "A"]
  expect_identical(bAsFirst, bAsSecond)
})
