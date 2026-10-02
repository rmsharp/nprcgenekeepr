# Get the direct relatives of selected animals from a pedigree

Gets the full connected pedigree component reachable from the selected
animals in the supplied pedigree (`ped`). The result includes ancestors,
descendants, and collaterals such as siblings and mates. A `NULL` `ped`
returns `NULL`.

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
  get a record as an ego; when `TRUE` they get a place holder record as
  an ego in which the parent (`sire`, `dam`) IDs are set to `NA`. Place
  holder records are made for every collected ID that is absent from
  `ped$id`, including a selected ID that is not in the pedigree.

## Value

A data.frame of pedigree records for the selected animals and the full
connected pedigree component (ancestors, descendants, siblings and
mates) in `ped`, or `NULL` when `ped` is `NULL`.

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
