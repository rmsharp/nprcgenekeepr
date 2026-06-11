# Get the direct ancestors of selected animals

Gets direct ancestors from labkey `study` schema and `demographics`
table.

## Usage

``` r
getLkDirectRelatives(ids, unrelatedParents = FALSE)
```

## Arguments

- ids:

  character vector with Ids.

- unrelatedParents:

  logical vector when `FALSE` the unrelated parents of offspring do not
  get a record as an ego; when `TRUE` a place holder record where parent
  (`sire`, `dam`) IDs are set to `NA`.

## Value

A data.frame with pedigree structure having all of the direct ancestors
for the Ids provided.

## Examples

``` r
# \donttest{
# Requires LabKey connection
library(nprcgenekeepr)
## Have to a vector of focal animals
focalAnimals <- c("1X2701", "1X0101")
suppressWarnings(getLkDirectRelatives(ids = focalAnimals))
#> NULL
# }
```
