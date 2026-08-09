## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #147 Slice 1): markerParentageLikelihood() ranks candidate replacement
## parents for a Mendelian-inconsistent recorded parent (as flagged by
## markerParentageExclusion()) using a CERVUS-style multilocus likelihood-ratio (LOD)
## score (Meagher & Thompson 1986; Marshall, Slate, Kruuk & Pemberton 1998), per
## docs/planning/issue147-likelihood-parentage-assignment-plan.md D1/D2/D8.
##
## Formula (independently re-derived from first principles at this session's Pre-RED,
## not trusted from memory -- see this project's own markerFst() precedent of a
## previously-shipped ~40%-off formula caught by exactly this discipline). For a
## biallelic locus with reference-allele (alphabetically first observed at that locus,
## matching markerFst()'s own convention) population frequency p:
##   t(genotype) = probability that parent transmits the reference allele:
##     homozygous-reference -> 1, heterozygous -> 0.5, homozygous-other -> 0
##   P(offspring genotype ; t1, t2) for two independent allele-transmission sources:
##     homozygous-reference: t1*t2 ; heterozygous: t1*(1-t2)+(1-t1)*t2 ;
##     homozygous-other: (1-t1)*(1-t2)
##   H1 (candidate IS the parent):   dyad t1=t(candidate), t2=p
##                                   trio t1=t(candidate), t2=t(other known parent)
##   H2 (candidate unrelated):        dyad t1=p,           t2=p
##                                   trio t1=p,             t2=t(other known parent)
##   LOD = sum over jointly-genotyped loci of ln(H1/H2)
## Verified via a standalone, from-scratch reference implementation independent of any
## planned package code (this session's Pre-RED scratch verification), including a
## sanity check that the dyad H2 formula reduces exactly to Hardy-Weinberg genotype
## frequencies. Trio-vs-dyad conditioning (D2) is AUTOMATIC: the offspring's other
## recorded parent is incorporated when genotyped and not itself Mendelian-excluded
## (exclusionCount > maxExclusions vs the offspring); otherwise the dyad (population-
## frequency) fallback applies. Two hand-verified findings this Pre-RED surfaced,
## deliberately exercised below rather than avoided:
##   (a) ANY single Mendelian-incompatible (opposite-homozygote) locus drives the
##       no-error-model LOD to exactly -Inf (a true Mendelian impossibility, probability
##       zero) -- independent of, and can occur even when, `excluded` is FALSE (i.e. the
##       exclusionCount is at or below maxExclusions, the genotyping-error TOLERANCE
##       threshold `markerParentageExclusion()` itself uses -- LOD has no such
##       tolerance in the no-error-model formula D2 ratified for this slice).
##   (b) `delta` (gap to the next-ranked candidate within the (id, role) group) is 0,
##       not NaN, for two candidates exactly tied at -Inf (`-Inf - (-Inf)` is NaN in
##       plain R arithmetic) -- surfaced concretely by Sunrel/Sexcl below, not just
##       hypothesized.
##
## Fixture design note: every other test_marker*.R file in this package (confirmed by
## grep for "extdata" across all of them: zero hits) uses small, inline, hand-built
## genotype matrices/pedigrees rather than a file under inst/extdata/examples/ -- this
## file follows that established, unbroken convention (a factual correction to the
## plan document's own "Touches" list, not a scope change).
##
## One shared fixture below combines TWO independent offspring scenarios in a single
## genotypeMatrix/pedigree (loci L1-L5 and M1-M4 are entirely disjoint column sets, so
## combining them does not perturb either scenario's own per-locus allele-frequency
## computation -- confirmed at Pre-RED by recomputing frequencies with the combined
## population before trusting any downstream LOD figure):
##
## Scenario O1 (loci L1-L5): dam D1 is recorded, genotyped, and NOT Mendelian-excluded
## (0 conflicts vs O1) -- exercises the TRIO conditioning path. The recorded sire is
## "Sexcl", who IS Mendelian-excluded (3 conflicts vs O1, exceeding the default
## maxExclusions=2), so markerParentageExclusion() flags (O1, "sire") but not
## (O1, "dam") -- the auto-detection test below relies on exactly this asymmetry.
## Scoring candidates for O1's sire slot: Strue (the true sire, 0 conflicts), Sunrel
## (1 conflict -- NOT excluded, but still LOD=-Inf, finding (a) above), Sexcl (3
## conflicts, excluded=TRUE, also LOD=-Inf), Ssib (0 conflicts but not the true sire --
## a demographically-eligible, Mendelian-COMPATIBLE alternative candidate that must
## still appear in ranked output, not be silently dropped, per the design's own Dragon
## 3; getPotentialParents() applies no kinship filter of its own, and is mocked with a
## fixed candidate list in the auto-detection test below, so "Ssib" here represents
## that eligibility via genetic similarity to Strue rather than a literally
## pedigree-simulated full sibling), and Slow (genotyped at only 2 of 5 loci vs O1,
## below the default minLoci=4 -- exercises lowPower). "Snoloci" is genotyped nowhere
## in this fixture at all (all-NA) -- exercises the zero-shared-loci contract.
##
## Scenario O2 (loci M1-M4): dam is UNRECORDED (NA) -- exercises the DYAD (no known
## other parent) conditioning path. The recorded sire is "Swrong2" (4 conflicts vs O2,
## all 4 loci, excluded=TRUE), scoring candidates Strue2 (the true sire, 0 conflicts)
## and Scand2 (0 conflicts, not the true sire).
##
## Expected LOD/delta values below were derived with a standalone, from-scratch
## reference implementation (plain base-R loop applying the formula above, independent
## of any planned package code) at this session's Pre-RED -- see this slice's Pre-RED
## scratch verification, not copied from any implementation, mirroring
## test_markerParentageExclusion.R's own precedent for this package.

