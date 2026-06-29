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
