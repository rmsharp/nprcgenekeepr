# Filter kinship pairs by the animals' sexes

Part of Group Formation

## Usage

``` r
filterPairs(kin, ped, ignore = list(c("F", "F")))
```

## Arguments

- kin:

  a dataframe with columns `id1`, `id2`, and `kinship`. This is the
  kinship data reformatted from a matrix, to a long-format table.

- ped:

  Dataframe of pedigree information including the IDs listed in
  `candidates`.

- ignore:

  a list containing zero or more character vectors of length 2
  indicating which sex pairs should be ignored with regard to kinship.
  Defaults to `list(c("F", "F"))`.

## Value

A dataframe representing a filtered long-format kinship table.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
kin <- kinMatrix2LongForm(kmat, removeDups = FALSE)
threshold <- 0.1
kin <- filterThreshold(kin, threshold = threshold)
ped$sex <- c("M", "F", "M", "M", "F", "F", "M")
kinNull <- filterPairs(kin, ped, ignore = NULL)
kinMM <- filterPairs(kin, ped, ignore = list(c("M", "M")))
ped
#>   id sire  dam gen population sex
#> 1  A <NA> <NA>   0       TRUE   M
#> 2  B <NA> <NA>   0       TRUE   F
#> 3  C    A    B   1       TRUE   M
#> 4  D    A    B   1       TRUE   M
#> 5  E <NA> <NA>   0       TRUE   F
#> 6  F    D    E   2       TRUE   F
#> 7  G    D    E   2       TRUE   M
kin[kin$id1 == "C", ]
#>    id1 id2 kinship
#> 11   C   A   0.250
#> 12   C   B   0.250
#> 13   C   C   0.500
#> 14   C   D   0.250
#> 15   C   F   0.125
#> 16   C   G   0.125
kinMM[kinMM$id1 == "C", ]
#>   id1 id2 kinship
#> 7   C   B   0.250
#> 8   C   F   0.125
```
