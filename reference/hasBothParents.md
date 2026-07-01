# Check whether an animal has both parents

Check whether an animal has both parents

## Usage

``` r
hasBothParents(id, ped)
```

## Arguments

- id:

  character vector of IDs to examine for parents

- ped:

  a pedigree

## Value

TRUE if ID has both sire and dam identified in `ped`.

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
