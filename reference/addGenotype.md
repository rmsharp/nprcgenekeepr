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

## Details

The two allele columns are coerced to character internally so the
name-keyed allele dictionary is both built and indexed by allele label.
This keeps the integer encoding consistent even when the allele columns
are supplied as factors (a factor would otherwise be indexed by its
integer codes).

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
