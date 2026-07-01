# Run Quality Control on Studbook with UI-Friendly Results

Wrapper function that runs `qcStudbook` and processes results into a
format suitable for Shiny UI display. This function performs two passes:
first to check for errors, then to get the cleaned data if no errors
exist.

## Usage

``` r
runQcStudbook(ped, minParentAge = 2, reportChanges = FALSE)
```

## Arguments

- ped:

  data.frame containing pedigree data with columns including id, sire,
  dam, sex, and optionally birth, death, departure, etc.

- minParentAge:

  numeric minimum age in years for parents (default 2.0). Parents
  younger than this at the time of offspring birth are flagged.

- reportChanges:

  logical whether to report column name changes in the result (default
  FALSE). When TRUE, warnings about renamed columns are included in the
  qcResult.

## Value

A list with the following components:

- `cleaned` - The cleaned pedigree data.frame with standardized column
  names, added generation numbers, etc. NULL if errors were found.

- `qcResult` - Result from `processQcStudbookResult` containing errors,
  warnings, changedCols, hasErrors, and hasChangedCols.

## See also

[`qcStudbook`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
for the underlying QC function

[`processQcStudbookResult`](https://github.com/rmsharp/nprcgenekeepr/reference/processQcStudbookResult.md)
for result processing

[`modInputServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md)
for Shiny module integration

## Examples

``` r
data("pedGood", package = "nprcgenekeepr")
result <- runQcStudbook(pedGood, minParentAge = 2.0)
if (!result$qcResult$hasErrors) {
  cleanedPed <- result$cleaned
}
```
