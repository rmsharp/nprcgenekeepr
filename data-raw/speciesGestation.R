#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Build script for the `speciesGestation` data object (issue #46 item 2): the
#' per-species maximum-gestation lookup consumed by getPotentialParents() via
#' getSpeciesGestation(). Seeded with rhesus = 210 days -- the conservative
#' upper bound used historically (typical rhesus gestation is about 165 days;
#' see Vinson & Raboin 2015). Any species not listed falls back to 210 in
#' getSpeciesGestation(), so this single row reproduces the historical behavior
#' while providing the extensible home for additional species. Add rows here and
#' re-run to extend. Idempotent.
#'
#' Run from the package root:
#'   Rscript data-raw/speciesGestation.R
speciesGestation <- data.frame(
  species = "RHESUS",
  gestation = 210L,
  stringsAsFactors = FALSE
)
save(speciesGestation,
  file = file.path("data", "speciesGestation.RData"),
  compress = "xz"
)
