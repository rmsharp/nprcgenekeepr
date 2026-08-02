## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #130 Slice 5): markerFst() computes a between-population
## allele-frequency differentiation statistic (Fst) from two centers' marker
## genotype matrices -- a population-level, two-dataset comparison,
## independent of any per-individual cross-center identity linkage (Slice 4)
## per the audit's own Dimension-6 wording. Estimator: Hudson's Fst (Hudson,
## Slatkin & Maddison 1992, Genetics 132(2):583-589, DOI
## 10.1093/genetics/132.2.583), in the explicit two-population
## biallelic-SNP closed form given by Bhatia, Patterson, Sankararaman &
## Price (2013, Genome Research 23(9):1514-1521, Eq. 10, DOI
## 10.1101/gr.154831.113) -- chosen over Weir & Cockerham (1984) per this
## slice's Pre-RED research (a 3-angle research pass plus an adversarial
## verification): Bhatia et al. explicitly and repeatedly recommend
## Hudson's estimator for pairwise two-named-population comparisons because
## it is not biased by the ratio of the two populations' sample sizes,
## unlike Weir & Cockerham -- and the adversarial verification pass found
## the "obvious" two-term Weir & Cockerham special case first considered is
## not actually what "Weir & Cockerham (1984)" refers to in the literature
## (the true estimator has a third, heterozygosity-driven component; the
## two-term version differed from it by ~40% on a hand-computed check).
##
## Formula, per shared locus, over allele "A" (biallelic, an arbitrary but
## consistent reference allele per locus -- the loci this function receives
## are already restricted to biallelic by checkMarkerGenotypeFile()):
##
##   N_l = (p1-p2)^2 - p1*(1-p1)/(n1-1) - p2*(1-p2)/(n2-1)
##   D_l = p1*(1-p2) + p2*(1-p1)
##   Fst_l = N_l / D_l
##
## where p_i is center i's sample frequency of allele "A" at locus l, and
## n_i is center i's ALLELE count at that locus (2 x the number of
## genotyped individuals). Pooled across loci as a ratio of sums, NOT a
## mean of per-locus ratios (Bhatia et al. explicitly warn the latter is
## materially biased -- on their own CEU-YRI example, a >2x difference):
##
##   pooledFst = sum(N_l over valid loci) / sum(D_l over valid loci)
##
## Expected values below were derived independently with exact-fraction
## arithmetic (not this package's planned code) during this slice's Pre-RED
## research, cross-checked against two independently-fetched primary
## sources (the Bhatia et al. 2013 PDF and the CRAN KRIS package's
## fst.hudson documentation) -- an independent oracle, not a copy of any
## planned implementation.

genotypeMatrixA <- matrix(
  c(
    "A/A", "A/A",
    "A/A", "A/B",
    "A/B", "A/B",
    "B/B", "A/A"
  ),
  nrow = 4L, byrow = TRUE,
  dimnames = list(c("A1", "A2", "A3", "A4"), c("L1", "L2"))
)

genotypeMatrixB <- matrix(
  c(
    "A/B", "B/B",
    "B/B", "A/B",
    "A/B", "B/B",
    "B/B", "B/B",
    "A/A", "B/B",
    "B/B", "A/B"
  ),
  nrow = 6L, byrow = TRUE,
  dimnames = list(paste0("B", 1L:6L), c("L1", "L2"))
)

test_that("markerFst matches hand-verified values for a two-locus, two-center fixture", {
  result <- markerFst(genotypeMatrixA, genotypeMatrixB)

  expect_type(result, "list")
  expect_identical(sort(names(result)), c("perLocus", "pooledFst"))
  expect_true(is.numeric(result$perLocus))
  expect_identical(sort(names(result$perLocus)), c("L1", "L2"))
  expect_true(is.numeric(result$pooledFst))
  expect_length(result$pooledFst, 1L)

  expect_equal(result$perLocus[["L1"]], 58 / 1001, tolerance = 1e-6)
  expect_equal(result$perLocus[["L2"]], 139 / 308, tolerance = 1e-6)
  expect_equal(result$pooledFst, 614 / 2233, tolerance = 1e-6)
})

