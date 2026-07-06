## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
pedWithGenotypeReport <- nprcgenekeepr::pedWithGenotypeReport
ped <- nprcgenekeepr::qcPed
rpt <- pedWithGenotypeReport$report

test_that("orderReport preserves all rows of the report", {
  rpt1 <- nprcgenekeepr:::orderReport(rpt, ped)
  expect_identical(nrow(rpt1), nrow(rpt))
  expect_true(all(rpt$id %in% rpt1$id))
})

test_that("orderReport preserves all rows without an age column", {
  rptNoAge <- rpt[, !names(rpt) == "age"]
  rpt1 <- nprcgenekeepr:::orderReport(rptNoAge, ped)
  expect_identical(nrow(rpt1), nrow(rptNoAge))
  expect_true(all(rptNoAge$id %in% rpt1$id))
})

# Issue #9 Slice 3: orderReport flags both-unknown founders that lack a recorded
# origin (ONPRC-born missing-parentage) as noParentage / "Undetermined" -- even
# when they have offspring -- while genuine imports (origin present) are kept,
# and one-unknown / known animals rank normally. Deterministic fixture with an
# origin column (qcPed has none); classification is U-id aware via the
# parentage column carried by reportGV.
test_that("orderReport flags no-origin both-unknown founders, keeps imports (#9 Slice 3)", {
  rpt3 <- data.frame(
    id             = c("KNOWN1", "ONEUNK", "STUB1", "IMPORT1"),
    sire           = c("S1",     "U0001",  NA,      NA),
    dam            = c("D1",     "D2",     NA,      NA),
    origin         = c(NA,       NA,       NA,      "TEXAS"),
    gu             = c(2,        3,        50,      50),
    zScores        = c(1.0,      0.5,      -2.0,    -2.0),
    totalOffspring = c(1L,       1L,       2L,      2L),
    parentage      = c("known", "one unknown parent",
                       "both unknown", "both unknown"),
    stringsAsFactors = FALSE
  )
  ped3 <- data.frame(
    id   = c("KNOWN1", "ONEUNK", "STUB1", "IMPORT1",
             "S1", "D1", "D2", "U0001"),
    sire = c("S1", "U0001", NA, NA, NA, NA, NA, NA),
    dam  = c("D1", "D2",    NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  out <- nprcgenekeepr:::orderReport(rpt3, ped3)

  # STUB1: no-origin both-unknown founder WITH offspring -> Undetermined, rank NA
  expect_identical(out$value[out$id == "STUB1"], "Undetermined")
  expect_true(is.na(out$rank[out$id == "STUB1"]))
  # IMPORT1: origin present -> kept, NOT Undetermined
  expect_false(out$value[out$id == "IMPORT1"] == "Undetermined")
  # one-unknown and known animals are not flagged as no-parentage
  expect_false(out$value[out$id == "ONEUNK"] == "Undetermined")
  expect_false(out$value[out$id == "KNOWN1"] == "Undetermined")
  # the flagged stub is ranked below the known animal (sinks to the bottom)
  expect_gt(which(out$id == "STUB1"), which(out$id == "KNOWN1"))
})

# Issue #111 coverage backfill (S293): the else branch at orderReport.R L42 --
# a report with NO `parentage` column, so both-unknown founders are derived
# from getFounders(ped) instead of the parentage column.
test_that("orderReport uses getFounders when parentage absent", {
  # No parentage column -> both-unknown founders come from getFounders(ped)
  # (orderReport.R L42, the else branch).
  rptNoParentage <- data.frame(
    id      = c("F1", "K1"),
    gu      = c(2, 3),
    zScores = c(1.0, 0.5),
    stringsAsFactors = FALSE
  )
  pedNP <- data.frame(
    id   = c("F1", "K1", "S1", "D1"),
    sire = c(NA, "S1", NA, NA),
    dam  = c(NA, "D1", NA, NA),
    stringsAsFactors = FALSE
  )
  out <- nprcgenekeepr:::orderReport(rptNoParentage, pedNP)
  # F1 is a both-unknown founder per getFounders(ped): no origin ->
  # Undetermined, rank NA.
  expect_identical(out$value[out$id == "F1"], "Undetermined")
  expect_true(is.na(out$rank[out$id == "F1"]))
  # K1 has known parents -> not flagged.
  expect_false(out$value[out$id == "K1"] == "Undetermined")
  expect_identical(nrow(out), nrow(rptNoParentage))
})
