## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
qcPed <- nprcgenekeepr::qcPed
gvReport <- reportGV(qcPed, guIter = 20L)
test_that("reportGV forms correct genetic value report", {
  expect_named(gvReport, c(
    "report", "kinship", "gu", "fe", "fg", "fgSE", "neGD", "neSexRatio",
    "neVariance", "maleFounders", "femaleFounders",
    "nMaleFounders", "nFemaleFounders", "total"
  ))
  expect_named(gvReport$report,
    c(
      "id", "sex", "age", "birth", "exit", "population", "sire", "dam",
      "indivMeanKin", "zScores", "gu", "guSE", "totalOffspring",
      "livingOffspring", "parentage", "value", "rank"
    )
  )
  expect_identical(nrow(gvReport$report), nrow(qcPed))
  expect_identical(nrow(gvReport$gu), nrow(qcPed))
  expect_identical(gvReport$nMaleFounders, 20L)
  expect_identical(gvReport$nFemaleFounders, 61L)
})
updateProgress <- function(n = 1L, detail = NULL, value = 0L, reset = FALSE) {
  "stub"
}

gvReport <- reportGV(qcPed, guIter = 20L, updateProgress = updateProgress)
test_that(
  "reportGV forms correct genetic value report with updateProgress defined",
  {
    expect_named(gvReport, c(
      "report", "kinship", "gu", "fe", "fg", "fgSE", "neGD", "neSexRatio",
      "neVariance", "maleFounders", "femaleFounders",
      "nMaleFounders", "nFemaleFounders", "total"
    ))
    expect_named(gvReport$report,
      c(
        "id", "sex", "age", "birth", "exit", "population", "sire", "dam",
        "indivMeanKin", "zScores", "gu", "guSE", "totalOffspring",
        "livingOffspring", "parentage", "value", "rank"
      )
    )
    expect_identical(nrow(gvReport$report), nrow(qcPed))
    expect_identical(nrow(gvReport$gu), nrow(qcPed))
    expect_identical(gvReport$nMaleFounders, 20L)
    expect_identical(gvReport$nFemaleFounders, 61L)
  }
)

# ---------------------------------------------------------------------------
# Issue #118 Slice 1 (E1): reportGV carries gene diversity (GD) as a
# colony-level SCALAR neGD alongside fg, GD = 1 - 1/(2*FG). Like fgSE it is one
# number that rides next to fg -- NOT a per-animal column in $report or $gu. GD
# is over the SAME population as FG (the analysis set), so it is reported beside
# FG, not in the living-breeder Ne block E2/E3 will add. neGD is a deterministic
# function of the bundle's own fg, so the relation holds regardless of the
# gene-drop RNG; fe/fg golden-master values (asserted elsewhere) are unchanged.
# ---------------------------------------------------------------------------
test_that("reportGV carries scalar neGD = 1 - 1/(2*fg) beside fg (issue #118 Slice 1 E1)", {
  gv <- reportGV(qcPed, guIter = 20L)

  expect_true("neGD" %in% names(gv))
  expect_length(gv$neGD, 1L)
  expect_true(is.numeric(gv$neGD))

  ## neGD is exactly the closed-form GD of the bundle's own fg
  expect_equal(gv$neGD, calcGeneDiversity(gv$fg))
  expect_equal(gv$neGD, 1 - 1 / (2 * gv$fg))

  ## a proper diversity proportion on qcPed: finite, strictly inside (0, 1)
  expect_true(is.finite(gv$neGD))
  expect_gt(gv$neGD, 0)
  expect_lt(gv$neGD, 1)

  ## GD is a colony-level scalar like fg -- it must NOT be a per-animal column
  expect_false("neGD" %in% names(gv$report))
  expect_false("neGD" %in% names(gv$gu))
})

# ---------------------------------------------------------------------------
# Issue #118 Slice 2 (E2): reportGV carries the demographic sex-ratio effective
# size (Ne_sr = 4 * Nm * Nf / (Nm + Nf)) as a colony-level SCALAR neSexRatio,
# computed over the CURRENT LIVING BREEDERS in the pedigree -- a DIFFERENT
# population than fg / neGD (which are over the analysis set). Like fgSE / neGD
# it is one number riding beside them, NOT a per-animal column. It is a
# deterministic function of the pedigree's own demographics (no gene drop), so
# it must equal the standalone calcNeSexRatio(ped) on the same pedigree.
# ---------------------------------------------------------------------------
test_that("reportGV carries scalar neSexRatio over living breeders (issue #118 Slice 2 E2)", {
  gv <- reportGV(qcPed, guIter = 20L)

  expect_true("neSexRatio" %in% names(gv))
  expect_length(gv$neSexRatio, 1L)
  expect_true(is.numeric(gv$neSexRatio))

  ## exactly the standalone E2 computed on the same pedigree (living breeders)
  expect_equal(gv$neSexRatio, calcNeSexRatio(qcPed))

  ## a finite, non-negative effective size on qcPed
  expect_true(is.finite(gv$neSexRatio))
  expect_gte(gv$neSexRatio, 0)

  ## Ne_sr is a colony-level scalar -- it must NOT be a per-animal column
  expect_false("neSexRatio" %in% names(gv$report))
  expect_false("neSexRatio" %in% names(gv$gu))
})