genotypeMatrix <- matrix(
  c(
    ## O1-scenario columns (L1-L5)                    M1-scenario columns (M1-M4)
    "A/A","A/A","B/B","A/B","A/B",                    NA,NA,NA,NA,             # O1
    "A/B","A/A","B/B","A/B","A/A",                    NA,NA,NA,NA,             # D1
    "A/A","A/A","B/B","A/B","B/B",                    NA,NA,NA,NA,             # Strue
    "B/B","A/A","B/B","A/A","B/B",                    NA,NA,NA,NA,             # Sunrel
    "B/B","B/B","A/A","A/A","B/B",                    NA,NA,NA,NA,             # Sexcl
    "A/B","A/A","A/B","A/A","A/B",                    NA,NA,NA,NA,             # Ssib
    "A/A","A/A", NA , NA , NA,                        NA,NA,NA,NA,             # Slow
    NA,NA,NA,NA,NA,                                   NA,NA,NA,NA,             # Snoloci
    NA,NA,NA,NA,NA,                                   "A/A","B/B","A/A","B/B",  # O2
    NA,NA,NA,NA,NA,                                   "A/A","B/B","A/A","B/B",  # Strue2
    NA,NA,NA,NA,NA,                                   "A/B","A/B","A/B","A/B",  # Scand2
    NA,NA,NA,NA,NA,                                   "B/B","A/A","B/B","A/A"   # Swrong2
  ),
  nrow = 12L, byrow = TRUE,
  dimnames = list(
    c("O1", "D1", "Strue", "Sunrel", "Sexcl", "Ssib", "Slow", "Snoloci",
      "O2", "Strue2", "Scand2", "Swrong2"),
    c(paste0("L", 1L:5L), paste0("M", 1L:4L))
  )
)

## O1's recorded sire (Sexcl) is Mendelian-excluded; its recorded dam (D1) is not.
## O2's recorded sire (Swrong2) is Mendelian-excluded; it has no recorded dam at all.
pedigree <- data.frame(
  id   = c("O1", "O2"),
  sire = c("Sexcl", "Swrong2"),
  dam  = c("D1", NA_character_),
  stringsAsFactors = FALSE
)

test_that(".markerAlleleFrequencyTable computes per-allele frequency from non-NA cells", {
  ## A locus with 3 genotyped individuals (6 allele calls: 4 A, 2 B) plus one NA
  ## individual who must be excluded from both numerator and denominator.
  gm <- matrix(
    c("A/A", "A/B", "A/B", NA_character_),
    nrow = 4L, dimnames = list(c("I1", "I2", "I3", "I4"), "L1")
  )
  freq <- .markerAlleleFrequencyTable(gm, "L1")
  expect_true(is.numeric(freq))
  expect_identical(sort(names(freq)), c("A", "B"))
  expect_equal(unname(freq[["A"]]), 4 / 6, tolerance = 1e-6)
  expect_equal(unname(freq[["B"]]), 2 / 6, tolerance = 1e-6)
})

