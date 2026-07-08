## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# ---------------------------------------------------------------------------
# Issue #118 Slice 2 (E2): getLivingBreeders(ped) is the shared @noRd helper
# (reused by E3 in Slice 3) that returns the ids of the CURRENT LIVING BREEDERS
# in a pedigree -- the population the demographic effective sizes are computed
# over. A living breeder is an animal that (1) is living (exit is NA, or every
# animal when the pedigree carries no exit column) and (2) appears as a non-NA,
# non-auto-generated-unknown (non U-id) sire or dam somewhere in the pedigree.
# This population is derived from the ped data.frame itself, independent of any
# proband/population selection (owner decision D-b).
# ---------------------------------------------------------------------------

# A tiny pedigree exercising every predicate: S1/D1 are living breeders; S2 is a
# breeder but dead (exit set) -> excluded; D2 is a living breeder; U0001 is a
# generated-unknown parent that appears as a sire -> excluded; K1/K2/K3 are
# living but never parents -> excluded; LONE is living but never a parent.
makeBreederTestPed <- function() {
  data.frame(
    id   = c("S1", "D1", "S2", "D2", "K1", "K2", "K3", "U0001", "LONE"),
    sire = c(NA,   NA,   NA,   NA,   "S1", "S2", "U0001", NA,    NA),
    dam  = c(NA,   NA,   NA,   NA,   "D1", "D2", "D1",    NA,    NA),
    sex  = c("M",  "F",  "M",  "F",  "F",  "M",  "M",  "U",      "F"),
    exit = c(NA,   NA,   "2020-01-01", NA, NA, NA, NA, NA,       NA),
    stringsAsFactors = FALSE
  )
}

test_that("getLivingBreeders returns the living animals that are sires or dams", {
  ped <- makeBreederTestPed()
  lb <- nprcgenekeepr:::getLivingBreeders(ped)
  ## S1 and D1 (living, parents) plus D2 (living, dam) -- but NOT dead S2
  expect_setequal(lb, c("S1", "D1", "D2"))
  expect_type(lb, "character")
})

test_that("getLivingBreeders excludes dead breeders", {
  ped <- makeBreederTestPed()
  lb <- nprcgenekeepr:::getLivingBreeders(ped)
  ## S2 is a sire (breeder) but has a non-NA exit (dead) -> not a living breeder
  expect_false("S2" %in% lb)
})

test_that("getLivingBreeders excludes living non-breeders", {
  ped <- makeBreederTestPed()
  lb <- nprcgenekeepr:::getLivingBreeders(ped)
  ## the offspring and the lone animal are living but never appear as a parent
  expect_false(any(c("K1", "K2", "K3", "LONE") %in% lb))
})

test_that("getLivingBreeders excludes generated-unknown (U-id) parents", {
  ped <- makeBreederTestPed()
  lb <- nprcgenekeepr:::getLivingBreeders(ped)
  ## U0001 appears as a sire and is living, but a U-id placeholder is not a
  ## real breeder (mirrors the founder-count U-id exclusion in reportGV)
  expect_false("U0001" %in% lb)
})

test_that("getLivingBreeders treats all animals as living when no exit column", {
  ped <- makeBreederTestPed()
  ped$exit <- NULL
  lb <- nprcgenekeepr:::getLivingBreeders(ped)
  ## with no exit information, every breeder counts as living -- so the
  ## previously-dead S2 is now included
  expect_setequal(lb, c("S1", "S2", "D1", "D2"))
  expect_true("S2" %in% lb)
})

test_that("getLivingBreeders returns an empty character vector when no breeders", {
  ped <- data.frame(
    id   = c("A", "B"),
    sire = c(NA, NA),
    dam  = c(NA, NA),
    sex  = c("M", "F"),
    exit = c(NA, NA),
    stringsAsFactors = FALSE
  )
  lb <- nprcgenekeepr:::getLivingBreeders(ped)
  expect_length(lb, 0L)
  expect_type(lb, "character")
})
