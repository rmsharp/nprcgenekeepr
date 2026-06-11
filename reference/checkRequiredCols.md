# Examines column names, `cols` for required column names

Examines column names, `cols` for required column names

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
