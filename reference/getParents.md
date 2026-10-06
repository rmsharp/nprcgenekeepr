# Get parents to corresponding animal IDs provided

Get parents to corresponding animal IDs provided

## Usage

``` r
getParents(pedSourceDf, ids)
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

A character vector with the IDs of the parents of the provided ID list.

## Examples

``` r
library(nprcgenekeepr)
pedOne <- nprcgenekeepr::pedOne
names(pedOne) <- c("id", "sire", "dam", "sex", "birth")
getParents(pedOne, c("o1", "d4"))
#> [1] "s1" "d1"
```
