## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #152 Slice 3): computeGenomicROH() computes genomic Runs of
## Homozygosity (ROH) and the genomic inbreeding coefficient F_ROH from a
## sequence-scale marker genotype matrix, per Ceballos, Joshi, Clark, Ramsay
## & Wilson (2018, Nature Reviews Genetics 19:220-234, the standard ROH/F_ROH
## review) and PLINK's own field-standard dual-threshold ROH-calling
## convention (Purcell et al. 2007, --homozyg-snp / --homozyg-kb).
##
## Algorithm (design doc docs/planning/issue152-sequence-input-genetic
## -metrics-plan.md section 3 D6, section 4, section 5 Slice 3; three
## judgment calls ratified via AskUserQuestion at this slice's own Pre-RED):
##
##   1. Restrict to loci with FULL locusMetadata coverage (both chrom and
##      pos present, per checkLocusMetadata()'s own three-tier
##      classification) -- a locus missing chrom/pos, or entirely absent
##      from locusMetadata, cannot be placed in the ordered walk and is
##      excluded (with a warning naming it), not treated as a run-breaking
##      event.
##   2. Within each chromosome, order the remaining full-coverage loci by
##      pos. Walk each individual's genotypes in that order. A "run" is a
##      maximal, gapless stretch of homozygous, non-missing genotyped loci
##      -- BOTH a heterozygous call and a missing (NA) call end the current
##      run.
##   3. A run qualifies as an ROH segment only if it has AT LEAST minSnp
##      loci AND spans AT LEAST minBp base pairs (span = pos of the run's
##      last locus - pos of its first locus) -- the field-standard dual
##      threshold; either condition alone is not sufficient.
##   4. totalRohLength (per individual) = sum of qualifying segments' spans,
##      summed across all chromosomes. nSegments = count of qualifying
##      segments.
##   5. F_ROH = totalRohLength / genomeLength, where genomeLength is a
##      SINGLE value shared across every individual: the sum, per
##      chromosome, of (max pos - min pos) among the full-coverage loci in
##      locusMetadata -- matching Ceballos et al. 2018's L_autosome
##      convention (a fixed denominator keeps F_ROH comparable across a
##      cohort and avoids conflating an individual's own missingness with
##      inbreeding). A zero genomeLength (e.g. every chromosome has only one
##      full-coverage locus) makes F_ROH an undefined 0/0 ratio -- NA with a
##      warning, not NaN silently, mirroring markerFst()'s own
##      undefined-ratio precedent.
##   6. Defaults: minSnp = 50L, minBp = 1e6 (1 Mb) -- 1 Mb matches PLINK's
##      own --homozyg-kb default and Ceballos et al. 2018's commonly-cited
##      ROH-calling threshold; 50 SNPs is scaled down from PLINK's literal
##      default (100) for this package's sparser ~1,000-50,000-locus
##      sparse/GBS-scale target tier (design doc D1).
##
## Expected values below were derived independently by hand from the
## fixture's own literal locus positions (not this package's planned code)
## -- exact integer/fraction arithmetic wherever possible, matching
## test_markerFst.R's own convention.

## ---------------------------------------------------------------------
## Core fixture: 3 individuals x 2 chromosomes (9 loci total), explicit
## non-default minSnp/minBp so a small, hand-verifiable fixture can still
## produce real (non-trivial) ROH segments.
## ---------------------------------------------------------------------
coreLocusMetadata <- data.frame(
  locus = c("L1", "L2", "L3", "L4", "L5", "L6", "L7", "L8", "L9"),
  chrom = c("1", "1", "1", "1", "1", "1", "2", "2", "2"),
  pos = c(0, 300000, 700000, 1100000, 1500000, 2000000, 0, 400000, 900000),
  stringsAsFactors = FALSE
)

## Chrom "1" full-coverage span: 2,000,000 - 0 = 2,000,000
## Chrom "2" full-coverage span:   900,000 - 0 =   900,000
## genomeLength (shared) = 2,900,000

