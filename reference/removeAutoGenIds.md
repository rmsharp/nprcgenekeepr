# Remove automatically generated IDs from pedigree

Identifies automatically generated IDs via `isGeneratedUnknownId()`, the
shared detection predicate derived from the configurable auto-ID format
(see
[`getAutoIdFormat`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md);
default a leading "U"). Routing detection through that single predicate
is the "function call" the former inline leading-"U" check was flagged
to become.

## Usage

``` r
removeAutoGenIds(ped)
```

## Arguments

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.
  The `id`, `sire`, and `dame` columns are required.

## Value

A pedigree with automatically generated IDs removed.

## Examples

``` r
examplePedigree <- nprcgenekeepr::examplePedigree
length(examplePedigree$id)
#> [1] 3694
ped <- removeAutoGenIds(examplePedigree)
length(ped$id)
#> [1] 2322
```
