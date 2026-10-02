# Count total offspring for each animal

Part of Genetic Value Analysis

## Usage

``` r
findOffspring(probands, ped)
```

## Arguments

- probands:

  character vector of egos for which offspring should be counted and
  returned.

- ped:

  the pedigree information in datatable format. Pedigree (req. fields:
  id, sire, dam). This requires complete pedigree information.

## Value

A named integer vector containing the offspring counts for each animal
in `probands`. The names are set to the IDs from `probands`, and an ID
that is not a parent in `ped` gets 0.

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
ped <- setPopulation(ped = breederPed, ids = focalAnimals)
trimmedPed <- trimPedigree(focalAnimals, breederPed)
probands <- ped$id[ped$population]
totalOffspring <- findOffspring(probands, ped)
```
