# Extract genotype data for a genetic value report

Extracts genotype data if available otherwise NULL is returned.

## Usage

``` r
getGVGenotype(ped)
```

## Arguments

- ped:

  the pedigree information in datatable format

## Value

A data.frame with the columns `id`, `first`, and `second` extracted from
a pedigree object (a data.frame) containing genotypic data. If the
pedigree object does not contain genotypic data the `NULL` is returned.

## Examples

``` r
## We usually define `n` to be >= 1000
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
allelesNew <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
  genotype = NULL, n = 50, updateProgress = NULL
)
genotype <- data.frame(
  id = ped$id,
  first_allele = c(
    NA, NA, "A001_B001", "A001_B002",
    NA, "A001_B002", "A001_B001"
  ),
  second_allele = c(
    NA, NA, "A010_B001", "A001_B001",
    NA, NA, NA
  ),
  stringsAsFactors = FALSE
)
pedWithGenotype <- addGenotype(ped, genotype)
pedGenotype <- getGVGenotype(pedWithGenotype)
allelesNewGen <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
  genotype = pedGenotype,
  n = 5, updateProgress = NULL
)
```
