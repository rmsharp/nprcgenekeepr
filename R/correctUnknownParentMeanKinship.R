#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr

#' Select a focal animal's contemporaneous breeding-age peer cohort
#'
#' Returns the ids of the candidate animals that could stand in for a focal
#' animal's missing parent: animals of the missing parent's sex, of breeding age
#' relative to the focal birth, and present in the colony at the focal's
#' conception. Breeding age is keyed to each candidate's species via
#' \code{\link{getSpeciesMinBreedingAge}} (falling back to 2 years when the
#' \code{species} column is absent or unrecognized); the conception window is
#' keyed to the focal animal's species via \code{\link{getSpeciesGestation}}
#' (falling back to 210 days). Part of the issue #9 Slice 2 mean-kinship
#' correction.
#'
#' @param focalBirth the focal animal's birth date (\code{Date}, length 1).
#' @param focalSpecies the focal animal's species (character, length 1, may be
#' \code{NA}); keys the conception window.
#' @param missingSex \code{"M"} when the sire is missing, \code{"F"} when the
#' dam is missing.
#' @param candidatePed data.frame of candidate animals with at least \code{id},
#' \code{sex}, \code{birth} (\code{Date}), and \code{exit} (\code{Date},
#' \code{NA} when still present); an optional \code{species} column keys the
#' per-candidate breeding age.
#' @param gestationTable optional gestation lookup passed to
#' \code{\link{getSpeciesGestation}}.
#' @param breedingTable optional breeding-age lookup passed to
#' \code{\link{getSpeciesMinBreedingAge}}.
#' @param breedingAgeDefault optional numeric fallback breeding age (years) for
#' species absent from the table; \code{NULL} (the default) uses the accessor's
#' built-in (2 years). Issue #73 Part 2.
#' @param gestationDefault optional integer fallback gestation window (days) for
#' species absent from the table; \code{NULL} (the default) uses the accessor's
#' built-in (210 days). Issue #73 Part 2.
#' @return a character vector of candidate ids in the cohort (possibly empty).
#' @noRd
getBreedingPeerCohort <- function(focalBirth, focalSpecies, missingSex,
                                  candidatePed, gestationTable = NULL,
                                  breedingTable = NULL,
                                  breedingAgeDefault = NULL,
                                  gestationDefault = NULL) {
  if (length(focalBirth) != 1L || is.na(focalBirth) ||
    nrow(candidatePed) == 0L) {
    return(character(0L))
  }
  spp <- if ("species" %in% names(candidatePed)) {
    candidatePed$species
  } else {
    rep(NA_character_, nrow(candidatePed))
  }
  # A configurable default of NULL means "use the accessor's built-in". The
  # accessors do not accept default = NULL (rep(NULL, n) empties the result), so
  # omit the argument rather than threading a bare NULL (issue #73 Part 2, R2).
  minAge <- if (is.null(breedingAgeDefault)) {
    getSpeciesMinBreedingAge(spp, missingSex, breedingTable = breedingTable)
  } else {
    getSpeciesMinBreedingAge(spp, missingSex, breedingTable = breedingTable,
      default = breedingAgeDefault
    )
  }
  dYear <- 365L
  gestWindow <- if (is.null(gestationDefault)) {
    getSpeciesGestation(focalSpecies, gestationTable = gestationTable)
  } else {
    getSpeciesGestation(focalSpecies, gestationTable = gestationTable,
      default = gestationDefault
    )
  }
  birth <- candidatePed$birth
  exit <- candidatePed$exit
  keep <- candidatePed$sex == missingSex &
    !is.na(birth) &
    birth <= (focalBirth - dYear * minAge) &
    (is.na(exit) | exit >= (focalBirth - gestWindow))
  keep[is.na(keep)] <- FALSE
  as.character(candidatePed$id[keep])
}

