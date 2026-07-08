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

## See also

Other genetic value analysis:
[`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
[`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
[`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md),
[`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`calcGeneDiversity()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md),
[`calcNeSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md)

## Examples

``` r
library(nprcgenekeepr)
data("lacy1989Ped")
data("lacy1989PedAlleles")
ped <- lacy1989Ped
alleles <- lacy1989PedAlleles
retention <- calcRetention(ped, alleles)
```
