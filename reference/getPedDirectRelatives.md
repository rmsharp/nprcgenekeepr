# Get the direct relatives of selected animals from a pedigree

Gets the direct relatives (ancestors and descendants) of the selected
animals from the supplied pedigree (`ped`).

## Usage

``` r
getPedDirectRelatives(ids, ped, unrelatedParents = FALSE)
```

## Arguments

- ids:

  character vector of animal IDs

- ped:

  pedigree dataframe object that is used as the source of pedigree
  information.

- unrelatedParents:

  logical vector when `FALSE` the unrelated parents of offspring do not
  get a record as an ego; when `TRUE` a place holder record where parent
  (`sire`, `dam`) IDs are set to `NA`.

## Value

A data.frame of pedigree records for the selected animals and their
direct relatives (ancestors and descendants) in `ped`.

## See also

Other direct relatives:
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md),
[`getLkDirectAncestors()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectAncestors.md),
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)

## Examples

``` r
library(nprcgenekeepr)
## A pedigree to search and a focal animal whose direct relatives we want
ped <- nprcgenekeepr::lacy1989Ped
getPedDirectRelatives(ids = "E", ped = ped)
#>   id sire  dam gen population
#> 1  A <NA> <NA>   0       TRUE
#> 2  B <NA> <NA>   0       TRUE
#> 3  C    A    B   1       TRUE
#> 4  D    A    B   1       TRUE
#> 5  E <NA> <NA>   0       TRUE
#> 6  F    D    E   2       TRUE
#> 7  G    D    E   2       TRUE
```
