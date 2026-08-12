## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #153 Slice 4): markerLdBlock(genotypeMatrix, locusMetadata,
## founderIds = NULL) computes a descriptive, same-chromosome-pairs-only
## LD/block statistic (D3b) -- a genuine statistical compromise, not a
## rigorous pedigree-aware method (sec 7 Dragon 3): no CRAN package is both
## pedigree-aware and multiallelic-capable (sec 2.12), so this hand-rolls
## (D8) in base R.
##
## This package's genotype matrix (buildMarkerGenotypeMatrix()) is
## UNPHASED -- a double-heterozygote at both loci cannot be resolved into
## coupling (AB/ab) vs. repulsion (Ab/aB) from the genotype alone. This
## session's own PRE-RED found and verified (independent standalone R
## scripts, not this package's implementation) that a two-locus,
## multiallelic maximum-likelihood (EM) phase-frequency estimator --
##
##   Excoffier, L. & Slatkin, M. (1995). "Maximum-likelihood estimation of
##   molecular haplotype frequencies in a diploid population." Molecular
##   Biology and Evolution 12(5):921-927.
##
## -- generalized from its classic biallelic form to arbitrary allele
## counts, is the correct approach: it reproduced the exact classic D when
## phase happened to be fully resolvable, recovered a known true D within
## 2% on a 600-individual random-mating simulation with 209 genuinely
## phase-ambiguous double heterozygotes, and recovered a known 3-allele x
## 3-allele joint frequency table within ~0.017 absolute error at n=800.
##
## Per-allele-pair D_ij/D'_ij use the classic Lewontin (1964) Dmax
## standardization. The per-locus-pair aggregate statistics are:
##
##   Dprime = sum_i sum_j p_i * q_j * |D'_ij|      (Hedrick 1987)
##   r2     = sum_i sum_j D_ij^2 / (p_i * q_j)     (chi-squared / Cramer's
##            phi-squared-style multiallelic generalization)
##
## This session proved algebraically -- and confirmed numerically -- that
## r2 reduces EXACTLY to the classic biallelic r^2 = D^2/(pA(1-pA)pB(1-pB))
## whenever both loci happen to be biallelic (a hard identity: at fixed j,
## sum_i D_ij = 0 since the dosage/frequency total is fixed, which is what
## makes the 2x2 collapse exact). Reference: Weir, B.S. (1996). Genetic
## Data Analysis II. Sinauer Associates. See also Zaykin, D.V., Pudovkin,
## A. & Weir, B.S. (2008). "Correlation-based inference for linkage
## disequilibrium with multiple alleles." Genetics 180(1):533-545 (the
## same sum-of-pairwise-associations idea, for testing significance).
##
## D1 vocabulary discipline: "LD block" throughout, never bare
## "haplotype" (sequencing-audit vocabulary-overlap finding with issue
## #148's MHC "haplotype" usage) -- this file follows that discipline in
## its own prose too, except when citing a paper's own title/terminology.
##
## Reference Dprime/r2/nUsed values below were computed independently via
## a standalone, non-package R script implementing the algorithm above
## against the ALREADY-COMMITTED STR fixture (Slice 1's
## example_locus_metadata.csv / example_str_marker_genotypes.csv) -- no
## new fixture needed. STR01/STR02 share chrom "1"; STR03/STR04 share
## chrom "2" -- the fixture's only two same-chromosome pairs among its 8
## chrom-bearing loci.

library(testthat)

i153LocusMetadataPath <- function() {
  system.file("extdata", "examples", "example_locus_metadata.csv",
              package = "nprcgenekeepr")
}
i153GenotypePath <- function() {
  system.file("extdata", "examples", "example_str_marker_genotypes.csv",
              package = "nprcgenekeepr")
}
i153LocusMetadata <- function() {
  checkLocusMetadata(read.csv(i153LocusMetadataPath(), stringsAsFactors = FALSE))
}
i153GenotypeMatrix <- function() {
  genotype <- checkLinkageMarkerGenotypeFile(
    read.csv(i153GenotypePath(), stringsAsFactors = FALSE)
  )
  buildMarkerGenotypeMatrix(genotype)
}

test_that("markerLdBlock matches hand-verified values for STR01 x STR02 (chrom 1)", {
  result <- markerLdBlock(i153GenotypeMatrix(), i153LocusMetadata())
  row12 <- result[result$locus1 == "STR01" & result$locus2 == "STR02", ]
  expect_equal(nrow(row12), 1L)
  expect_equal(row12$chrom, "1")
  expect_equal(row12$Dprime, 0.606061, tolerance = 1e-5)
  expect_equal(row12$r2, 0.288889, tolerance = 1e-5)
  expect_equal(row12$nUsed, 10L)
  expect_true(is.na(row12$idsUsed))
})

