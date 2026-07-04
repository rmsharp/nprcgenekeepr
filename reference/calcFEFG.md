# Calculate founder equivalents and founder genome equivalents

Part of the Genetic Value Analysis

## Usage

``` r
calcFEFG(ped, alleles)
```

## Arguments

- ped:

  the pedigree information in datatable format. Pedigree (req. fields:
  id, sire, dam, gen, population).

  The pedigree must have no partial parentage (every animal has both
  parents known or both unknown); `calcFEFG` stops with an error
  otherwise.

- alleles:

  dataframe contains an `AlleleTable`. This is a table of allele
  information produced by
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md).

## Value

The list containing the founder equivalents, `FE = 1 / sum(p ^ 2)`, and
the founder genome equivalents, `FG = 1 / sum( (p ^ 2) / r)` where `p`
is the vector of founder mean contributions to the current descendants
and `r` is the mean number of founder alleles retained in the gene
dropping experiment.

`FE` is deterministic and always returned. `FG` is `NA` (with a warning)
when a contributing founder (`p > 0`) is retained in zero of the
gene-drop iterations (`r == 0`), which would otherwise collapse `FG`
silently to 0; raise the number of iterations. See
[`calcFGSE`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md)
for the sampling standard error of `FG`.

## See also

Other genetic value analysis:
[`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
[`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
[`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md),
[`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)

## Examples

``` r
data(lacy1989Ped)
## Example from Analysis of Founder Representation in Pedigrees: Founder
## Equivalents and Founder Genome Equivalents.
## Zoo Biology 8:111-123, (1989) by Robert C. Lacy

library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
alleles <- lacy1989PedAlleles
pedFactors <- data.frame(
  id = as.factor(ped$id),
  sire = as.factor(ped$sire),
  dam = as.factor(ped$dam),
  gen = ped$gen,
  population = ped$population,
  stringsAsFactors = TRUE
)
allelesFactors <- geneDrop(pedFactors$id, pedFactors$sire, pedFactors$dam,
  pedFactors$gen,
  genotype = NULL, n = 1000,
  updateProgress = NULL
)
feFg <- calcFEFG(ped, alleles)
feFgFactors <- calcFEFG(pedFactors, allelesFactors)
```
