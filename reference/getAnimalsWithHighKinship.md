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
  group. Defaults to character(0) assuming no groups are existent.

- ignore:

  list of character vectors representing the sex combinations to be
  ignored. If provided, the vectors in the list specify if pairwise
  kinship should be ignored between certain sexes. Default is to ignore
  all pairwise kinship between females.

- minAge:

  integer value indicating the minimum age to consider in group
  formation. Pairwise kinships involving an animal of this age or
  younger will be ignored. Default is 1 year.

## Value

A list of named character vectors where each name is an animal Id and
the character vectors are made up of animals sharing a kinship value
greater than our equal to the `threshold` value.

## Examples

``` r
qcPed <- nprcgenekeepr::qcPed
ped <- qcStudbook(qcPed,
  minParentAge = 2L, reportChanges = FALSE,
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
