## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check parent ages against a minimum age
#'
#' Ensure parents are sufficiently older than offspring
#'
#' @param sb A dataframe containing a table of pedigree and demographic
#' information.
#' @param minSireAge numeric minimum age in years for a male to have sired an
#' offspring. \code{NULL} (default) looks up the floor for each sire's species
#' via \code{\link{getSpeciesMinBreedingAge}} (falling back to 2 years when the
#' species is missing or unknown); a supplied value overrides that floor for
#' all sires. The check is not performed for animals with missing birth dates.
#' @param minDamAge numeric minimum age in years for a female to have borne an
#' offspring. \code{NULL} (default) looks up the floor for each dam's species
#' via \code{\link{getSpeciesMinBreedingAge}} (falling back to 2 years when the
#' species is missing or unknown); a supplied value overrides that floor for
#' all dams.
#' @param minParentAge `r lifecycle::badge("deprecated")` Deprecated scalar
#' minimum parent age. Supplying it sets both \code{minSireAge} and
#' \code{minDamAge}; use those sex-specific parameters instead.
#' @param reportErrors logical value if TRUE will scan the entire file and
#' make a list of all errors found. The errors will be returned in a
#' list of list where each sublist is a type of error found.
#' @return A dataframe containing rows for each animal where one or more
#' parent was less than \code{minParentAge}. It contains all of the columns
#' in the original \code{sb} dataframe with the following added columns:
#' \enumerate{
#' \item \code{sireBirth} -- sire's birth date
#' \item \code{sireAge} -- age of sire in years on the date indicated by
#'  \code{birth}.
#' \item \code{damBirth} -- dam's birth date
#' \item \code{damAge} -- age of dam in years on the date indicated by
#'  \code{birth}.
#' }
#'
#' @importFrom anytime anytime
#' @importFrom lubridate dyears
#' @export
#' @importFrom lifecycle deprecated is_present deprecate_warn
#' @examples
#' library(nprcgenekeepr)
#' qcPed <- nprcgenekeepr::qcPed
#' checkParentAge(qcPed, minSireAge = 2L, minDamAge = 2L)
#' checkParentAge(qcPed, minSireAge = 3L, minDamAge = 3L)
#' checkParentAge(qcPed, minSireAge = 5L, minDamAge = 5L)
#' checkParentAge(qcPed, minSireAge = 6L, minDamAge = 6L)
#' head(checkParentAge(qcPed, minSireAge = 10L, minDamAge = 10L))
checkParentAge <- function(sb,
                           minSireAge = NULL,
                           minDamAge = NULL,
                           minParentAge = lifecycle::deprecated(),
                           reportErrors = FALSE) {
  if (lifecycle::is_present(minParentAge)) {
    lifecycle::deprecate_warn(
      when = "2.0.0",
      what = "checkParentAge(minParentAge)",
      details = "Use minSireAge and minDamAge instead."
    )
    if (is.null(minParentAge)) {
      ## Legacy: minParentAge = NULL disabled the age check entirely.
      minSireAge <- -Inf
      minDamAge <- -Inf
    } else {
      if (is.null(minSireAge)) minSireAge <- minParentAge
      if (is.null(minDamAge)) minDamAge <- minParentAge
    }
  }
  ## Map each id to its species so the floor can key on the PARENT's species
  ## (the merges below reorder rows). Absent species column -> fallback floor.
  if ("species" %in% names(sb)) {
    speciesById <- as.character(sb$species)
    names(speciesById) <- as.character(sb$id)
  } else {
    speciesById <- character(0L)
  }
  if (nrow(sb) == 0L ||
    !all(c("id", "sire", "dam") %in% names(sb))) {
    if (reportErrors) {
      return(NULL)
    } else {
      return(sb)
    }
  }
  if (!any(inherits(sb$birth, c("Date", "POSIXct", "character")))) {
    if (reportErrors) {
      ## Bad birth date column precludes checking parent age
      return(NULL)
    } else {
      stop("Birth column must be of class 'Date', 'POSIXct', or 'character'")
    }
  } else if (inherits(sb$birth, "character")) {
    sb$birth <- suppressWarnings(anytime(sb$birth))
  } else {
    sb$birth <- suppressWarnings(as.Date(sb$birth))
  }

  sireBirth <- data.frame(
    id = sb$id[sb$id %in% sb$sire & !is.na(sb$birth)],
    sireBirth = sb$birth[sb$id %in% sb$sire & !is.na(sb$birth)],
    stringsAsFactors = FALSE
  )
  damBirth <- data.frame(
    id = sb$id[sb$id %in% sb$dam & !is.na(sb$birth)],
    damBirth = sb$birth[sb$id %in% sb$dam & !is.na(sb$birth)],
    stringsAsFactors = FALSE
  )
  sb <- merge(sb,
    sireBirth,
    by.x = "sire",
    by.y = "id",
    all = TRUE
  )
  sb <- merge(sb,
    damBirth,
    by.x = "dam",
    by.y = "id",
    all = TRUE
  )
  sb$sireAge <- NA
  sb$sireAge[!is.na(sb$sireBirth)] <-
    (sb$birth[!is.na(sb$sireBirth)] -
      sb$sireBirth[!is.na(sb$sireBirth)]) / dyears(1L)
  sb$damAge <- NA
  sb$damAge[!is.na(sb$damBirth)] <-
    (sb$birth[!is.na(sb$damBirth)] -
      sb$damBirth[!is.na(sb$damBirth)]) / dyears(1L)
  sb <- sb[!is.na(sb$birth), ]
  ## Per-parent floors key on the parent's own species and sex (sires are
  ## male, dams female). Absent species -> resolveBreedingAge fallback (2).
  if (length(speciesById) > 0L) {
    sireSpecies <- unname(speciesById[as.character(sb$sire)])
    damSpecies <- unname(speciesById[as.character(sb$dam)])
  } else {
    sireSpecies <- rep(NA_character_, nrow(sb))
    damSpecies <- rep(NA_character_, nrow(sb))
  }
  sireFloor <- resolveBreedingAge(sireSpecies, "M",
    minSireAge = minSireAge, minDamAge = minDamAge
  )
  damFloor <- resolveBreedingAge(damSpecies, "F",
    minSireAge = minSireAge, minDamAge = minDamAge
  )
  sb <- sb[(sb$sireAge < sireFloor & !is.na(sb$sireBirth)) |
    (sb$damAge < damFloor & !is.na(sb$damBirth)), ]
  sb$exit <- as.character(sb$exit)
  sb$sireAge <- round(sb$sireAge, 2L)
  sb$damAge <- round(sb$damAge, 2L)
  sb
}