# ---------------------------------------------------------------------------
# Issue #118 Slice 3 (E3): reportGV carries the variance effective size
# (Ne_v = (N*kbar - 1)/(kbar - 1 + Vk/kbar), the ratified mean-adjusted
# Crow-Kimura form) as a colony-level SCALAR neVariance, computed over the
# CURRENT LIVING BREEDERS -- the same living-breeder population as neSexRatio
# and a DIFFERENT population than fg / neGD (the analysis set). Like the other
# Ne scalars it is one number riding beside them, NOT a per-animal column, and
# it must equal the standalone calcNeVariance(ped) on the same pedigree.
# ---------------------------------------------------------------------------
test_that("reportGV carries scalar neVariance over living breeders (issue #118 Slice 3 E3)", {
  gv <- reportGV(qcPed, guIter = 20L)

  expect_true("neVariance" %in% names(gv))
  expect_length(gv$neVariance, 1L)
  expect_true(is.numeric(gv$neVariance))

  ## exactly the standalone E3 computed on the same pedigree (living breeders)
  expect_equal(gv$neVariance, calcNeVariance(qcPed))

  ## a finite, positive effective size on qcPed
  expect_true(is.finite(gv$neVariance))
  expect_gt(gv$neVariance, 0)

  ## Ne_v is a colony-level scalar -- it must NOT be a per-animal column
  expect_false("neVariance" %in% names(gv$report))
  expect_false("neVariance" %in% names(gv$gu))
})

# ---------------------------------------------------------------------------
# Issue #9 Slice 2: animals missing exactly one parent receive a peer-cohort
# mean-kinship floor (+ sexMean / 2). The expected correction is recomputed
# independently in base R from the uncorrected baseline so the assertion does
# not depend on the implementation. On qcPed all 43 one-unknown animals are
# missing the sire (male cohort), the pedigree has no species column (so the
# breeding-age cutoff is the default 2, not rhesus 4), and the strict cohort is
# never empty -- the fallback does not fire (plan section 8-A/E).
# ---------------------------------------------------------------------------
test_that("reportGV raises one-unknown animals' mean kinship by sexMean/2 (issue #9 Slice 2)", {
  ped <- nprcgenekeepr::qcPed
  probands <- as.character(ped$id) # population defaults to all animals
  mk0 <- meanKinship(
    nprcgenekeepr:::filterKinMatrix(
      probands, kinship(ped$id, ped$sire, ped$dam, ped$gen)
    )
  )[probands]

  gvr <- reportGV(ped, guIter = 20L)
  imk <- stats::setNames(gvr$report$indivMeanKin, as.character(gvr$report$id))
  imk <- imk[probands] # align to ped order

  isU <- function(x) is.na(x) | nprcgenekeepr:::isGeneratedUnknownId(x)
  sireMiss <- isU(ped$sire)
  damMiss <- isU(ped$dam)
  oneU <- xor(sireMiss, damMiss)
  unchanged <- !oneU
  expect_true(any(oneU)) # guard: the fixture must exercise the path

  ## independent base-R recomputation of the expected one-unknown correction
  dYear <- 365L
  expected <- mk0
  for (i in which(oneU)) {
    bf <- ped$birth[i]
    missingSex <- if (sireMiss[i]) "M" else "F"
    minAge <- 2L # qcPed carries no species column -> default cutoff
    gest <- 210L # getSpeciesGestation(NA) default window
    cand <- ped$sex == missingSex &
      !is.na(ped$birth) & ped$birth <= (bf - dYear * minAge) &
      (is.na(ped$exit) | ped$exit >= (bf - gest)) &
      ped$id != ped$id[i]
    cohort <- as.character(ped$id[cand])
    cohort <- cohort[cohort %in% probands]
    sexMean <- mean(mk0[cohort])
    expected[ped$id[i]] <- min(mk0[ped$id[i]] + sexMean / 2, 1)
  }

  ## one-unknown animals raised to exactly the expected peer-cohort floor
  expect_equal(unname(imk[ped$id[oneU]]), unname(expected[ped$id[oneU]]))
  expect_true(all(imk[ped$id[oneU]] >= mk0[ped$id[oneU]]))
  expect_true(mean(imk[ped$id[oneU]]) > mean(mk0[ped$id[oneU]]))
  ## known and both-unknown animals are untouched
  expect_equal(unname(imk[ped$id[unchanged]]), unname(mk0[ped$id[unchanged]]))
  ## [0,1] invariant preserved
  expect_true(all(imk >= 0))
  expect_true(all(imk <= 1))
})

