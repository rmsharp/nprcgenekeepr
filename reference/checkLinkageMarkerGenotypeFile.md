# Check a long-format multi-locus marker genotype file, multiallelic-tolerant

Validates the structure of a long-format marker genotype table (one row
per `id` x `locus`), the same schema
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)
checks – but, unlike that function, does not require every locus to be
biallelic. This is a new, sibling validator for the linkage-aware and
haplotype-block metrics family (issue \#153): real colony marker panels
(e.g. microsatellite/STR panels) are routinely multiallelic, a data
shape the KING-robust kinship estimator checked by
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)
cannot represent, but which
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)
pivots without error.
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)
itself, and everything downstream of it
([`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)),
is untouched by this function.

## Usage

``` r
checkLinkageMarkerGenotypeFile(genotype)
```

## Arguments

- genotype:

  dataframe with long-format marker genotype data: exactly four columns,
  `id`, `locus`, `allele1`, `allele2` (one row per individual x locus).

## Value

The genotype dataframe, checked to ensure the column count, first-column
identity, and row uniqueness are all valid. The returned dataframe has
its column names forced to `c("id", "locus", "allele1", "allele2")`.

## Details

All of
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)'s
structural checks are retained – exactly four columns, `id` as the first
column, no duplicate `id` x `locus` rows – except the per-locus
more-than-two-distinct-alleles rejection, which is deliberately omitted.

## See also

[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)

## Examples

``` r
library(nprcgenekeepr)
markerGenotype <- data.frame(
  id = c("W", "X", "Y", "Z"),
  locus = c("L1", "L1", "L1", "L1"),
  allele1 = c("A", "A", "A", "A"),
  allele2 = c("B", "C", "A", "D"),
  stringsAsFactors = FALSE
)
checkLinkageMarkerGenotypeFile(markerGenotype)
#>   id locus allele1 allele2
#> 1  W    L1       A       B
#> 2  X    L1       A       C
#> 3  Y    L1       A       A
#> 4  Z    L1       A       D
```
