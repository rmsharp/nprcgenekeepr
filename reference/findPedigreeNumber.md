# Determines the pedigree number for each id

One of Pedigree Curation functions

## Usage

``` r
findPedigreeNumber(id, sire, dam)
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

Integer vector indicating generation numbers for each id, starting at 0
for individuals lacking IDs for both parents.

## Examples

``` r
library(nprcgenekeepr)
library(stringi)
ped <- nprcgenekeepr::lacy1989Ped
ped$gen <- NULL
ped$population <- NULL
ped2 <- ped
ped2$id <- stri_c(ped$id, "2")
ped2$sire <- stri_c(ped$sire, "2")
ped2$dam <- stri_c(ped$dam, "2")
ped3 <- ped
ped3$id <- stri_c(ped$id, "3")
ped3$sire <- stri_c(ped$sire, "3")
ped3$dam <- stri_c(ped$dam, "3")
ped <- rbind(ped, ped2)
ped <- rbind(ped, ped3)
ped$pedigree <- findPedigreeNumber(ped$id, ped$sire, ped$dam)
ped$pedigree
#>  [1] 1 1 1 1 1 1 1 2 2 2 2 2 2 2 3 3 3 3 3 3 3
```
