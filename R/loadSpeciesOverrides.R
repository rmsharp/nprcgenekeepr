## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Load user-configurable species reproductive-parameter overrides
#'
#' Reads the optional species-override settings from the user's site
#' configuration file (\code{~/.nprcgenekeepr_config}, or
#' \code{~/_nprcgenekeepr_config} on Windows) and assembles the override tables
#' and fallbacks consumed by the Genetic Value Analysis. The
#' configuration may carry up to three optional keys, each looked up softly (the
#' \code{getConfigApiKey} pattern -- absent keys are not an error and never
#' touch the fixed-schema \code{\link{getSiteInfo}} parser):
#' \itemize{
#'   \item \code{speciesOverridesPath} -- path to a CSV with the four
#'     \code{\link{speciesGestation}} columns (\code{species},
#'     \code{gestation}, \code{minMaleBreedingAge}, \code{minFemaleBreedingAge};
#'     header required, matched by name). A colony lists only the rows
#'     (species) it wants to change; the CSV is \strong{merged onto} the bundled
#'     table, so every unlisted species keeps its bundled value (not replaced).
#'   \item \code{minBreedingAgeDefault} -- numeric fallback (years) for a
#'     species absent from the table (bundled built-in 2.0).
#'   \item \code{gestationDefault} -- integer fallback (days) for a species
#'     absent from the table (bundled built-in 210).
#' }
#'
#' Like \code{\link{loadSiteConfig}}, this never crashes the application on
#' boot: a missing configuration file, a missing override key, or a
#' missing/malformed CSV all fall back to the bundled values (a warning is
#' raised for an unreadable CSV).
#'
#' @return A named list with elements \code{breedingTable},
#' \code{gestationTable} (each the merged \code{\link{speciesGestation}}-shaped
#' data.frame, or \code{NULL} when no CSV is configured),
#' \code{breedingAgeDefault} (numeric or \code{NULL}), and
#' \code{gestationDefault} (integer or \code{NULL}). A \code{NULL} element means
#' "use the bundled value / built-in default".
#'
#' @seealso \code{\link{loadSiteConfig}},
#'  \code{\link{getSpeciesMinBreedingAge}},
#'  \code{\link{getSpeciesGestation}}, \code{\link{reportGV}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ## Reads optional species overrides from the user's site config
#' ## file; with no config file every element is NULL, meaning "use
#' ## the bundled speciesGestation values / built-in defaults".
#' overrides <- loadSpeciesOverrides()
#' str(overrides)
loadSpeciesOverrides <- function() {
  empty <- list(
    breedingTable = NULL, gestationTable = NULL,
    breedingAgeDefault = NULL, gestationDefault = NULL
  )
  configFile <- getConfigFileName(Sys.info())[["configFile"]]
  if (is.null(configFile) || !file.exists(configFile)) {
    return(empty)
  }

  out <- empty
  ageTok <- getOptionalConfigToken(configFile, "minBreedingAgeDefault")
  if (nzchar(ageTok)) {
    out$breedingAgeDefault <- as.numeric(ageTok)
  }
  gestTok <- getOptionalConfigToken(configFile, "gestationDefault")
  if (nzchar(gestTok)) {
    out$gestationDefault <- as.integer(gestTok)
  }

  path <- getSpeciesOverridesPath(configFile)
  if (!nzchar(path)) {
    return(out)
  }

  merged <- tryCatch(
    readAndMergeSpeciesOverrides(path),
    error = function(e) {
      warning(sprintf(
        paste0("Species overrides file '%s' could not be loaded (%s); ",
               "using bundled values."),
        path, conditionMessage(e)
      ), call. = FALSE)
      NULL
    }
  )
  if (is.null(merged)) {
    return(out)
  }
  out$breedingTable <- merged
  out$gestationTable <- merged
  out
}

#' Read and validate the species-override CSV, then merge onto the bundled table
#'
#' @param path path to the override CSV.
#' @return the bundled \code{\link{speciesGestation}} data.frame with the user's
#' rows merged in. Stops on a missing file or a missing required column.
#' @noRd
readAndMergeSpeciesOverrides <- function(path) {
  if (!file.exists(path)) {
    stop(sprintf("file does not exist: %s", path))
  }
  userTbl <- utils::read.csv(path, stringsAsFactors = FALSE)
  required <- c(
    "species", "gestation", "minMaleBreedingAge", "minFemaleBreedingAge"
  )
  missingCols <- setdiff(required, names(userTbl))
  if (length(missingCols) > 0L) {
    stop(sprintf(
      "missing required column(s): %s", toString(missingCols)
    ))
  }
  userTbl <- userTbl[, required, drop = FALSE]
  userTbl$species <- as.character(userTbl$species)
  userTbl$gestation <- as.integer(userTbl$gestation)
  userTbl$minMaleBreedingAge <- as.numeric(userTbl$minMaleBreedingAge)
  userTbl$minFemaleBreedingAge <- as.numeric(userTbl$minFemaleBreedingAge)
  mergeSpeciesOverrides(userTbl)
}

#' Merge a user override table onto the bundled speciesGestation table (D4)
#'
#' User rows override matching species (case- and whitespace-insensitive on the
#' species key); species absent from the user table keep their bundled values;
#' species present only in the user table are appended. The bundled package data
#' object is never mutated.
#'
#' @param userTbl validated, type-coerced user override data.frame.
#' @return the merged data.frame (bundled columns, bundled order plus appends).
#' @noRd
mergeSpeciesOverrides <- function(userTbl) {
  merged <- speciesGestation
  cols <- c("gestation", "minMaleBreedingAge", "minFemaleBreedingAge")
  bKey <- toupper(trimws(as.character(merged$species)))
  for (j in seq_len(nrow(userTbl))) {
    uKey <- toupper(trimws(userTbl$species[j]))
    pos <- match(uKey, bKey)
    if (is.na(pos)) {
      merged <- rbind(merged, userTbl[j, names(merged), drop = FALSE])
      bKey <- c(bKey, uKey)
    } else {
      merged[pos, cols] <- userTbl[j, cols]
    }
  }
  merged
}

utils::globalVariables("speciesGestation")
