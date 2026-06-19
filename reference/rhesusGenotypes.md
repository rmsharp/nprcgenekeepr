# Rhesus genotypes (two haplotypes per animal)

A dataframe with two haplotypes per animal.

## Usage

``` r
data(rhesusGenotypes)
```

## Format

An object of class `data.frame` with 31 rows and 3 columns.

## Details

There are 31 rows and 3 columns.

Represents 31 animals that are also in the obfuscated `rhesusPedigree`
pedigree from *obfuscated_rhesus_mhc_breeder_genotypes.csv*.

- id:

  – character column of animal IDs

- first_name:

  – a generic name for the first haplotype

- second_name:

  – a generic name for the second haplotype

## Examples

``` r
library(nprcgenekeepr)
data("rhesusGenotypes")
```
