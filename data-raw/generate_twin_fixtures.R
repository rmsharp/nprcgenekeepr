## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Generate the issue #137 Slice 1 twin/zygosity fixture pair:
#'   inst/extdata/examples/obfuscated_rhesus_mhc_ped_twins.csv
#'   inst/extdata/examples/obfuscated_rhesus_mhc_twin_relations.csv
#'
#' A sibling pair, mirroring the #133/#136 _affected.csv/_name.csv precedent
#' (docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md sec 4
#' Slice 1). Unlike those two, twin/zygosity data lives in a *separate*
#' sidecar table (D1) rather than a new column on the pedigree itself, so
#' obfuscated_rhesus_mhc_ped_twins.csv is a verbatim sibling copy of
#' inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv (same 375
#' individuals, unchanged columns) -- its only purpose is to give the twin-
#' relations sidecar a naturally-paired base-pedigree fixture to sit
#' alongside, matching the established naming convention. A new sibling
#' file, not an in-place edit to the base fixture, for the same reason as
#' the #133/#136 precedent: the base obfuscated_rhesus_mhc_ped.csv is read
#' by ~20 existing tests, several of which pin its exact row/column counts.
#'
#' RED-phase unit tests use small inline data.frame() literals instead (see
#' test_checkTwinRelations.R / test_obfuscateTwinRelations.R) -- this
#' fixture pair's only role is realistic-scale live rendering, once Slice 2
#' exists (Phase 3E).
#'
#' Twin-pair selection: DETERMINISTIC, not a seeded random sample. Sec 2.7
#' of the design doc confirmed the base pedigree has no birth-date-
#' coincident twin structure, but it does contain real, already-existing
#' full-sibling pairs (individuals sharing both sire and dam) -- this
#' script enumerates them programmatically and selects specific, verified
#' real pairs rather than fabricating individuals or birth dates. No
#' random sampling is involved, so no set.seed() call is needed for
#' reproducibility; re-running this script against an unchanged base
#' pedigree always selects the identical pairs.
#'
#' Selected pairs (design doc sec 4 Slice 1 requires >= 1 each of MZ/DZ/UZ,
#' plus sec 6 Dragon 3 coverage -- a twin who is ALSO a multi-mate parent
#' elsewhere in the pedigree, to exercise D7's real-nodes-only connector
#' targeting once Slice 2 renders it):
#'   MZ: E06FRB / HV7LZ3 -- verified full siblings (sire H16EC4, dam
#'       BT0V1U), both sex "F" (kinship2's MZ sex-match rule). HV7LZ3 is
#'       independently a dam with 3 distinct mates elsewhere in the
#'       pedigree -- Dragon 3's exact scenario, confirmed by direct
#'       inspection, not fabricated.
#'   DZ: 8GSXTQ / P844CW -- verified full siblings (sire 7U5NJD, dam
#'       6WG3MZ), sexes "M"/"F" (DZ has no sex-match precondition).
#'   UZ: BRI2MW / 677E7M -- two founders (no sire/dam recorded for
#'       either), demonstrating UZ's confirmed lack of any shared-parent
#'       precondition (design doc sec 2.1).
#'
#' The resulting twinRelations table is validated against
#' checkTwinRelations() before being written, so the fixture is guaranteed
#' to load cleanly and pass validation (design doc sec 4 Slice 1 DONE
#' criteria).
#'
#' Run from the package root (after devtools::load_all() or an installed
#' build, since it calls checkTwinRelations()):
#'   Rscript data-raw/generate_twin_fixtures.R

pkgload::load_all(".", quiet = TRUE)

basePed <- read.csv(
  file.path("inst", "extdata", "examples", "obfuscated_rhesus_mhc_ped.csv"),
  stringsAsFactors = FALSE
)

write.csv(
  basePed,
  file.path("inst", "extdata", "examples",
            "obfuscated_rhesus_mhc_ped_twins.csv"),
  row.names = FALSE, na = "NA"
)

twinRelations <- data.frame(
  id1 = c("E06FRB", "8GSXTQ", "BRI2MW"),
  id2 = c("HV7LZ3", "P844CW", "677E7M"),
  code = c("MZ twin", "DZ twin", "UZ twin"),
  stringsAsFactors = FALSE
)

## Fail loudly at generation time if the fixture is ever inconsistent with
## checkTwinRelations()'s own rules -- the fixture must always be valid.
twinRelations <- checkTwinRelations(basePed, twinRelations)

write.csv(
  twinRelations,
  file.path("inst", "extdata", "examples",
            "obfuscated_rhesus_mhc_twin_relations.csv"),
  row.names = FALSE, na = "NA"
)
