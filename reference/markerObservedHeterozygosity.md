# Compute per-animal observed heterozygosity from marker genotypes

Computes, for each individual, the fraction of its genotyped
(non-missing) loci at which it is heterozygous – the standard
"individual/multilocus heterozygosity" statistic conventionally reported
per animal (as opposed to the per-locus population framing, which this
function does not compute; see
[`markerExpectedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerExpectedHeterozygosity.md)
for the population-level counterpart). A raw empirical proportion, not
an estimate of a hidden population parameter, so no bias correction
applies.

## Usage

``` r
markerObservedHeterozygosity(genotypeMatrix)
```

## Arguments

- genotypeMatrix:

  a character matrix as returned by
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md):
  rows are individual `id`s, columns are loci, and each cell is that
  individual's two alleles at that locus, sorted and joined by `"/"` (or
  `NA` if not genotyped at that locus).

## Value

A named numeric vector, one observed-heterozygosity value per `id`
(names taken from `rownames(genotypeMatrix)`), each in `[0, 1]`. An
individual with no non-missing loci returns `NA`.

## References

Nei, M. (1973). Analysis of gene diversity in subdivided populations.
*Proceedings of the National Academy of Sciences USA*, 70(12),
3321-3323.
[doi:10.1073/pnas.70.12.3321](https://doi.org/10.1073/pnas.70.12.3321)

## See also

[`markerExpectedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerExpectedHeterozygosity.md),
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
markerObservedHeterozygosity(genotypeMatrix)
#>   A   B 
#> 0.5 1.0 
```
