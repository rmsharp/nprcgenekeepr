# De-identify a markerLdBlock() result table

Remaps the `idsUsed` column of a
[`markerLdBlock`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md)
result table through the same alias vector
[`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`
already returns, mirroring
[`obfuscateTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)'s
pattern.
[`markerLdBlock`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md)'s
output is otherwise a locus-pair-level population statistic table with
no per-individual ids – `idsUsed` (populated only when `markerLdBlock`
was called with `founderIds`) is the only place a real id can appear,
and any exported block/LD statistic table must route through the same
curator-controlled de-identification gate issue \#150 established (D9):
a joint, multi-locus statistic carries *more* identifying power than a
single-locus one, not less.

## Usage

``` r
obfuscateLdBlocks(ldBlockResult, map)
```

## Arguments

- ldBlockResult:

  data.frame as returned by
  [`markerLdBlock`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md):
  at least an `idsUsed` column (comma-joined ids, or `NA`).

- map:

  named character vector of aliases, keyed by the original id – the
  `map` element of
  [`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`'s
  return value.

## Value

`ldBlockResult` with `idsUsed` ids replaced by their aliases
(comma-joined, same order); a row whose `idsUsed` is `NA` is returned
unchanged. Every other column is unchanged.

## Details

A row whose `idsUsed` contains an id absent from `map`
[`stop()`](https://rdrr.io/r/base/stop.html)s rather than silently
dropping or leaking the real id –
[`markerLdBlock`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md)'s
own `founderIds` contract should already guarantee every id is a valid
pedigree id, so this is a defensive check, not the primary validation
path.

## See also

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
[`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md),
[`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md),
[`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md),
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md),
[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)

## Examples

``` r
library(nprcgenekeepr)
ped <- data.frame(
  id = c("F1", "F2", "S1", "S2"),
  sire = c(NA, NA, "F1", "F1"),
  dam = c(NA, NA, "F2", "F2"),
  sex = c("M", "F", "F", "F"),
  stringsAsFactors = FALSE
)
ldBlockResult <- data.frame(
  locus1 = "L1", locus2 = "L2", chrom = "1", Dprime = 0.5, r2 = 0.3,
  nUsed = 2L, idsUsed = "F1,F2", caveat = "Descriptive statistic only.",
  stringsAsFactors = FALSE
)
obfuscated <- obfuscatePed(ped, map = TRUE)
obfuscateLdBlocks(ldBlockResult, obfuscated$map)
#>   locus1 locus2 chrom Dprime  r2 nUsed       idsUsed
#> 1     L1     L2     1    0.5 0.3     2 XNZZUQ,QKV6EP
#>                        caveat
#> 1 Descriptive statistic only.
```