test_that(".markerAlleleFrequencyTable handles a locus monomorphic among genotyped individuals", {
  gm <- matrix(c("A/A", "A/A"), nrow = 2L, dimnames = list(c("I1", "I2"), "L1"))
  freq <- .markerAlleleFrequencyTable(gm, "L1")
  expect_identical(names(freq), "A")
  expect_equal(unname(freq[["A"]]), 1.0, tolerance = 1e-6)
})

test_that(".markerOppositeHomozygoteCount matches markerParentageExclusion's own extracted logic", {
  ## Reuses the O1/Strue (0 conflicts), O1/Sunrel (1 conflict), O1/Sexcl (3
  ## conflicts) triples already independently confirmed against the real,
  ## current (pre-extraction) markerParentageExclusion() at this session's Pre-RED.
  ## O1 and Strue are genotyped ONLY at L1-L5 (both NA at M1-M4) -- the shared
  ## (jointly non-NA) count over the full 9-column row is 5, not 9, confirming
  ## columns NA in BOTH individuals are excluded from the count, not treated as
  ## a trivial match.
  r <- .markerOppositeHomozygoteCount(genotypeMatrix["O1", ], genotypeMatrix["Strue", ])
  expect_identical(r$exclusionCount, 0L)
  expect_identical(r$nLoci, 5L)

  rSunrel <- .markerOppositeHomozygoteCount(genotypeMatrix["O1", ], genotypeMatrix["Sunrel", ])
  expect_identical(rSunrel$exclusionCount, 1L)
  expect_identical(rSunrel$nLoci, 5L)

  rSexcl <- .markerOppositeHomozygoteCount(genotypeMatrix["O1", ], genotypeMatrix["Sexcl", ])
  expect_identical(rSexcl$exclusionCount, 3L)
  expect_identical(rSexcl$nLoci, 5L)
})

test_that(".markerOppositeHomozygoteCount returns NA exclusionCount when zero loci are shared", {
  r <- .markerOppositeHomozygoteCount(genotypeMatrix["O1", ], genotypeMatrix["Snoloci", ])
  expect_true(is.na(r$exclusionCount))
  expect_identical(r$nLoci, 0L)
})

## REFACTOR (GREEN->REFACTOR, owner-approved): .markerTransmissionProbability()
## and .markerTwoSourceGenotypeProbability() were hoisted out of
## markerParentageLikelihood()'s own internal scoreOnePair() closure into
## named, directly-testable helpers -- these tests pin the Mendelian
## transmission-probability formula itself (D2), independent of the
## end-to-end hand-verified LOD sums already asserted above/below, an extra
## verification layer for exactly the kind of formula this project has
## previously shipped wrong under a mis-attributed citation (markerFst()'s
## own Pre-RED history).
test_that(".markerTransmissionProbability computes t(genotype) correctly", {
  expect_equal(.markerTransmissionProbability("A/A", "A"), 1.0)
  expect_equal(.markerTransmissionProbability("A/B", "A"), 0.5)
  expect_equal(.markerTransmissionProbability("B/B", "A"), 0.0)
})

test_that(".markerTwoSourceGenotypeProbability computes P(offspring geno; t1, t2) correctly", {
  ## Homozygous-reference offspring genotype: t1*t2.
  expect_equal(.markerTwoSourceGenotypeProbability(0.8, 0.3, "A/A", "A"), 0.8 * 0.3)
  ## Heterozygous offspring genotype: t1*(1-t2) + (1-t1)*t2.
  expect_equal(.markerTwoSourceGenotypeProbability(0.8, 0.3, "A/B", "A"),
               0.8 * (1 - 0.3) + (1 - 0.8) * 0.3)
  ## Homozygous-other offspring genotype: (1-t1)*(1-t2).
  expect_equal(.markerTwoSourceGenotypeProbability(0.8, 0.3, "B/B", "A"),
               (1 - 0.8) * (1 - 0.3))
})

test_that(".markerTwoSourceGenotypeProbability reduces to Hardy-Weinberg when t1 == t2 == p (H2, dyad)", {
  p <- 0.35
  expect_equal(.markerTwoSourceGenotypeProbability(p, p, "A/A", "A"), p^2)
  expect_equal(.markerTwoSourceGenotypeProbability(p, p, "A/B", "A"), 2 * p * (1 - p))
  expect_equal(.markerTwoSourceGenotypeProbability(p, p, "B/B", "A"), (1 - p)^2)
})

