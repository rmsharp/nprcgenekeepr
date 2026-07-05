# Remove duplicate records from pedigree

Part of Pedigree Curation

## Usage

``` r
removeDuplicates(ped, reportErrors = FALSE)
```

## Arguments

- ped:

  dataframe that is the `Pedigree`. It contains pedigree information.
  The `id` and `recordStatus` columns are required.

- reportErrors:

  logical value if TRUE the function returns a character vector of
  duplicate `id` values found among original records (or `NULL` when
  none are found) instead of the de-duplicated pedigree.

## Value

When `reportErrors` is `FALSE`, a `Pedigree` object with duplicate rows
removed; when `reportErrors` is `TRUE`, a character vector of duplicate
`id` values (or `NULL` when none are found).

## Details

Returns an updated dataframe with duplicate rows removed.

Returns an error if the table has duplicate IDs with differing data.

## Examples

``` r
ped <- nprcgenekeepr::smallPed
newPed <- cbind(ped, recordStatus = rep("original", nrow(ped)))
ped1 <- removeDuplicates(newPed)
nrow(newPed)
#> [1] 17
nrow(ped1)
#> [1] 17
pedWithDups <- rbind(newPed, newPed[1:3, ])
ped2 <- removeDuplicates(pedWithDups)
nrow(pedWithDups)
#> [1] 20
nrow(ped2)
#> [1] 17
```
