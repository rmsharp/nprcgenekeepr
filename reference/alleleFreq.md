# Count each allele in a vector

Part of Genetic Value Analysis

## Usage

``` r
alleleFreq(alleles, ids = NULL)
```

## Arguments

- alleles:

  an integer vector of alleles in the population

- ids:

  character vector of IDs indicating to which animal each allele in
  `alleles` belongs.

## Value

A data.frame with columns `allele` and `freq`. This is a table of allele
counts within the population.

## Details

If ids are provided, the function will only count the unique alleles for
an individual (homozygous alleles will be counted as 1).

## Examples

``` r
library(nprcgenekeepr)
data("ped1Alleles")
ids <- ped1Alleles$id
alleles <- ped1Alleles[, !(names(ped1Alleles) %in% c("id", "parent"))]
aF <- alleleFreq(alleles[[1]], ids = NULL)
aF[aF$freq >= 10, ]
#>     allele freq
#> 230  20004   10
#> 238  20012   11
```
