# Count each individual's rare alleles per simulation

Part of Genetic Value Analysis

## Usage

``` r
calcA(alleles, threshold = 1L, byID = FALSE)
```

## Arguments

- alleles:

  a matrix with {V1 ... Vn, id, parent} providing the alleles an animal
  received during each simulation. The first n columns provide the
  alleles; the final two columns provide the animal ID and the parent
  the allele came from.

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

## See also

Other genetic value analysis:
[`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
[`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md),
[`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`calcGeneDiversity()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md),
[`calcNeSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md),
[`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)

## Examples

``` r
library(nprcgenekeepr)
rare <- calcA(nprcgenekeepr::ped1Alleles, threshold = 3, byID = FALSE)
```
