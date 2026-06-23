#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Build script for the `speciesGestation` data object: the per-species
#' reproductive-parameter lookup. It serves two consumers:
#'   - gestation (issue #46 item 2): the maximum-gestation window consumed by
#'     getPotentialParents() via getSpeciesGestation(); and
#'   - minMaleBreedingAge / minFemaleBreedingAge (issue #9 Slice 2): the minimum
#'     breeding ages (years) consumed by the GVA unknown-parent mean-kinship
#'     correction via getSpeciesMinBreedingAge().
#' Seeded with rhesus = 210-day gestation (the conservative upper bound used
#' historically; typical rhesus gestation is about 165 days, see Vinson &
#' Raboin 2015) and rhesus minimum breeding ages male = 4, female = 3. Any
#' species not listed falls back to 210 days in getSpeciesGestation() and to 2
#' years in getSpeciesMinBreedingAge(), so this single row reproduces the
#' historical behavior while providing the extensible home for additional
#' species. Generalizing this table to all common colony NHP species and making
#' the values user-configurable is tracked as issue #73. Add rows here and
#' re-run to extend. Idempotent.
#'
#' Run from the package root:
#'   Rscript data-raw/speciesGestation.R
speciesGestation <- data.frame(
  species = "RHESUS",
  gestation = 210L,
  minMaleBreedingAge = 4L,
  minFemaleBreedingAge = 3L,
  stringsAsFactors = FALSE
)
save(speciesGestation,
  file = file.path("data", "speciesGestation.RData"),
  compress = "xz"
)
