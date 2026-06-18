# Converts pairwise kinship values to a relationship category descriptor

Part of Relations

## Usage

``` r
convertRelationships(kmat, ped, ids = NULL, updateProgress = NULL)
```

## Arguments

- kmat:

  a numeric matrix of pairwise kinship coefficients. Rows and columns
  should be named with IDs.

- ped:

  the pedigree information in datatable format with required colnames
  `id`, `sire`, and `dam`.

- ids:

  character vector of IDs or NULL to which the analysis should be
  restricted. If provided, only relationships between these IDs will be
  converted to relationships.

- updateProgress:

  function or NULL. If this function is defined, it will be called
  during each iteration to update a
  [`shiny::Progress`](https://rdrr.io/pkg/shiny/man/Progress.html)
  object.

## Value

A dataframe with columns `id1`, `id2`, `kinship`, `relation`. It is a
long-form table of pairwise kinships, with relationship categories
included for each pair.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::smallPed
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
ids <- c("A", "B", "D", "E", "F", "G", "I", "J", "L", "M", "O", "P")
relIds <- convertRelationships(kmat, ped, ids)
rel <- convertRelationships(kmat, ped, updateProgress = function() {})
head(rel)
#>   id1 id2 kinship               relation
#> 1   A   A   0.500                   Self
#> 2   A   B   0.000            No Relation
#> 3   A   C   0.250       Parent-Offspring
#> 4   A   D   0.250       Parent-Offspring
#> 5   A   E   0.000            No Relation
#> 6   A   F   0.125 Grandparent-Grandchild
ped <- nprcgenekeepr::qcPed
bkmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen,
  sparse = FALSE
)
relBIds <- convertRelationships(bkmat, ped, c("4LFS70", "DD1U77"))
relBIds
#>      id1    id2 kinship relation
#> 1 4LFS70 4LFS70 0.50000     Self
#> 2 4LFS70 DD1U77 0.03125    Other
#> 4 DD1U77 DD1U77 0.50000     Self
```
