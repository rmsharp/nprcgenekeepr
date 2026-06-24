#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
qcPed <- nprcgenekeepr::qcPed
gvReport <- reportGV(qcPed, guIter = 100L)
test_that("reportGV forms correct genetic value report", {
  expect_named(gvReport, c(
    "report", "kinship", "gu", "fe", "fg",
    "maleFounders", "femaleFounders",
    "nMaleFounders", "nFemaleFounders", "total"
  ))
  expect_named(gvReport$report,
    c(
      "id", "sex", "age", "birth", "exit", "population", "sire", "dam",
      "indivMeanKin", "zScores", "gu", "totalOffspring",
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

gvReport <- reportGV(qcPed, guIter = 100L, updateProgress = updateProgress)
test_that(
  "reportGV forms correct genetic value report with updateProgress defined",
  {
    expect_named(gvReport, c(
      "report", "kinship", "gu", "fe", "fg",
      "maleFounders", "femaleFounders",
      "nMaleFounders", "nFemaleFounders", "total"
    ))
    expect_named(gvReport$report,
      c(
        "id", "sex", "age", "birth", "exit", "population", "sire", "dam",
        "indivMeanKin", "zScores", "gu", "totalOffspring",
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

  gvr <- reportGV(ped, guIter = 100L)
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
  rpt <- reportGV(ped, guIter = 100L)$report
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

  over <- reportGV(ped, guIter = 100L, breedingAgeDefault = 4)
  base <- reportGV(ped, guIter = 100L)
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

  over <- reportGV(ped, guIter = 100L, gestationDefault = 36500L)
  base <- reportGV(ped, guIter = 100L)
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
  over <- reportGV(pedSpp, guIter = 100L, breedingTable = custom)
  bundled <- reportGV(pedSpp, guIter = 100L) # bundled RHESUS male 4
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
  over <- reportGV(pedSpp, guIter = 100L,
                   breedingTable = customAge, gestationTable = customGest)
  base <- reportGV(pedSpp, guIter = 100L, breedingTable = customAge)
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
  a <- reportGV(ped, guIter = 100L)
  b <- reportGV(ped, guIter = 100L, breedingTable = NULL, gestationTable = NULL,
                breedingAgeDefault = NULL, gestationDefault = NULL)
  ## indivMeanKin is deterministic (kinship + correction; no gene-drop random);
  ## explicit-NULL overrides must reproduce today's behavior byte for byte.
  ia <- a$report$indivMeanKin[order(a$report$id)]
  ib <- b$report$indivMeanKin[order(b$report$id)]
  expect_equal(ia, ib)
})

