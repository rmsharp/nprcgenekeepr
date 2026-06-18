# Focal animal IDs from examplePedigree

A dataframe with one column (*id*) containing the animal Ids from the
**examplePedigree** pedigree. They can be used to illustrate the
identification of a population of interest as is shown in the example
below.

## Usage

``` r
data(focalAnimals)
```

## Format

An object of class `data.frame` with 327 rows and 1 columns.

## Examples

``` r
library(nprcgenekeepr)
data("focalAnimals")
data("examplePedigree")
any(names(examplePedigree) == "population")
#> [1] FALSE
nrow(examplePedigree)
#> [1] 3694
examplePedigree <- setPopulation(
  ped = examplePedigree,
  ids = focalAnimals$id
)
any(names(examplePedigree) == "population")
#> [1] TRUE
nrow(examplePedigree)
#> [1] 3694
nrow(examplePedigree[examplePedigree$population, ])
#> [1] 327
```
