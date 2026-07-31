# Estimate pairwise kinship directly from marker genotypes (KING-robust)

Estimates a marker-based kinship matrix, independent of pedigree, using
the "between-family" KING-robust estimator of Manichaikul et al. (2010),
Equation 11 – the estimator KING, PLINK2, `SNPRelate::snpgdsIBDKING`,
and `GENESIS::kingToMatrix` all implement under the name "KING-robust".
Unlike
[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
(which is purely pedigree-derived), this function never looks at
parentage – it is a genotype-only check, matching the issue's own
framing of an independent relatedness estimate.

## Usage

``` r
markerKinship(genotypeMatrix)
```

## Arguments

- genotypeMatrix:

  a character matrix as returned by
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md):
  rows are individual `id`s, columns are loci, and each cell is that
  individual's two alleles at that locus, sorted and joined by `"/"` (or
  `NA` if not genotyped at that locus).

## Value

A numeric `id` x `id` matrix (symmetric, diagonal `0.5`), the same shape
[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
returns.

## Details

For a pair of individuals \\i, j\\, over the loci genotyped in both:
\$\$\hat\phi\_{ij} = 0.5 + \frac{2 N\_{AaAa} - 4 N\_{AAaa} -
N\_{Aa}^{(i)} - N\_{Aa}^{(j)}}{4 \min(N\_{Aa}^{(i)}, N\_{Aa}^{(j)})}\$\$
where \\N\_{AaAa}\\ counts loci at which both individuals are
heterozygous, \\N\_{AAaa}\\ counts loci at which they have opposite
homozygous genotypes (identity-by-state 0), and \\N\_{Aa}^{(i)}\\/
\\N\_{Aa}^{(j)}\\ count each individual's own heterozygous loci (all
restricted to the shared, jointly-non-missing locus set). The estimator
requires biallelic markers (see
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md))
and is not bounded below by zero – a negative estimate is informative
(more divergent ancestry than the reference sample), not an error, and
is not clipped.

The diagonal is set to `0.5` by definition (self-kinship), matching
[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)'s
convention, rather than evaluated from the formula above – which divides
by zero whenever an individual has no heterozygous loci at all.

When neither individual in a pair has a shared heterozygous locus (the
formula's denominator is zero), the pair's kinship is undefined; that
pair's entry is `NA` and a warning names the pair.

## References

Manichaikul, A., Mychaleckyj, J. C., Rich, S. S., Daly, K., Sale, M., &
Chen, W.-M. (2010). Robust relationship inference in genome-wide
association studies. *Bioinformatics*, 26(22), 2867-2873.
[doi:10.1093/bioinformatics/btq559](https://doi.org/10.1093/bioinformatics/btq559)

## See also

[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md),
[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)

## Examples

``` r
library(nprcgenekeepr)
markerGenotype <- data.frame(
  id = c("A", "A", "B", "B"),
  locus = c("L1", "L2", "L1", "L2"),
  allele1 = c("A", "A", "A", "A"),
  allele2 = c("A", "B", "B", "B"),
  stringsAsFactors = FALSE
)
genotypeMatrix <- buildMarkerGenotypeMatrix(markerGenotype)
markerKinship(genotypeMatrix)
#>      A    B
#> A 0.50 0.25
#> B 0.25 0.50
```
