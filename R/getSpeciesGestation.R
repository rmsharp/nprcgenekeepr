#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr

#' Look up the maximum gestation period (days) for one or more species
#'
#' Maps each supplied species name to a conservative upper bound on the number
#' of days from conception to birth, using the \code{\link{speciesGestation}}
#' lookup table (or a supplied \code{gestationTable}). Matching is case- and
#' whitespace-insensitive. Any species that is missing, \code{NA}, an empty
#' string, or not present in the table falls back to \code{default} (210 days,
#' the conservative rhesus bound). Used by \code{\link{getPotentialParents}} to
#' key its gestation window on the first-class \code{species} pedigree column
#' (issue #46 item 2).
#'
#' @param species character vector of species names (may contain \code{NA}).
#' @param gestationTable optional data.frame with a character column
#' \code{species} and an integer column \code{gestation} to use instead of the
#' bundled \code{\link{speciesGestation}} table. Defaults to \code{NULL}, which
#' uses the bundled table.
#' @param default integer fallback returned for species that are missing,
#' \code{NA}, empty, or not found in the table. Defaults to \code{210L}.
#' @return an integer vector of gestation-period day bounds, the same length and
#' order as \code{species}.
#' @examples
#' getSpeciesGestation("RHESUS")
#' getSpeciesGestation(c("RHESUS", "UNICORN", NA))
#' @export
getSpeciesGestation <- function(species, gestationTable = NULL,
                                default = 210L) {
  if (is.null(gestationTable)) {
    gestationTable <- speciesGestation
  }
  default <- as.integer(default)
  if (length(species) == 0L) {
    return(integer(0L))
  }
  key <- toupper(trimws(as.character(species)))
  tableKey <- toupper(trimws(as.character(gestationTable$species)))
  out <- as.integer(gestationTable$gestation)[match(key, tableKey)]
  out[is.na(out)] <- default
  out
}

utils::globalVariables("speciesGestation")
