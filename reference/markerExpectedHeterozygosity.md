# Compute per-locus and population-wide expected heterozygosity

Computes Nei's gene diversity (the standard \\He = 1 - \sum p_i^2\\
form, where \\p_i\\ is the population frequency of allele \\i\\ at a
locus) for each locus from the non-missing genotype calls at that locus,
plus the unweighted mean across loci as a population-wide summary. This
is the plain (uncorrected) estimator – the small-sample-size-corrected
variant (Nei & Roychoudhury 1974) is not computed here.

## Usage

``` r
markerExpectedHeterozygosity(genotypeMatrix)
```

## Arguments

- genotypeMatrix:

  a character matrix as returned by
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md):
  rows are individual `id`s, columns are loci, and each cell is that
  individual's two alleles at that locus, sorted and joined by `"/"` (or
  `NA` if not genotyped at that locus).

## Value

A list with two elements: `perLocus`, a named numeric vector of expected
heterozygosity per locus (names taken from `colnames(genotypeMatrix)`);
and `meanHe`, the unweighted mean of `perLocus` across all loci.

## References

Nei, M. (1973). Analysis of gene diversity in subdivided populations.
*Proceedings of the National Academy of Sciences USA*, 70(12),
3321-3323.
[doi:10.1073/pnas.70.12.3321](https://doi.org/10.1073/pnas.70.12.3321)

## See also

[`markerObservedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerObservedHeterozygosity.md),
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md),
[`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)

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
markerExpectedHeterozygosity(genotypeMatrix)
#> $perLocus
#>    L1    L2 
#> 0.375 0.500 
#> 
#> $meanHe
#> [1] 0.4375
#> 
```
