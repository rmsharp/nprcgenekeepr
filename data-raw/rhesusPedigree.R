#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Re-export of the bundled `rhesusPedigree` data object (Session 123, owner
#' pick A6: correct the degraded column types).
#'
#' `rhesusPedigree` is an obfuscated 375-animal rhesus studbook with NO
#' reproducible generator: the original object was obfuscated from
#' inst/extdata/rhesusPedigree_fromCenter.csv via obfuscatePed() and saved by
#' hand (commit 31c4679d, 2020-02-02). The obfuscation is non-deterministic and
#' was never scripted or seeded, so the exact shipped (obfuscated) id and birth
#' VALUES cannot be re-derived from the CSV. This script therefore COERCES the
#' existing object's column types to the canonical pedigree types (matching
#' `examplePedigree`) WITHOUT altering any values, then re-saves it in place.
#' Re-running it on an already-corrected object is a no-op (idempotent).
#'
#' Run from the package root:
#'   Rscript data-raw/rhesusPedigree.R

## Load the current shipped object, preserving its obfuscated id/birth values.
load("data/rhesusPedigree.RData")

## id / sire / dam: factor -> character (a stringsAsFactors-era artifact;
## as.character() preserves the exact string values, NA included).
rhesusPedigree$id <- as.character(rhesusPedigree$id)
rhesusPedigree$sire <- as.character(rhesusPedigree$sire)
rhesusPedigree$dam <- as.character(rhesusPedigree$dam)

## birth: factor of date-strings -> Date. Every non-NA level is an ISO date
## that parses cleanly, so the NA pattern is preserved exactly.
rhesusPedigree$birth <- as.Date(as.character(rhesusPedigree$birth))

## exit: all-NA logical -> all-NA Date. The source records no exit dates, but the
## column must be Date-typed to match the canonical pedigree structure and the
## Date arithmetic in getPotentialParents() (ba$exit >= birth comparisons).
rhesusPedigree$exit <- as.Date(rep(NA_character_, nrow(rhesusPedigree)))

## sex (factor F,M), gen (integer), and age (numeric) are already correct and
## are left unchanged.

save(rhesusPedigree, file = "data/rhesusPedigree.RData", compress = "xz")
