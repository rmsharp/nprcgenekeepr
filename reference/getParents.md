# Get parents to corresponding animal IDs provided

Get parents to corresponding animal IDs provided

## Usage

``` r
getParents(pedSourceDf, ids)
```

## Arguments

- pedSourceDf:

  dataframe with pedigree structure having at least the columns id,
  sire, and dam.

- ids:

  character vector of animal IDs

## Value

A character vector with the IDs of the parents of the provided ID list.

## Examples

``` r
library(nprcgenekeepr)
pedOne <- nprcgenekeepr::pedOne
names(pedOne) <- c("id", "sire", "dam", "sex", "birth")
getParents(pedOne, c("o1", "d4"))
#> [1] "s1" "d1"
```
