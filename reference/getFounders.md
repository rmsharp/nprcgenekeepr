# Get the founder ids from a pedigree

Part of Pedigree Curation

## Usage

``` r
getFounders(ped)
```

## Arguments

- ped:

  a pedigree `data.frame` with (at least) the columns `id`, `sire`, and
  `dam`.

## Value

A vector of the `id` values of the founders, in pedigree order. It has
the same type as `ped$id` and is empty when there are no founders.

## Details

A founder is an animal whose sire and dam are both unknown (`NA`).
Animals with exactly one known parent (partial parentage) are **not**
founders.

## See also

[`isFounder`](https://github.com/rmsharp/nprcgenekeepr/reference/isFounder.md)
for the founder logical mask.

## Examples

``` r
library(nprcgenekeepr)
ped <- data.frame(
  id = c("A", "B", "C", "D", "E", "F", "G"),
  sire = c(NA, NA, "A", "A", NA, "D", "D"),
  dam = c(NA, NA, "B", "B", NA, "E", "E"),
  stringsAsFactors = FALSE
)
getFounders(ped)
#> [1] "A" "B" "E"
```
