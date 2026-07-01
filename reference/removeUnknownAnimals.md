# Remove placeholder animals added for unknown parents

Remove placeholder animals added for unknown parents

## Usage

``` r
removeUnknownAnimals(ped)
```

## Arguments

- ped:

  pedigree dataframe

## Value

Pedigree with unknown animals removed

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::smallPed
addedPed <- cbind(ped,
  recordStatus = rep("original", nrow(ped)),
  stringsAsFactors = FALSE
)
addedPed[1:3, "recordStatus"] <- "added"
ped2 <- removeUnknownAnimals(addedPed)
nrow(ped)
#> [1] 17
nrow(ped2)
#> [1] 14
```
