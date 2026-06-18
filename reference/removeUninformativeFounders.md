# Remove uninformative founders

Founders (having unknown sire and dam) that appear only one time in a
pedigree are uninformative and can be removed from a pedigree without
loss of information.

## Usage

``` r
removeUninformativeFounders(ped)
```

## Arguments

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.
  The fields `sire` and `dam` are required.

## Value

A reduced pedigree.

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
```
