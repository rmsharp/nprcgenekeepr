# Identify the founders in a pedigree

Part of Pedigree Curation

## Usage

``` r
isFounder(ped)
```

## Arguments

- ped:

  a pedigree `data.frame` with (at least) the columns `sire` and `dam`.

## Value

A logical vector with one element per row of `ped` that is `TRUE` for
each animal whose sire and dam are both `NA`. The result never contains
`NA`.

## Details

A founder is an animal whose sire and dam are both unknown (`NA`).
Animals with exactly one known parent (partial parentage) are **not**
founders.

## See also

[`getFounders`](https://github.com/rmsharp/nprcgenekeepr/reference/getFounders.md)
for the founder `id` values.

## Examples

``` r
library(nprcgenekeepr)
ped <- data.frame(
  id = c("A", "B", "C", "D", "E", "F", "G"),
  sire = c(NA, NA, "A", "A", NA, "D", "D"),
  dam = c(NA, NA, "B", "B", NA, "E", "E"),
  stringsAsFactors = FALSE
)
isFounder(ped)
#> [1]  TRUE  TRUE FALSE FALSE  TRUE FALSE FALSE
```
