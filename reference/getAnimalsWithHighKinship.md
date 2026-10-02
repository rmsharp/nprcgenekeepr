# List each animal's high-kinship relatives

List each animal's high-kinship relatives

## Usage

``` r
getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups, ignore, minAge)
```

## Arguments

- kmat:

  a numeric matrix of pairwise kinship coefficients. Animal IDs are the
  row and column names.

- ped:

  The pedigree information in data.frame format

- threshold:

  numeric value representing the minimum kinship level to be considered
  in group formation. Pairwise kinship below this level will be ignored.

- currentGroups:

  list of character vectors of IDs of animals currently assigned to the
  group. Required (no default); use `character(0L)` when no groups
  exist.

- ignore:

  list of character vectors representing the sex combinations to be
  ignored. If provided, the vectors in the list specify if pairwise
  kinship should be ignored between certain sexes. Required (no
  default);
  [`filterPairs()`](https://github.com/rmsharp/nprcgenekeepr/reference/filterPairs.md)
  itself ignores female-female pairs when called directly.

- minAge:

  integer value indicating the minimum age to consider in group
  formation. Required (no default). Pairwise kinships involving an
  animal younger than this age are ignored; animals of exactly this age
  or with a missing age are retained.

## Value

A one-dimensional array of mode list (from
[`tapply()`](https://rdrr.io/r/base/tapply.html)), not a plain list. Its
names are animal IDs, and each element is a character vector of animals
sharing a kinship value greater than or equal to the `threshold` value.
[`names()`](https://rdrr.io/r/base/names.html) and `[[` work as for a
list.

## Examples

``` r
qcPed <- nprcgenekeepr::qcPed
ped <- qcStudbook(qcPed,
  minSireAge = 2L, minDamAge = 2L, reportChanges = FALSE,
  reportErrors = FALSE
)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
currentGroups <- list(1L)
currentGroups[[1L]] <- examplePedigree$id[1L:3L]
candidates <- examplePedigree$id[examplePedigree$status == "ALIVE"]
threshold <- 0.015625
kin <- getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups,
  ignore = list(c("F", "F")), minAge = 1.0
)
length(kin) # should be 259
#> [1] 259
kin[["0DAV0I"]] # should have 34 IDs
#>  [1] "95U2JO" "F50D26" "HRBVOE" "HRQJQR" "RD6KMA" "168Q0A" "6IPOZK" "96W7N8"
#>  [9] "AD0UE1" "DHCUI7" "G6P0W4" "KVPYE4" "NHE3Z8" "OTAC9O" "ZWBMTP" "4UTH8P"
#> [17] "9FR6Q8" "H00H7D" "H0UP6R" "NPK1YN" "NY9FEC" "QR5CMP" "S8IEHH" "T5KNUX"
#> [25] "ZLPSUH" "2YGWN0" "HP3E04" "MF8X1C" "RSROMX" "WMUJC5" "2IXJ2N" "CAST4W"
#> [33] "JGPN6K" "ZC5SCR"
```
