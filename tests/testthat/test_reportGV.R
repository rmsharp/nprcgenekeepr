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

