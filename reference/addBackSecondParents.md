# Add back second parents to a trimmed pedigree

Uses the `ped` dataframe, which has full complement of parents and the
`uPed` dataframe, which has all uninformative parents removed to add
back single parents to the `uPed` dataframe where one parent is known.
The parents are added back to the pedigree as an ID record with NA for
both sire and dam of the added back ID.

## Usage

``` r
addBackSecondParents(uPed, ped)
```

## Arguments

- uPed:

  a trimmed pedigree dataframe with uninformative founders removed.

- ped:

  the full (untrimmed) pedigree dataframe, from which the second parents
  are taken.

## Value

A pedigree with single parents added. It is a `data.table` once any
record is added and a plain dataframe when none is.

## Examples

``` r
examplePedigree <- nprcgenekeepr::examplePedigree
breederPed <- qcStudbook(examplePedigree,
  minSireAge = 2, minDamAge = 2,
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
```
