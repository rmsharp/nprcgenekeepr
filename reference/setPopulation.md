# Flag animals as the population of interest

Part of the pedigree filtering toolset.

## Usage

``` r
setPopulation(ped, ids)
```

## Arguments

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.
  The `id` column is required.

- ids:

  character vector of IDs to be flagged as part of the population under
  consideration.

## Value

An updated pedigree with the `population` column added or updated by
being set to `TRUE` for the animal IDs in `ped$id` and `FALSE`
otherwise.

## Examples

``` r
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
nrow(breederPed[breederPed$population, ])
#> [1] 327
```
