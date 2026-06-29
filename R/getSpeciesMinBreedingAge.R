## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Look up the minimum breeding age (years) for one or more species and sexes
#'
#' Maps each supplied (species, sex) pair to the minimum age in years at which
#' an animal of that species and sex can produce offspring, using the
#' \code{\link{speciesGestation}} lookup table (or a supplied
#' \code{breedingTable}). Matching is case- and whitespace-insensitive on both
#' species and sex. Any species that is missing, \code{NA}, an empty string, or
#' not present in the table -- and any sex that is not \code{"M"} or \code{"F"}
#' -- falls back to \code{default} (2 years, the legacy package-wide minimum
#' parent age). Used by the Genetic Value Analysis unknown-parent mean-kinship
#' correction to form a focal animal's contemporaneous breeding-age peer
#' cohort. The bundled table is populated for the common colony NHP species;
#' the user-configurable override path is a separate feature.
#'
#' @param species character vector of species names (may contain \code{NA}).
#' @param sex character vector of sexes (\code{"M"} or \code{"F"}); recycled to
#' the length of \code{species} (or vice versa).
#' @param breedingTable optional data.frame with a character column
#' \code{species} and numeric columns \code{minMaleBreedingAge} and
#' \code{minFemaleBreedingAge} to use instead of the bundled
#' \code{\link{speciesGestation}} table. Defaults to \code{NULL}, which uses the
#' bundled table.
#' @param default numeric fallback returned for species that are missing,
#' \code{NA}, empty, or not found, and for a sex that is not \code{"M"}/`"F"`.
#' Defaults to \code{2}.
#' @return a numeric vector of minimum breeding ages in years, the same length
#' as the longer of \code{species} and \code{sex}.
#' @examples
#' getSpeciesMinBreedingAge("RHESUS", "M")
#' getSpeciesMinBreedingAge("RHESUS", "F")
#' getSpeciesMinBreedingAge(c("RHESUS", "UNICORN"), c("M", "F"))
#' @export
getSpeciesMinBreedingAge <- function(species, sex, breedingTable = NULL,
                                     default = 2.0) {
  if (is.null(breedingTable)) {
    breedingTable <- speciesGestation
  }
  default <- as.numeric(default)
  if (length(species) == 0L || length(sex) == 0L) {
    return(numeric(0L))
  }
  n <- max(length(species), length(sex))
  species <- rep_len(as.character(species), n)
  sex <- rep_len(as.character(sex), n)
  key <- toupper(trimws(species))
  sexKey <- toupper(trimws(sex))
  tableKey <- toupper(trimws(as.character(breedingTable$species)))
  idx <- match(key, tableKey)
  maleAge <- as.numeric(breedingTable$minMaleBreedingAge)[idx]
  femaleAge <- as.numeric(breedingTable$minFemaleBreedingAge)[idx]
  out <- rep(default, n)
  isM <- !is.na(sexKey) & sexKey == "M" & !is.na(maleAge)
  isF <- !is.na(sexKey) & sexKey == "F" & !is.na(femaleAge)
  out[isM] <- maleAge[isM]
  out[isF] <- femaleAge[isF]
  out
}

utils::globalVariables("speciesGestation")
