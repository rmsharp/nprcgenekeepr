# Compute genomic Runs of Homozygosity (ROH) and F_ROH

Computes per-individual genomic Runs of Homozygosity (ROH) segments and
the genomic inbreeding coefficient F_ROH from a sequence-scale marker
genotype matrix (issue \#152 Slice 3, design decision D6) – a
sequence-verified inbreeding estimate independent of (often incomplete)
pedigree records, complementing rather than duplicating this package's
existing pedigree-based kinship/founder metrics.

## Usage

``` r
computeGenomicROH(genotypeMatrix, locusMetadata, minSnp = 50L, minBp = 1e+06)
```

## Arguments

- genotypeMatrix:

  a character matrix as returned by
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md):
  rows are individual `id`s, columns are loci, and each cell is that
  individual's two alleles at that locus, sorted and joined by `"/"`
  (e.g. `"A/B"`), or `NA` if not genotyped at that locus.

- locusMetadata:

  dataframe with locus metadata (see
  [`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)):
  `locus`, `chrom`, `pos`, and optionally `cM`, one row per locus.
  Required – absent or `NULL` triggers an early
  [`stop()`](https://rdrr.io/r/base/stop.html) rather than a silent
  `NA`.

- minSnp:

  integer minimum number of consecutive homozygous loci required for a
  run to qualify as an ROH segment. Default `50L`, scaled down from
  PLINK's own literal default (`100`) for this package's sparser
  sparse/GBS-scale target tier (design doc D1).

- minBp:

  numeric minimum base-pair span (last locus `pos` minus first locus
  `pos`) required for a run to qualify as an ROH segment. Default `1e6`
  (1 Mb), matching PLINK's own `--homozyg-kb` default and Ceballos et
  al. (2018)'s commonly-cited ROH-calling threshold.

## Value

A per-individual dataframe: `id`, `nSegments` (count of qualifying ROH
segments), `totalRohLength` (their summed bp span), and `fRoh` (the
genomic inbreeding coefficient, or `NA` if `genomeLength` is 0).

## Details

Within each chromosome, loci are ordered by `pos`. A "run" is a maximal,
gapless stretch of homozygous, non-missing genotyped loci – both a
heterozygous call and a missing (`NA`) call end the current run. A run
qualifies as an ROH segment only if it has at least `minSnp` loci AND
spans at least `minBp` base pairs (the field-standard dual threshold,
matching PLINK's `--homozyg-snp`/ `--homozyg-kb`, Purcell et al. 2007) –
either condition alone is not sufficient. `totalRohLength` sums the
qualifying segments' spans across all chromosomes; `fRoh` divides that
sum by `genomeLength`, a single value shared across every individual:
the sum, per chromosome, of `(max(pos) - min(pos))` among the
full-coverage loci in `locusMetadata` (Ceballos et al. 2018's
\\L\_{autosome}\\ convention). A fixed, shared denominator keeps `fRoh`
comparable across a cohort and avoids conflating an individual's own
missingness with inbreeding.

Only loci with full `locusMetadata` coverage (both `chrom` and `pos`
present, per
[`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)'s
own three-tier classification) can be placed in the ordered walk; a
locus lacking full coverage, or entirely absent from `locusMetadata`, is
excluded from both the walk and the `genomeLength` denominator, with a
warning naming it – it is never treated as a run-breaking gap. When
every chromosome has at most one full-coverage locus, `genomeLength` is
0 and `fRoh` is an undefined `0/0` ratio: `NA` with a warning, not `NaN`
silently, mirroring
[`markerFst`](https://github.com/rmsharp/nprcgenekeepr/reference/markerFst.md)'s
own undefined-ratio precedent.

## References

Ceballos, F. C., Joshi, P. K., Clark, D. W., Ramsay, M., & Wilson, J. F.
(2018). Runs of homozygosity: windows into population history and trait
architecture. *Nature Reviews Genetics*, 19(4), 220-234.
[doi:10.1038/nrg.2017.109](https://doi.org/10.1038/nrg.2017.109)

Purcell, S., et al. (2007). PLINK: a tool set for whole-genome
association and population-based linkage analyses. *American Journal of
Human Genetics*, 81(3), 559-575.
[doi:10.1086/519795](https://doi.org/10.1086/519795)

## See also

[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md),
[`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md),
[`checkSequenceGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSequenceGenotypeFile.md)

## Examples

``` r
library(nprcgenekeepr)
locusMetadata <- data.frame(
  locus = c("L1", "L2", "L3", "L4"),
  chrom = c("1", "1", "1", "1"),
  pos = c(0, 400000, 900000, 1400000),
  stringsAsFactors = FALSE
)
genotypeMatrix <- matrix(
  c("A/A", "A/A", "A/B", "A/A"),
  nrow = 1L, dimnames = list("Animal1", locusMetadata$locus)
)
computeGenomicROH(genotypeMatrix, locusMetadata, minSnp = 2L, minBp = 300000)
#>        id nSegments totalRohLength      fRoh
#> 1 Animal1         1          4e+05 0.2857143
```
