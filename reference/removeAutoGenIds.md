# Remove automatically generated IDs from pedigree

Identifies automatically generated IDs via `isGeneratedUnknownId()`, the
shared detection predicate derived from the configurable auto-ID format
(see
[`getAutoIdFormat`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md)).
With the default `"U%04d"`, an automatically generated ID is a capital
"U" followed by at least four capital letters or digits (`"U0001"`, or
`"U05X3C"` after de-identification). A real animal whose ID merely
starts with "U" (`"U1"`, `"U123"`, `"Uma"`) is kept, and so is its place
as a sire or dam; a real ID of the full shape (`"U1234"`) is removed.

## Usage

``` r
removeAutoGenIds(ped)
```

## Arguments

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.
  The fields `id`, `sire` and `dam` are required.

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
