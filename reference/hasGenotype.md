# Check for genotype data in dataframe

Checks to ensure the content and structure are appropriate for genotype
data are in the dataframe and ready for the `geneDrop` function by
already being mapped to numbers (integer codes are expected, but any
numeric value passes) and placed in columns named `first` and `second`.
Only the `id` column is matched loosely (any column whose lower-cased
name contains `"id"`). The allele columns must be named exactly `first`
and `second` and be numeric; no check is made of the values' range, so
negative, missing or very large numbers still give `TRUE`.

## Usage

``` r
hasGenotype(genotype)
```

## Arguments

- genotype:

  dataframe with genotype data

## Value

A logical value representing whether or not the data.frame passed in
contains genotypic data that can be used. Columns named `First` or
`Second` (other cases) give `FALSE`.

## Examples

``` r
library(nprcgenekeepr)
rhesusPedigree <- nprcgenekeepr::rhesusPedigree
rhesusGenotypes <- nprcgenekeepr::rhesusGenotypes
pedWithGenotypes <- addGenotype(
  ped = rhesusPedigree,
  genotype = rhesusGenotypes
)
hasGenotype(pedWithGenotypes)
#> [1] TRUE
```
