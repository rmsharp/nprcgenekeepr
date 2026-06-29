#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
##
## Tests for the issue #9 Slice 2 mean-kinship correction (plan section 8-C/E):
## animals missing exactly one parent (the other parent known) have their
## individual mean kinship raised by sexMean/2, where sexMean is the mean
## individual mean kinship of the focal animal's contemporaneous breeding-age
## peers of the MISSING parent's sex. Fully-known-parentage animals and
## both-unknown founders are left unchanged. Two internal helpers are exercised:
##   getBreedingPeerCohort()         -- selects the contemporaneous, breeding-age,
##                                      sex-appropriate peer ids
##   correctUnknownParentMeanKinship() -- orchestrates the per-animal correction
## The fallback ladder is tier 1 (strict contemporaneous cohort) -> tier 3
## (leave uncorrected and flag; add 0, never NA). Tier 2 (nearest-earlier
## same-era cohort) is deferred (owner decision, S178) -- it never fires on the
## shipped qcPed and "same era side" has no era mechanism in the package yet.

d <- function(x) as.Date(x)

# ---------------------------------------------------------------------------
# getBreedingPeerCohort() -- cohort selection
# ---------------------------------------------------------------------------

## Candidate pool (no species column): breeding age uses the default cutoff 2.
## focal birth 2010-01-01, missing sire -> male cohort.
##   breeding age (cutoff 2): birth <= 2010-01-01 - 730 d  = 2008-01-02
##   contemporaneous (default gestation 210 d): present at conception, i.e.
##     exit is NA OR exit >= 2010-01-01 - 210 d = 2009-06-05
cohortPedNoSpecies <- data.frame(
  id = c("M_old", "M_mid", "M_exited_ok", "M_exited", "M_young2", "F_old"),
  sex = c("M", "M", "M", "M", "M", "F"),
  birth = d(c("2005-01-01", "2007-06-01", "2005-01-01",
    "2005-01-01", "2008-06-01", "2005-01-01")),
  exit = d(c(NA, NA, "2009-12-01", "2009-01-01", NA, NA)),
  stringsAsFactors = FALSE
)

test_that("getBreedingPeerCohort selects contemporaneous breeding-age peers (cutoff 2)", {
  cohort <- nprcgenekeepr:::getBreedingPeerCohort(
    focalBirth = d("2010-01-01"),
    focalSpecies = NA_character_,
    missingSex = "M",
    candidatePed = cohortPedNoSpecies
  )
  ## M_mid is breeding-age at cutoff 2; M_young2 too young; M_exited left the
  ## colony before conception; F_old is the wrong sex.
  expect_setequal(cohort, c("M_old", "M_mid", "M_exited_ok"))
})

test_that("getBreedingPeerCohort uses the species cutoff when species is present", {
  cohortPedRhesus <- cohortPedNoSpecies
  cohortPedRhesus$species <- "RHESUS"
  cohort <- nprcgenekeepr:::getBreedingPeerCohort(
    focalBirth = d("2010-01-01"),
    focalSpecies = "RHESUS",
    missingSex = "M",
    candidatePed = cohortPedRhesus
  )
  ## rhesus male cutoff 4: birth <= 2010-01-01 - 1460 d = 2006-01-02, so M_mid
  ## (born 2007-06-01) is now too young and drops out.
  expect_setequal(cohort, c("M_old", "M_exited_ok"))
})

test_that("getBreedingPeerCohort returns character(0) when no peer qualifies", {
  onlyYoung <- data.frame(
    id = c("y1", "y2"),
    sex = c("M", "M"),
    birth = d(c("2009-06-01", "2009-09-01")),
    exit = d(c(NA, NA)),
    stringsAsFactors = FALSE
  )
  cohort <- nprcgenekeepr:::getBreedingPeerCohort(
    focalBirth = d("2010-01-01"),
    focalSpecies = NA_character_,
    missingSex = "M",
    candidatePed = onlyYoung
  )
  expect_identical(cohort, character(0L))
})

# ---------------------------------------------------------------------------
# correctUnknownParentMeanKinship() -- per-animal orchestration
# ---------------------------------------------------------------------------

## One coherent fixture. Peers are both-unknown founders (sire = dam = NA) with
## assigned indivMeanKin; they are left unchanged but serve as cohort members.
## focal birth 2010-01-01, cutoff 2 -> breeding-age birth <= 2008-01-02.
##   male cohort   = {m1, m2, sire_known}     sexMean = mean(.10,.30,.20) = .20
##   female cohort = {f1, f2, dam_known}      sexMean = mean(.40,.60,.50) = .50
orchPed <- data.frame(
  id = c("foc_sire", "foc_uid", "foc_dam", "known", "both_unk",
    "m1", "m2", "sire_known", "f1", "f2", "dam_known"),
  sex = c("F", "F", "M", "F", "M",
    "M", "M", "M", "F", "F", "F"),
  birth = d(c("2010-01-01", "2010-01-01", "2010-01-01", "2012-01-01",
    "2008-06-01", "2005-01-01", "2006-01-01", "2004-01-01",
    "2005-01-01", "2006-01-01", "2004-01-01")),
  exit = as.Date(rep(NA, 11L)),
  sire = c(NA, "U0001", "sire_known", "sire_known", NA,
    NA, NA, NA, NA, NA, NA),
  dam = c("dam_known", "dam_known", NA, "dam_known", NA,
    NA, NA, NA, NA, NA, NA),
  stringsAsFactors = FALSE
)
orchImk <- c(
  foc_sire = 0.05, foc_uid = 0.05, foc_dam = 0.05, known = 0.07,
  both_unk = 0.02, m1 = 0.10, m2 = 0.30, sire_known = 0.20,
  f1 = 0.40, f2 = 0.60, dam_known = 0.50
)

