# Check whether an animal has both parents

Check whether an animal has both parents

## Usage

``` r
hasBothParents(id, ped)
```

## Arguments

- id:

  a single ID to examine for parents. A vector of IDs is not supported
  and gives a recycling warning.

- ped:

  The pedigree information in data.frame format

## Value

TRUE if ID has both sire and dam identified in `ped`, FALSE if one or
both are unknown, and `logical(0)` if `id` is not in `ped`.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::pedOne
names(ped) <- c("id", "sire", "dam", "sex", "birth")
hasBothParents("o2", ped)
#> [1] TRUE
ped$sire[ped$id == "o2"] <- NA
hasBothParents("o2", ped)
#> [1] FALSE
```
