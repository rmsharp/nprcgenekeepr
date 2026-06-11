# Get offspring to corresponding animal IDs provided

Get offspring to corresponding animal IDs provided

## Usage

``` r
getOffspring(pedSourceDf, ids)
```

## Arguments

- pedSourceDf:

  dataframe with pedigree structure having at least the columns id,
  sire, and dam.

- ids:

  character vector of animal IDs

## Value

A character vector containing all of the ancestor IDs for all of the IDs
provided in the second argument `ids`. All ancestors are combined and
duplicates are removed.

## Examples

``` r
library(nprcgenekeepr)
pedOne <- nprcgenekeepr::pedOne
names(pedOne) <- c("id", "sire", "dam", "sex", "birth")
getOffspring(pedOne, c("s1", "d2"))
#> [1] "o1" "o2" "o3" "o4"
```
