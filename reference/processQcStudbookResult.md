# Process qcStudbook Result into UI-Friendly Format

Converts the errorLst object returned by qcStudbook (when
reportErrors=TRUE) into a format suitable for display in the Shiny UI.

## Usage

``` r
processQcStudbookResult(errorLst)
```

## Arguments

- errorLst:

  list object returned by `qcStudbook` with `reportErrors = TRUE`, or
  NULL. Expected to be of class `nprcgenekeeprErr` containing error
  fields such as femaleSires, maleDams, sireAndDam, duplicateIds,
  invalidIdChars, missingColumns, invalidDateRows, suspiciousParents,
  failedDatabaseConnection, and changedCols.

## Value

A list with the following components:

- `errors` - data.frame with columns Row, Error, Details

- `warnings` - data.frame with columns Row, Warning, Details

- `changedCols` - list of changed column information

- `hasErrors` - logical indicating if any errors were found

- `hasChangedCols` - logical indicating if columns were renamed

## See also

[`qcStudbook`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
for generating the errorLst input

[`runQcStudbook`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md)
for a wrapper that uses this function

[`checkErrorLst`](https://github.com/rmsharp/nprcgenekeepr/reference/checkErrorLst.md)
for checking if errorLst has errors

[`checkChangedColsLst`](https://github.com/rmsharp/nprcgenekeepr/reference/checkChangedColsLst.md)
for checking column changes

## Examples

``` r
library(nprcgenekeepr)
## Turn a qcStudbook error list into UI-friendly data frames.
errorLst <- qcStudbook(nprcgenekeepr::pedFemaleSireMaleDam,
  reportErrors = TRUE
)
result <- processQcStudbookResult(errorLst)
result$hasErrors
#> [1] TRUE
result$errors
#>   Row                 Error                                  Details
#> 1  NA Female listed as sire Animal s1 is female but listed as a sire
#> 2  NA    Male listed as dam    Animal d1 is male but listed as a dam
```