# ---------------------------------------------------------------------------
# Issue #9 Slice 3: reportGV carries a parentage classification column
# (U-id aware), and on qcPed -- which has no origin column -- every both-unknown
# founder is flagged as noParentage ("Undetermined") so the displayed rank can
# demote them. One-unknown and known animals are not flagged.
# ---------------------------------------------------------------------------
test_that("reportGV classifies parentage and flags both-unknown founders (issue #9 Slice 3)", {
  ped <- nprcgenekeepr::qcPed
  rpt <- reportGV(ped, guIter = 20L)$report
  expect_true("parentage" %in% names(rpt))
  expect_identical(sum(rpt$parentage == "both unknown"), 124L)
  expect_identical(sum(rpt$parentage == "one unknown parent"), 43L)
  expect_identical(sum(rpt$parentage == "known"), 113L)
  ## qcPed has no origin -> all 124 both-unknown founders become Undetermined
  expect_true(all(rpt$value[rpt$parentage == "both unknown"] == "Undetermined"))
  ## known and one-unknown animals are not flagged as no-parentage
  expect_true(all(rpt$value[rpt$parentage != "both unknown"] != "Undetermined"))
})

# ---------------------------------------------------------------------------
# Issue #73 Part 2 Slice 1: reportGV threads the user-configurable species
# overrides (breedingTable / gestationTable / breedingAgeDefault /
# gestationDefault) down to the unknown-parent mean-kinship correction. Each
# expected correction is recomputed independently in base R from the uncorrected
# baseline. On qcPed all 43 one-unknown animals are missing the sire (male
# cohort) and there is no species column, so the *Default params drive the
# cutoff/window directly; the *Table params bite only when a species column is
# present (so those two tests add species = "RHESUS").
# ---------------------------------------------------------------------------

# Independent base-R recomputation of the one-unknown correction at a given
# breeding-age cutoff (years) and gestation window (days).
recomputeCorrection <- function(ped, mk0, probands, minAgeYears, gestDays) {
  dYear <- 365L
  isU <- function(x) is.na(x) | nprcgenekeepr:::isGeneratedUnknownId(x)
  sireMiss <- isU(ped$sire)
  oneU <- xor(sireMiss, isU(ped$dam))
  expected <- mk0
  for (i in which(oneU)) {
    bf <- ped$birth[i]
    missingSex <- if (sireMiss[i]) "M" else "F"
    cand <- ped$sex == missingSex & !is.na(ped$birth) &
      ped$birth <= (bf - dYear * minAgeYears) &
      (is.na(ped$exit) | ped$exit >= (bf - gestDays)) &
      ped$id != ped$id[i]
    cohort <- as.character(ped$id[cand])
    cohort <- cohort[cohort %in% probands]
    if (length(cohort) == 0L) next
    expected[ped$id[i]] <- min(mk0[ped$id[i]] + mean(mk0[cohort]) / 2, 1)
  }
  expected
}

makeMk0 <- function(ped) {
  probands <- as.character(ped$id)
  meanKinship(nprcgenekeepr:::filterKinMatrix(
    probands, kinship(ped$id, ped$sire, ped$dam, ped$gen)
  ))[probands]
}

alignImk <- function(gvr, probands) {
  stats::setNames(
    gvr$report$indivMeanKin, as.character(gvr$report$id)
  )[probands]
}

test_that("reportGV threads breedingAgeDefault into the correction (#73 Part 2)", {
  ped <- nprcgenekeepr::qcPed
  probands <- as.character(ped$id)
  mk0 <- makeMk0(ped)
  isU <- function(x) is.na(x) | nprcgenekeepr:::isGeneratedUnknownId(x)
  oneU <- xor(isU(ped$sire), isU(ped$dam))
  expect_true(any(oneU))

  over <- reportGV(ped, guIter = 20L, breedingAgeDefault = 4)
  base <- reportGV(ped, guIter = 20L)
  imkOver <- alignImk(over, probands)
  imkBase <- alignImk(base, probands)

  expected <- recomputeCorrection(ped, mk0, probands, 4L, 210L)
  expect_equal(unname(imkOver[ped$id[oneU]]), unname(expected[ped$id[oneU]]))
  ## the override actually changed the result vs the default-2 baseline
  expect_false(isTRUE(all.equal(
    unname(imkOver[ped$id[oneU]]), unname(imkBase[ped$id[oneU]])
  )))
})