test_that("correctUnknownParentMeanKinship raises one-unknown animals by sexMean/2", {
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(orchImk, orchPed)
  ## missing sire -> male cohort sexMean .20 -> +.10
  expect_equal(res$indivMeanKin[["foc_sire"]], 0.15)
  ## U-id sire string is treated as missing (the qcPed targeting trap)
  expect_equal(res$indivMeanKin[["foc_uid"]], 0.15)
  ## missing dam -> female cohort sexMean .50 -> +.25
  expect_equal(res$indivMeanKin[["foc_dam"]], 0.30)
})

test_that("correctUnknownParentMeanKinship leaves known and both-unknown unchanged", {
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(orchImk, orchPed)
  expect_equal(res$indivMeanKin[["known"]], 0.07)
  expect_equal(res$indivMeanKin[["both_unk"]], 0.02)
  ## peers (both-unknown founders) are untouched too
  expect_equal(res$indivMeanKin[["m1"]], 0.10)
  expect_equal(res$indivMeanKin[["dam_known"]], 0.50)
})

test_that("correctUnknownParentMeanKinship preserves names and order", {
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(orchImk, orchPed)
  expect_identical(names(res$indivMeanKin), names(orchImk))
})

test_that("correctUnknownParentMeanKinship reports no flag when cohorts are non-empty", {
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(orchImk, orchPed)
  expect_identical(res$flagged, character(0L))
})

test_that("correctUnknownParentMeanKinship clamps the corrected value to 1", {
  clampPed <- data.frame(
    id = c("foc_clamp", "mp", "dk"),
    sex = c("F", "M", "F"),
    birth = d(c("2010-01-01", "2005-01-01", "2004-01-01")),
    exit = as.Date(rep(NA, 3L)),
    sire = c(NA, NA, NA),
    dam = c("dk", NA, NA),
    stringsAsFactors = FALSE
  )
  clampImk <- c(foc_clamp = 0.95, mp = 0.40, dk = 0.50)
  ## male cohort = {mp}, sexMean = .40 -> 0.95 + .20 = 1.15 -> clamp to 1
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(clampImk, clampPed)
  expect_equal(res$indivMeanKin[["foc_clamp"]], 1.0)
})

test_that("correctUnknownParentMeanKinship flags (not NA) an empty-cohort animal", {
  emptyPed <- data.frame(
    id = c("foc_empty", "too_young", "dk2"),
    sex = c("F", "M", "F"),
    birth = d(c("2010-01-01", "2009-06-01", "2004-01-01")),
    exit = as.Date(rep(NA, 3L)),
    sire = c(NA, NA, NA),
    dam = c("dk2", NA, NA),
    stringsAsFactors = FALSE
  )
  emptyImk <- c(foc_empty = 0.05, too_young = 0.10, dk2 = 0.50)
  ## the only male is too young -> empty male cohort -> tier 3 fallback
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(emptyImk, emptyPed)
  expect_equal(res$indivMeanKin[["foc_empty"]], 0.05) # unchanged, NOT NA
  expect_false(is.na(res$indivMeanKin[["foc_empty"]]))
  expect_true("foc_empty" %in% res$flagged)
})

test_that("correctUnknownParentMeanKinship flags an animal with no birth date", {
  noBirthPed <- data.frame(
    id = c("foc_nobirth", "m1", "dk3"),
    sex = c("F", "M", "F"),
    birth = d(c(NA, "2005-01-01", "2004-01-01")),
    exit = as.Date(rep(NA, 3L)),
    sire = c(NA, NA, NA),
    dam = c("dk3", NA, NA),
    stringsAsFactors = FALSE
  )
  noBirthImk <- c(foc_nobirth = 0.05, m1 = 0.10, dk3 = 0.50)
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(noBirthImk, noBirthPed)
  expect_equal(res$indivMeanKin[["foc_nobirth"]], 0.05) # unchanged, NOT NA
  expect_true("foc_nobirth" %in% res$flagged)
})

test_that("correctUnknownParentMeanKinship keeps the corrected vector in [0,1]", {
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(orchImk, orchPed)
  expect_true(all(res$indivMeanKin >= 0))
  expect_true(all(res$indivMeanKin <= 1))
})

