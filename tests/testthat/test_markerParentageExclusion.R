## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #130 Slice 3): markerParentageExclusion() flags a pedigree's
## recorded dam/sire as Mendelian-inconsistent with an offspring's marker
## genotype -- directly targeting the issue's named ~5% dam-misidentification
## problem. A locus is a Mendelian conflict when offspring and candidate
## parent are BOTH homozygous for a DIFFERENT allele ("opposite homozygotes",
## the same N_AAaa concept markerKinship() already counts internally) --
## the biallelic-marker "informative conflict" definition verified verbatim
## against the ICAR/ISAG cattle-SNP parentage standard at this slice's
## Pre-RED. Conflicts are counted over each offspring/parent pair's shared
## (jointly non-missing) loci only.
##
## Dragon P4 (a naive zero-tolerance rule risks false exclusion from a
## single genotyping error or mutation): this slice's Pre-RED sourced and
## adversarially cross-checked two independently-verified thresholds --
## the ICAR/ISAG SNP standard and Cifuentes et al. 2006 (>=3 inconsistencies
## for human STR panels) vs. the bison/cattle microsatellite precedent
## (Schnabel et al. 2000 / US Patent 7,083,925, >=2). The cross-check
## re-verified both PDFs/patent directly and recommended `maxExclusions = 2`
## (flag only at 3+ inconsistent loci) as the better fit for this package's
## BIALLELIC marker model (checkMarkerGenotypeFile() enforces biallelic-only
## loci), grounded in Cifuentes LO, Martinez EH, Acuna MP, Jonquera HG
## (2006). "Probability of exclusion in paternity testing: time to
## reassess." Journal of Forensic Sciences, 51(2), 349-350, and de Groot NG,
## de Vos-Rouweler AJM, Heijmans CMC, et al. (2025). "Genetic Conservation
## and Population Management of Non-Human Primates: Parentage Determination
## Using Seven Microsatellite-Based Multiplexes." Ecology and Evolution,
## 15(4), e71216 -- a real captive rhesus/cynomolgus macaque colony
## precedent tolerating up to 3 mismatches. Owner-approved via
## AskUserQuestion over the alternative maxExclusions = 2/flag-at-2+ option.
## `maxExclusions` is a tunable parameter, not a hardcoded magic number, per
## the plan's own Dragon P4 text.
##
## Expected values below were derived with a standalone, from-scratch
## reference implementation (plain base-R loop counting opposite-homozygote
## loci, independent of any planned package code) -- see this slice's
## Pre-RED scratch verification, not copied from any implementation.

genotypeMatrix <- matrix(
  c(
    "A/B", "A/B", "A/B", "A/B", "A/B", # O1: heterozygous everywhere ->
    # can never be an "opposite homozygote" of any parent genotype, so O1
    # is Mendelian-consistent with any parent by construction.
    "A/A", "A/B", "B/B", "A/B", "A/A", # D1
    "A/B", "B/B", "A/A", "A/B", "A/B", # S1
    "A/A", "A/A", "A/B", "A/B", "A/B", # O2: homozygous at L1-L2 only.
    "B/B", "B/B", "A/A", "A/A", "B/B", # D2: opposite homozygote to O2 at
    # L1 and L2 -> exactly 2 conflicts (tolerated: maxExclusions default 2).
    "A/A", "A/A", "A/A", "A/B", "A/B", # O3: homozygous at L1-L3.
    "B/B", "B/B", "B/B", "A/A", "B/B", # S3: opposite homozygote to O3 at
    # L1, L2, L3 -> exactly 3 conflicts (exceeds maxExclusions=2, flagged).
    "A/B", "A/B", "A/B", "A/B", "A/B", # O4: heterozygous everywhere.
    "A/B", "A/B", "A/B", "A/B", "A/B"  # O5: heterozygous everywhere.
  ),
  nrow = 9L, byrow = TRUE,
  dimnames = list(c("O1", "D1", "S1", "O2", "D2", "O3", "S3", "O4", "O5"),
                   paste0("L", 1L:5L))
)

## O2's sire and O3's dam are unrecorded (NA, unknown parent) -- must be
## skipped, not treated as a 0-conflict match. O4's recorded dam "D4" is
## NOT a row in genotypeMatrix (never genotyped) -- must also be skipped,
## distinct from the NA case. O5's dam is NA; its sire S1 is genotyped and
## consistent.
pedigree <- data.frame(
  id   = c("O1", "O2", "O3", "O4", "O5"),
  sire = c("S1", NA_character_, "S3", "S1", "S1"),
  dam  = c("D1", "D2", NA_character_, "D4", NA_character_),
  stringsAsFactors = FALSE
)

