# Add genotype data to pedigree file

Assumes genotype has been opened by `checkGenotypeFile`

## Usage

``` r
addGenotype(ped, genotype)
```

## Arguments

- ped:

  pedigree dataframe. `ped` is to be provided by `qcStudbook` so it is
  not checked.

- genotype:

  genotype dataframe. `genotype` is to be provided by
  `checkGenotypeFile` so it is not checked.

## Value

A pedigree object with genotype data added.

## Examples

``` r
library(nprcgenekeepr)
rhesusPedigree <- nprcgenekeepr::rhesusPedigree
rhesusGenotypes <- nprcgenekeepr::rhesusGenotypes
pedWithGenotypes <- addGenotype(
  ped = rhesusPedigree,
  genotype = rhesusGenotypes
)
```
