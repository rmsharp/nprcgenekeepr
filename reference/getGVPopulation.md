# Get the population of interest for the Genetic Value analysis

If user has limited the population of interest by defining `pop`, that
information is incorporated via the `ped$population` column.

## Usage

``` r
getGVPopulation(ped, pop)
```

## Arguments

- ped:

  The pedigree information in data.frame format

- pop:

  character vector with animal IDs to consider as the population of
  interest. The default is NULL: an existing `population` column of
  `ped` is used if there is one, otherwise all animals.

## Value

A logical vector with one element per row of `ped`, in the order of
`ped`: `TRUE` if the animal is in the population of interest. IDs in
`pop` that are not in `ped` are ignored.

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
```
