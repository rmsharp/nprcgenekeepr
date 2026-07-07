## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Resolve per-row minimum breeding-age floors from optional sex overrides
#'
#' Internal helper shared by the quality-control and potential-parent code
#' paths. Turns the two optional override scalars (\code{minSireAge},
#' \code{minDamAge}) plus a (species, sex) context into a numeric vector of
#' per-row minimum breeding-age floors. When both overrides are \code{NULL} the
#' floors come straight from \code{\link{getSpeciesMinBreedingAge}} (species-
#' and sex-specific); a supplied override replaces the floor for that sex.
#' Absent, empty, or unknown species falls back to \code{default}, so data with
#' no \code{species} column behaves exactly as the legacy flat minimum did.
#'
#' @param species character vector of species names (may contain \code{NA}).
#' @param sex character vector of sexes (\code{"M"} or \code{"F"}), recycled to
#' the resolved floor length.
#' @param minSireAge optional numeric override applied to male (\code{"M"})
#' rows. \code{NULL} (default) means use the species+sex table floor.
#' @param minDamAge optional numeric override applied to female (\code{"F"})
#' rows. \code{NULL} (default) means use the species+sex table floor.
#' @param breedingTable optional data.frame passed through to
#' \code{\link{getSpeciesMinBreedingAge}}; \code{NULL} uses the bundled table.
#' @param default numeric fallback for species/sex not found in the table.
#' @return numeric vector of minimum breeding ages, one per resolved row.
#' @noRd
resolveBreedingAge <- function(species, sex,
                               minSireAge = NULL, minDamAge = NULL,
                               breedingTable = NULL, default = 2.0) {
  floors <- getSpeciesMinBreedingAge(species, sex,
    breedingTable = breedingTable, default = default
  )
  sexKey <- rep_len(toupper(trimws(as.character(sex))), length(floors))
  if (!is.null(minSireAge)) {
    floors[!is.na(sexKey) & sexKey == "M"] <- as.numeric(minSireAge)
  }
  if (!is.null(minDamAge)) {
    floors[!is.na(sexKey) & sexKey == "F"] <- as.numeric(minDamAge)
  }
  floors
}
