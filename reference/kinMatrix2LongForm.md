# Reformats a kinship matrix into a long-format table

Part of Group Formation

## Usage

``` r
kinMatrix2LongForm(kinMatrix, removeDups = FALSE)
```

## Arguments

- kinMatrix:

  numerical matrix of pairwise kinship values. The row and column names
  correspond to animal IDs.

- removeDups:

  logical value indication whether or not reverse-order ID pairs be
  filtered out? (i.e., "ID1 ID2 kin_val" and "ID2 ID1 kin_val" will be
  collapsed into a single entry if removeDups = TRUE)

## Value

A dataframe with columns `id1`, `id2`, and `kinship`. This is the
kinship data reformatted from a matrix, to a long-format table.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
reformattedKmat <- kinMatrix2LongForm(kmat, removeDups = FALSE)
nrow(reformattedKmat)
#> [1] 49
reformattedNoDupsKmat <- kinMatrix2LongForm(kmat, removeDups = TRUE)
nrow(reformattedNoDupsKmat)
#> [1] 28
```
