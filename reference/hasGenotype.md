# Check for genotype data in dataframe

Checks to ensure the content and structure are appropriate for genotype
data are in the dataframe and ready for the `geneDrop` function by
already being mapped to integers and placed in columns named `first` and
`second`. These checks are simply based on expected columns and legal
domains.

## Usage

``` r
hasGenotype(genotype)
```

## Arguments

- genotype:

  dataframe with genotype data

## Value

A logical value representing whether or not the data.frame passed in
contains genotypic data that can be used. Non-standard column names are
accepted for this assessment.

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
