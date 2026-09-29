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

## NEW-38 F2 (docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md, probe P3): addUIds()
## minted a duplicate "U0001" for a pedigree that already had a real "U0001".
## It must now skip past any candidate id that already exists in the pedigree.
test_that("addUIds() skips candidate ids that already exist in the pedigree", {
  ped <- data.frame(
    id = c("U0001", "s1", "d0"),
    sire = c(NA, NA, NA),
    dam = c(NA, "d0", NA),
    sex = c("M", "M", "F"),
    stringsAsFactors = FALSE
  )
  newPed <- addUIds(ped)
  minted <- newPed$sire[newPed$id == "s1"]
  expect_false(identical(minted, "U0001")) # never duplicate the existing real id
  expect_equal(minted, "U0002") # advances to the next available id
  expect_equal(sum(newPed$id == "U0001"), 1L) # no duplicate id created
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

## Placeholder-marking plan Slice 2 (M11, S808): an id used only as a sire or a
## dam, with no row of its own, is in use too. Minting it again for another
## animal's missing parent would merge a recorded parent with a made-up one
## (K2 would become K1's paternal half-sib through U0001).
test_that("addUIds() never reuses an id used only as a sire or a dam", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL) # default U%04d
  ped <- data.frame(
    id = c("K1", "K2", "K3", "K4", "D1", "S1"),
    sire = c("U0001", NA, "S1", "S1", NA, NA),
    dam = c("D1", "D1", "U0002", NA, NA, NA),
    sex = c("M", "F", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  newPed <- addUIds(ped)
  mintedSire <- newPed$sire[newPed$id == "K2"]
  mintedDam <- newPed$dam[newPed$id == "K4"]
  expect_false(mintedSire %in% c("U0001", "U0002"))
  expect_false(mintedDam %in% c("U0001", "U0002"))
  expect_false(identical(mintedSire, mintedDam))
  expect_identical(newPed$sire[newPed$id == "K1"], "U0001") # recorded, kept
  expect_identical(newPed$dam[newPed$id == "K3"], "U0002") # recorded, kept
})
