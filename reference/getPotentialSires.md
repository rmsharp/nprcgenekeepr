# List potential sires

List potential sires

## Usage

``` r
getPotentialSires(ids, ped, minAge = 1L)
```

## Arguments

- ids:

  character vector of animal IDs

- ped:

  dataframe that is the `Pedigree`. It contains pedigree information
  including the IDs listed in `candidates`.

- minAge:

  integer value indicating the minimum age to consider in group
  formation. Pairwise kinships involving an animal of this age or
  younger will be ignored. Default is 1 year.

## Value

A character vector of potential sire Ids

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::pedWithGenotype
ids <- nprcgenekeepr::qcBreeders
getPotentialSires(ids, ped, minAge = 1L)
#> [1] "J3D3N5" "VFS0XB" "HP3E04"
```
