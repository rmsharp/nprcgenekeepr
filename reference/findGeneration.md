# Determine the generation number for each ID

This loops through the entire pedigree one generation at a time. It
finds the zeroth generation during first loop. The first time through
this loop no sire or dam is in parents. This means that the animals
without a sire and without a dam are assigned to generation 0 and become
the first parental generation. The second time through this loop finds
all of the animals that do not have a sire or do not have a dam and at
least one parent is in the vector of parents defined the first time
through. The ids that were not assigned as parents in the previous loop
are given the incremented generation number.

## Usage

``` r
findGeneration(id, sire, dam)
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

An integer vector indication the generation numbers for each id,
starting at 0 for individuals lacking IDs for both parents. Any id that
cannot be placed — e.g. when the pedigree contains a cycle or references
a parent ID that is not itself present as an ego ID — is returned as
`NA` and triggers a `warning` naming the affected ids.

## Details

Subsequent trips in the loop repeat what was done the second time
through until no further animals can be added to the `nextGen` vector.

This does not work if the pedigree does not have all parent IDs as ego
IDs.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped[, c("id", "sire", "dam")]
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
ped
#>   id sire  dam gen
#> 1  A <NA> <NA>   0
#> 2  B <NA> <NA>   0
#> 3  C    A    B   1
#> 4  D    A    B   1
#> 5  E <NA> <NA>   0
#> 6  F    D    E   2
#> 7  G    D    E   2
```
