# Filter out kinship pairs below a threshold

Part of Group Formation Filters kinship values less than the specified
threshold from a long-format table of kinship values.

## Usage

``` r
filterThreshold(kin, threshold = 0.015625)
```

## Arguments

- kin:

  a dataframe with columns `id1`, `id2`, and `kinship`. This is the
  kinship data reformatted from a matrix, to a long-format table.

- threshold:

  numeric value representing the minimum kinship level to be considered
  in group formation. Pairwise kinship below this level will be ignored.

## Value

The filtered long-format kinship table (a data.frame) with all kinship
relationships below the threshold value removed.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
kin <- kinMatrix2LongForm(kmat, removeDups = FALSE)
kinFiltered_0.3 <- filterThreshold(kin, threshold = 0.3)
kinFiltered_0.1 <- filterThreshold(kin, threshold = 0.1)
```
