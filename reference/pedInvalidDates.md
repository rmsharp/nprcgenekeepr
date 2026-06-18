# Example studbook with invalid birth dates

A data frame with 8 rows and 5 columns (id, sire, dam, sex, birth)
representing a full pedigree with values in the `birth` column that are
not valid dates.

## Usage

``` r
data(pedInvalidDates)
```

## Format

An object of class `data.frame` with 8 rows and 5 columns.

## Details

It is one of six pedigrees (`pedDuplicateIds`, `pedFemaleSireMaleDam`,
`pedGood`, `pedInvalidDates`, `pedMissingBirth`,
`pedSameMaleIsSireAndDam`) used to demonstrate error detection by the
qcStudbook function.
