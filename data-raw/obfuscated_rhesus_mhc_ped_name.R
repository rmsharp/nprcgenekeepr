## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Generate the issue #136 Slice 1 sibling fixture:
#' inst/extdata/examples/obfuscated_rhesus_mhc_ped_name.csv
#'
#' A new sibling of inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv
#' (design doc D9, docs/planning/issue136-name-labels-pedigree-diagram-
#' plan.md) -- reuses the same 375 individuals' id/sire/dam/sex/gen/birth/
#' exit/age columns verbatim (no re-obfuscation pass needed), and adds one
#' fabricated `name` column so a future Slice 2's on-canvas name labels have
#' a realistic-scale fixture to render against for live/e2e verification
#' (Phase 3E). Slice 1 itself has no rendering to verify -- this fixture is
#' pre-staged now, matching the #133/S486 `..._affected.csv` precedent,
#' where the sibling fixture was also created a slice ahead of the
#' rendering work that consumes it. RED-phase unit tests use small inline
#' data.frame() literals instead (see test_name_first_class.R /
#' test_obfuscatePed.R) -- this fixture's only role is realistic-scale live
#' rendering, once Slice 2 exists.
#'
#' DISCLOSURE: every name below is entirely synthetic -- drawn from a fixed
#' pool of generic animal nicknames, not from any real colony's records,
#' matching this project's existing synthetic-data disclosure convention
#' (vignettes/a2interactive.Rmd footnote 4, "This pedigree is entirely
#' synthetic -- constructed for this tutorial, not drawn from any real
#' colony's records").
#'
#' Composition (design doc D9's three required cases):
#'   - ~70% of individuals get a name drawn from the synthetic pool
#'     (the "names exist at some centers" case).
#'   - ~15% of individuals get an empty name ("") and ~15% get no name
#'     at all (NA) -- the "inconsistent, per-animal" case (D4's mandatory
#'     id fallback exists precisely because of this).
#'   - Exactly one individual (the first row) is deliberately given a very
#'     long name, to stress-test the geometry mitigation (D10, sec 2.3)
#'     once Slice 2 renders it -- this project's own measurement found
#'     zero horizontal headroom beyond today's uniform 6-character ids.
#'
#' A new sibling file, not an in-place edit to the base fixture (D9, same
#' rationale as the #133 precedent): the base obfuscated_rhesus_mhc_ped.csv
#' is read by ~20 existing test files, several of which pin its exact
#' column/row counts -- adding a column in-place risks silently perturbing
#' tests unrelated to this feature.
#' Idempotent up to the fixed seed: re-running reproduces the identical
#' `name` values every time.
#'
#' Run from the package root:
#'   Rscript data-raw/obfuscated_rhesus_mhc_ped_name.R

set.seed(136L) ## issue #136 -- reproducible fabricated name column

basePed <- read.csv(
  file.path("inst", "extdata", "examples", "obfuscated_rhesus_mhc_ped.csv"),
  stringsAsFactors = FALSE
)

namePool <- c(
  "Apollo", "Bandit", "Clover", "Comet", "Dusty", "Ember", "Freckles",
  "Ginger", "Hazel", "Juniper", "Kepler", "Luna", "Maple", "Marbles",
  "Nutmeg", "Onyx", "Pepper", "Quill", "Ranger", "Sage", "Willow", "Ziggy"
)

n <- nrow(basePed)
name <- sample(namePool, size = n, replace = TRUE)

## Inconsistent recording (D4): ~15% empty string, ~15% NA.
inconsistent <- sample(
  c("empty", "na", "keep"),
  size = n,
  replace = TRUE,
  prob = c(0.15, 0.15, 0.70)
)
name[inconsistent == "empty"] <- ""
name[inconsistent == "na"] <- NA_character_

## Deliberately long name (D10 geometry stress case, sec 2.3): the real
## fixture's ids are exactly 6 characters with ~zero horizontal headroom
## between adjacent label-bearing nodes; this name is intentionally far
## longer than any truncation budget a future Slice 2 would choose.
name[1L] <- "Grand-Champion-Xerxes-Constantinopolous-The-Magnificent-III"

namePed <- cbind(basePed, name = name)

write.csv(
  namePed,
  file.path("inst", "extdata", "examples",
            "obfuscated_rhesus_mhc_ped_name.csv"),
  row.names = FALSE, na = "NA"
)