test_that("markerLdBlock matches hand-verified values for STR03 x STR04 (chrom 2)", {
  result <- markerLdBlock(i153GenotypeMatrix(), i153LocusMetadata())
  row34 <- result[result$locus1 == "STR03" & result$locus2 == "STR04", ]
  expect_equal(nrow(row34), 1L)
  expect_equal(row34$chrom, "2")
  expect_equal(row34$Dprime, 0.662317, tolerance = 1e-5)
  expect_equal(row34$r2, 0.498590, tolerance = 1e-5)
  expect_equal(row34$nUsed, 10L)
})

test_that("markerLdBlock never pairs loci on different chromosomes", {
  result <- markerLdBlock(i153GenotypeMatrix(), i153LocusMetadata())
  ## STR01 (chrom 1) x STR03 (chrom 2): cross-chromosome, must not appear.
  crossPair <- result[(result$locus1 == "STR01" & result$locus2 == "STR03") |
    (result$locus1 == "STR03" & result$locus2 == "STR01"), ]
  expect_equal(nrow(crossPair), 0L)
})

test_that("markerLdBlock excludes loci with NA chrom (STR11/STR12) from pairing", {
  result <- markerLdBlock(i153GenotypeMatrix(), i153LocusMetadata())
  expect_false(any(result$locus1 == "STR11" | result$locus2 == "STR11"))
  expect_false(any(result$locus1 == "STR12" | result$locus2 == "STR12"))
})

test_that("markerLdBlock produces exactly two pairs for the STR fixture (only two chroms have >1 locus)", {
  ## chrom "1": STR01/STR02 (1 pair). chrom "2": STR03/STR04 (1 pair).
  ## STR05-STR08 are each alone on their own chrom (chrom 3-6). STR09/STR10
  ## have chrom but no pos, each alone on chrom 7/8 -- no partner either.
  ## STR11/STR12 have NA chrom. Total: exactly 2 pairs.
  result <- markerLdBlock(i153GenotypeMatrix(), i153LocusMetadata())
  expect_equal(nrow(result), 2L)
})

test_that("markerLdBlock restricts to founderIds, matching the hand-verified restricted value", {
  founders <- c("A01", "A02", "A03", "A04", "A05")
  result <- markerLdBlock(i153GenotypeMatrix(), i153LocusMetadata(),
                           founderIds = founders)
  row12 <- result[result$locus1 == "STR01" & result$locus2 == "STR02", ]
  expect_equal(row12$Dprime, 0.714286, tolerance = 1e-5)
  expect_equal(row12$r2, 0.682540, tolerance = 1e-5)
  expect_equal(row12$nUsed, 5L)
  expect_setequal(strsplit(row12$idsUsed, ",", fixed = TRUE)[[1L]], founders)
})

test_that("markerLdBlock includes a fixed, non-empty caveat on every row", {
  result <- markerLdBlock(i153GenotypeMatrix(), i153LocusMetadata())
  expect_true(all(!is.na(result$caveat)))
  expect_true(all(nzchar(result$caveat)))
  expect_equal(length(unique(result$caveat)), 1L)
})

test_that("markerLdBlock returns the documented column contract", {
  result <- markerLdBlock(i153GenotypeMatrix(), i153LocusMetadata())
  expect_identical(
    names(result),
    c("locus1", "locus2", "chrom", "Dprime", "r2", "nUsed", "idsUsed", "caveat")
  )
})

test_that("markerLdBlock stops when no locus has a usable (non-NA) chrom", {
  noChrom <- i153LocusMetadata()
  noChrom$chrom <- NA_character_
  expect_error(
    markerLdBlock(i153GenotypeMatrix(), noChrom),
    "chrom",
    ignore.case = TRUE
  )
})

test_that("markerLdBlock stops on a malformed genotype matrix", {
  expect_error(
    markerLdBlock(list(a = 1L), i153LocusMetadata()),
    "matrix",
    ignore.case = TRUE
  )
})

test_that("markerLdBlock stops on malformed locusMetadata (missing 'chrom')", {
  badMetadata <- i153LocusMetadata()[, c("locus", "pos")]
  expect_error(
    markerLdBlock(i153GenotypeMatrix(), badMetadata),
    "chrom",
    ignore.case = TRUE
  )
})

test_that("markerLdBlock returns NA with a named warning when a pair has fewer than 2 shared genotyped individuals", {
  ## Restricting to a single founder leaves nUsed = 1 for every pair --
  ## nothing computable, matching markerFst()'s NA-with-warning precedent
  ## for an insufficient-evidence pair (not a stop()).
  expect_warning(
    result <- markerLdBlock(i153GenotypeMatrix(), i153LocusMetadata(),
                             founderIds = "A01"),
    "STR01"
  )
  row12 <- result[result$locus1 == "STR01" & result$locus2 == "STR02", ]
  expect_true(is.na(row12$Dprime))
  expect_true(is.na(row12$r2))
  expect_equal(row12$nUsed, 1L)
})
