## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Test-harness support for Track C of the kinship2 structural/topological
## comparison (docs/planning/pedigree-diagram-kinship2-structural-comparison-
## plan.md sections 3.4/4.3). These 2 functions have a GENUINE kinship2
## dependency (toKinship2Pedigree() calls kinship2::pedigree() directly) and
## so, per the plan's D-5, must never live in R/ package code. They live
## here rather than at the plan's literal "data-raw/kinship2FidelityValidation.R"
## suggestion because that script has hard top-level requireNamespace()
## stop()s for chromote/htmlwidgets that would break sourcing it from a test
## -- matching the project's own established data-raw/fgSEValidation.R +
## tests/testthat/helper-fgSEValidation.R split instead: harness functions
## live in a testthat helper (auto-loaded for the suite, real per-function
## test coverage); data-raw/kinship2FidelityValidation.R can source this
## file directly when Track D needs these functions for the vignette's own
## regeneration.
##
## Auto-loaded under test_dir()/test_local()/devtools::test() but NOT under
## test_file() -- source on demand (matches helper-fgSEValidation.R's own
## established pattern, test_fgSEValidation.R:26-28).
##
## Calls into R/ are explicitly `nprcgenekeepr:::`-prefixed throughout this
## file -- unlike test_comparePedigreeStructure.R's own bare-name calls to
## .extractKinship2Structure()/.extractNprcStructure() (that file IS their
## paired test file), this helper is an external caller, matching that same
## test file's own explicit-prefix treatment of makePedigreeMatingLayout()
## (defined in a different R/ file it doesn't own either).

## Auto-detects and swaps a reversed sire/dam row (plan D-5) before building
## a kinship2::pedigree() object. kinship2 enforces dadid=male/momid=female;
## nprcgenekeepr's own sire/dam columns carry no such constraint (a mating
## pair is symmetric in nprcgenekeepr -- e.g. the existing Track C fixture's
## own C2 row lists sire="Y" even though Y's sex is female, since
## nprcgenekeepr's mating-unit detection is symmetric in the pair). A row is
## "reversed" only when the sire column's own individual is female AND the
## dam column's own individual is male -- any other sex mismatch (e.g. both
## parents male) is a genuine data error, left for kinship2::pedigree()'s
## own validation to catch and report, never silently "fixed" here.
##
## @param ped a data.frame with id/sire/dam/sex columns (nprcgenekeepr's own
##   pedigree shape).
## @return a kinship2::pedigree() object.
toKinship2Pedigree <- function(ped) {
  if (!requireNamespace("kinship2", quietly = TRUE)) {
    stop("kinship2 must be installed locally to call toKinship2Pedigree() ",
      "(not a package dependency): install.packages(\"kinship2\")")
  }
  sire <- ped$sire
  dam <- ped$dam
  sexById <- stats::setNames(ped$sex, ped$id)
  sireSex <- unname(sexById[sire])
  damSex <- unname(sexById[dam])
  reversed <- !is.na(sire) & !is.na(dam) &
    !is.na(sireSex) & !is.na(damSex) &
    sireSex == "F" & damSex == "M"
  if (any(reversed)) {
    tmp <- sire[reversed]
    sire[reversed] <- dam[reversed]
    dam[reversed] <- tmp
  }
  kinship2::pedigree(id = ped$id, dadid = sire, momid = dam, sex = ped$sex)
}

## Orchestrates the full cross-package comparison (plan section 3.4): builds
## both sides' structural extraction from the SAME nprcgenekeepr-format
## pedigree data.frame and diffs them via .comparePedigreeStructures()
## (Track C's own R/ deliverable, plan section 3.3).
##
## @param ped a data.frame with id/sire/dam/sex/gen columns.
## @return .comparePedigreeStructures()'s own return value.
compareAgainstKinship2 <- function(ped) {
  pedK2 <- toKinship2Pedigree(ped)
  kinship2Struct <- nprcgenekeepr:::.extractKinship2Structure(pedK2)
  nprcLayout <- nprcgenekeepr:::makePedigreeMatingLayout(ped,
    edgeStyle = "direct")
  nprcStruct <- nprcgenekeepr:::.extractNprcStructure(nprcLayout)
  nprcgenekeepr:::.comparePedigreeStructures(kinship2Struct, nprcStruct)
}
