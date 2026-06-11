# Gets pedigree to ancestors of provided group leaving uninformative ancestors.

Filters a pedigree down to only the ancestors of the provided group,
removing unnecessary individuals from the studbook. This version builds
the pedigree back in time starting from a group of probands. This will
include all ancestors of the probands, even ones that might be
uninformative.

## Usage

``` r
getProbandPedigree(probands, ped)
```

## Arguments

- probands:

  a character vector with the list of animals whose ancestors should be
  included in the final pedigree.

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.
  The fields `sire` and `dam` are required.

## Value

A reduced pedigree.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::pedWithGenotype
ids <- nprcgenekeepr::qcBreeders
sires <- getPotentialSires(ids, ped, minAge = 1)
head(getProbandPedigree(probands = sires, ped = ped))
#>         id sire  dam sex gen      birth       exit  age first second first_name
#> 91  6EJ6RI <NA> <NA>   F   0 1964-12-02 1989-09-04 24.8    NA     NA       <NA>
#> 92  F50D26 <NA> <NA>   F   0 1969-01-21 1992-05-11 23.3    NA     NA       <NA>
#> 95  0RZ5LL <NA> <NA>   M   0 1971-01-05 1978-12-28  8.0    NA     NA       <NA>
#> 102 RD6KMA <NA> <NA>   F   0 1968-12-13 1992-04-15 23.3 10003  20003     first3
#> 103 HRBVOE <NA> <NA>   M   0 1970-12-04 1993-05-01 22.4 10004  20004     first4
#> 107 ZSDDUI <NA> <NA>   F   0 1969-12-10 2001-03-16 31.3 10008  20008     first8
#>     second_name
#> 91         <NA>
#> 92         <NA>
#> 95         <NA>
#> 102     second3
#> 103     second4
#> 107     second8
```