coreGenotypeMatrix <- matrix(
  c(
    ## L1       L2      L3      L4      L5      L6      L7      L8      L9
    "A/A", "A/A", "A/A", "A/A", "A/B", "B/B", "A/A", "A/A", "A/A", # I1
    "A/A", "A/A", NA, "A/A", "A/B", "B/B", "A/B", "A/A", "A/A", # I2
    "A/A", "A/A", "A/A", "A/A", "A/A", "A/A", "A/A", "A/A", "A/A" # I3
  ),
  nrow = 3L, byrow = TRUE,
  dimnames = list(c("I1", "I2", "I3"), coreLocusMetadata$locus)
)

test_that("computeGenomicROH matches hand-verified segments/F_ROH for a multi-chromosome, multi-individual fixture", {
  ## I1, chrom 1: L1-L4 homozygous (4 SNPs, span 1,100,000) qualifies
  ## (minSnp=3, minBp=1,000,000); L5 heterozygous breaks the run; L6
  ## homozygous but isolated (1 SNP < 3) does not qualify.
  ## I1, chrom 2: L7-L9 all homozygous (3 SNPs >= 3) but span only 900,000
  ## < 1,000,000 -- fails the bp threshold, 0 segments (dual-threshold).
  ## I1 totals: nSegments=1, totalRohLength=1,100,000,
  ##   fRoh = 1,100,000 / 2,900,000 = 11/29.
  ##
  ## I2, chrom 1: L3 is missing -- L1-L2 (2 SNPs < 3) too short; L4 isolated
  ## (1 SNP) too short; L5 heterozygous, L6 isolated (1 SNP) too short.
  ## I2, chrom 2: L7 heterozygous; L8-L9 homozygous (2 SNPs < 3) too short.
  ## I2 totals: nSegments=0, totalRohLength=0, fRoh=0.
  ##
  ## I3: every locus on both chromosomes is homozygous.
  ## chrom 1: 6 SNPs, span 2,000,000 -- qualifies (>= 3 SNPs, >= 1,000,000).
  ## chrom 2: 3 SNPs, span 900,000 -- fails the bp threshold, as for I1.
  ## I3 totals: nSegments=1, totalRohLength=2,000,000,
  ##   fRoh = 2,000,000 / 2,900,000 = 20/29.
  result <- computeGenomicROH(coreGenotypeMatrix, coreLocusMetadata,
                               minSnp = 3L, minBp = 1000000)

  expect_s3_class(result, "data.frame")
  expect_identical(sort(names(result)),
                    sort(c("id", "nSegments", "totalRohLength", "fRoh")))
  expect_identical(sort(result$id), c("I1", "I2", "I3"))

  byId <- function(col) stats::setNames(result[[col]], result$id)

  expect_equal(byId("nSegments")[["I1"]], 1L)
  expect_equal(byId("totalRohLength")[["I1"]], 1100000)
  expect_equal(byId("fRoh")[["I1"]], 11 / 29, tolerance = 1e-6)

  expect_equal(byId("nSegments")[["I2"]], 0L)
  expect_equal(byId("totalRohLength")[["I2"]], 0)
  expect_equal(byId("fRoh")[["I2"]], 0, tolerance = 1e-6)

  expect_equal(byId("nSegments")[["I3"]], 1L)
  expect_equal(byId("totalRohLength")[["I3"]], 2000000)
  expect_equal(byId("fRoh")[["I3"]], 20 / 29, tolerance = 1e-6)
})

test_that("computeGenomicROH treats a heterozygous genotype as ending a run", {
  ## Without the L3 break, L1-L4 would span 1,400,000 (4 SNPs). The
  ## heterozygous call at L3 must cut the qualifying run down to L1-L2
  ## only (2 SNPs, span 400,000) -- proving the break, not just that SOME
  ## segment is found.
  locusMetadata <- data.frame(
    locus = c("L1", "L2", "L3", "L4"),
    chrom = c("1", "1", "1", "1"),
    pos = c(0, 400000, 900000, 1400000),
    stringsAsFactors = FALSE
  )
  genotypeMatrix <- matrix(
    c("A/A", "A/A", "A/B", "A/A"),
    nrow = 1L, dimnames = list("X1", locusMetadata$locus)
  )

  result <- computeGenomicROH(genotypeMatrix, locusMetadata,
                               minSnp = 2L, minBp = 300000)

  expect_equal(result$nSegments[result$id == "X1"], 1L)
  expect_equal(result$totalRohLength[result$id == "X1"], 400000)
  ## genomeLength = 1,400,000 - 0 = 1,400,000; fRoh = 400,000/1,400,000 = 2/7.
  expect_equal(result$fRoh[result$id == "X1"], 2 / 7, tolerance = 1e-6)
})

