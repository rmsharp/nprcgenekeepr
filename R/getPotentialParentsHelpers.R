## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Internal helpers for getPotentialParents() (PED-4, NEW-54). The exported
## function keeps the argument handling and the per-animal loop; each helper
## below is one step of that loop. Inside the data.table calls a column name
## wins over a variable of the same name, which is why the focal animal's birth
## date is passed as `focalBirth` and never as `birth`.

#' Map the deprecated minParentAge onto the sex-specific minimum ages
#'
#' Used only when \code{minParentAge} was supplied. A \code{NULL}
#' \code{minParentAge} is the legacy "no age check" and overrides both ages; a
#' scalar fills whichever of the two ages is \code{NULL}.
#'
#' @param minSireAge numeric or \code{NULL}.
#' @param minDamAge numeric or \code{NULL}.
#' @param minParentAge numeric scalar or \code{NULL}.
#' @return a list with elements \code{minSireAge} and \code{minDamAge}.
#' @noRd
resolveMinParentAges <- function(minSireAge, minDamAge, minParentAge) {
  if (is.null(minParentAge)) {
    ## Legacy: minParentAge = NULL disabled the age check entirely.
    minSireAge <- -Inf
    minDamAge <- -Inf
  } else {
    if (is.null(minSireAge)) minSireAge <- minParentAge
    if (is.null(minDamAge)) minDamAge <- minParentAge
  }
  list(minSireAge = minSireAge, minDamAge = minDamAge)
}

#' Gestation window for each animal with an unknown parent
#'
#' A supplied \code{maxGestationalPeriod} is used for every animal; otherwise
#' the window is keyed to each animal's species and falls back to 210 days when
#' the \code{species} column is absent, missing, or unrecognized.
#'
#' @param pUnknown data.table of the animals with an unknown parent.
#' @param maxGestationalPeriod integer or \code{NULL}.
#' @param gestationTable optional table passed to
#' \code{\link{getSpeciesGestation}}.
#' @return integer vector, one window (days) per row of \code{pUnknown}.
#' @noRd
gestationWindows <- function(pUnknown, maxGestationalPeriod, gestationTable) {
  if (is.null(maxGestationalPeriod)) {
    speciesVec <- if ("species" %in% names(pUnknown)) {
      pUnknown$species
    } else {
      rep(NA_character_, nrow(pUnknown))
    }
    getSpeciesGestation(speciesVec, gestationTable = gestationTable)
  } else {
    rep(as.integer(maxGestationalPeriod), nrow(pUnknown))
  }
}

#' Candidate sires for one focal animal
#'
#' @param ba data.table of the candidates old enough to be a parent.
#' @param focalBirth the focal animal's birth date.
#' @param mgp gestation window in days; a sire who exited before conception
#' (\code{focalBirth - mgp}) is dropped.
#' @return character vector of candidate sire ids.
#' @noRd
selectPotentialSires <- function(ba, focalBirth, mgp) {
  exit <- id <- sex <- NULL
  ba[
    sex == sexCodes[["male"]] &
      (is.na(exit) | exit >= (focalBirth - mgp)),
    id
  ]
}

#' Candidate dams for one focal animal, and which tier supplied them
#'
#' Females present at the birth who did not deliver another offspring within
#' \code{mgp} days of it. Proven breeders (an offspring 0.5 to 1.5 years from
#' the focal birth) are preferred; when none remain every such female is
#' offered.
#'
#' @param ba data.table of the candidates old enough to be a parent.
#' @param focalBirth the focal animal's birth date.
#' @param mgp gestation window in days.
#' @param ped data.table of the whole working pedigree.
#' @return list with \code{ids} (character) and \code{basis}
#' (\code{"provenBreeder"} or \code{"eligibleFemale"}).
#' @noRd
selectPotentialDams <- function(ba, focalBirth, mgp, ped) {
  birth <- exit <- id <- sex <- NULL
  dYear <- 365L # used for number of days in a year
  potentialDams <- ba[sex == sexCodes[["female"]] &
    (is.na(exit) | exit >= focalBirth), ]

  ## Females who delivered another offspring within one gestational period of
  ## the focal birth: a female bears one offspring at a time, so she cannot have
  ## gestated the focal animal as well.
  births <-
    ped[birth >= focalBirth - mgp &
      birth <= focalBirth + mgp, ]

  ## Females who had an offspring in the year prior or year after
  births_plus_minus_one <-
    ped[(
      birth <= focalBirth + (dYear * 1.5) &
        birth > focalBirth + (dYear / 2L)
    ) |
      (
        birth >= focalBirth - (dYear * 1.5) &
          birth < focalBirth - (dYear / 2L)
      ), ]
  births_plus_minus_one <-
    births_plus_minus_one[!duplicated(births_plus_minus_one$dam), ]

  eligibleDams <- potentialDams[!id %in% births$dam, ]
  ## Preferentially accept dams that are proven breeders near the time of the
  ## birth.
  provenDams <- eligibleDams[id %in% births_plus_minus_one$dam, ]
  if (nrow(provenDams) == 0L) {
    ## No proven breeder remains: accept every eligible female (PED_GV F3,
    ## NEW-35).
    list(ids = eligibleDams$id, basis = "eligibleFemale")
  } else {
    list(ids = provenDams$id, basis = "provenBreeder")
  }
}

#' One entry of the getPotentialParents() result
#'
#' Candidates are listed only for the parent that is missing; a recorded parent
#' is never re-listed. \code{damBasis} is \code{NA} when no dam is listed.
#'
#' @param focal one-row data.table with \code{id}, \code{sire} and \code{dam}.
#' @param sires character vector of candidate sire ids.
#' @param dams character vector of candidate dam ids.
#' @param damBasis the tier that supplied \code{dams}.
#' @return list with \code{id}, \code{sires}, \code{dams} and \code{damBasis}.
#' @noRd
buildParentEntry <- function(focal, sires, dams, damBasis) {
  dams <- if (is.na(focal$dam)) dams else character(0L)
  list(
    id = focal$id,
    sires = if (is.na(focal$sire)) sires else character(0L),
    dams = dams,
    damBasis = if (length(dams) > 0L) damBasis else NA_character_
  )
}
