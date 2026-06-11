# Makes a list object of kinship matrices from simulated pedigrees of possible parents for animals with unknown parents

`createSimKinships` uses `makeSimPed` with the `ped` object and the
`allSimParents` object to create a set of kinship matrices to be used in
forming the *Monte Carlo* estimates for the kinship values.

## Usage

``` r
createSimKinships(ped, allSimParents, pop = NULL, n = 10L, verbose = FALSE)
```

## Arguments

- ped:

  The pedigree information in data.frame format

- allSimParents:

  list made up of lists where the internal list has the offspring ID,
  `id`, a vector of representative sires (`sires`), and a vector of
  representative dams (`dams`).

- pop:

  Character vector with animal IDs to consider as the population of
  interest. This allows you to provide a pedigree in `ped` that has more
  animals than you want to use in the simulation by defining `pop` with
  the subset of interest. The default is NULL.

- n:

  integer value of the number of simulated pedigrees to generate.

- verbose:

  logical vector of length one that indicates whether or not to print
  out when an animal is missing a sire or a dam.

## Value

A list of `n` lists with each internal list containing a kinship matrix
from simulated pedigrees of possible parents for animals with unknown
parents.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::smallPed
simParent_1 <- list(
  id = "A",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_2 <- list(
  id = "B",
  sires = c("s2_1", "s2_2", "s2_3"),
  dams = c("d2_1", "d2_2", "d2_3", "d2_4")
)
simParent_3 <- list(
  id = "E",
  sires = c("s3_1", "s3_2", "s3_3"),
  dams = c("d3_1", "d3_2", "d3_3", "d3_4")
)
allSimParents <- list(simParent_1, simParent_2, simParent_3)
pop <- LETTERS[1:7]
simKinships <- createSimKinships(ped, allSimParents, pop, n = 10)
```
