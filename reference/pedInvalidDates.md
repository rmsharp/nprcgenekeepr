# pedInvalidDates is a dataframe with 8 rows and 5 columns (ego_id, sire, dam_id, sex, birth_date) representing a full pedigree with values in the `birth_date` column that are not valid dates.

It is one of six pedigrees (`pedDuplicateIds`, `pedFemaleSireMaleDam`,
`pedgood`, `pedInvalidDates`, `pedMissingBirth`,
`pedSameMaleIsSireAndDam`) used to demonstrate error detection by the
qcStudbook function.

## Usage

``` r
pedInvalidDates
```

## Format

An object of class `data.frame` with 8 rows and 5 columns.
