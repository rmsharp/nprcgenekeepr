# Make the initial groupMembers animal list

Make the initial groupMembers animal list

## Usage

``` r
makeGroupMembers(numGp, currentGroups, candidates, ped, harem, minAge)
```

## Arguments

- numGp:

  integer value indicating the number of groups that should be formed
  from the list of IDs. Default is 1.

- currentGroups:

  list of character vectors of IDs of animals currently assigned to the
  group. Defaults to character(0) assuming no groups are existent.

- candidates:

  character vector of IDs of the animals available for use in the group.

- ped:

  dataframe that is the `Pedigree`. It contains pedigree information
  including the IDs listed in `candidates`.

- harem:

  logical variable when set to `TRUE`, the formed groups have a single
  male at least `minAge` old.

- minAge:

  integer value indicating the minimum age to consider in group
  formation. Pairwise kinships involving an animal of this age or
  younger will be ignored. Default is 1 year.

## Value

Initial groupMembers list

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::qcPed
candidates <- nprcgenekeepr::qcBreeders
## Non-harem: pre-seed group 1 with animals already assigned; a
## second, empty group is initialized ready to be filled.
currentGroups <- list(candidates[1L:3L])
groupMembers <- makeGroupMembers(
  numGp = 2L, currentGroups = currentGroups, candidates = candidates,
  ped = ped, harem = FALSE, minAge = 1L
)
groupMembers
#> [[1]]
#> [1] "Q0RGP7" "C1ICXL" "J3D3N5"
#> 
#> [[2]]
#> logical(0)
#> 
## Harem: each group is seeded with one available male (uses sample()).
set.seed(1L)
haremMembers <- makeGroupMembers(
  numGp = 2L, currentGroups = list(), candidates = candidates,
  ped = ped, harem = TRUE, minAge = 1L
)
haremMembers
#> [[1]]
#> [1] "J3D3N5"
#> 
#> [[2]]
#> [1] "HP3E04"
#> 
```
