# Remove placeholder animals added for unknown parents

Remove placeholder animals added for unknown parents

## Usage

``` r
removeUnknownAnimals(ped)
```

## Arguments

- ped:

  The pedigree information in data.frame format

## Value

Pedigree with the animals whose `recordStatus` is `"added"` removed.
Every other animal is kept, including one whose `recordStatus` is
missing (`NA`) or has any other value. A pedigree without a
`recordStatus` column has no animals marked as added, so it is returned
unchanged.

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
