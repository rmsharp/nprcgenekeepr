# Get ids of animals with only one parent

Get ids of animals with only one parent

## Usage

``` r
getIdsWithOneParent(uPed)
```

## Arguments

- uPed:

  a trimmed pedigree dataframe with uninformative founders removed.

## Value

Character vector of all single parents

## Examples

``` r
examplePedigree <- nprcgenekeepr::examplePedigree
breederPed <- qcStudbook(examplePedigree,
  minParentAge = 2,
  reportChanges = FALSE,
  reportErrors = FALSE
)
probands <- breederPed$id[!(is.na(breederPed$sire) &
  is.na(breederPed$dam)) &
  is.na(breederPed$exit)]
ped <- getProbandPedigree(probands, breederPed)
nrow(ped)
#> [1] 704
p <- removeUninformativeFounders(ped)
nrow(p)
#> [1] 509
p <- addBackSecondParents(p, ped)
nrow(p)
#> [1] 690
getIdsWithOneParent(p)
#> character(0)
```