test_that("markerFst restricts to loci present in both centers' matrices", {
  ## matA has L1/L2; matB has L1/L3 -- only L1 is shared. L2 and L3 must not
  ## appear in the output at all (a plain locus-name intersection, not a
  ## warned/degenerate case).
  matA <- matrix(
    c("A/A", "A/A", "A/B", "A/B"),
    nrow = 2L, byrow = TRUE,
    dimnames = list(c("X1", "X2"), c("L1", "L2"))
  )
  matB <- matrix(
    c("A/B", "A/A", "B/B", "A/B"),
    nrow = 2L, byrow = TRUE,
    dimnames = list(c("Y1", "Y2"), c("L1", "L3"))
  )

  result <- markerFst(matA, matB)
  expect_identical(names(result$perLocus), "L1")
  expect_equal(result$perLocus[["L1"]], 0.2, tolerance = 1e-6)
  expect_equal(result$pooledFst, 0.2, tolerance = 1e-6)
})

test_that("markerFst excludes a locus with zero genotyped individuals in one center", {
  ## L1 is genotyped in both centers (same numbers as the intersection test
  ## above, Fst_L1 = 0.2); L2 is a column in both matrices, but entirely NA
  ## in matA -- zero genotyped individuals at that locus in Center A. That
  ## locus must be excluded (NA, not an error), and pooledFst must reflect
  ## only L1.
  matA <- matrix(
    c("A/A", NA_character_, "A/B", NA_character_),
    nrow = 2L, byrow = TRUE,
    dimnames = list(c("P1", "P2"), c("L1", "L2"))
  )
  matB <- matrix(
    c("A/B", "A/A", "B/B", "A/B"),
    nrow = 2L, byrow = TRUE,
    dimnames = list(c("Q1", "Q2"), c("L1", "L2"))
  )

  expect_warning(
    result <- markerFst(matA, matB),
    "L2"
  )
  expect_equal(result$perLocus[["L1"]], 0.2, tolerance = 1e-6)
  expect_true(is.na(result$perLocus[["L2"]]))
  expect_equal(result$pooledFst, 0.2, tolerance = 1e-6)
})

test_that("markerFst returns NA, not NaN, for a locus monomorphic in both centers", {
  ## Both centers fixed for allele "A" at L1 -- N_l = D_l = 0 exactly, an
  ## undefined 0/0 ratio, not a genuine zero-differentiation signal.
  matA <- matrix(
    c("A/A", "A/A"),
    nrow = 2L, byrow = TRUE,
    dimnames = list(c("M1", "M2"), "L1")
  )
  matB <- matrix(
    c("A/A", "A/A", "A/A"),
    nrow = 3L, byrow = TRUE,
    dimnames = list(c("N1", "N2", "N3"), "L1")
  )

  expect_warning(
    result <- markerFst(matA, matB),
    "L1"
  )
  expect_true(is.na(result$perLocus[["L1"]]))
  expect_false(is.nan(result$perLocus[["L1"]]))
  expect_true(is.na(result$pooledFst))
})

test_that("markerFst does not clamp a negative per-locus value", {
  ## Both centers at p = 0.5 exactly, small equal n -- the sampling-variance
  ## correction terms exceed the (zero) between-population term, producing a
  ## genuinely negative Fst (not an error, not clamped to 0).
  matA <- matrix(
    c("A/B", "A/B", "A/B", "A/B"),
    nrow = 4L, byrow = TRUE,
    dimnames = list(paste0("R", 1L:4L), "L1")
  )
  matB <- matrix(
    c("A/B", "A/B", "A/B", "A/B"),
    nrow = 4L, byrow = TRUE,
    dimnames = list(paste0("S", 1L:4L), "L1")
  )

  result <- markerFst(matA, matB)
  expect_true(result$perLocus[["L1"]] < 0)
  expect_equal(result$perLocus[["L1"]], -1 / 7, tolerance = 1e-6)
  expect_equal(result$pooledFst, -1 / 7, tolerance = 1e-6)
})
