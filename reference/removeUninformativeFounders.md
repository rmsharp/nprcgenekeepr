# Remove uninformative founders

Founders (having unknown sire and dam) that appear only one time in a
pedigree are uninformative and can be removed from a pedigree without
loss of information. Removal repeats until no such founder remains,
because removing one can leave another founder appearing only once.

## Usage

``` r
removeUninformativeFounders(ped)
```

## Arguments

- ped:

  dataframe that is the `Pedigree`. The `id`, `sire` and `dam` columns
  are required.

## Value

A reduced pedigree.

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
