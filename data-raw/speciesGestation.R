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
#' Rhesus gestation is 210 days (the historical conservative upper bound;
#' typical rhesus gestation is about 165 days, see Vinson & Raboin 2015). The
#' breeding-age columns are numeric (years) so fractional minima such as 2.5 are
#' exact; rhesus minimum breeding ages are male = 4, female = 2.5. The table is
#' populated for the common colony NHP species (issue #73); gestation values are
#' conservative upper bounds. Any species not listed falls back to 210 days in
#' getSpeciesGestation() and to 2 years in getSpeciesMinBreedingAge(). Making
#' the values user-configurable is the remaining part of issue #73. Add or
#' adjust rows here and re-run to update. Idempotent.
#'
#' Run from the package root:
#'   Rscript data-raw/speciesGestation.R
speciesGestation <- data.frame(
  species = c(
    "RHESUS", "CYNOMOLGUS", "JAPANESE MACAQUE", "PIG-TAILED MACAQUE",
    "BABOON", "VERVET", "AFRICAN GREEN MONKEY", "SQUIRREL MONKEY",
    "COMMON MARMOSET", "COTTON-TOP TAMARIN", "OWL MONKEY", "CAPUCHIN",
    "CHIMPANZEE", "BONOBO"
  ),
  gestation = c(
    210L, 170L, 180L, 175L, 187L, 170L, 170L, 170L, 145L, 185L, 140L, 160L,
    240L, 240L
  ),
  minMaleBreedingAge = c(
    4.0, 4.0, 5.0, 4.0, 6.0, 4.0, 4.0, 3.5, 1.0, 1.5, 2.0, 6.0, 12.0, 12.0
  ),
  minFemaleBreedingAge = c(
    2.5, 2.5, 4.0, 3.0, 4.0, 3.0, 3.0, 2.5, 1.0, 1.5, 2.0, 4.0, 8.0, 8.0
  ),
  stringsAsFactors = FALSE
)
save(speciesGestation,
  file = file.path("data", "speciesGestation.RData"),
  compress = "xz"
)
