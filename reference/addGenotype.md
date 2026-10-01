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

A plain `data.frame` (not a special pedigree class) with the rows of
`ped` plus integer columns `first` and `second` holding the allele codes
(numbered from 10001).

## Details

The two allele columns are coerced to character internally so the
name-keyed allele dictionary is both built and indexed by allele label.
This keeps the integer encoding consistent even when the allele columns
are supplied as factors (a factor would otherwise be indexed by its
integer codes). The allele columns are taken by position (columns 2 and
3 of `genotype`), not by name. The result is the output of a full outer
[`merge()`](https://rdrr.io/r/base/merge.html) on `id`, so genotype ids
that are absent from `ped` are added as extra rows.

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
