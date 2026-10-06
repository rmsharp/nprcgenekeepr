# Get offspring to corresponding animal IDs provided

Get offspring to corresponding animal IDs provided

## Usage

``` r
getOffspring(pedSourceDf, ids)
```

## Arguments

- pedSourceDf:

  dataframe with pedigree structure having at least the columns id,
  sire, and dam. The pedigree is the first argument, unlike
  [`getProbandPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getProbandPedigree.md),
  [`getDescendantPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDescendantPedigree.md),
  [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
  and
  [`findOffspring()`](https://github.com/rmsharp/nprcgenekeepr/reference/findOffspring.md),
  which take the animal ids first.

- ids:

  character vector of animal IDs

## Value

A character vector containing all of the offspring IDs for all of the
IDs provided in the second argument `ids`. All offspring are combined
and duplicates are removed.

## Examples

``` r
library(nprcgenekeepr)
pedOne <- nprcgenekeepr::pedOne
names(pedOne) <- c("id", "sire", "dam", "sex", "birth")
getOffspring(pedOne, c("s1", "d2"))
#> [1] "o1" "o2" "o3" "o4"
```