test_that("markerParentageExclusion flags a Mendelian-inconsistent recorded parent above maxExclusions", {
  tbl <- markerParentageExclusion(genotypeMatrix, pedigree, maxExclusions = 2L)

  expect_s3_class(tbl, "data.frame")
  expect_identical(sort(names(tbl)),
                    sort(c("id", "parentId", "role", "exclusionCount",
                            "nLoci", "flagged")))

  ## O2, O3, O4, O5 each have exactly one NA/unrecorded or ungenotyped
  ## parent, so exactly 6 rows total: O1 x {dam, sire}, O2 x dam, O3 x
  ## sire, O4 x sire, O5 x sire.
  expect_identical(nrow(tbl), 6L)

  byPair <- function(id, role) tbl[tbl$id == id & tbl$role == role, ]

  o1dam <- byPair("O1", "dam")
  expect_identical(o1dam$parentId, "D1")
  expect_identical(o1dam$exclusionCount, 0L)
  expect_identical(o1dam$nLoci, 5L)
  expect_false(o1dam$flagged)

  o1sire <- byPair("O1", "sire")
  expect_identical(o1sire$parentId, "S1")
  expect_identical(o1sire$exclusionCount, 0L)
  expect_false(o1sire$flagged)

  ## Boundary: exactly maxExclusions (2) conflicts is tolerated, not flagged.
  o2dam <- byPair("O2", "dam")
  expect_identical(o2dam$parentId, "D2")
  expect_identical(o2dam$exclusionCount, 2L)
  expect_identical(o2dam$nLoci, 5L)
  expect_false(o2dam$flagged)

  ## Boundary: exceeding maxExclusions (3 > 2) is flagged.
  o3sire <- byPair("O3", "sire")
  expect_identical(o3sire$parentId, "S3")
  expect_identical(o3sire$exclusionCount, 3L)
  expect_true(o3sire$flagged)

  ## O4's dam "D4" is recorded but never genotyped -- no row emitted for
  ## that pair at all (distinct from a flagged=NA row).
  expect_identical(nrow(byPair("O4", "dam")), 0L)
  o4sire <- byPair("O4", "sire")
  expect_identical(o4sire$parentId, "S1")
  expect_identical(o4sire$exclusionCount, 0L)
  expect_false(o4sire$flagged)

  ## O5's dam is unrecorded (NA) -- no row emitted.
  expect_identical(nrow(byPair("O5", "dam")), 0L)
  o5sire <- byPair("O5", "sire")
  expect_identical(o5sire$exclusionCount, 0L)
  expect_false(o5sire$flagged)

  ## O2's sire and O3's dam are both NA -- confirm no stray rows exist for
  ## those either.
  expect_identical(nrow(byPair("O2", "sire")), 0L)
  expect_identical(nrow(byPair("O3", "dam")), 0L)
})

test_that("markerParentageExclusion's maxExclusions parameter is tunable", {
  ## At the stricter maxExclusions = 1, O2's 2-conflict pair (tolerated at
  ## the default) becomes flagged.
  tbl <- markerParentageExclusion(genotypeMatrix, pedigree, maxExclusions = 1L)
  o2dam <- tbl[tbl$id == "O2" & tbl$role == "dam", ]
  expect_identical(o2dam$exclusionCount, 2L)
  expect_true(o2dam$flagged)
})

test_that("markerParentageExclusion returns NA with a warning when a pair shares no genotyped loci", {
  zeroMat <- matrix(
    c("A/A", NA_character_,
      NA_character_, "A/B"),
    nrow = 2L, byrow = TRUE,
    dimnames = list(c("Z1", "P1"), c("M1", "M2"))
  )
  zeroPed <- data.frame(id = "Z1", sire = "P1", dam = NA_character_,
                          stringsAsFactors = FALSE)

  expect_warning(
    tbl <- markerParentageExclusion(zeroMat, zeroPed, maxExclusions = 2L),
    "no shared genotyped loci"
  )
  expect_identical(nrow(tbl), 1L)
  expect_true(is.na(tbl$exclusionCount))
  expect_identical(tbl$nLoci, 0L)
  expect_true(is.na(tbl$flagged))
})

test_that("markerParentageExclusion returns a zero-row data.frame with the right shape when no pair is checkable", {
  emptyPed <- data.frame(id = "O1", sire = NA_character_,
                           dam = NA_character_, stringsAsFactors = FALSE)
  tbl <- markerParentageExclusion(genotypeMatrix, emptyPed, maxExclusions = 2L)

  expect_s3_class(tbl, "data.frame")
  expect_identical(nrow(tbl), 0L)
  expect_identical(sort(names(tbl)),
                    sort(c("id", "parentId", "role", "exclusionCount",
                            "nLoci", "flagged")))
})
