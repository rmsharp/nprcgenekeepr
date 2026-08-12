## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Generate the issue #152 Slice 1 sequence-scale biallelic marker fixture
#' pair:
#'   inst/extdata/examples/example_sequence_locus_metadata.csv
#'   inst/extdata/examples/example_sequence_genotypes.csv
#'
#' A new, synthetic sequence-scale SNP panel and its locus-metadata sidecar
#' (docs/planning/issue152-sequence-input-genetic-metrics-plan.md sec 5
#' Slice 1). Sized to D1's lower-middle scope-tier range (this session's own
#' PRE-RED AskUserQuestion, weighed against every existing bundled fixture
#' topping out at 271 KB): 50 individuals x 1,000 loci (50,000 genotype
#' rows), spread across 20 chromosomes (rhesus macaque autosome count),
#' 50 loci per chromosome.
#'
#' This is FABRICATED data (synthetic individual ids, synthetic positions,
#' synthetic allele calls) -- no real panel or published position data is
#' reproduced, avoiding any licensing question (mirrors
#' generate_str_fixtures.R's own Dragon 2 precedent). Alleles are drawn from
#' 4 realistic SNP transition/transversion pairs (A/G, C/T, A/C, G/T),
#' cycled across loci; positions ascend within each chromosome via
#' cumulative random gaps (10-500 kb), a plausible SNP-panel marker density.
#'
#' locusMetadata is deliberately 100% "full" coverage throughout (unlike
#' issue #153's own STR fixture, which deliberately models a realistic
#' sparse mix) -- this fixture's own stated purpose is scale/performance
#' exercise (Slice 2) and reuse by the future F_ROH metric (Slice 3), which
#' needs position data for every locus to define contiguous homozygous
#' runs; sparse coverage would silently narrow what later slices can test
#' against it.
#'
#' Genotypes carry a ~2% per-allele-call no-call (NA) rate, a realistic
#' sparse-missingness level for a genotyped SNP panel -- deliberately never
#' a literal "." (that placeholder is Slice 1's own rejected-input case,
#' proven against a small inline fixture in
#' tests/testthat/test_checkSequenceGenotypeFile.R, not this committed one).
#'
#' Validated against checkLocusMetadata(), checkSequenceGenotypeFile(), and
#' buildMarkerGenotypeMatrix() before being written, so the fixture is
#' guaranteed to load cleanly and pass validation (design doc sec 5 Slice 1
#' DONE criteria: "the fixture is reusable by every later slice") -- matching
#' generate_str_fixtures.R's own fail-loudly-at-generation-time discipline.
#'
#' Run from the package root (after devtools::load_all() or an installed
#' build, since it calls checkLocusMetadata()/checkSequenceGenotypeFile()/
#' buildMarkerGenotypeMatrix()/set_seed()):
#'   Rscript data-raw/generate_sequence_fixtures.R

pkgload::load_all(".", quiet = TRUE)

nIndividuals <- 50L
nLoci <- 1000L
nChrom <- 20L
lociPerChrom <- nLoci / nChrom

ids <- sprintf("S%03d", seq_len(nIndividuals))
loci <- sprintf("SNP%04d", seq_len(nLoci))
chrom <- rep(as.character(seq_len(nChrom)), each = lociPerChrom)

set_seed(152L)

## Positions ascend within each chromosome via cumulative random gaps
## (10 kb-500 kb spacing), a plausible SNP-panel marker density, offset so
## every chromosome starts past 1 Mb (avoids an unrealistic pos = 0).
pos <- unlist(lapply(seq_len(nChrom), function(i) {
  gaps <- sample(10000L:500000L, lociPerChrom, replace = TRUE)
  cumsum(gaps) + 1000000L
}))

locusMetadata <- data.frame(
  locus = loci,
  chrom = chrom,
  pos = pos,
  cM = NA_real_,
  stringsAsFactors = FALSE
)

## Fail loudly at generation time if the fixture is ever inconsistent with
## checkLocusMetadata()'s own rules -- the fixture must always be valid, and
## must always be 100% "full" coverage (see the file-level comment above).
checkedLocusMetadata <- checkLocusMetadata(locusMetadata)
stopifnot(checkedLocusMetadata$coverage == "full")

## Biallelic allele pools, cycling through 4 realistic SNP transition/
## transversion pairs.
allelePairs <- list(c("A", "G"), c("C", "T"), c("A", "C"), c("G", "T"))
locusAlleles <- allelePairs[((seq_len(nLoci) - 1L) %% 4L) + 1L]
names(locusAlleles) <- loci

genotype <- do.call(rbind, lapply(loci, function(locus) {
  pool <- locusAlleles[[locus]]
  allele1 <- sample(pool, nIndividuals, replace = TRUE)
  allele2 <- sample(pool, nIndividuals, replace = TRUE)
  ## ~2% no-call rate per allele call.
  missing1 <- sample(c(TRUE, FALSE), nIndividuals, replace = TRUE,
                      prob = c(0.02, 0.98))
  missing2 <- sample(c(TRUE, FALSE), nIndividuals, replace = TRUE,
                      prob = c(0.02, 0.98))
  allele1[missing1] <- NA
  allele2[missing2] <- NA
  data.frame(id = ids, locus = locus, allele1 = allele1, allele2 = allele2,
             stringsAsFactors = FALSE)
}))
rownames(genotype) <- NULL

## Confirm biallelic throughout (guaranteed by construction, proven anyway)
## and that it validates via the new checkSequenceGenotypeFile() (including
## its optional locusMetadata cross-validation) and pivots through the
## existing, UNMODIFIED buildMarkerGenotypeMatrix() -- design doc sec 5
## Slice 1 DONE criteria.
checkedGenotype <- checkSequenceGenotypeFile(
  genotype,
  locusMetadata = checkedLocusMetadata[, c("locus", "chrom", "pos", "cM")]
)
stopifnot(identical(nrow(checkedGenotype), nIndividuals * nLoci))

mat <- buildMarkerGenotypeMatrix(checkedGenotype)
stopifnot(identical(dim(mat), c(nIndividuals, nLoci)))

write.csv(
  checkedLocusMetadata[, c("locus", "chrom", "pos", "cM")],
  file.path("inst", "extdata", "examples",
            "example_sequence_locus_metadata.csv"),
  row.names = FALSE, na = "NA"
)

write.csv(
  genotype,
  file.path("inst", "extdata", "examples", "example_sequence_genotypes.csv"),
  row.names = FALSE, na = "NA"
)
