# Pivot a long-format marker genotype table into a wide genotype matrix

Converts a validated long-format marker genotype table (see
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md))
into a wide `id` x `locus` character matrix, the input shape
[`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)
consumes.

## Usage

``` r
buildMarkerGenotypeMatrix(genotype)
```

## Arguments

- genotype:

  dataframe with long-format marker genotype data, as returned by
  [`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md):
  columns `id`, `locus`, `allele1`, `allele2`.

## Value

A character matrix with one row per unique `id` and one column per
unique `locus`. Each cell holds that individual's two alleles at that
locus, sorted alphabetically and joined by `"/"` (e.g. `"A/B"`), or `NA`
when that individual has no genotype record at that locus.

## Details

Row and column order follow first appearance in `genotype`, not a string
sort – a string sort would place `"L10"` before `"L2"` for any panel
with more than nine loci, silently scrambling locus order.

## See also

[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
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
buildMarkerGenotypeMatrix(markerGenotype)
#>   L1    L2   
#> A "A/A" "A/B"
#> B "A/B" "A/B"
```
