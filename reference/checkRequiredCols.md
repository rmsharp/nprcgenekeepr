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

  logical value with no default. When `TRUE` and required columns are
  missing, a character vector of the names of the missing columns is
  returned. When `FALSE` and required columns are missing, the program
  stops with the error `"Required field(s) missing: ..."`.

## Value

`NULL` is returned if all required columns are present. See description
of `reportErrors` for what happens when required columns are missing.

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
cols <- strsplit(
  paste0(
    "id,sire,siretype,dam,damtype,sex,numberofparentsknown,birth,",
    "arrivalatcenter,death,departure,status,ancestry,fromcenter?,",
    "origin"
  ),
  ","
)[[1L]]
checkRequiredCols(cols, reportErrors = TRUE) # NULL: all required present
#> NULL
# A missing required column is returned by name
checkRequiredCols(setdiff(cols, "birth"), reportErrors = TRUE)
#> [1] "birth"
```
