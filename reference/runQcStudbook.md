# Run Quality Control on Studbook with UI-Friendly Results

Wrapper function that runs `qcStudbook` and processes results into a
format suitable for Shiny UI display. This function performs two passes:
first to check for errors, then to get the cleaned data if no errors
exist.

## Usage

``` r
runQcStudbook(
  ped,
  minSireAge = NULL,
  minDamAge = NULL,
  minParentAge = lifecycle::deprecated(),
  reportChanges = FALSE
)
```

## Arguments

- ped:

  data.frame containing pedigree data with columns including id, sire,
  dam, sex, and optionally birth, death, departure, etc.

- minSireAge:

  numeric minimum age in years for a male to have sired an offspring.
  `NULL` (default) looks up each sire's species floor via
  [`getSpeciesMinBreedingAge`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md)
  (2 years when species is unknown); a supplied value overrides that
  floor.

- minDamAge:

  numeric minimum age in years for a female to have borne an offspring.
  `NULL` (default) looks up each dam's species floor via
  [`getSpeciesMinBreedingAge`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md)
  (2 years when species is unknown); a supplied value overrides that
  floor.

- minParentAge:

  **\[deprecated\]** Deprecated scalar minimum parent age. Supplying it
  sets both `minSireAge` and `minDamAge`; use those sex-specific
  parameters instead.

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

- `errorLst` - The raw `nprcgenekeeprErr` list from `qcStudbook`'s first
  pass (the same object `qcResult` was derived from), exposed so callers
  that need the raw fields (e.g. `femaleSires`,
  `failedDatabaseConnection`) do not have to call `qcStudbook` a second
  time themselves.

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
result <- runQcStudbook(pedGood, minSireAge = 2.0, minDamAge = 2.0)
if (!result$qcResult$hasErrors) {
  cleanedPed <- result$cleaned
}
```
