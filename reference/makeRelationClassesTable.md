# Make relation classes table from `kin` dataframe

From Relations

## Usage

``` r
makeRelationClassesTable(kin)
```

## Arguments

- kin:

  a dataframe with columns `id1`, `id2`, `kinship`, and `relation`. It
  is a long-form table of pairwise kinships, with relationship
  categories included for each pair.

## Value

A data.frame with the number of instances of following relationship
classes: Parent-Offspring, Full-Siblings, Half-Siblings,
Grandparent-Grandchild, Full-Cousins, Cousin - Other, Full-Avuncular,
Avuncular - Other, Other, and No Relation.

## Examples

``` r
library(nprcgenekeepr)
suppressMessages(library(dplyr))

qcPed <- nprcgenekeepr::qcPed
qcPed <- qcPed[1:50, ] # Comment out for full example
bkmat <- kinship(qcPed$id, qcPed$sire, qcPed$dam, qcPed$gen,
  sparse = FALSE
)
kin <- convertRelationships(bkmat, qcPed)
relClasses <- makeRelationClassesTable(kin)
relClasses$`Relationship Class` <-
  as.character(relClasses$`Relationship Class`)
relClassTbl <- kin[!kin$relation == "Self", ] |>
  group_by(relation) |>
  summarise(count = n())
relClassTbl
#> # A tibble: 1 × 2
#>   relation    count
#>   <chr>       <int>
#> 1 No Relation  1225
```
