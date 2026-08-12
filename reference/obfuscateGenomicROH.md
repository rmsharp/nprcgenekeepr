# De-identify a computeGenomicROH() result table

Remaps the `id` column of a
[`computeGenomicROH`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md)
result table through the same alias vector
[`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`
already returns, mirroring
[`obfuscateTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)'s
and
[`obfuscateGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md)'s
pattern (issue \#152 Slice 5, design decision D7: "any sequence-derived
export... routes through a new de-identification primitive").
[`computeGenomicROH`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md)'s
output is a plain per-individual data.frame keyed by a single `id`
column – a different shape from every prior `obfuscate*()` sibling, so
none of them fit directly.

## Usage

``` r
obfuscateGenomicROH(rohTable, map)
```

## Arguments

- rohTable:

  data.frame as returned by
  [`computeGenomicROH`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md):
  at least an `id` column.

- map:

  named character vector of aliases, keyed by the original id – the
  `map` element of
  [`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`'s
  return value.

## Value

`rohTable` with `id` replaced by its alias; every other column
(`nSegments`, `totalRohLength`, `fRoh`) is unchanged.

## Details

A row whose `id` is absent from `map`
[`stop()`](https://rdrr.io/r/base/stop.html)s rather than silently
dropping or leaking the real id.

## See also

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
[`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md),
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
rohTable <- data.frame(
  id = c("A01", "A02"), nSegments = c(1L, 0L),
  totalRohLength = c(1000000, 0), fRoh = c(0.1, 0),
  stringsAsFactors = FALSE
)
obfuscated <- obfuscatePed(ped, map = TRUE)
obfuscateGenomicROH(rohTable, obfuscated$map)
#>       id nSegments totalRohLength fRoh
#> 1 QX9SRG         1          1e+06  0.1
#> 2 1QSHIV         0          0e+00  0.0
```