test_that("computeGenomicROH treats a missing genotype as ending a run", {
  ## Identical layout/thresholds to the heterozygous-break test above,
  ## with L3 missing (NA) instead of heterozygous -- must produce the
  ## identical result, proving missingness ends a run exactly like
  ## heterozygosity does.
  locusMetadata <- data.frame(
    locus = c("L1", "L2", "L3", "L4"),
    chrom = c("1", "1", "1", "1"),
    pos = c(0, 400000, 900000, 1400000),
    stringsAsFactors = FALSE
  )
  genotypeMatrix <- matrix(
    c("A/A", "A/A", NA, "A/A"),
    nrow = 1L, dimnames = list("X1", locusMetadata$locus)
  )

  result <- computeGenomicROH(genotypeMatrix, locusMetadata,
                               minSnp = 2L, minBp = 300000)

  expect_equal(result$nSegments[result$id == "X1"], 1L)
  expect_equal(result$totalRohLength[result$id == "X1"], 400000)
  expect_equal(result$fRoh[result$id == "X1"], 2 / 7, tolerance = 1e-6)
})

test_that("computeGenomicROH excludes a locus without full locusMetadata coverage, with a warning", {
  ## L2 has chrom but no pos (checkLocusMetadata()'s "partial" tier) --
  ## must be dropped from BOTH the per-chromosome walk and the genomeLength
  ## denominator, not treated as a run-breaking gap. After dropping L2, the
  ## walk is just L1 (pos 0) then L3 (pos 1,200,000): both homozygous, 2
  ## SNPs >= minSnp(2), span 1,200,000 >= minBp(1,000,000) -- qualifies.
  ## genomeLength = 1,200,000 - 0 = 1,200,000 (L2 excluded here too), so
  ## fRoh = 1,200,000/1,200,000 = 1 exactly.
  locusMetadata <- data.frame(
    locus = c("L1", "L2", "L3"),
    chrom = c("1", "1", "1"),
    pos = c(0, NA, 1200000),
    stringsAsFactors = FALSE
  )
  genotypeMatrix <- matrix(
    c("A/A", "A/A", "A/A"),
    nrow = 1L, dimnames = list("Y1", locusMetadata$locus)
  )

  expect_warning(
    result <- computeGenomicROH(genotypeMatrix, locusMetadata,
                                 minSnp = 2L, minBp = 1000000),
    "L2"
  )
  expect_equal(result$nSegments[result$id == "Y1"], 1L)
  expect_equal(result$totalRohLength[result$id == "Y1"], 1200000)
  expect_equal(result$fRoh[result$id == "Y1"], 1, tolerance = 1e-6)
})

test_that("computeGenomicROH requires BOTH the minSnp and minBp thresholds to be met", {
  ## Scenario A: enough SNPs (3 >= 3), not enough bp span (200,000 <
  ## 1,000,000) -- must NOT qualify.
  locusMetadataA <- data.frame(
    locus = c("M1", "M2", "M3"),
    chrom = c("1", "1", "1"),
    pos = c(0, 100000, 200000),
    stringsAsFactors = FALSE
  )
  genotypeMatrixA <- matrix(
    c("A/A", "A/A", "A/A"),
    nrow = 1L, dimnames = list("Z1", locusMetadataA$locus)
  )
  resultA <- computeGenomicROH(genotypeMatrixA, locusMetadataA,
                                minSnp = 3L, minBp = 1000000)
  expect_equal(resultA$nSegments[resultA$id == "Z1"], 0L)
  expect_equal(resultA$totalRohLength[resultA$id == "Z1"], 0)

  ## Scenario B: enough bp span (2,000,000 >= 1,000,000), not enough SNPs
  ## (2 < 3) -- must NOT qualify.
  locusMetadataB <- data.frame(
    locus = c("N1", "N2"),
    chrom = c("1", "1"),
    pos = c(0, 2000000),
    stringsAsFactors = FALSE
  )
  genotypeMatrixB <- matrix(
    c("A/A", "A/A"),
    nrow = 1L, dimnames = list("Z2", locusMetadataB$locus)
  )
  resultB <- computeGenomicROH(genotypeMatrixB, locusMetadataB,
                                minSnp = 3L, minBp = 1000000)
  expect_equal(resultB$nSegments[resultB$id == "Z2"], 0L)
  expect_equal(resultB$totalRohLength[resultB$id == "Z2"], 0)
})

