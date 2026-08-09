# De-identify a twin/zygosity relations table

Remaps `id1`/`id2` in a twin/zygosity sidecar table (see
[`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md))
through the same alias vector
[`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`
already returns.
[`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
scrubs exactly one pedigree data frame and cannot reach a second,
sidecar object – this is the companion scrub a twin-relations table
needs so an "obfuscated" export never leaks real ids through the sidecar
table while the main pedigree is de-identified.

## Usage

``` r
obfuscateTwinRelations(twinRelations, map)
```

## Arguments

- twinRelations:

  data.frame with columns `id1`, `id2`, `code`. See
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md).

- map:

  named character vector of aliases, keyed by the original id – the
  `map` element of
  [`obfuscatePed`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)`(..., map = TRUE)`'s
  return value.

## Value

`twinRelations` with `id1`/`id2` replaced by their aliases; `code` is
unchanged.

## Details

A row whose `id1` or `id2` is absent from `map`
[`stop()`](https://rdrr.io/r/base/stop.html)s rather than silently
dropping or leaking the real id.
[`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)'s
own existence rule should already have excluded that case upstream
against the un-obfuscated pedigree, so this is a defensive check, not
the primary validation path.

## See also

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
[`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md),
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)

## Examples

``` r
ped <- data.frame(
  id = c("F1", "F2", "S1", "S2"),
  sire = c(NA, NA, "F1", "F1"),
  dam = c(NA, NA, "F2", "F2"),
  sex = c("M", "F", "F", "F"),
  stringsAsFactors = FALSE
)
twinRelations <- data.frame(
  id1 = "S1", id2 = "S2", code = "MZ twin", stringsAsFactors = FALSE
)
obfuscated <- obfuscatePed(ped, map = TRUE)
obfuscateTwinRelations(twinRelations, obfuscated$map)
#>      id1    id2    code
#> 1 HE9LSY DEB7YD MZ twin
```
