# Get the maximum age of live animals in the pedigree

Get the maximum age of live animals in the pedigree

## Usage

``` r
getPedMaxAge(ped)
```

## Arguments

- ped:

  dataframe with pedigree

## Value

Numeric value representing the maximum age of animals in the pedigree.

## Examples

``` r
library(nprcgenekeepr)
examplePedigree <- nprcgenekeepr::examplePedigree
ped <- qcStudbook(examplePedigree,
  minParentAge = 2,
  reportChanges = FALSE,
  reportErrors = FALSE
)
getPedMaxAge(ped)
#> [1] 38.4
```
