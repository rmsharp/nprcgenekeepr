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

Calculates the first-order relationships in a pedigree, and to convert
pairwise kinships to the appropriate relationship category.

Relationships categories: For each ID in the pair, find a CEPH-style
pedigree and compare them

- If one is the parent of the other — Designate the relationship as
  `parent-offspring`

- Else if both parents are shared — Designate the relationship as
  `full-siblings`

- Else if one parent is shared — Designate the relationship as
  `half-siblings`

- Else if one is the grandparent of the other — Designate the
  relationship as `grandparent-grandchild`

- Else if both grand parents are shared — Designate the relationship as
  `cousin`

- Else if at least one grand parent is shared — Designate the
  relationship as `cousin - other`

- Else if the parents of one are the grandparents of the other —
  Designate the relationship as `full-avuncular`

- Else if a single parent of one is the grandparent of the other —
  Designate the relationship as `avuncular - other`

- Else if the kinship is greater than 0, but the pair don't fall into
  the above categories — Designate the relationship as `other`

- Else — Designate the relationships as `no relation.`

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
