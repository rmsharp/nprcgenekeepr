# Example quality-controlled baboon pedigree

A data frame with 280 rows and 8 columns.

- id:

  character column of animal IDs

- sire:

  the male parent of the animal indicated by the `id` column.

- dam:

  the female parent of the animal indicated by the `id` column.

- sex:

  sex of the animal indicated by the `id` column.

- gen:

  generation number (integers beginning with 0 for the founder
  generation) of the animal indicated by the `id` column.

- birth:

  birth date in `Date` format of the animal indicated by the `id`
  column.

- exit:

  exit date in `Date` format of the animal indicated by the `id` column.

- age:

  age in year (numeric) of the animal indicated by the `id` column.

## Usage

``` r
data(qcPed)
```

## Format

An object of class `data.frame` with 280 rows and 8 columns.
