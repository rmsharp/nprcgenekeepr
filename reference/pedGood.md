# Valid example studbook (no QC errors)

A data frame with 8 rows and 5 columns (ego_id, si.re, dam_id, sex,
birth_date) representing a full pedigree with no errors.

## Usage

``` r
data(pedGood)
```

## Format

An object of class `data.frame` with 8 rows and 5 columns.

## Details

It is one of six pedigrees (`pedDuplicateIds`, `pedFemaleSireMaleDam`,
`pedGood`, `pedInvalidDates`, `pedMissingBirth`,
`pedSameMaleIsSireAndDam`) used to demonstrate error detection by the
qcStudbook function.
