## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Generate the issue #153 Slice 1 multiallelic STR marker fixture pair:
#'   inst/extdata/examples/example_locus_metadata.csv
#'   inst/extdata/examples/example_str_marker_genotypes.csv
#'
#' A new, realistic multiallelic Short Tandem Repeat (STR) marker panel and
#' its locus-metadata sidecar (docs/planning/
#' issue153-linkage-haplotype-block-metrics-plan.md sec 5 Slice 1). No
#' bundled fixture exercises the long-format multi-locus schema (id, locus,
#' allele1, allele2) at multiallelic, panel scale -- sec 2.8 of the design
#' doc confirms the only existing bundled genotype fixture
#' (obfuscated_rhesus_mhc_breeder_genotypes.csv) is single-locus and
#' biallelic-only.
#'
#' Panel shape modeled on de Groot et al. 2025 (Ecology and Evolution
#' 15(4):e71216) -- 23 microsatellite markers across 15 of 20 rhesus
#' autosomes, mapped for chromosome + approximate position, no cM data --
#' scaled down to 12 loci / 8 chromosomes for a manageable committed
#' fixture. This is FABRICATED data (synthetic individual ids, synthetic
#' allele values): only the realistic SHAPE (marker count, chromosome
#' spread, allele-count distribution, coverage sparsity) is modeled on the
#' published panel, not its literal genotypes, avoiding any licensing
#' question around redistributing real published data (design doc sec 7
#' Dragon 2).
#'
#' Coverage mix (D2's three-tier definition): 8 of 12 loci "full" (chrom +
#' pos, no cM -- matching de Groot's own real-world coverage shape); 2
#' "partial" (chrom only); 2 "none" (neither) -- deliberately exercising
#' every tier so checkLocusMetadata()'s classifier is proven against a
#' realistic-shaped mix, not just a synthetic edge case.
#'
#' Genotypes: 10 individuals x 12 loci, STR-style repeat-length alleles
#' (even bp values), allele pools of size 2-5 per locus. Genotypes are
#' drawn via set_seed(153L) (issue-number-tied, matching the
#' set_seed()/createPedOne()/createPedSix() convention) -- this is
#' genuinely fabricated data with no real relationships to preserve, unlike
#' the twin-fixture precedent's real-sibling selection, so a seeded random
#' draw (rather than a fully hand-typed table) is the appropriate
#' generation method here.
#'
#' Validated against checkLocusMetadata() and round-tripped through
#' buildMarkerGenotypeMatrix() before being written, so the fixture is
#' guaranteed to load cleanly and pass validation (design doc sec 5 Slice 1
#' DONE criteria) -- matching generate_twin_fixtures.R's own
#' fail-loudly-at-generation-time discipline. Deliberately NOT run through
#' checkMarkerGenotypeFile(), which would reject it -- the multiallelic-
#' tolerant sibling validator is Slice 2's job, not this one's.
#'
#' Run from the package root (after devtools::load_all() or an installed
#' build, since it calls checkLocusMetadata()/buildMarkerGenotypeMatrix()/
#' set_seed()):
#'   Rscript data-raw/generate_str_fixtures.R

pkgload::load_all(".", quiet = TRUE)

loci <- sprintf("STR%02d", 1L:12L)

## Loci 1-8: full coverage (chrom + pos, no cM). Loci 9-10: partial
## (chrom only). Loci 11-12: none (neither).
locusMetadata <- data.frame(
  locus = loci,
  chrom = c("1", "1", "2", "2", "3", "4", "5", "6", "7", "8", NA, NA),
  pos = c(15234567L, 48213890L, 9876543L, 112233445L, 33445566L, 77889900L,
          11223344L, 99887766L, NA, NA, NA, NA),
  cM = NA_real_,
  stringsAsFactors = FALSE
)

## Fail loudly at generation time if the fixture is ever inconsistent with
## checkLocusMetadata()'s own rules -- the fixture must always be valid.
checkedLocusMetadata <- checkLocusMetadata(locusMetadata)
tiers <- c("full", "partial", "none")
coverageCounts <- table(checkedLocusMetadata$coverage)[tiers]
stopifnot(identical(as.integer(coverageCounts), c(8L, 2L, 2L)))

ids <- sprintf("A%02d", 1L:10L)

## Allele pools, STR-style repeat-length values (even bp). STR03 and STR07
## are deliberately given 4-5 distinct alleles so the panel is provably
## multiallelic (>= 2 loci with 3+ observed alleles) regardless of which
## values the seeded draw below happens to pick.
allelePools <- list(
  STR01 = c("142", "146"),
  STR02 = c("120", "124", "128"),
  STR03 = c("200", "204", "208", "212"),
  STR04 = c("158", "162"),
  STR05 = c("176", "180", "184"),
  STR06 = c("140", "144"),
  STR07 = c("220", "224", "228", "232", "236"),
  STR08 = c("110", "114"),
  STR09 = c("190", "194"),
  STR10 = c("166", "170", "174"),
  STR11 = c("130", "134"),
  STR12 = c("150", "154", "158")
)

set_seed(153L)
genotype <- do.call(rbind, lapply(loci, function(locus) {
  pool <- allelePools[[locus]]
  data.frame(
    id = ids,
    locus = locus,
    allele1 = sample(pool, length(ids), replace = TRUE),
    allele2 = sample(pool, length(ids), replace = TRUE),
    stringsAsFactors = FALSE
  )
}))
rownames(genotype) <- NULL

## Confirm genuinely multiallelic (>= 2 loci with 3+ distinct alleles
## observed across the panel) and that it pivots through the existing,
## UNMODIFIED buildMarkerGenotypeMatrix() (design doc sec 5 Slice 1 DONE
## criteria).
alleleCounts <- tapply(
  c(genotype$allele1, genotype$allele2),
  rep(genotype$locus, 2L),
  function(a) length(unique(a[!is.na(a)]))
)
stopifnot(sum(alleleCounts > 2L) >= 2L)

mat <- buildMarkerGenotypeMatrix(genotype)
stopifnot(identical(dim(mat), c(10L, 12L)))

write.csv(
  checkedLocusMetadata[, c("locus", "chrom", "pos", "cM")],
  file.path("inst", "extdata", "examples", "example_locus_metadata.csv"),
  row.names = FALSE, na = "NA"
)

write.csv(
  genotype,
  file.path("inst", "extdata", "examples",
            "example_str_marker_genotypes.csv"),
  row.names = FALSE, na = "NA"
)
