# Finds the total number of offspring for each animal in the pedigree

Optionally find the number that are part of the population of interest.

## Usage

``` r
offspringCounts(probands, ped, considerPop = FALSE)
```

## Arguments

- probands:

  character vector of egos for which offspring should be counted.

- ped:

  the pedigree information in datatable format. Pedigree (req. fields:
  id, sire, dam, gen, population). This is the complete pedigree.

- considerPop:

  logical value indication whether or not the number of offspring that
  are part of the focal population are to be counted? Default is
  `FALSE`.

## Value

A dataframe with at least `id` and `totalOffspring` required and
`livingOffspring` optional.

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
ped <- setPopulation(ped = breederPed, ids = focalAnimals)
trimmedPed <- trimPedigree(focalAnimals, breederPed)
probands <- ped$id[ped$population]
counts <- offspringCounts(probands, ped)
```
