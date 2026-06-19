# Obfuscated rhesus pedigree object

A pedigree object. Represents an obfuscated pedigree from
*obfuscated_rhesus_mhc_ped.csv* where the IDs and dates have been
modified to de-identify the data.

- id:

  – character column of animal IDs

- sire:

  – the male parent of the animal indicated by the `id` column. Unknown
  sires are indicated with `NA`

- dam:

  – the female parent of the animal indicated by the `id` column.
  Unknown dams are indicated with `NA`

- sex:

  – factor with levels: "F", "M". Sex specifier for an individual.

- gen:

  – generation number (integers beginning with 0 for the founder
  generation) of the animal indicated by the `id` column.

- birth:

  – `Date` vector of birth dates

- exit:

  – `Date` vector, all `NA` (no exit dates are recorded in this
  obfuscated pedigree)

- age:

  – numerical vector of age in years

## Usage

``` r
data(rhesusPedigree)
```

## Format

An object of class `data.frame` with 375 rows and 8 columns.

## Examples

``` r
library(nprcgenekeepr)
data("rhesusPedigree")
```
