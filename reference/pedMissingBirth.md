# Example studbook missing the birth date column

A data frame with 8 rows and 4 columns (ego_id, si.re, dam_id, sex)
representing a full pedigree that is missing the birth_date column.

## Usage

``` r
data(pedMissingBirth)
```

## Format

An object of class `data.frame` with 8 rows and 4 columns.

## Details

It is one of six pedigrees (`pedDuplicateIds`, `pedFemaleSireMaleDam`,
`pedGood`, `pedInvalidDates`, `pedMissingBirth`,
`pedSameMaleIsSireAndDam`) used to demonstrate error detection by the
qcStudbook function.
