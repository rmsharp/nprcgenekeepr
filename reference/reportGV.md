# Generates a genetic value report for a provided pedigree

This is the main function for the Genetic Value Analysis.

## Usage

``` r
reportGV(
  ped,
  guIter = 5000L,
  guThresh = 1L,
  pop = NULL,
  byID = TRUE,
  updateProgress = NULL,
  breedingTable = NULL,
  gestationTable = NULL,
  breedingAgeDefault = NULL,
  gestationDefault = NULL
)
```

## Arguments

- ped:

  The pedigree information in data.frame format

- guIter:

  Integer indicating the number of iterations for the gene-drop
  analysis. Default is 5000 iterations

- guThresh:

  Integer indicating the threshold number of animals for defining a
  unique allele. Default considers an allele "unique" if it is found in
  only 1 animal.

- pop:

  Character vector with animal IDs to consider as the population of
  interest. The default is NULL.

- byID:

  Logical variable of length 1 that is passed through to eventually be
  used by
  [`alleleFreq()`](https://github.com/rmsharp/nprcgenekeepr/reference/alleleFreq.md),
  which calculates the count of each allele in the provided vector. If
  `byID` is TRUE and ids are provided, the function will only count the
  unique alleles for an individual (homozygous alleles will be counted
  as 1).

- updateProgress:

  Function or NULL. If this function is defined, it will be called
  during each iteration to update a
  [`shiny::Progress`](https://rdrr.io/pkg/shiny/man/Progress.html)
  object.

- breedingTable:

  Optional data.frame overriding the bundled per-species minimum
  breeding ages used by the unknown-parent mean-kinship correction
  (issue \#73 Part 2). `NULL` (the default) uses the bundled
  [`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
  table.

- gestationTable:

  Optional data.frame overriding the bundled per-species gestation
  windows used by the correction's conception window. `NULL` uses the
  bundled table.

- breedingAgeDefault:

  Optional numeric fallback minimum breeding age (years) for species
  absent from the table. `NULL` uses the built-in 2 years.

- gestationDefault:

  Optional integer fallback gestation window (days) for species absent
  from the table. `NULL` uses the built-in 210 days.

## Value

An object of class `nprcgenekeeprGV`: a list with elements `report` (a
dataframe with the genetic value report, with animals ranked in order of
descending value), `kinship` (the kinship matrix), `gu` (genome
uniqueness values), `fe` (founder equivalents), `fg` (founder genome
equivalents), `maleFounders` and `femaleFounders` (dataframes of the
known male and female founder records), `nMaleFounders` and
`nFemaleFounders` (the counts of those founders), and `total` (the total
number of known founders).

## Examples

``` r
library(nprcgenekeepr)
examplePedigree <- nprcgenekeepr::examplePedigree
breederPed <- qcStudbook(examplePedigree,
  minParentAge = 2,
  reportChanges = FALSE,
  reportErrors = FALSE
)
focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
  is.na(breederPed$dam)) &
  is.na(breederPed$exit)]
ped <- setPopulation(ped = breederPed, ids = focalAnimals)
trimmedPed <- trimPedigree(focalAnimals, breederPed)
probands <- ped$id[ped$population]
ped <- trimPedigree(probands, ped,
  removeUninformative = FALSE,
  addBackParents = FALSE
)
geneticValue <- reportGV(ped,
  guIter = 50, # should be >= 1000
  guThresh = 3,
  byID = TRUE,
  updateProgress = NULL
)
trimmedGeneticValue <- reportGV(trimmedPed,
  guIter = 50, # should be >= 1000
  guThresh = 3,
  byID = TRUE,
  updateProgress = NULL
)
rpt <- trimmedGeneticValue[["report"]]
kmat <- trimmedGeneticValue[["kinship"]]
f <- trimmedGeneticValue[["total"]]
mf <- trimmedGeneticValue[["maleFounders"]]
ff <- trimmedGeneticValue[["femaleFounders"]]
nmf <- trimmedGeneticValue[["nMaleFounders"]]
nff <- trimmedGeneticValue[["nFemaleFounders"]]
fe <- trimmedGeneticValue[["fe"]]
fg <- trimmedGeneticValue[["fg"]]
```
