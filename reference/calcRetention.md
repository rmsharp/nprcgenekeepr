# Calculate allelic retention

Part of Genetic Value Analysis

## Usage

``` r
calcRetention(ped, alleles)
```

## Arguments

- ped:

  the pedigree information in datatable format. Pedigree (req. fields:
  id, sire, dam, gen, population).

  It is assumed that the pedigree has no partial parentage

- alleles:

  dataframe of containing an `AlleleTable`. This is a table of allele
  information produced by
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md).

## Value

A vector of the mean number of founder alleles retained in the gene
dropping simulation.

## Examples

``` r
library(nprcgenekeepr)
data("lacy1989Ped")
data("lacy1989PedAlleles")
ped <- lacy1989Ped
alleles <- lacy1989PedAlleles
retention <- calcRetention(ped, alleles)
```
