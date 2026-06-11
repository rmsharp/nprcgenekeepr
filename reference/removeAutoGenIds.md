# Remove automatically generated IDs from pedigree

Currently uses leading "U" to identify automatically generated IDs. TODO
change identification of automatically generated IDs from looking for an
initial "U" at the beginning of an ID to a function call so that actual
ID that start with a "U" are possible.

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
