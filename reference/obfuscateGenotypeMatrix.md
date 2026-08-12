# De-identify a sequence-scale genotype matrix

Remaps the row names (individual `id`s) of a
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)-shaped
wide genotype matrix through the same alias vector
[`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`
already returns, mirroring
[`obfuscateTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)'s
and
[`obfuscateLdBlocks`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md)'s
pattern. Genotype/allele values themselves are never perturbed – unlike
a date, there is no scientifically-valid "obfuscation" of an allele call
that preserves validity while hiding identity, so the only real
protection this primitive provides is which people see the exported file
at all (issue \#152 Slice 4, design decision D7).

## Usage

``` r
obfuscateGenotypeMatrix(genotypeMatrix, map)
```

## Arguments

- genotypeMatrix:

  a character matrix as returned by
  [`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md):
  rows are individual `id`s, columns are loci.

- map:

  named character vector of aliases, keyed by the original id – the
  `map` element of
  [`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`'s
  return value.

## Value

`genotypeMatrix` with row names replaced by their aliases; column names
and every genotype cell value are unchanged.

## Details

A row whose id is absent from `map`
[`stop()`](https://rdrr.io/r/base/stop.html)s rather than silently
dropping or leaking the real id.

## See also

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
[`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md),
[`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md),
[`obfuscateLdBlocks()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md),
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md),
[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)

## Examples

``` r
library(nprcgenekeepr)
ped <- data.frame(
  id = c("A01", "A02"),
  sire = c(NA, NA),
  dam = c(NA, NA),
  sex = c("M", "F"),
  stringsAsFactors = FALSE
)
genotypeMatrix <- matrix(
  c("A/A", "A/B"), nrow = 2L, dimnames = list(c("A01", "A02"), "L1")
)
obfuscated <- obfuscatePed(ped, map = TRUE)
obfuscateGenotypeMatrix(genotypeMatrix, obfuscated$map)
#>        L1   
#> VCBX7V "A/A"
#> IJ0QG1 "A/B"
```
