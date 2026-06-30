# Add parents

Pedigree curation function Given a pedigree, find any IDs listed in the
"sire" or "dam" columns that lack their own line entry and generate one.

## Usage

``` r
addParents(ped)
```

## Arguments

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.

## Value

An updated pedigree with entries added as necessary. Entries have the id
and sex specified; all remaining columns are filled with `NA`.

## Details

This must be run after to `addUIds` since the IDs made there are used by
`addParents`

## Examples

``` r
pedTwo <- data.frame(
  id = c("d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, NA, NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, NA, NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "M", "F", "F", "F", "F", "M"),
  stringsAsFactors = FALSE
)
newPed <- addParents(pedTwo)
newPed
#>   id sire  dam sex recordStatus
#> 1 d1 <NA> <NA>   F     original
#> 2 s2 <NA> <NA>   M     original
#> 3 d2 <NA> <NA>   F     original
#> 4 o1   s1   d1   F     original
#> 5 o2   s1   d2   F     original
#> 6 o3   s2   d2   F     original
#> 7 o4   s2   d2   M     original
#> 8 s1 <NA> <NA>   M        added
```
