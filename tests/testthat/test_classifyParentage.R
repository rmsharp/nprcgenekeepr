#' Copyright(c) 2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)

# Issue #9 Slice 3: classifyParentage() labels each animal by how much of its
# parentage is known, U-id aware (an auto-generated unknown-parent placeholder,
# isGeneratedUnknownId, counts as unknown, as does NA). Used to flag both-unknown
# founders for the displayed-rank demotion and to surface a parentage column.

test_that("classifyParentage labels known / one unknown parent / both unknown", {
  sire <- c("A",   NA,   "U0001", "B",  NA,   "U0002", "UABCDE")
  dam  <- c("X",   "Y",  "Z",     NA,   NA,   "U0003", "W")
  # A/X         both real            -> "known"
  # NA/Y        sire NA              -> "one unknown parent"
  # U0001/Z     sire U-id unknown    -> "one unknown parent"
  # B/NA        dam NA               -> "one unknown parent"
  # NA/NA       both NA              -> "both unknown"
  # U0002/U0003 both U-id unknown    -> "both unknown"
  # UABCDE/W    sire U-id unknown    -> "one unknown parent"
  expect_identical(
    nprcgenekeepr:::classifyParentage(sire, dam),
    c("known", "one unknown parent", "one unknown parent",
      "one unknown parent", "both unknown", "both unknown",
      "one unknown parent")
  )
})

test_that("classifyParentage is vectorized and preserves length and order", {
  expect_identical(
    nprcgenekeepr:::classifyParentage(character(0L), character(0L)),
    character(0L)
  )
  expect_identical(
    nprcgenekeepr:::classifyParentage(c(NA, "A"), c(NA, "B")),
    c("both unknown", "known")
  )
})

test_that("classifyParentage matches the qcPed parentage counts", {
  ped <- nprcgenekeepr::qcPed
  cls <- nprcgenekeepr:::classifyParentage(ped$sire, ped$dam)
  expect_length(cls, nrow(ped))
  expect_identical(sum(cls == "both unknown"), 124L)
  expect_identical(sum(cls == "one unknown parent"), 43L)
  expect_identical(sum(cls == "known"), 113L)
})
