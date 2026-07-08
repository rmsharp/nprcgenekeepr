# Calculate founder genome equivalents

Part of the Genetic Value Analysis

## Usage

``` r
calcFG(ped, alleles)
```

## Arguments

- ped:

  the pedigree information in datatable format. Pedigree (req. fields:
  id, sire, dam, gen, population). The pedigree must have no partial
  parentage (every animal has both parents known or both unknown);
  `calcFG` stops with an error otherwise.

- alleles:

  dataframe contains an `AlleleTable`. This is a table of allele
  information produced by
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md).

## Value

The founder genome equivalents, `FG = 1 / sum( (p ^ 2) / r)` where `p`
is the vector of founder mean contributions to the current descendants
and `r` is the mean number of founder alleles retained in the gene
dropping experiment.

Returns `NA` with a warning when a contributing founder (`p > 0`) is
retained in zero of the gene-drop iterations (`r == 0`): that term is
`p^2 / 0 = Inf`, which would otherwise collapse `FG` silently to 0.
Raise the number of iterations. See
[`calcFGSE`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md)
for the sampling standard error of `FG`.

## See also

Other genetic value analysis:
[`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
[`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
[`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
[`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md),
[`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
[`calcGeneDiversity()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md),
[`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)

## Examples

``` r
## Example from Analysis of Founder Representation in Pedigrees: Founder
## Equivalents and Founder Genome Equivalents.
## Zoo Biology 8:111-123, (1989) by Robert C. Lacy

library(nprcgenekeepr)
ped <- data.frame(
  id = c("A", "B", "C", "D", "E", "F", "G"),
  sire = c(NA, NA, "A", "A", NA, "D", "D"),
  dam = c(NA, NA, "B", "B", NA, "E", "E"),
  stringsAsFactors = FALSE
)
ped["gen"] <- findGeneration(ped$id, ped$sire, ped$dam)
ped$population <- getGVPopulation(ped, NULL)
pedFactors <- data.frame(
  id = c("A", "B", "C", "D", "E", "F", "G"),
  sire = c(NA, NA, "A", "A", NA, "D", "D"),
  dam = c(NA, NA, "B", "B", NA, "E", "E"),
  stringsAsFactors = TRUE
)
pedFactors["gen"] <- findGeneration(
  pedFactors$id, pedFactors$sire,
  pedFactors$dam
)
pedFactors$population <- getGVPopulation(pedFactors, NULL)
alleles <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
  genotype = NULL,
  n = 1000, updateProgress = NULL
)
allelesFactors <- geneDrop(pedFactors$id, pedFactors$sire, pedFactors$dam,
  pedFactors$gen,
  genotype = NULL, n = 1000,
  updateProgress = NULL
)
fg <- calcFG(ped, alleles)
fgFactors <- calcFG(pedFactors, allelesFactors)
```
