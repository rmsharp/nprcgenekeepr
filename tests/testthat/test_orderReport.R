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

# Issue #125 Slice 1: orderReport gains guCutoff/zScoreCutoff/axisPriority,
# each NULL-defaulting to today's hardcoded 10L / 0.25 / "gu" behavior.
test_that("orderReport with explicit default cutoffs matches the bare call (backward compat, #125 Slice 1)", {
  rpt1 <- nprcgenekeepr:::orderReport(rpt, ped)
  rpt2 <- nprcgenekeepr:::orderReport(
    rpt, ped,
    guCutoff = 10L, zScoreCutoff = 0.25, axisPriority = "gu"
  )
  expect_identical(rpt1, rpt2)
})

test_that("orderReport axisPriority = 'mk' flips which tier claims a dual-qualifying animal (#125 Slice 1)", {
  # DUAL1 qualifies for BOTH gu > 10 and zScores <= 0.25; GUONLY qualifies only
  # for the gu axis; MKONLY qualifies only for the mk axis.
  rptX <- data.frame(
    id             = c("DUAL1", "GUONLY", "MKONLY"),
    sire           = c("S1", "S1", "S1"),
    dam            = c("D1", "D1", "D1"),
    gu             = c(15, 20, 2),
    zScores        = c(0.05, 0.5, 0.20),
    totalOffspring = c(0L, 0L, 0L),
    parentage      = c("known", "known", "known"),
    stringsAsFactors = FALSE
  )
  pedX <- data.frame(
    id   = c("DUAL1", "GUONLY", "MKONLY", "S1", "D1"),
    sire = c("S1", "S1", "S1", NA, NA),
    dam  = c("D1", "D1", "D1", NA, NA),
    stringsAsFactors = FALSE
  )

  outGu <- nprcgenekeepr:::orderReport(rptX, pedX) # default axisPriority = "gu"
  outMk <- nprcgenekeepr:::orderReport(rptX, pedX, axisPriority = "mk")

  # gu-priority (today's behavior): highGu (gu > 10) is filtered FIRST, so
  # DUAL1 is claimed by the highGu tier alongside GUONLY, sorted by
  # descending gu; MKONLY is the only animal left for the lowMk tier.
  expect_identical(outGu$id, c("GUONLY", "DUAL1", "MKONLY"))

  # mk-priority: lowMk (zScores <= 0.25) is filtered FIRST instead, so DUAL1
  # is claimed by the lowMk tier alongside MKONLY, sorted by ascending
  # zScores; GUONLY is the only animal left for the highGu tier.
  expect_identical(outMk$id, c("DUAL1", "MKONLY", "GUONLY"))
})

test_that("orderReport custom guCutoff/zScoreCutoff change tier membership (#125 Slice 1)", {
  # Y1 sits between the default and custom cutoffs on both axes; Y2 always
  # qualifies for lowMk under gu-priority. Under the default cutoffs (10 /
  # 0.25) both animals land in lowMk (Y2 first, ascending zScores). Under the
  # custom cutoffs (guCutoff = 5 / zScoreCutoff = 0.1), Y1's gu = 8 now clears
  # the lower guCutoff, moving it into highGu ahead of Y2's lowMk tier.
  rptY <- data.frame(
    id             = c("Y1", "Y2"),
    sire           = c("S1", "S1"),
    dam            = c("D1", "D1"),
    gu             = c(8, 3),
    zScores        = c(0.15, 0.05),
    totalOffspring = c(0L, 0L),
    parentage      = c("known", "known"),
    stringsAsFactors = FALSE
  )
  pedY <- data.frame(
    id   = c("Y1", "Y2", "S1", "D1"),
    sire = c("S1", "S1", NA, NA),
    dam  = c("D1", "D1", NA, NA),
    stringsAsFactors = FALSE
  )

  outDefault <- nprcgenekeepr:::orderReport(rptY, pedY)
  outCustom <- nprcgenekeepr:::orderReport(
    rptY, pedY,
    guCutoff = 5L, zScoreCutoff = 0.1
  )

  expect_identical(outDefault$id, c("Y2", "Y1"))
  expect_identical(outCustom$id, c("Y1", "Y2"))
})

## BACKLOG (found S578, broadened S581): the imports/noParentage `order(id)`
## calls at orderReport.R L81/L93 (no `age` column present) use plain,
## locale-dependent `order()`, the same class of bug Learning 585 fixed in
## `.positionMatingUnitForest()` via `method = "radix"`. Empirically confirmed
## (S581) this session that plain `order()` on this id set diverges between
## `LC_COLLATE = "C"` and this environment's own default (`en_US.UTF-8`) --
## byte/radix order is `A1, B2, _ctrl, a9, b17`; the current default-locale
## order is `_ctrl, A1, a9, b17, B2`. Both fixtures below are ALL
## both-unknown-parent founders with no `age` column, so every row lands in
## a single tier (imports or noParentage respectively) and the returned
## `$id` sequence is exactly that tier's own order() output.
test_that("orderReport imports tier orders ids by byte/radix order, not locale collation (#578)", {
  divergingIds <- c("b17", "B2", "a9", "A1", "_ctrl")
  rptImports <- data.frame(
    id = divergingIds,
    sire = rep(NA_character_, 5L),
    dam = rep(NA_character_, 5L),
    origin = rep("TEXAS", 5L),
    gu = rep(50, 5L),
    zScores = rep(-2.0, 5L),
    parentage = rep("both unknown", 5L),
    stringsAsFactors = FALSE
  )
  pedImports <- data.frame(
    id = divergingIds,
    sire = rep(NA_character_, 5L),
    dam = rep(NA_character_, 5L),
    stringsAsFactors = FALSE
  )
  out <- nprcgenekeepr:::orderReport(rptImports, pedImports)
  expect_identical(out$id, c("A1", "B2", "_ctrl", "a9", "b17"))
})

test_that("orderReport noParentage tier orders ids by byte/radix order, not locale collation (#578)", {
  divergingIds <- c("b17", "B2", "a9", "A1", "_ctrl")
  rptNoParentage <- data.frame(
    id = divergingIds,
    sire = rep(NA_character_, 5L),
    dam = rep(NA_character_, 5L),
    gu = rep(2, 5L),
    zScores = rep(1.0, 5L),
    parentage = rep("both unknown", 5L),
    stringsAsFactors = FALSE
  )
  pedNoParentage <- data.frame(
    id = divergingIds,
    sire = rep(NA_character_, 5L),
    dam = rep(NA_character_, 5L),
    stringsAsFactors = FALSE
  )
  out <- nprcgenekeepr:::orderReport(rptNoParentage, pedNoParentage)
  expect_identical(out$id, c("A1", "B2", "_ctrl", "a9", "b17"))
  expect_true(all(out$value == "Undetermined"))
})
