# Get the direct ancestors of selected animals from supplied pedigree.

Gets direct ancestors from labkey `study` schema and `demographics`
table.

## Usage

``` r
getPedDirectRelatives(ids, ped, unrelatedParents = FALSE)
```

## Arguments

- ids:

  character vector with Ids.

- ped:

  pedigree dataframe object that is used as the source of pedigree
  information.

- unrelatedParents:

  logical vector when `FALSE` the unrelated parents of offspring do not
  get a record as an ego; when `TRUE` a place holder record where parent
  (`sire`, `dam`) IDs are set to `NA`.

## Value

A data.frame with pedigree structure having all of the direct ancestors
for the Ids provided.

## Examples

``` r
library(nprcgenekeepr)
## Have to a vector of focal animals
focalAnimals <- c("1X2701", "1X0101")
suppressWarnings(getLkDirectRelatives(ids = focalAnimals))
#> NULL
```
