## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Column names of the snapshot-history table
#'
#' Single source of truth for the 27 columns of a colony snapshot-history
#' table (schema version 1), in schema order, and for the three that hold text.
#' Internal helper constants -- \code{\link{checkSnapshotHistory}} requires the
#' columns and checks that the other 24 are numeric, and
#' \code{\link{readSnapshotHistory}} converts those 24 when it reads an Excel
#' file, so the two cannot disagree about which columns are numbers.
#' @noRd
snapshotSchemaColumns <- c(
  # Provenance and comparability columns.
  "schemaVersion", "snapshotDate", "packageVersion", "membershipRule",
  "guIter", "guThresh", "nAnimals", "nMales", "nFemales",
  # Colony scalars, verbatim from reportGV().
  "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
  "nMaleFounders", "nFemaleFounders", "nFounders",
  # Colony aggregates of per-animal metrics.
  "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
  "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
  "skewnessGu", "kurtosisGu"
)

## The three columns that hold text; the other 24 hold numbers.
snapshotSchemaTextColumns <- c(
  "snapshotDate", "packageVersion", "membershipRule"
)

snapshotSchemaNumericColumns <- setdiff(
  snapshotSchemaColumns, snapshotSchemaTextColumns
)
