# Trim a pedigree to a group's ancestors

Filters a pedigree down to the provided group (the probands) and all of
their ancestors, removing unnecessary individuals from the studbook. By
default only that filtering is done. Uninformative founders are removed
only when `removeUninformative = TRUE`, and single parents are added
back only when both `removeUninformative` and `addBackParents` are
`TRUE`.

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
  The fields `id`, `sire` and `dam` are required.

- removeUninformative:

  logical defaults to `FALSE`. If set to `TRUE`, uninformative founders
  are removed.

  Founders (having unknown sire and dam) that appear only one time in a
  pedigree are uninformative and can be removed from a pedigree without
  loss of information.

- addBackParents:

  logical defaults to `FALSE`. If set to `TRUE`, the function adds back
  single parents to the `p` dataframe when one parent is known. It is
  ignored unless `removeUninformative = TRUE`. The function
  `addBackSecondParents` uses the `ped` dataframe, which has full
  complement of parents and the `p` dataframe, which has all
  uninformative parents removed to add back single parents to the `p`
  dataframe.

## Value

A pedigree containing the probands and all of their ancestors.
Uninformative founders are removed only when `removeUninformative` is
`TRUE`, and single parents are added back only when `addBackParents` is
also `TRUE`.

## Examples

``` r
library(nprcgenekeepr)
examplePedigree <- nprcgenekeepr::examplePedigree
breederPed <- qcStudbook(examplePedigree,
  minSireAge = 2,
  minDamAge = 2,
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
