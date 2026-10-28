## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the harem group-formation tests (test_haremPartialSeeds.R,
## test_haremSexRatioStop.R): one small made-up pedigree, its kinship matrix and
## the check that two lists of groups hold the same animals.
##
## Six unrelated adult males M1-M5 and MR, eight unrelated adult females F1-F8,
## and FR, a young female whose sire is MR (kinship 0.25, at the Max kinship
## the tests use), so a seeded FR keeps MR out of the pool.

## The 15 animals, run through qcStudbook().
haremFixturePedigree <- function() {
  ids <- c("M1", "M2", "M3", "M4", "M5", "MR", paste0("F", 1:8), "FR")
  raw <- data.frame(
    id = ids,
    sire = c(rep(NA, 14), "MR"),
    dam = c(rep(NA, 14), "F8"),
    sex = c(rep("M", 6), rep("F", 9)),
    birth = c(rep("2005-01-01", 14), "2010-01-01"),
    stringsAsFactors = FALSE
  )
  suppressWarnings(qcStudbook(raw, reportChanges = FALSE, reportErrors = FALSE))
}

## The dense kinship matrix of a pedigree with a `gen` column (such as the
## output of haremFixturePedigree()).
pedigreeKinship <- function(ped) {
  kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
}

## TRUE when `found` and `expected` are lists of the same length whose members
## hold the same animals, group by group.
sameGroups <- function(found, expected) {
  length(found) == length(expected) &&
    all(mapply(
      function(f, e) setequal(f, e) && length(f) == length(e),
      found, expected
    ))
}
