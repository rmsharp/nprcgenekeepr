# Compute a descriptive, same-chromosome pairwise LD/block statistic

Estimates a descriptive linkage-disequilibrium (LD) block statistic (D',
a chi-squared-based generalization of r2) for every pair of loci on the
same chromosome (issue \#153, D3b). This is deliberately the
*secondary*, exploratory-use statistic in the design's two-metric pair –
[`markerRealizedRelatednessVariance`](https://github.com/rmsharp/nprcgenekeepr/reference/markerRealizedRelatednessVariance.md)
is the primary, genuinely pedigree-valid metric. No CRAN package is both
pedigree-aware and multiallelic-capable (issue \#153 design doc sec
2.12), so classical LD theory's random-mating assumption is a genuine,
documented compromise for a pedigreed colony sample (D8) – the `caveat`
column on every returned row is not decorative and must not be dropped.

## Usage

``` r
markerLdBlock(genotypeMatrix, locusMetadata, founderIds = NULL)
```

## Arguments

- genotypeMatrix:

  a character matrix as returned by
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md):
  rows are individual `id`s, columns are loci, and each cell is that
  individual's two alleles at that locus, sorted and joined by `"/"` (or
  `NA` if not genotyped at that locus).

- locusMetadata:

  dataframe as returned by
  [`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md):
  at least `locus` and `chrom` columns. Loci with `NA` `chrom` are
  excluded from pairing.

- founderIds:

  optional character vector of ids to which the computation should be
  restricted (e.g.
  [`getFounders`](https://github.com/rmsharp/nprcgenekeepr/reference/getFounders.md)`(ped)`);
  `NULL` (default) uses every individual in `genotypeMatrix`.

## Value

A dataframe with one row per same-chromosome locus pair: `locus1`,
`locus2`, `chrom`, `Dprime`, `r2`, `nUsed` (individuals genotyped at
both loci), `idsUsed` (comma-joined ids, populated only when
`founderIds` is supplied – `NA` otherwise), and `caveat` (a fixed,
non-droppable descriptive-statistic warning on every row).

## Details

Because the genotype matrix is unphased, `markerLdBlock` estimates
two-locus phase frequencies for each pair via a multiallelic
maximum-likelihood (EM) estimator, generalizing the classic biallelic
two-locus EM (Excoffier & Slatkin 1995) to arbitrary allele counts per
locus. Per-allele-pair D and its standardized D-prime use the classic
Lewontin (1964) standardization; the per-pair `Dprime` is Hedrick's
(1987) frequency-weighted average of the absolute standardized
per-allele-pair values across all allele pairs, and `r2` is a
chi-squared/Cramer's-phi-squared-style multiallelic generalization that
reduces exactly to the classic biallelic \\r^2\\ when both loci happen
to be biallelic.

Only same-chromosome locus pairs are computed – `locusMetadata`'s
`pos`/`cM` columns are not used (D2's own finding that locus-order
metadata is typically sparse or absent for real colony panels). A pair
with fewer than 2 individuals genotyped at both loci (after any
`founderIds` restriction) returns `NA` with a named warning, matching
[`markerFst`](https://github.com/rmsharp/nprcgenekeepr/reference/markerFst.md)'s
precedent for an insufficient-evidence pair – not a
[`stop()`](https://rdrr.io/r/base/stop.html).

## References

Excoffier, L., & Slatkin, M. (1995). Maximum-likelihood estimation of
molecular haplotype frequencies in a diploid population. *Molecular
Biology and Evolution*, 12(5), 921-927.
[doi:10.1093/oxfordjournals.molbev.a040269](https://doi.org/10.1093/oxfordjournals.molbev.a040269)

Hedrick, P. W. (1987). Gametic disequilibrium measures: proceed with
caution. *Genetics*, 117(2), 331-341.

Weir, B. S. (1996). *Genetic Data Analysis II: Methods for Discrete
Population Genetic Data*. Sinauer Associates.

## See also

[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md),
[`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md),
[`markerRealizedRelatednessVariance`](https://github.com/rmsharp/nprcgenekeepr/reference/markerRealizedRelatednessVariance.md),
[`obfuscateLdBlocks`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md)

## Examples

``` r
library(nprcgenekeepr)
genotype <- checkLinkageMarkerGenotypeFile(data.frame(
  id = rep(c("W", "X", "Y", "Z"), 2),
  locus = rep(c("L1", "L2"), each = 4),
  allele1 = c("A", "A", "A", "A", "M", "M", "N", "N"),
  allele2 = c("A", "B", "A", "B", "M", "N", "M", "N"),
  stringsAsFactors = FALSE
))
genotypeMatrix <- buildMarkerGenotypeMatrix(genotype)
locusMetadata <- checkLocusMetadata(data.frame(
  locus = c("L1", "L2"), chrom = c("1", "1"), pos = c(NA, NA),
  stringsAsFactors = FALSE
))
markerLdBlock(genotypeMatrix, locusMetadata)
#>   locus1 locus2 chrom Dprime        r2 nUsed idsUsed
#> 1     L1     L2     1      1 0.3333333     4    <NA>
#>                                                                                                                                                                                                                                                      caveat
#> 1 Descriptive statistic only -- not a rigorous, pedigree-aware LD-block measure. Classical linkage-disequilibrium theory assumes random mating, which a pedigreed colony violates; prefer markerRealizedRelatednessVariance() for pedigree-valid estimates.
```