#' Correct the mean kinship of animals missing exactly one parent
#'
#' Raises the individual mean kinship of each animal that is missing exactly one
#' parent (the other parent known) by half the mean individual mean kinship of
#' its contemporaneous breeding-age peers of the missing parent's sex, so a
#' single unknown parent no longer falsely elevates an animal's genetic value
#' (issue #9 Slice 2). The owner's 2020 remedy: model the unknown parent as a
#' typical contemporaneous opposite-sex peer contributing \code{sexMean} to the
#' focal animal's relatedness, so the focal's mean kinship rises by
#' \code{sexMean / 2} per missing parent. Fully-known-parentage animals and
#' both-unknown founders are left unchanged (both-unknown founders are deferred
#' to Slice 3). Unknown parents are detected by an id that is \code{NA} or an
#' auto-generated \code{U}-id.
#'
#' Peer cohorts are computed from the \emph{uncorrected} input so the order of
#' correction does not matter. The correction is clamped to \code{[0, 1]}. When
#' a focal animal has no eligible peer cohort (an empty strict cohort, or no
#' birth date), it is left uncorrected and its id is returned in \code{flagged}
#' (never \code{NA}, never a colony-wide mean). The tier-2 "nearest-earlier
#' same-era cohort" fallback in the ratified plan is deferred (it never fires on
#' the shipped data and the package has no era mechanism yet; owner decision,
#' Session 178). The cohort is drawn only from animals that have an individual
#' mean kinship (the analysis probands), since that is what \code{sexMean}
#' averages.
#'
#' @param indivMeanKin named numeric vector of individual mean kinships, named
#' by animal id (the analysis probands).
#' @param ped pedigree data.frame with at least \code{id}, \code{sire},
#' \code{dam}, \code{sex}, and \code{birth}; optional \code{exit} and
#' \code{species} columns refine the cohort.
#' @param gestationTable optional gestation lookup passed through.
#' @param breedingTable optional breeding-age lookup passed through.
#' @param breedingAgeDefault optional numeric fallback breeding age (years)
#' passed through to the cohort selection; \code{NULL} uses the built-in 2 years
#' (issue #73 Part 2).
#' @param gestationDefault optional integer fallback gestation window (days)
#' passed through to the cohort selection; \code{NULL} uses the built-in 210
#' days (issue #73 Part 2).
#' @return a list with \code{indivMeanKin} (the corrected vector, names and
#' order preserved) and \code{flagged} (character vector of ids left
#' uncorrected for lack of a peer cohort).
#' @noRd
correctUnknownParentMeanKinship <- function(indivMeanKin, ped,
                                            gestationTable = NULL,
                                            breedingTable = NULL,
                                            breedingAgeDefault = NULL,
                                            gestationDefault = NULL) {
  flagged <- character(0L)
  ## Cohort formation needs id/parentage/sex/birth; without them, no correction.
  if (!all(c("id", "sire", "dam", "sex", "birth") %in% names(ped))) {
    return(list(indivMeanKin = indivMeanKin, flagged = flagged))
  }
  candidateIds <- names(indivMeanKin)
  if (is.null(candidateIds)) {
    return(list(indivMeanKin = indivMeanKin, flagged = flagged))
  }
  ped <- as.data.frame(ped, stringsAsFactors = FALSE)
  rownames(ped) <- as.character(ped$id)
  candPed <- ped[candidateIds, , drop = FALSE]
  if (is.null(candPed$exit)) {
    candPed$exit <- as.Date(NA)
  }

  isU <- function(x) is.na(x) | isGeneratedUnknownId(x)
  sireMiss <- isU(candPed$sire)
  damMiss <- isU(candPed$dam)
  oneU <- xor(sireMiss, damMiss)

  spp <- if ("species" %in% names(candPed)) {
    candPed$species
  } else {
    rep(NA_character_, nrow(candPed))
  }

  original <- indivMeanKin # snapshot: cohorts use the uncorrected values
  corrected <- indivMeanKin
  for (i in which(oneU)) {
    focalId <- candidateIds[i]
    missingSex <- if (sireMiss[i]) "M" else "F"
    cohort <- getBreedingPeerCohort(
      focalBirth = candPed$birth[i],
      focalSpecies = spp[i],
      missingSex = missingSex,
      candidatePed = candPed,
      gestationTable = gestationTable,
      breedingTable = breedingTable,
      breedingAgeDefault = breedingAgeDefault,
      gestationDefault = gestationDefault
    )
    cohort <- setdiff(cohort, focalId)
    cohort <- cohort[cohort %in% names(original)]
    if (length(cohort) == 0L) {
      flagged <- c(flagged, focalId)
      next
    }
    sexMean <- mean(original[cohort])
    corrected[focalId] <- min(original[focalId] + sexMean * 0.5, 1.0)
  }
  list(indivMeanKin = corrected, flagged = flagged)
}
