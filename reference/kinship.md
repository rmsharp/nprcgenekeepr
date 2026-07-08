# Generate a kinship matrix

The function previously had an internal call to the kindepth function in
order to provide the parameter pdepth (the generation number). This
version requires the generation number to be calculated elsewhere and
passed into the function.

## Usage

``` r
kinship(id, father.id, mother.id, pdepth, sparse = FALSE)
```

## Arguments

- id:

  character vector of IDs for a set of animals.

- father.id:

  character vector or NA for the IDs of the sires for the set of
  animals.

- mother.id:

  character vector or NA for the IDs of the dams for the set of animals.

- pdepth:

  integer vector indicating the generation number for each animal.

- sparse:

  logical flag. If `TRUE`, `Matrix::Diagnol()` is used to make a unit
  diagonal matrix. If `FALSE`,
  [`base::diag()`](https://rdrr.io/r/base/diag.html) is used to make a
  unit square matrix.

## Value

A kinship square matrix

## Details

The rows (cols) of founders are just 0.5 \* identity matrix, no further
processing is needed for them. Parents must be processed before their
children, and then a child's kinship is just a sum of the kinship's for
his or her parents.

The code for the kinship function was written by Terry Therneau at the
Mayo clinic and taken from his website. This function is part of a
package written in S (and later ported to R) for calculating kinship and
other statistics.

## References

<https://cran.r-project.org/package=kinship2>

\$Id: kinship.s,v 1.5 2003/01/04 19:07:53 therneau Exp \$

Create the kinship matrix, using the algorithm of K Lange, Mathematical
and Statistical Methods for Genetic Analysis, Springer, 1997, p 71-72.

## Author

Terry M. Therneau, Mayo Clinic (mayo.edu), original version

All of the code on the original S-Plus kinship function (originally
hosted on Terry Therneau's Mayo Clinic software page, offline since at
least 2019) was stated to be released under the GNU General Public
License (version 2 or later).

The R version became the kinship2 package available on CRAN:

as modified by M Raboin, 2014-09-08 14:44:26

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
ped
#>   id sire  dam gen population
#> 1  A <NA> <NA>   0       TRUE
#> 2  B <NA> <NA>   0       TRUE
#> 3  C    A    B   1       TRUE
#> 4  D    A    B   1       TRUE
#> 5  E <NA> <NA>   0       TRUE
#> 6  F    D    E   2       TRUE
#> 7  G    D    E   2       TRUE
kmat
#>       A     B     C    D    E     F     G
#> A 0.500 0.000 0.250 0.25 0.00 0.125 0.125
#> B 0.000 0.500 0.250 0.25 0.00 0.125 0.125
#> C 0.250 0.250 0.500 0.25 0.00 0.125 0.125
#> D 0.250 0.250 0.250 0.50 0.00 0.250 0.250
#> E 0.000 0.000 0.000 0.00 0.50 0.250 0.250
#> F 0.125 0.125 0.125 0.25 0.25 0.500 0.250
#> G 0.125 0.125 0.125 0.25 0.25 0.250 0.500
```