test_that("reportGV threads gestationDefault into the correction (#73 Part 2)", {
  ped <- nprcgenekeepr::qcPed
  probands <- as.character(ped$id)
  mk0 <- makeMk0(ped)
  isU <- function(x) is.na(x) | nprcgenekeepr:::isGeneratedUnknownId(x)
  oneU <- xor(isU(ped$sire), isU(ped$dam))

  over <- reportGV(ped, guIter = 20L, gestationDefault = 36500L)
  base <- reportGV(ped, guIter = 20L)
  imkOver <- alignImk(over, probands)
  imkBase <- alignImk(base, probands)

  expected <- recomputeCorrection(ped, mk0, probands, 2L, 36500L)
  expect_equal(unname(imkOver[ped$id[oneU]]), unname(expected[ped$id[oneU]]))
  expect_false(isTRUE(all.equal(
    unname(imkOver[ped$id[oneU]]), unname(imkBase[ped$id[oneU]])
  )))
})

test_that("reportGV threads a custom breedingTable into the correction (#73 Part 2)", {
  ped <- nprcgenekeepr::qcPed
  pedSpp <- ped
  pedSpp$species <- "RHESUS"
  probands <- as.character(ped$id)
  mk0 <- makeMk0(ped)
  isU <- function(x) is.na(x) | nprcgenekeepr:::isGeneratedUnknownId(x)
  oneU <- xor(isU(ped$sire), isU(ped$dam))

  ## custom RHESUS male cutoff 2 (vs bundled 4); gestation 210 unchanged
  custom <- data.frame(
    species = "RHESUS", gestation = 210L,
    minMaleBreedingAge = 2.0, minFemaleBreedingAge = 2.0,
    stringsAsFactors = FALSE
  )
  over <- reportGV(pedSpp, guIter = 20L, breedingTable = custom)
  bundled <- reportGV(pedSpp, guIter = 20L) # bundled RHESUS male 4
  imkOver <- alignImk(over, probands)
  imkBundled <- alignImk(bundled, probands)

  ## custom cutoff 2 reproduces the default-2 baseline
  expected <- recomputeCorrection(ped, mk0, probands, 2L, 210L)
  expect_equal(unname(imkOver[ped$id[oneU]]), unname(expected[ped$id[oneU]]))
  ## bundled RHESUS cutoff 4 differs from the custom cutoff 2
  expect_false(isTRUE(all.equal(
    unname(imkOver[ped$id[oneU]]), unname(imkBundled[ped$id[oneU]])
  )))
})

test_that("reportGV threads a custom gestationTable into the correction (#73 Part 2)", {
  ped <- nprcgenekeepr::qcPed
  pedSpp <- ped
  pedSpp$species <- "RHESUS"
  probands <- as.character(ped$id)
  mk0 <- makeMk0(ped)
  isU <- function(x) is.na(x) | nprcgenekeepr:::isGeneratedUnknownId(x)
  oneU <- xor(isU(ped$sire), isU(ped$dam))

  ## fix the cutoff at 2 via a custom breedingTable, vary only the gestation
  ## window: a 10-day window (vs bundled RHESUS 210) excludes more exited peers.
  customAge <- data.frame(
    species = "RHESUS", gestation = 210L,
    minMaleBreedingAge = 2.0, minFemaleBreedingAge = 2.0,
    stringsAsFactors = FALSE
  )
  customGest <- data.frame(
    species = "RHESUS", gestation = 10L, stringsAsFactors = FALSE
  )
  over <- reportGV(pedSpp, guIter = 20L,
                   breedingTable = customAge, gestationTable = customGest)
  base <- reportGV(pedSpp, guIter = 20L, breedingTable = customAge)
  imkOver <- alignImk(over, probands)
  imkBase <- alignImk(base, probands)

  expected <- recomputeCorrection(ped, mk0, probands, 2L, 10L)
  expect_equal(unname(imkOver[ped$id[oneU]]), unname(expected[ped$id[oneU]]))
  expect_false(isTRUE(all.equal(
    unname(imkOver[ped$id[oneU]]), unname(imkBase[ped$id[oneU]])
  )))
})

test_that("reportGV with explicit NULL overrides equals the no-override default (#73 Part 2)", {
  ped <- nprcgenekeepr::qcPed
  a <- reportGV(ped, guIter = 20L)
  b <- reportGV(ped, guIter = 20L, breedingTable = NULL, gestationTable = NULL,
                breedingAgeDefault = NULL, gestationDefault = NULL)
  ## indivMeanKin is deterministic (kinship + correction; no gene-drop random);
  ## explicit-NULL overrides must reproduce today's behavior byte for byte.
  ia <- a$report$indivMeanKin[order(a$report$id)]
  ib <- b$report$indivMeanKin[order(b$report$id)]
  expect_equal(ia, ib)
})

