# Tabulate offspring counts, optionally by population

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
  id, sire, dam; `population` is also read when `considerPop` is
  `TRUE`). This is the complete pedigree.

- considerPop:

  logical value indication whether or not the number of offspring that
  are part of the focal population are to be counted? Default is
  `FALSE`. If `ped` has no `population` column, `considerPop` has no
  effect and only `totalOffspring` is returned.

## Value

A dataframe containing the column `totalOffspring` (and
`livingOffspring` when `considerPop` is `TRUE` and `ped` has a
`population` column). The animal ids are the data frame row names when
`probands` are unique; duplicated `probands` give sequential row names.

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
counts <- offspringCounts(probands, ped)
```