test_that("markerParentageLikelihood ranks candidates by hand-verified LOD under TRIO conditioning", {
  result <- markerParentageLikelihood(
    genotypeMatrix, pedigree, id = "O1", role = "sire",
    candidates = c("Strue", "Sunrel", "Sexcl", "Ssib", "Slow")
  )

  expect_s3_class(result, "data.frame")
  expect_identical(sort(names(result)),
                    sort(c("id", "role", "candidateId", "LOD", "delta",
                            "nLociUsed", "excluded", "lowPower")))
  expect_identical(nrow(result), 5L)
  expect_true(all(result$id == "O1"))
  expect_true(all(result$role == "sire"))

  byCand <- function(cid) result[result$candidateId == cid, ]

  strue <- byCand("Strue")
  expect_equal(strue$LOD, 1.406913648322626, tolerance = 1e-6)
  expect_identical(strue$nLociUsed, 5L)
  expect_false(strue$excluded)
  expect_false(strue$lowPower)

  slow <- byCand("Slow")
  expect_equal(slow$LOD, 0.713766467762681, tolerance = 1e-6)
  expect_identical(slow$nLociUsed, 2L)
  expect_false(slow$excluded)
  expect_true(slow$lowPower) # nLociUsed (2) < default minLoci (4)

  ssib <- byCand("Ssib")
  expect_equal(ssib$LOD, -0.672527893357210, tolerance = 1e-6)
  expect_identical(ssib$nLociUsed, 5L)
  expect_false(ssib$excluded)
  expect_false(ssib$lowPower)

  ## Sunrel (1 conflict, NOT excluded) and Sexcl (3 conflicts, excluded=TRUE) are
  ## BOTH Mendelian-incompatible at >=1 locus -> both LOD = -Inf (finding (a)).
  sunrel <- byCand("Sunrel")
  expect_identical(sunrel$LOD, -Inf)
  expect_identical(sunrel$nLociUsed, 5L)
  expect_false(sunrel$excluded) # 1 conflict <= default maxExclusions (2)

  sexcl <- byCand("Sexcl")
  expect_identical(sexcl$LOD, -Inf)
  expect_identical(sexcl$nLociUsed, 5L)
  expect_true(sexcl$excluded) # 3 conflicts > default maxExclusions (2)

  ## Ranking order (LOD descending): Strue > Slow > Ssib > {Sunrel, Sexcl} tied.
  expect_identical(result$candidateId,
                    c("Strue", "Slow", "Ssib", "Sunrel", "Sexcl"))

  ## delta = gap to the NEXT-ranked candidate in the group; NA for the last row.
  expect_equal(byCand("Strue")$delta, 0.693147180559945, tolerance = 1e-6)
  expect_equal(byCand("Slow")$delta, 1.386294361119891, tolerance = 1e-6)
  expect_identical(byCand("Ssib")$delta, Inf) # gap down to a -Inf neighbor is +Inf
  ## Sunrel and Sexcl are EXACTLY tied at -Inf: delta is 0, not NaN (finding (b)).
  expect_identical(byCand("Sunrel")$delta, 0)
  expect_true(is.na(byCand("Sexcl")$delta)) # last-ranked row: no next-best below it
})

test_that("markerParentageLikelihood computes hand-verified LOD under DYAD conditioning (no known other parent)", {
  result <- markerParentageLikelihood(
    genotypeMatrix, pedigree, id = "O2", role = "sire",
    candidates = c("Strue2", "Scand2")
  )

  expect_identical(nrow(result), 2L)
  byCand <- function(cid) result[result$candidateId == cid, ]

  strue2 <- byCand("Strue2")
  expect_equal(strue2$LOD, 1.880014516982943, tolerance = 1e-6)
  expect_identical(strue2$nLociUsed, 4L)
  expect_false(strue2$excluded)
  expect_false(strue2$lowPower)
  expect_equal(strue2$delta, 2.772588722239782, tolerance = 1e-6)

  scand2 <- byCand("Scand2")
  expect_equal(scand2$LOD, -0.892574205256839, tolerance = 1e-6)
  expect_identical(scand2$nLociUsed, 4L)
  expect_false(scand2$excluded)
  expect_true(is.na(scand2$delta)) # last-ranked (sole remaining) row

  expect_identical(result$candidateId, c("Strue2", "Scand2")) # Strue2 ranks first
})

