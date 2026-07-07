# Add an NA value for animals with no relative

This allows `kin` to be used with `setdiff` when there are no relatives
otherwise an error would occur because
`kin[['animal_with_no_relative']]` would not be found. See the
following: in **groupAddAssign**

## Usage

``` r
addAnimalsWithNoRelative(kin, candidates)
```

## Arguments

- kin:

  named list of high-kinship relatives, as produced by
  `getAnimalsWithHighKinship`, where each name is an animal Id and each
  value is a character vector of the Ids sharing a kinship value at or
  above the threshold.

- candidates:

  character vector of IDs of the animals available for use in the group.

## Value

The named list of high-kinship relatives (one element per animal Id,
each value a character vector of that Id's high-kinship relatives) with
an added element set to `NA` for each candidate that has no relative.

## Details

    available[[i]] <- setdiff(available[[i]], kin[[id]])

## Examples

``` r
library(nprcgenekeepr)
qcPed <- nprcgenekeepr::qcPed
ped <- qcStudbook(qcPed,
  minParentAge = 2.0, reportChanges = FALSE,
  reportErrors = FALSE
)
#> Warning: The `minParentAge` argument of `qcStudbook()` is deprecated as of nprcgenekeepr
#> 2.0.0.
#> ℹ Use minSireAge and minDamAge instead.
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
currentGroups <- list(1L)
currentGroups[[1]] <- examplePedigree$id[1:3]
candidates <- examplePedigree$id[examplePedigree$status == "ALIVE"]
threshold <- 0.015625
kin <- getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups,
  ignore = list(c("F", "F")), minAge = 1.0
)
# Filtering out candidates related to current group members
conflicts <- unique(c(
  unlist(kin[unlist(currentGroups)]),
  unlist(currentGroups)
))
candidates <- setdiff(candidates, conflicts)
kin <- addAnimalsWithNoRelative(kin, candidates)
length(kin) # should be 259
#> [1] 591
kin[["0DAV0I"]] # should have 34 IDs
#>  [1] "95U2JO" "F50D26" "HRBVOE" "HRQJQR" "RD6KMA" "168Q0A" "6IPOZK" "96W7N8"
#>  [9] "AD0UE1" "DHCUI7" "G6P0W4" "KVPYE4" "NHE3Z8" "OTAC9O" "ZWBMTP" "4UTH8P"
#> [17] "9FR6Q8" "H00H7D" "H0UP6R" "NPK1YN" "NY9FEC" "QR5CMP" "S8IEHH" "T5KNUX"
#> [25] "ZLPSUH" "2YGWN0" "HP3E04" "MF8X1C" "RSROMX" "WMUJC5" "2IXJ2N" "CAST4W"
#> [33] "JGPN6K" "ZC5SCR"
```
