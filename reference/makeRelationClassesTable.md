# Make a relation classes table from kinship pairs

Counts the pairs of animals in each relationship class of a long-form
kinship table.

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

A data.frame with columns `Relationship Class` and `Frequency`: the
number of pairs in each of the following relationship classes:
Parent-Offspring, Full-Siblings, Half-Siblings, Grandparent-Grandchild,
Full-Cousins, Cousin - Other, Full-Avuncular, Avuncular - Other, Other,
and No Relation. Self pairs are not counted, and classes with no pairs
are left out. When no pair of different animals is left to count, the
table has its two columns and no rows.

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
