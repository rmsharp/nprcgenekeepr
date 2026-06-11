# Calculates `a`, the number of an individual's alleles that are rare in each simulation.

Part of Genetic Value Analysis

## Usage

``` r
calcA(alleles, threshold = 1L, byID = FALSE)
```

## Arguments

- alleles:

  a matrix with {id, parent, V1 ... Vn} providing the alleles an animal
  received during each simulation. The first 2 columns provide the
  animal ID and the parent the allele came from. Remaining columns
  provide alleles.

- threshold:

  an integer indicating the maximum number of copies of an allele that
  can be present in the population for it to be considered rare. Default
  is 1.

- byID:

  logical variable of length 1 that is passed through to eventually be
  used by
  [`alleleFreq()`](https://github.com/rmsharp/nprcgenekeepr/reference/alleleFreq.md),
  which calculates the count of each allele in the provided vector. If
  `byID` is TRUE and ids are provided, the function will only count the
  unique alleles for an individual (homozygous alleles will be counted
  as 1).

## Value

A matrix with named rows indicating the number of unique alleles an
animal had during each round of simulation (indicated in columns).

## Examples

``` r
library(nprcgenekeepr)
rare <- calcA(nprcgenekeepr::ped1Alleles, threshold = 3, byID = FALSE)
```