# ---------------------------------------------------------------------------
# Issue #76 (Reading A): reportGV declines to credit genome uniqueness whose
# apparent rarity is an artifact of unknown parentage. Animals whose parentage
# is "both unknown" (U-id aware) AND that lack a recorded origin -- the
# "Undetermined" / noParentage set the displayed rank demotes (issue #9 Slice 3)
# -- have their reported genome uniqueness set to 0 in BOTH the report's gu
# column and the returned $gu element. Imports (both-unknown WITH a recorded
# origin) and all known / one-unknown animals are preserved. calcGU()/calcA()/
# geneDrop() are untouched -- this is a report-layer colony policy.
#
# A fixture WITH an origin column is required to exercise the import-preservation
# branch (qcPed has no origin column). guThresh = 2 so the both-unknown founders
# AND the U-id-parented proband carry strictly positive genome uniqueness on the
# pre-de-inflation code, making the change observable; a fixed seed keeps the
# preserved values deterministic. Only the discriminating properties are asserted
# (== 0 for targets, > 0 for preserved), so the test is robust to RNG / R-version
# differences.
# ---------------------------------------------------------------------------
makeOriginTestPed <- function() {
  ped <- data.frame(
    id = c("U0001", "U0002", "M1", "F1", "M2", "F2", "P1", "O1", "O2", "O3"),
    sire = c(NA, NA, NA, NA, NA, NA, "U0001", "M1", "M2", "M1"),
    dam = c(NA, NA, NA, NA, NA, NA, "U0002", "F1", "F2", "F2"),
    sex = c("M", "F", "M", "F", "M", "F", "M", "F", "M", "F"),
    origin = c(NA, NA, NA, NA, "CHINA", "CHINA", NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

test_that("reportGV de-inflates gu to 0 for unknown-origin both-unknown animals, preserving imports (issue #76)", {
  ped <- makeOriginTestPed()
  set.seed(17L)
  gv <- reportGV(ped, guIter = 1000L, guThresh = 2L)

  rptGu <- stats::setNames(gv$report$gu, as.character(gv$report$id))
  eltGu <- stats::setNames(gv$gu$gu, rownames(gv$gu))

  ## ONPRC-born both-unknown founders (origin NA) -> de-inflated to 0 in BOTH
  ## the report's gu column and the returned $gu element.
  expect_equal(unname(rptGu[c("M1", "F1")]), c(0, 0))
  expect_equal(unname(eltGu[c("M1", "F1")]), c(0, 0))

  ## imports (both-unknown WITH a recorded origin) -> preserved, not de-inflated
  expect_true(all(rptGu[c("M2", "F2")] > 0))
  expect_equal(unname(rptGu[c("M2", "F2")]), unname(eltGu[c("M2", "F2")]))

  ## a fully-known animal is left unchanged (not forced to 0)
  expect_true(rptGu[["O2"]] > 0)
  expect_equal(rptGu[["O2"]], eltGu[["O2"]])
})

test_that("reportGV gu de-inflation predicate is U-id aware, not raw is.na (issue #76)", {
  ped <- makeOriginTestPed()
  set.seed(17L)
  gv <- reportGV(ped, guIter = 1000L, guThresh = 2L)

  rptGu <- stats::setNames(gv$report$gu, as.character(gv$report$id))
  eltGu <- stats::setNames(gv$gu$gu, rownames(gv$gu))

  ## P1's parents are generated U-ids (U0001 / U0002), not literal NA, and P1
  ## has no recorded origin. classifyParentage() treats U-ids as unknown, so P1
  ## is "both unknown" / Undetermined and must be de-inflated to 0. A raw
  ## is.na(sire) & is.na(dam) predicate would wrongly leave P1's gu > 0.
  expect_identical(
    as.character(gv$report$parentage[gv$report$id == "P1"]),
    "both unknown"
  )
  expect_equal(rptGu[["P1"]], 0)
  expect_equal(eltGu[["P1"]], 0)
})

# ---------------------------------------------------------------------------
# Issue #2 Slice 1: reportGV carries a per-animal genome-uniqueness standard
# error (guSE) -- the Monte Carlo sampling SE of the gene-drop gu estimate --
# in BOTH the report data.frame and the returned $gu element. guSE is computed
# from the same rare matrix calcGU() uses, so it is correct for any guThresh /
# byID. The issue #76 "Undetermined" set (gu de-inflated to 0) also has guSE
# set to 0: a policy constant has no sampling error. A fixed seed and
# guThresh = 2 keep the discriminating properties (== 0 for de-inflated, > 0
# somewhere) deterministic; the fixture has a recorded-origin import branch.
# ---------------------------------------------------------------------------
test_that("reportGV carries a guSE column in $report and $gu (issue #2 Slice 1)", {
  ped <- makeOriginTestPed()
  set.seed(17L)
  gv <- reportGV(ped, guIter = 1000L, guThresh = 2L)

  ## both surfaces carry a numeric guSE column
  expect_true("guSE" %in% names(gv$report))
  expect_true("guSE" %in% names(gv$gu))
  expect_true(is.numeric(gv$report$guSE))
  expect_true(is.numeric(gv$gu$guSE))

  rptSE <- stats::setNames(gv$report$guSE, as.character(gv$report$id))
  eltSE <- stats::setNames(gv$gu$guSE, rownames(gv$gu))

  ## guSE >= 0 everywhere, and the SE is genuinely computed (not hardcoded 0)
  expect_true(all(rptSE >= 0))
  expect_true(any(rptSE > 0))

  ## the issue #76 Undetermined set (gu == 0 policy) also has guSE == 0 in BOTH
  ## surfaces -- M1 / F1 (origin NA both-unknown) and P1 (U-id parents, no
  ## origin); imports M2 / F2 (origin CHINA) are NOT de-inflated.
  expect_equal(unname(rptSE[c("M1", "F1", "P1")]), c(0, 0, 0))
  expect_equal(unname(eltSE[c("M1", "F1", "P1")]), c(0, 0, 0))

  ## the report's guSE and the $gu element's guSE agree per animal
  expect_equal(unname(rptSE[names(eltSE)]), unname(eltSE))

  ## the de-inflated animals keep gu == 0 in step with guSE == 0
  rptGu <- stats::setNames(gv$report$gu, as.character(gv$report$id))
  expect_equal(unname(rptGu[c("M1", "F1", "P1")]), c(0, 0, 0))
})

test_that("reportGV defaults guIter to 1000 iterations (issue #2 Slice 3)", {
  ## Issue #2 D3 (RATIFIED S196): the reportGV/geneDrop function default is
  ## aligned DOWN from 5000 to 1000, to match the Shiny UI default and the
  ## NEWS/CHANGELOG claim. The effective default number of gene-drop
  ## iterations is the contract a scripting user inherits when guIter is
  ## omitted.
  expect_identical(eval(formals(reportGV)[["guIter"]]), 1000L)
})

# ---------------------------------------------------------------------------
# Issue #86 (Session 206): the bundled genetic-value reports embed the
# name-aligned (correct) founder genome equivalent. calcFEFG paired the founder
# contribution vector p (row order) and retention r (id-sorted) BY POSITION, so
# the shipped qcPedGvReport$fg and pedWithGenotypeReport$fg were the wrong
# positional 39.92 -- both pedigrees have unsorted founders. The fix plus a full
# regeneration (set_seed(10); reportGV(ped, guIter = 10000)) replaces them with
# the aligned ~52.75 and refreshes the otherwise-stale objects (they predated
# guSE / nMaleFounders / parentage). FE (no retention term) is unchanged.
# Session 210: S206 had saved a NON-reproducible fg=52.7641277 (a contaminated
# RNG state at save time); the documented recipe deterministically yields
# 52.7546854 (display 52.75). S210 regenerated to that reproducible value.
# ---------------------------------------------------------------------------
test_that("bundled GV reports embed the name-aligned fg (issue #86)", {
  for (rpt in list(nprcgenekeepr::qcPedGvReport,
                   nprcgenekeepr::pedWithGenotypeReport)) {
    expect_gt(rpt$fg, 50) # not the old positional 39.92
    expect_equal(rpt$fg, 52.7546854, tolerance = 1e-6) # reproducible value (S210)
    expect_equal(rpt$fe, 77.0402760, tolerance = 1e-6) # FE unaffected
  }
})

test_that("bundled GV reports are regenerated to the current reportGV structure (issue #86)", {
  for (rpt in list(nprcgenekeepr::qcPedGvReport,
                   nprcgenekeepr::pedWithGenotypeReport)) {
    expect_true(all(c("nMaleFounders", "nFemaleFounders") %in% names(rpt)))
    expect_true("guSE" %in% names(rpt$gu))
    expect_true(all(c("guSE", "parentage") %in% names(rpt$report)))
  }
})

# ---------------------------------------------------------------------------
# Session 210: the bundled GV reports were regenerated (set_seed(10);
# reportGV(ped, guIter = 10000)) AFTER fgSE was added to reportGV()'s return
# (issue #82 Slice 3, S208), so they now carry the founder-genome-equivalent
# sampling SE as a finite, positive colony-level scalar alongside fg.
# ---------------------------------------------------------------------------
test_that("bundled GV reports carry a finite positive scalar fgSE (issue #82, S210)", {
  for (rpt in list(nprcgenekeepr::qcPedGvReport,
                   nprcgenekeepr::pedWithGenotypeReport)) {
    expect_true("fgSE" %in% names(rpt))
    expect_length(rpt$fgSE, 1L)
    expect_true(is.finite(rpt$fgSE))
    expect_gt(rpt$fgSE, 0)
  }
})

# ---------------------------------------------------------------------------
# Issue #82 Slice 3: reportGV carries the founder-genome-equivalent sampling
# standard error (fgSE) as a colony-level SCALAR alongside fg, computed from the
# SAME gene drop that produces fg. Unlike guSE (per-animal), fgSE is one number,
# so it rides next to fg and is NOT a column in $report or $gu (plan F2). qcPed
# has real retention variance and no degeneracy at K = 1000 (seed 1), giving a
# finite, strictly positive SE.
# ---------------------------------------------------------------------------
test_that("reportGV carries a scalar fgSE alongside fg (issue #82 Slice 3)", {
  skip_on_cran()
  set.seed(1L)
  gv <- reportGV(nprcgenekeepr::qcPed, guIter = 1000L)

  expect_true("fgSE" %in% names(gv))
  expect_true(is.numeric(gv$fgSE))
  expect_length(gv$fgSE, 1L)
  expect_true(is.finite(gv$fgSE))
  expect_gt(gv$fgSE, 0)

  ## fg itself stays a scalar and is unchanged (additive)
  expect_length(gv$fg, 1L)

  ## FG is a colony-level scalar: fgSE must NOT be a per-animal column
  expect_false("fgSE" %in% names(gv$report))
  expect_false("fgSE" %in% names(gv$gu))
})

# ---------------------------------------------------------------------------
# Issue #13 Slice 1: reportGV accepts an optional kinshipOverrides frame
# (id1, id2, kinship) that REPLACES the named off-diagonal cells of the kinship
# matrix (and the symmetric twin) immediately after the matrix is built and
# BEFORE mean kinship / the issue-#9 correction, so outside information changes
# GV mean-kinship rankings from a script. Properties pinned:
#  - D10: the no-override path is byte-identical to today.
#  - D5: a non-proband override id is warn-dropped, never aborting the run.
#  - Keep-all (RATIFIED S234, revert of D11): an override REFINES a kinship cell
#    but NEVER drops a focal's +sexMean/2 prior -- every one-unknown animal
#    keeps its correction, and an overridden animal stays a valid cohort peer.
# Expected values are recomputed independently in base R from the *overridden*
# matrix so the assertions do not depend on the implementation. qcPed has no
# species column (default cutoff 2 years, gestation 210 days) and all 43
# one-unknown animals are sire-missing (male cohorts).
# ---------------------------------------------------------------------------

# Independent base-R one-unknown correction on a given (possibly overridden)
# mean-kinship vector. Keep-all (issue #95 revert, S234): EVERY one-unknown
# animal is corrected -- no override ever suppresses the +sexMean/2 add.
i13_correctKeepAll <- function(ped, original, probands) {
  isU <- function(x) is.na(x) | nprcgenekeepr:::isGeneratedUnknownId(x)
  sireMiss <- isU(ped$sire)
  oneU <- xor(sireMiss, isU(ped$dam))
  corrected <- original
  for (i in which(oneU)) {
    id <- as.character(ped$id[i])
    bf <- ped$birth[i]
    cand <- ped$sex == "M" & !is.na(ped$birth) &
      ped$birth <= (bf - 365L * 2L) &
      (is.na(ped$exit) | ped$exit >= (bf - 210L)) &
      ped$id != ped$id[i]
    cohort <- as.character(ped$id[cand])
    cohort <- cohort[cohort %in% probands]
    if (length(cohort) == 0L) next
    corrected[id] <- min(original[id] + mean(original[cohort]) / 2, 1)
  }
  corrected
}

test_that("reportGV no-override path is byte-identical to today (issue #13 D10)", {
  ped <- nprcgenekeepr::qcPed
  a <- reportGV(ped, guIter = 20L)
  b <- reportGV(ped, guIter = 20L, kinshipOverrides = NULL)
  ## indivMeanKin is deterministic (kinship + correction; no gene-drop random)
  ia <- a$report$indivMeanKin[order(a$report$id)]
  ib <- b$report$indivMeanKin[order(b$report$id)]
  expect_equal(ia, ib)
  ## the returned kinship matrix is unchanged by an absent override
  expect_equal(b$kinship, a$kinship)
})

test_that("reportGV applies an outside kinship override and KEEPS the #9 add for the overridden one-unknown animal (issue #95 keep-all revert)", {
  ped <- nprcgenekeepr::qcPed
  probands <- as.character(ped$id)
  isU <- function(x) is.na(x) | nprcgenekeepr:::isGeneratedUnknownId(x)
  oneU <- xor(isU(ped$sire), isU(ped$dam))

  X <- "0K7VJN" # male, one-unknown (sire missing)
  Y <- "N2XF08" # known parentage
  Z <- "K0ACWS" # one-unknown (sire missing); X is in its male cohort
  ## fixture guards: if qcPed changes, fail loudly instead of mis-testing
  expect_true(all(c(X, Y, Z) %in% probands))
  expect_true(oneU[ped$id == X])
  expect_true(oneU[ped$id == Z])
  expect_false(oneU[ped$id == Y])
  expect_identical(as.character(ped$sex[ped$id == X]), "M")

  ov <- data.frame(id1 = X, id2 = Y, kinship = 0.25, stringsAsFactors = FALSE)

  ## independent expectation: apply (X, Y) = 0.25, recompute mean kinship, then
  ## the keep-all #9 correction (every one-unknown animal keeps +sexMean/2).
  kmat <- nprcgenekeepr:::filterKinMatrix(
    probands, kinship(ped$id, ped$sire, ped$dam, ped$gen)
  )
  kmat[X, Y] <- kmat[Y, X] <- 0.25
  original <- meanKinship(kmat)[probands]
  expected <- i13_correctKeepAll(ped, original, probands)

  gvr <- suppressMessages(
    reportGV(ped, guIter = 20L, kinshipOverrides = ov)
  )
  imk <- stats::setNames(
    gvr$report$indivMeanKin, as.character(gvr$report$id)
  )[probands]

  ## backbone: the whole indivMeanKin vector matches the independent model
  expect_equal(unname(imk[probands]), unname(expected[probands]))

  ## the returned matrix carries the symmetric override
  expect_equal(gvr$kinship[X, Y], 0.25)
  expect_equal(gvr$kinship[Y, X], 0.25)

  ## the overridden one-unknown animal KEEPS its +sexMean/2 prior (the opposite
  ## of the reverted rule (i); the override refines `original`, not the prior)
  expect_gt(imk[[X]], original[[X]])
  ## a non-overridden one-unknown animal still gets its correction
  expect_gt(imk[[Z]], original[[Z]])
})

test_that("reportGV keeps an overridden animal as a valid cohort peer (issue #95 keep-all)", {
  ped <- nprcgenekeepr::qcPed
  probands <- as.character(ped$id)
  X <- "0K7VJN" # male one-unknown, a peer in Z's male cohort
  Y <- "N2XF08"
  Z <- "K0ACWS"
  ov <- data.frame(id1 = X, id2 = Y, kinship = 0.25, stringsAsFactors = FALSE)

  over <- suppressMessages(reportGV(ped, guIter = 20L, kinshipOverrides = ov))
  base <- reportGV(ped, guIter = 20L)
  imkOver <- stats::setNames(
    over$report$indivMeanKin, as.character(over$report$id)
  )
  imkBase <- stats::setNames(
    base$report$indivMeanKin, as.character(base$report$id)
  )
  ## Z's correction rises because peer X's override-raised value flows through
  ## its sexMean cohort (the cell-write refines `original`, which the cohort
  ## averages over).
  expect_gt(imkOver[[Z]], imkBase[[Z]])
})

test_that("reportGV warn-drops a non-proband override id rather than aborting the run (issue #13 D5)", {
  ped <- nprcgenekeepr::qcPed
  probands <- as.character(ped$id)
  bogus <- "NOT_A_PROBAND_ID"
  expect_false(bogus %in% probands)
  ov <- data.frame(
    id1 = c("0K7VJN", "0K7VJN"),
    id2 = c("N2XF08", bogus), # second pair references a non-member id
    kinship = c(0.25, 0.25),
    stringsAsFactors = FALSE
  )
  ## the run completes (not aborted) and warns about the dropped id
  expect_warning(
    gvr <- suppressMessages(
      reportGV(ped, guIter = 20L, kinshipOverrides = ov)
    )
  )
  expect_s3_class(gvr$report, "data.frame")
  ## the surviving real override still took effect
  expect_equal(gvr$kinship["0K7VJN", "N2XF08"], 0.25)
})

# ---------------------------------------------------------------------------
# Issue #123 (XARCH-5) Phase 1: today, reportGV() called on a pedigree missing
# 'sex' returns SUCCESSFULLY with no error/warning, silently dropping 'sex'
# from $report and corrupting nMaleFounders/nFemaleFounders/total to 0/0/0
# (reproduced by execution, docs/planning/issue123-xarch5-column-schema-plan.md
# S2.3). After the fix, the same call must instead error clearly, naming the
# missing column, before any founder-count corruption occurs.
# ---------------------------------------------------------------------------
test_that("reportGV errors clearly when 'sex' is missing instead of silently corrupting founder counts (issue #123 / XARCH-5)", {
  pedNoSex <- nprcgenekeepr::qcPed
  pedNoSex$sex <- NULL
  expect_error(
    reportGV(pedNoSex, guIter = 20L, guThresh = 3L, byID = TRUE,
             updateProgress = NULL),
    "required column\\(s\\) missing.*sex"
  )
})

