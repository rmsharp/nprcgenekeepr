# Calculate allelic retention

Part of Genetic Value Analysis

## Usage

``` r
calcRetention(ped, alleles)
```

## Arguments

- ped:

  the pedigree information in datatable format. Pedigree (req. fields:
  id, sire, dam, population).

  It is assumed that the pedigree has no partial parentage. When the
  `population` column is missing or has no `TRUE` values, there are no
  descendants and every retention value is 0.

- alleles:

  dataframe of containing an `AlleleTable`. This is a table of allele
  information produced by
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md).

## Value

A named one-dimensional array with one value per founder: the proportion
of the gene-drop simulations (a number from 0 to 1, not a count) in
which the founder's allele is retained in the population's descendants.

## References

Lacy RC. 1989. Analysis of founder representation in pedigrees: founder
equivalents and founder genome equivalents. Zoo Biol 8:111-123.

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
[`calcKurtosis()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcKurtosis.md),
[`calcNeSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md),
[`calcNeVariance()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeVariance.md),
[`calcSkewness()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcSkewness.md)

## Examples

``` r
library(nprcgenekeepr)
data("lacy1989Ped")
data("lacy1989PedAlleles")
ped <- lacy1989Ped
alleles <- lacy1989PedAlleles
retention <- calcRetention(ped, alleles)
```
