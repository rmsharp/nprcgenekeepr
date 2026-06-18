# Get the population of interest for the Genetic Value analysis

If user has limited the population of interest by defining `pop`, that
information is incorporated via the `ped$population` column.

## Usage

``` r
getGVPopulation(ped, pop)
```

## Arguments

- ped:

  the pedigree information in datatable format

- pop:

  character vector with animal IDs to consider as the population of
  interest. The default is NULL.

## Value

A logical vector corresponding to the IDs in the vector of animal IDs
provided to the function in `pop`.

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
