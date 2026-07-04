# Map IDs to Obfuscated IDs

This is not robust as it fails if all IDs are found not within `map`.

## Usage

``` r
mapIdsToObfuscated(ids, map)
```

## Arguments

- ids:

  character vector with original IDs

- map:

  named character vector where the values are the obfuscated IDs and the
  vector of names (`names(map)`) is the vector of original names.

## Value

A dataframe or vector with original IDs replaced by their obfuscated
counterparts.

## See also

Other obfuscation:
[`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
[`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md),
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)

## Examples

``` r
set_seed(1)
ped <- qcStudbook(nprcgenekeepr::pedSix)
obfuscated <- obfuscatePed(ped, map = TRUE)
someIds <- c("s1", "s2", "d1", "d1")
mapIdsToObfuscated(someIds, obfuscated$map)
#> [1] "JNAN5L" "0ZR5QI" "2D0P3X" "2D0P3X"
```
