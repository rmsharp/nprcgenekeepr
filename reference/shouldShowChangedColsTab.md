# Determine if Changed Columns tab should be displayed

Checks the changedCols list to determine if the Changed Columns tab
should be inserted into the application navigation. The tab is shown
when column names were modified during QC processing.

## Usage

``` r
shouldShowChangedColsTab(changedCols)
```

## Arguments

- changedCols:

  list containing information about changed column names. Expected
  fields include: `caseChange`, `spaceRemoved`, `periodRemoved`,
  `underScoreRemoved`, `egoToId`, `egoidToId`, `sireIdToSire`,
  `damIdToDam`, `birthdateToBirth`, `deathdateToDeath`,
  `recordstatusToRecordStatus`, `fromcenterToFromCenter`.

## Value

Logical. TRUE if columns were changed and tab should be shown, FALSE
otherwise.

## See also

[`checkChangedColsLst`](https://github.com/rmsharp/nprcgenekeepr/reference/checkChangedColsLst.md)
for the original implementation

## Examples

``` r
library(nprcgenekeepr)
## No column changes recorded: the tab stays hidden.
shouldShowChangedColsTab(list())
#> [1] FALSE
## A recorded case change: the tab should be shown.
shouldShowChangedColsTab(list(caseChange = c(Id = "id")))
#> [1] TRUE
```