test_that("markerParentageLikelihood reports a zero-shared-loci candidate honestly, with a warning", {
  expect_warning(
    result <- markerParentageLikelihood(
      genotypeMatrix, pedigree, id = "O1", role = "sire",
      candidates = c("Strue", "Snoloci")
    ),
    "no shared genotyped loci"
  )
  noloci <- result[result$candidateId == "Snoloci", ]
  expect_identical(noloci$nLociUsed, 0L)
  expect_true(is.na(noloci$LOD))
  expect_true(noloci$lowPower)
  expect_true(is.na(noloci$excluded)) # undefined, mirroring markerParentageExclusion()'s NA convention
})

test_that("markerParentageLikelihood auto-detects flagged pairs and conditions each correctly", {
  mockCandidates <- list(
    list(id = "O1", sires = c("Strue", "Sunrel", "Sexcl", "Ssib", "Slow"),
         dams = character(0L)),
    list(id = "O2", sires = c("Strue2", "Scand2"), dams = character(0L))
  )
  called <- FALSE
  testthat::local_mocked_bindings(
    getPotentialParents = function(ped, ...) {
      called <<- TRUE
      mockCandidates
    },
    .package = "nprcgenekeepr"
  )

  result <- markerParentageLikelihood(genotypeMatrix, pedigree)

  expect_true(called)
  ## Exactly the two FLAGGED pairs -- (O1, "sire") and (O2, "sire") -- never
  ## (O1, "dam"), whose recorded parent D1 is NOT Mendelian-excluded.
  pairs <- unique(result[c("id", "role")])
  pairs <- pairs[order(pairs$id, pairs$role), ]
  expect_identical(pairs$id, c("O1", "O2"))
  expect_identical(pairs$role, c("sire", "sire"))

  o1 <- result[result$id == "O1", ]
  expect_identical(nrow(o1), 5L)
  expect_equal(o1$LOD[o1$candidateId == "Strue"], 1.406913648322626, tolerance = 1e-6)

  o2 <- result[result$id == "O2", ]
  expect_identical(nrow(o2), 2L)
  expect_equal(o2$LOD[o2$candidateId == "Strue2"], 1.880014516982943, tolerance = 1e-6)
})

test_that("markerParentageLikelihood does not call getPotentialParents when candidates is supplied explicitly", {
  called <- FALSE
  testthat::local_mocked_bindings(
    getPotentialParents = function(ped, ...) {
      called <<- TRUE
      NULL
    },
    .package = "nprcgenekeepr"
  )
  markerParentageLikelihood(
    genotypeMatrix, pedigree, id = "O1", role = "sire",
    candidates = c("Strue", "Ssib")
  )
  expect_false(called)
})

test_that("markerParentageLikelihood never mutates its pedigree input (report-only contract)", {
  pedigreeBefore <- pedigree
  invisible(markerParentageLikelihood(
    genotypeMatrix, pedigree, id = "O1", role = "sire",
    candidates = c("Strue", "Ssib")
  ))
  expect_identical(pedigree, pedigreeBefore)

  testthat::local_mocked_bindings(
    getPotentialParents = function(ped, ...) {
      list(list(id = "O1", sires = c("Strue", "Ssib"), dams = character(0L)),
           list(id = "O2", sires = c("Strue2"), dams = character(0L)))
    },
    .package = "nprcgenekeepr"
  )
  invisible(markerParentageLikelihood(genotypeMatrix, pedigree))
  expect_identical(pedigree, pedigreeBefore)
})

test_that("markerParentageLikelihood errors loudly on a malformed pedigree shape", {
  badPedigree <- data.frame(id = "O1", stringsAsFactors = FALSE) # no sire/dam columns
  expect_error(
    markerParentageLikelihood(genotypeMatrix, badPedigree, id = "O1", role = "sire",
                               candidates = "Strue"),
    "sire.*dam|dam.*sire"
  )
})

test_that("markerParentageLikelihood returns a zero-row result with the full column shape when nothing is checkable", {
  cleanPedigree <- data.frame(id = "Strue", sire = NA_character_,
                                dam = NA_character_, stringsAsFactors = FALSE)
  result <- markerParentageLikelihood(genotypeMatrix, cleanPedigree)

  expect_s3_class(result, "data.frame")
  expect_identical(nrow(result), 0L)
  expect_identical(sort(names(result)),
                    sort(c("id", "role", "candidateId", "LOD", "delta",
                            "nLociUsed", "excluded", "lowPower")))
})
