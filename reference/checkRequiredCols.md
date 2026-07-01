# Check column names for required columns

Check column names for required columns

## Usage

``` r
checkRequiredCols(cols, reportErrors)
```

## Arguments

- cols:

  character vector of column names

- reportErrors:

  logical value when `TRUE` and missing columns are found the `errorLst`
  object is updated with the names of the missing columns and returned
  and when `FALSE` and missing columns are found the program is stopped.

## Value

NULL is returned if all required columns are present. See description of
`reportErrors` for return values when required columns are missing.

## Details

When `reportErrors = TRUE`, `NA` entries in `cols` are treated as
ordinary non-matching column names when building the list of missing
required columns, rather than causing an error. (Earlier versions could
error with `"missing value where TRUE/FALSE needed"` on such
out-of-contract input.)

## Examples

``` r
library(nprcgenekeepr)
requiredCols <- getRequiredCols()
cols <-
  paste0(
    "id,sire,siretype,dam,damtype,sex,numberofparentsknown,birth,",
    "arrivalatcenter,death,departure,status,ancestry,fromcenter?,",
    "origin"
  )
all(requiredCols %in% checkRequiredCols(cols, reportErrors = TRUE))
#> [1] TRUE
```
