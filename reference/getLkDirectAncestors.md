# Get the direct ancestors of selected animals

Gets direct ancestors from labkey `study` schema and `demographics`
table.

## Usage

``` r
getLkDirectAncestors(ids)
```

## Arguments

- ids:

  character vector with Ids.

## Value

data.frame with pedigree structure having all of the direct ancestors
for the Ids provided.

## Examples

``` r
# \donttest{
# Requires LabKey connection
library(nprcgenekeepr)
## Have to a vector of focal animals
focalAnimals <- c("1X2701", "1X0101")
suppressWarnings(getLkDirectAncestors(ids = focalAnimals))
#> NULL
# }
```
