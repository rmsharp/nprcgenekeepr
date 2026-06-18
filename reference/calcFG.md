# Calculates Founder Genome Equivalents

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
  n = 5000, updateProgress = NULL
)
allelesFactors <- geneDrop(pedFactors$id, pedFactors$sire, pedFactors$dam,
  pedFactors$gen,
  genotype = NULL, n = 5000,
  updateProgress = NULL
)
fg <- calcFG(ped, alleles)
fgFactors <- calcFG(pedFactors, allelesFactors)
```
