## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Validate a colony snapshot-history table
#'
#' Checks the structure and domain of a longitudinal colony snapshot history
#' (issue #167): one row per recorded snapshot, in the 27-column version-1
#' schema. It mirrors \code{\link{checkKinshipOverrides}}: it \code{stop()}s
#' with a specific message on structural or domain errors and returns the
#' coerced history when the input is acceptable.
#'
#' The schema has three groups of nine columns:
#' \describe{
#' \item{Provenance / comparability}{\code{schemaVersion}, \code{snapshotDate},
#' \code{packageVersion}, \code{membershipRule}, \code{guIter},
#' \code{guThresh}, \code{nAnimals}, \code{nMales}, \code{nFemales}. These let
#' successive snapshots be compared like with like: snapshots generated under
#' different membership rules, \code{guIter} settings, or package versions are
#' comparable only with care, and trend displays flag such mixed-provenance
#' series rather than hiding them.}
#' \item{Colony scalars}{\code{fe}, \code{fg}, \code{fgSE}, \code{neGD},
#' \code{neSexRatio}, \code{neVariance}, \code{nMaleFounders},
#' \code{nFemaleFounders}, \code{nFounders} — verbatim from
#' \code{\link{reportGV}}.}
#' \item{Colony aggregates}{\code{meanIndivMeanKin}, \code{medianIndivMeanKin},
#' \code{skewnessIndivMeanKin}, \code{kurtosisIndivMeanKin}, \code{meanGu},
#' \code{medianGu}, \code{meanGuSE}, \code{skewnessGu}, \code{kurtosisGu} —
#' the Summary Statistics definitions applied to the per-animal
#' \code{indivMeanKin} and \code{gu} report columns.}
#' }
#'
#' Violations rejected: missing columns, non-numeric metric or count fields,
#' an unrecognized \code{schemaVersion}, a duplicated
#' (\code{snapshotDate}, \code{membershipRule}) pair, and malformed (non
#' ISO-8601) dates. The \code{membershipRule} field is an open string — no
#' enumeration is enforced, so new rule names are additive. Extra columns are
#' ignored, matching the sibling validators.
#'
#' @param history data.frame holding the snapshot history, typically from
#' \code{\link{readSnapshotHistory}}; one row per snapshot.
#' @return The validated history with \code{snapshotDate} coerced to
#' \code{Date}, \code{packageVersion} and \code{membershipRule} coerced to
#' character, and \code{schemaVersion} and the count columns coerced to
#' integer.
#' @export
#' @examples
#' history <- readSnapshotHistory(system.file("extdata", "examples",
#'   "example_snapshot_history.csv",
#'   package = "nprcgenekeepr"
#' ))
#' history <- checkSnapshotHistory(history)
checkSnapshotHistory <- function(history) {
  required <- c(
    "schemaVersion", "snapshotDate", "packageVersion", "membershipRule",
    "guIter", "guThresh", "nAnimals", "nMales", "nFemales",
    "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
    "nMaleFounders", "nFemaleFounders", "nFounders",
    "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
    "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
    "skewnessGu", "kurtosisGu"
  )
  missingCols <- setdiff(required, names(history))
  if (length(missingCols) > 0L) {
    stop("Snapshot history must have columns ", toString(required),
      "; missing: ", toString(missingCols), ".")
  }
  history$packageVersion <- as.character(history$packageVersion)
  history$membershipRule <- as.character(history$membershipRule)

  dates <- as.Date(as.character(history$snapshotDate), format = "%Y-%m-%d")
  if (anyNA(dates)) {
    malformed <- as.character(history$snapshotDate)[is.na(dates)]
    stop("Snapshot history 'snapshotDate' values must be ISO-8601 ",
      "(YYYY-MM-DD) dates; malformed: ", toString(malformed), ".")
  }
  history$snapshotDate <- dates

  numericCols <- setdiff(
    required,
    c("snapshotDate", "packageVersion", "membershipRule")
  )
  for (numericCol in numericCols) {
    if (!is.numeric(history[[numericCol]])) {
      stop("Snapshot history '", numericCol, "' column must be numeric.")
    }
  }
  countCols <- c(
    "schemaVersion", "guIter", "guThresh", "nAnimals", "nMales",
    "nFemales", "nMaleFounders", "nFemaleFounders", "nFounders"
  )
  for (countCol in countCols) {
    history[[countCol]] <- as.integer(history[[countCol]])
  }

  knownVersions <- 1L
  unknownVersions <- setdiff(unique(history$schemaVersion), knownVersions)
  if (length(unknownVersions) > 0L) {
    stop("Snapshot history 'schemaVersion' value(s) not recognized by this ",
      "version of nprcgenekeepr: ", toString(unknownVersions),
      "; known: ", toString(knownVersions), ".")
  }

  ## a (snapshotDate, membershipRule) pair identifies a snapshot uniquely
  key <- paste(as.character(history$snapshotDate), history$membershipRule,
    sep = "\r")
  if (anyDuplicated(key) > 0L) {
    dup <- unique(key[duplicated(key)])
    stop("Snapshot history contains duplicated (snapshotDate, ",
      "membershipRule) pair(s): ",
      toString(gsub("\r", " ", dup, fixed = TRUE)), ".")
  }
  history
}
