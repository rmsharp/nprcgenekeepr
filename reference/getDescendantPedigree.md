# Gets pedigree with descendants of provided group.

Filters a pedigree down to only the descendants of the provided group,
building the pedigree forward in time starting from a group of probands.
This is the downward (descendants-only) mirror of
[`getProbandPedigree`](https://github.com/rmsharp/nprcgenekeepr/reference/getProbandPedigree.md):
it takes the transitive closure over offspring and returns the probands
together with all of their descendants. It does not include collateral
relatives (siblings, cousins, or mates).

## Usage

``` r
getDescendantPedigree(probands, ped)
```

## Arguments

- probands:

  a character vector with the list of animals whose descendants should
  be included in the final pedigree.

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.
  The fields `id`, `sire` and `dam` are required.

## Value

A reduced pedigree containing the probands and all of their descendants.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
## D's descendants are F and G
getDescendantPedigree(probands = "D", ped = ped)$id
#> [1] "D" "F" "G"
```
