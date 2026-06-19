# Example studbook with sex-mismatched parents

A data frame with 8 rows and 5 columns (ego_id, sire.id, dam_id, sex,
birth_date) representing a full pedigree with the errors of having a
sire labeled as female and a dam labeled as male.

## Usage

``` r
data(pedFemaleSireMaleDam)
```

## Format

An object of class `data.frame` with 8 rows and 5 columns.

## Details

It is one of six pedigrees (`pedDuplicateIds`, `pedFemaleSireMaleDam`,
`pedGood`, `pedInvalidDates`, `pedMissingBirth`,
`pedSameMaleIsSireAndDam`) used to demonstrate error detection by the
qcStudbook function.
