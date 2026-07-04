# Count first-order relatives

Part of Relations

## Usage

``` r
countFirstOrder(ped, ids = NULL)
```

## Arguments

- ped:

  The pedigree information in data.frame format

- ids:

  character vector of IDs or NULL These are the IDs to which the
  analysis should be restricted. First-order relationships will only be
  tallied for the listed IDs and will only consider relationships within
  the subset. If NULL, the analysis will include all IDs in the
  pedigree.

## Value

A dataframe with column `id`, `parents`, `offspring`, `siblings`, and
`total`. A table of first-order relationship counts, broken down to
indicate the number of parents, offspring, and siblings that are part of
the subset under consideration.

## Details

Tallies the number of first-order relatives for each member of the
provided pedigree. If 'ids' is provided, the analysis is restricted to
only the specified subset.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
ids <- c("B", "D", "E", "F", "G")
countIds <- countFirstOrder(ped, ids)
countIds
#>   id parents offspring siblings total
#> 1  B       0         1        0     1
#> 2  D       1         2        0     3
#> 3  E       0         2        0     2
#> 4  F       2         0        1     3
#> 5  G       2         0        1     3
count <- countFirstOrder(ped, NULL)
count
#>   id parents offspring siblings total
#> 1  A       0         2        0     2
#> 2  B       0         2        0     2
#> 3  C       2         0        1     3
#> 4  D       2         2        1     5
#> 5  E       0         2        0     2
#> 6  F       2         0        1     3
#> 7  G       2         0        1     3
```
