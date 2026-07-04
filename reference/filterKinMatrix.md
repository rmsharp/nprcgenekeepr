# Filter a kinship matrix to selected IDs

Filter a kinship matrix to selected IDs

## Usage

``` r
filterKinMatrix(ids, kmat)
```

## Arguments

- ids:

  character vector containing the IDs of interest. The kinship matrix
  should be reduced to only include these rows and columns.

- kmat:

  a numeric matrix of pairwise kinship coefficients. Animal IDs are the
  row and column names.

## Value

A numeric matrix that is the reduced kinship matrix with named rows and
columns (row and col names are 'ids').

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::qcPed
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen,
  sparse = FALSE
)
ids <- ped$id[c(189, 192, 194, 195)]
ncol(kmat)
#> [1] 280
nrow(kmat)
#> [1] 280
kmatFiltered <- filterKinMatrix(ids, kmat)
ncol(kmatFiltered)
#> [1] 4
nrow(kmatFiltered)
#> [1] 4
```