test_that("computeGenomicROH returns zero, not an error or warning, for an individual with no qualifying ROH", {
  ## Every locus heterozygous -- no homozygous run can ever form. A valid,
  ## nonzero genomeLength denominator makes fRoh a real 0, not an
  ## undefined/NA ratio, and no warning should fire for this ordinary case.
  locusMetadata <- data.frame(
    locus = c("P1", "P2", "P3"),
    chrom = c("1", "1", "1"),
    pos = c(0, 500000, 1500000),
    stringsAsFactors = FALSE
  )
  genotypeMatrix <- matrix(
    c("A/B", "A/B", "A/B"),
    nrow = 1L, dimnames = list("W1", locusMetadata$locus)
  )

  expect_no_warning(
    result <- computeGenomicROH(genotypeMatrix, locusMetadata,
                                 minSnp = 2L, minBp = 300000)
  )
  expect_equal(result$nSegments[result$id == "W1"], 0L)
  expect_equal(result$totalRohLength[result$id == "W1"], 0)
  expect_equal(result$fRoh[result$id == "W1"], 0, tolerance = 1e-6)
})

test_that("computeGenomicROH requires locusMetadata -- stop()s when absent or NULL", {
  genotypeMatrix <- matrix(
    "A/A", nrow = 1L, dimnames = list("V1", "Q1")
  )

  expect_error(computeGenomicROH(genotypeMatrix), "locusMetadata")
  expect_error(computeGenomicROH(genotypeMatrix, locusMetadata = NULL),
               "locusMetadata")
})

test_that("computeGenomicROH warns and returns NA fRoh when genomeLength is zero", {
  ## Every chromosome has exactly one full-coverage locus, so its own span
  ## (max pos - min pos) is 0 -- genomeLength sums to 0 across chromosomes,
  ## an undefined 0/0 ratio for fRoh (NA, not NaN, with a warning), even
  ## though nSegments/totalRohLength are still well-defined zeros.
  locusMetadata <- data.frame(
    locus = c("Q1", "R1"),
    chrom = c("1", "2"),
    pos = c(0, 500000),
    stringsAsFactors = FALSE
  )
  genotypeMatrix <- matrix(
    c("A/A", "A/A"),
    nrow = 1L, dimnames = list("V1", locusMetadata$locus)
  )

  expect_warning(
    result <- computeGenomicROH(genotypeMatrix, locusMetadata,
                                 minSnp = 2L, minBp = 1000000),
    "genome"
  )
  expect_equal(result$nSegments[result$id == "V1"], 0L)
  expect_equal(result$totalRohLength[result$id == "V1"], 0)
  expect_true(is.na(result$fRoh[result$id == "V1"]))
  expect_false(is.nan(result$fRoh[result$id == "V1"]))
})

test_that("computeGenomicROH defaults to minSnp = 50L and minBp = 1e6", {
  ## Reuses the core fixture (I1's chrom-1 run is only 4 SNPs spanning
  ## 1,100,000; I3's is 6 SNPs spanning 2,000,000) -- both clear the
  ## 1,000,000 bp default but neither reaches 50 SNPs, so under the
  ## function's OWN defaults (no minSnp/minBp supplied) every individual
  ## must get zero segments, unlike the explicit minSnp=3 core test above.
  result <- computeGenomicROH(coreGenotypeMatrix, coreLocusMetadata)

  expect_true(all(result$nSegments == 0L))
  expect_true(all(result$totalRohLength == 0))
  expect_true(all(result$fRoh == 0))
})
