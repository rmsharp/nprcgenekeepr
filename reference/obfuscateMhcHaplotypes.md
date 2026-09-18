# De-identify an MHC haplotype carrier table

Remaps the `id` column of a
[`mhcHaplotypeCarriers`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeCarriers.md)
table through the same alias vector
[`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`
already returns.
[`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
scrubs exactly one pedigree data frame and cannot reach a second,
sidecar object – this is the companion scrub an MHC carrier table needs
so an "obfuscated" export never leaks real animal ids while the main
pedigree is de-identified.

## Usage

``` r
obfuscateMhcHaplotypes(carriers, map)
```

## Arguments

- carriers:

  data.frame with columns `haplotype`, `id`, `uncertain` as returned by
  [`mhcHaplotypeCarriers`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeCarriers.md).

- map:

  named character vector of aliases, keyed by the original id – the
  `map` element of
  [`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`'s
  return value.

## Value

`carriers` with `id` replaced by its alias; `haplotype` and `uncertain`
are unchanged.

## Details

Haplotype labels are left byte-identical: an MHC haplotype name is a
shared nomenclature term, not an animal identifier, and there is no
validity-preserving way to obfuscate one. Only `id` is ever remapped – a
map entry whose name happens to match a haplotype label never touches
the `haplotype` column. The `uncertain` disclosure column passes through
unchanged.

A row whose `id` is absent from `map`
[`stop()`](https://rdrr.io/r/base/stop.html)s rather than silently
dropping or leaking the real id.

## See also

[`mhcHaplotypeCarriers`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeCarriers.md),
[`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
[`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md),
[`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md),
[`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md),
[`obfuscateLdBlocks()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md),
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md),
[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)

## Examples

``` r
ped <- data.frame(
  id = c("F1", "F2", "S1", "S2"),
  sire = c(NA, NA, "F1", "F1"),
  dam = c(NA, NA, "F2", "F2"),
  sex = c("M", "F", "F", "F"),
  stringsAsFactors = FALSE
)
genotype <- data.frame(
  id = c("S1", "S2"),
  haplotype1 = c("A001_B001", "A001_B001"),
  haplotype2 = c("A002_B012", "A008_B015b"),
  stringsAsFactors = FALSE
)
carriers <- mhcHaplotypeCarriers(genotype, rareOnly = FALSE)
obfuscated <- obfuscatePed(ped, map = TRUE)
obfuscateMhcHaplotypes(carriers, obfuscated$map)
#>    haplotype     id uncertain
#> 1  A001_B001 FCDNFK     FALSE
#> 2  A001_B001 GJGR1A     FALSE
#> 3  A002_B012 FCDNFK     FALSE
#> 4 A008_B015b GJGR1A     FALSE
```
