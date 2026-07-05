# Get the maximum age of any animal in the pedigree

Returns the maximum age among all animals in the pedigree that have a
non-NA age. Because ages are computed for deceased animals (age at exit)
as well, the maximum can reflect a deceased animal.

## Usage

``` r
getPedMaxAge(ped)
```

## Arguments

- ped:

  The pedigree information in data.frame format

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
