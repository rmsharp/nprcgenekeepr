# Calculate mean kinship for each animal in a kinship matrix

Part of Genetic Value Analysis

## Usage

``` r
meanKinship(kmat)
```

## Arguments

- kmat:

  a numeric matrix of pairwise kinship coefficients. Animal IDs are the
  row and column names.

## Value

A named numeric vector of average kinship coefficients for each animal
ID. Elements are named with the IDs from the columns of kmat.

## Details

The mean kinship of animal *i* is \$\$MK_i = \Sigma f_ij / N\$\$, in
which the summation is over all animals, *j*, including the kinship of
animal *i* to itself.

## References

Ballou JD, Lacy RC. 1995. Identifying genetically important individuals
for management of genetic variation in pedigreed populations, p 77-111.
In: Ballou JD, Gilpin M, Foose TJ, editors. Population management for
survival and recovery. New York (NY): Columbia University Press.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::qcPed
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
head(meanKinship(kmat))
#>      4LFS70      81KHJN      IU065S      H7R5WN      YAYD44      BRLQFI 
#> 0.003459821 0.003348214 0.003459821 0.005468750 0.003459821 0.003125000 
```
