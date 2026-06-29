## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Re-export of the bundled `rhesusGenotypes` data object (Session 124, owner
#' pick A7: correct the degraded column types).
#'
#' `rhesusGenotypes` is a 31-animal, two-haplotype-per-animal MHC genotype table
#' with NO reproducible generator: it was hand-saved (commit 31c4679d,
#' 2020-02-02) alongside its sibling `rhesusPedigree`, with which it shares all
#' 31 obfuscated ids. The obfuscation that produced those ids is
#' non-deterministic and was never scripted or seeded, so re-deriving the object
#' would change the ids and desync it from `rhesusPedigree`. This script
#' therefore COERCES the existing object's column types to character WITHOUT
#' altering any values, then re-saves it in place. Re-running it on an
#' already-corrected object is a no-op (idempotent).
#'
#' A value-identical export ships at
#' inst/extdata/obfuscated_rhesus_mhc_breeder_genotypes.csv and serves as an
#' independent cross-check that the coercion preserves all values.
#'
#' Run from the package root:
#'   Rscript data-raw/rhesusGenotypes.R

## Load the current shipped object, preserving its obfuscated values.
load(file.path("data", "rhesusGenotypes.RData"))

## id / first_name / second_name: factor -> character (a stringsAsFactors-era
## artifact; as.character() preserves the exact string values). The allele
## name columns (first_name, second_name) must be character so that
## addGenotype()'s name-keyed dictionary lookup encodes each allele
## consistently across both columns (a factor is silently indexed by its
## integer codes, yielding an inconsistent encoding).
rhesusGenotypes$id <- as.character(rhesusGenotypes$id)
rhesusGenotypes$first_name <- as.character(rhesusGenotypes$first_name)
rhesusGenotypes$second_name <- as.character(rhesusGenotypes$second_name)

save(rhesusGenotypes, file = file.path("data", "rhesusGenotypes.RData"),
     compress = "xz")
