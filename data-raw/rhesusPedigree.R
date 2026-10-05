## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Re-export of the bundled `rhesusPedigree` data object (Session 123, owner
#' pick A6: correct the degraded column types).
#'
#' `rhesusPedigree` is a 375-animal rhesus studbook with NO reproducible
#' generator: no script here builds it, and data/rhesusPedigree.RData was
#' first committed in 31c4679d (2020-02-02). Any obfuscation of its id and
#' birth values (obfuscatePed() draws random date offsets) cannot be
#' reproduced, since no script or seed for it is kept in this repository.
#' Nor is inst/extdata/examples/rhesusPedigree_fromCenter.csv an independent
#' pre-obfuscation source: its 8 shared columns (id, sire, dam, sex, gen,
#' birth, exit, age) hold the object's values on all 375 rows (compared
#' 2026-10-05), and it was first committed in 868a4975 (2026-06-15), after
#' the object. This
#' script therefore COERCES the existing object's column types to the
#' canonical pedigree types (matching `examplePedigree`) WITHOUT altering any
#' values, then re-saves it in place.
#' Re-running it on an already-corrected object is a no-op (idempotent).
#'
#' Run from the package root:
#'   Rscript data-raw/rhesusPedigree.R

## Load the current shipped object, preserving its obfuscated id/birth values.
load(file.path("data", "rhesusPedigree.RData"))

## id / sire / dam: factor -> character (a stringsAsFactors-era artifact;
## as.character() preserves the exact string values, NA included).
rhesusPedigree$id <- as.character(rhesusPedigree$id)
rhesusPedigree$sire <- as.character(rhesusPedigree$sire)
rhesusPedigree$dam <- as.character(rhesusPedigree$dam)

## birth: factor of date-strings -> Date. Every non-NA level is an ISO date
## that parses cleanly, so the NA pattern is preserved exactly.
rhesusPedigree$birth <- as.Date(as.character(rhesusPedigree$birth))

## exit: all-NA logical -> all-NA Date. The source records no exit dates, but
## the column must be Date-typed to match the canonical pedigree structure and
## the Date arithmetic in getPotentialParents() (ba$exit >= birth comparisons).
rhesusPedigree$exit <- as.Date(rep(NA_character_, nrow(rhesusPedigree)))

## sex (factor F,M), gen (integer), and age (numeric) are already correct and
## are left unchanged.

save(rhesusPedigree, file = file.path("data", "rhesusPedigree.RData"),
     compress = "xz")
