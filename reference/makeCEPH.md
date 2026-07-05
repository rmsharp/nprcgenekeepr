# Make a CEPH-style pedigree for each id

Part of Relations

## Usage

``` r
makeCEPH(id, sire, dam)
```

## Arguments

- id:

  character vector with unique identifier for an individual

- sire:

  character vector with unique identifier for an individual's father
  (`NA` if unknown).

- dam:

  character vector with unique identifier for an individual's mother
  (`NA` if unknown).

## Value

List of lists: fields: id, subfields: parents, pgp, mgp. Pedigree
information converted into a CEPH-style list. The top level list
elements are the IDs from id. Below each ID is a list of three elements:
parents (sire, dam), paternal grandparents (pgp: sire, dam), and
maternal grandparents (mgp: sire, dam).

## Details

Creates a CEPH-style pedigree for each id, consisting of three
generations: the id, the parents, and the grandparents. Inserts NA for
unknown pedigree members.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
pedCEPH <- makeCEPH(ped$id, ped$sire, ped$dam)
head(ped)
#>   id sire  dam gen population
#> 1  A <NA> <NA>   0       TRUE
#> 2  B <NA> <NA>   0       TRUE
#> 3  C    A    B   1       TRUE
#> 4  D    A    B   1       TRUE
#> 5  E <NA> <NA>   0       TRUE
#> 6  F    D    E   2       TRUE
head(pedCEPH$F)
#> $parents
#> [1] "D" "E"
#> 
#> $pgp
#> [1] "A" "B"
#> 
#> $mgp
#> [1] NA NA
#> 
```