# ---------------------------------------------------------------------------
# Issue #73 Part 2 Slice 1: configurable absent-species fallbacks threaded down
# to the accessors. getBreedingPeerCohort and correctUnknownParentMeanKinship
# gain breedingAgeDefault / gestationDefault params; NULL (the default) means
# "use the accessor's built-in" (2 years / 210 days) so no-config behavior is
# byte-identical to today. The breedingTable / gestationTable params already
# exist (issue #9 Slice 2) and are exercised above.
# ---------------------------------------------------------------------------

test_that("getBreedingPeerCohort honors a configurable breedingAgeDefault", {
  ## cutoff 4 (no species -> default): birth <= 2010-01-01 - 1460 d = 2006-01-02,
  ## so M_mid (born 2007-06-01) drops out vs the default-2 cohort.
  cohort <- nprcgenekeepr:::getBreedingPeerCohort(
    focalBirth = d("2010-01-01"),
    focalSpecies = NA_character_,
    missingSex = "M",
    candidatePed = cohortPedNoSpecies,
    breedingAgeDefault = 4
  )
  expect_setequal(cohort, c("M_old", "M_exited_ok"))
})

test_that("getBreedingPeerCohort honors a configurable gestationDefault", {
  ## widening the conception window to 365 d (cutoff 2009-01-01) lets M_exited
  ## (exit 2009-01-01) back into the cohort vs the default-210 window.
  cohort <- nprcgenekeepr:::getBreedingPeerCohort(
    focalBirth = d("2010-01-01"),
    focalSpecies = NA_character_,
    missingSex = "M",
    candidatePed = cohortPedNoSpecies,
    gestationDefault = 365L
  )
  expect_setequal(cohort, c("M_old", "M_mid", "M_exited_ok", "M_exited"))
})

test_that("correctUnknownParentMeanKinship honors a configurable breedingAgeDefault", {
  ## cutoff 5 (birth <= 2005-01-02) shrinks the male cohort to {m1, sire_known}
  ## (mean .15) and the female cohort to {f1, dam_known} (mean .45).
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(
    orchImk, orchPed, breedingAgeDefault = 5
  )
  expect_equal(res$indivMeanKin[["foc_sire"]], 0.125)
  expect_equal(res$indivMeanKin[["foc_uid"]], 0.125)
  expect_equal(res$indivMeanKin[["foc_dam"]], 0.275)
})

test_that("correctUnknownParentMeanKinship honors a configurable gestationDefault", {
  gestPed <- data.frame(
    id = c("foc", "m_in", "m_exit_edge", "dk"),
    sex = c("F", "M", "M", "F"),
    birth = d(c("2010-01-01", "2005-01-01", "2005-01-01", "2004-01-01")),
    exit = d(c(NA, NA, "2009-03-01", NA)),
    sire = c("U0001", NA, NA, NA),
    dam = c("dk", NA, NA, NA),
    stringsAsFactors = FALSE
  )
  gestImk <- c(foc = 0.05, m_in = 0.10, m_exit_edge = 0.30, dk = 0.50)
  ## default 210 d: conception window cutoff 2009-06-05; m_exit_edge (exit
  ## 2009-03-01) is excluded -> male cohort {m_in} mean .10 -> foc 0.05 + .05.
  resDefault <- nprcgenekeepr:::correctUnknownParentMeanKinship(gestImk, gestPed)
  expect_equal(resDefault$indivMeanKin[["foc"]], 0.10)
  ## 400 d: cutoff 2008-11-27; m_exit_edge now present -> cohort {m_in,
  ## m_exit_edge} mean .20 -> foc 0.05 + .10.
  resWide <- nprcgenekeepr:::correctUnknownParentMeanKinship(
    gestImk, gestPed, gestationDefault = 400L
  )
  expect_equal(resWide$indivMeanKin[["foc"]], 0.15)
})

# ---------------------------------------------------------------------------
# Issue #95 revert (RATIFIED S234, implemented S235): the option-C / D11
# blanket supersession is reverted to KEEP-ALL. correctUnknownParentMeanKinship
# no longer takes an `overriddenIds` argument and corrects EVERY one-unknown
# animal -- an override refines a kinship cell (issue #13) but never drops a
# focal's +sexMean/2 prior. See the issue95 targeted-suppression plan section 9.
# ---------------------------------------------------------------------------

test_that("correctUnknownParentMeanKinship no longer accepts an overriddenIds argument", {
  expect_error(
    nprcgenekeepr:::correctUnknownParentMeanKinship(
      orchImk, orchPed,
      overriddenIds = "foc_sire"
    ),
    "unused argument"
  )
})

test_that("correctUnknownParentMeanKinship corrects every one-unknown animal (keep-all)", {
  res <- nprcgenekeepr:::correctUnknownParentMeanKinship(orchImk, orchPed)
  ## every one-unknown animal keeps its +sexMean/2 prior; none is suppressed
  expect_gt(res$indivMeanKin[["foc_sire"]], orchImk[["foc_sire"]])
  expect_gt(res$indivMeanKin[["foc_uid"]], orchImk[["foc_uid"]])
  expect_gt(res$indivMeanKin[["foc_dam"]], orchImk[["foc_dam"]])
})
