# Trim a pedigree to a group's ancestors

Filters a pedigree down to only the ancestors of the provided group,
removing unnecessary individuals from the studbook. This version builds
the pedigree back in time starting from a group of probands, then moves
back down the tree trimming off uninformative ancestors.

## Usage

``` r
trimPedigree(
  probands,
  ped,
  removeUninformative = FALSE,
  addBackParents = FALSE
)
```

## Arguments

- probands:

  a character vector with the list of animals whose ancestors should be
  included in the final pedigree.

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.
  The fields `sire` and `dam` are required.

- removeUninformative:

  logical defaults to `FALSE`. If set to `TRUE`, uninformative founders
  are removed.

  Founders (having unknown sire and dam) that appear only one time in a
  pedigree are uninformative and can be removed from a pedigree without
  loss of information.

- addBackParents:

  logical defaults to `FALSE`. If set to `TRUE`, the function adds back
  single parents to the `p` dataframe when one parent is known. The
  function `addBackSecondParents` uses the `ped` dataframe, which has
  full complement of parents and the `p` dataframe, which has all
  uninformative parents removed to add back single parents to the `p`
  dataframe.

## Value

A pedigree that has been trimmed, had uninformative founders removed and
single parents added back.

## Examples

``` r
library(nprcgenekeepr)
examplePedigree <- nprcgenekeepr::examplePedigree
breederPed <- qcStudbook(examplePedigree,
  minParentAge = 2,
  reportChanges = FALSE,
  reportErrors = FALSE
)
focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
  is.na(breederPed$dam)) &
  is.na(breederPed$exit)]
breederPed <- setPopulation(ped = breederPed, ids = focalAnimals)
trimmedPed <- trimPedigree(focalAnimals, breederPed)
trimmedPedInformative <- trimPedigree(focalAnimals, breederPed,
  removeUninformative = TRUE
)
nrow(breederPed)
#> [1] 3694
nrow(trimmedPed)
#> [1] 704
nrow(trimmedPedInformative)
#> [1] 509
```
