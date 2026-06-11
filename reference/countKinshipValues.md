# Counts the number of occurrences of each kinship value seen for a pair of individuals in a series of simulated pedigrees.

Counts the number of occurrences of each kinship value seen for a pair
of individuals in a series of simulated pedigrees.

## Usage

``` r
countKinshipValues(kinshipValues, accummulatedKValueCounts = NULL)
```

## Arguments

- kinshipValues:

  matrix of kinship values from simulated pedigrees where each row
  represents a pair of individuals in the pedigree and each column
  represents the vector of kinship values generated in a simulated
  pedigree.

- accummulatedKValueCounts:

  list object with same structure as that returned by this function.

## Value

A list of three lists named `kIds` (kinship IDs), `kValues` (kinship
values), and `kCounts` (kinship counts).

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
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_3 <- list(
  id = "E",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_4 <- list(
  id = "J",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_5 <- list(
  id = "K",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_6 <- list(
  id = "N",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
allSimParents <- list(
  simParent_1, simParent_2, simParent_3,
  simParent_4, simParent_5, simParent_6
)

extractKinship <- function(simKinships, id1, id2, simulation) {
  ids <- dimnames(simKinships[[simulation]])[[1]]
  simKinships[[simulation]][
    seq_along(ids)[ids == id1],
    seq_along(ids)[ids == id2]
  ]
}

extractKValue <- function(kValue, id1, id2, simulation) {
  kValue[
    kValue$id_1 == id1 & kValue$id_2 == id2,
    paste0("sim_", simulation)
  ]
}

n <- 10
simKinships <- createSimKinships(ped, allSimParents,
  pop = ped$id, n = n
)
kValues <- kinshipMatricesToKValues(simKinships)
extractKValue(kValues, id1 = "A", id2 = "F", simulation = 1:n)
#>  [1] "sim_1"  "sim_2"  "sim_3"  "sim_4"  "sim_5"  "sim_6"  "sim_7"  "sim_8" 
#>  [9] "sim_9"  "sim_10"
counts <- countKinshipValues(kValues)
n <- 10
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
kValues <- kinshipMatricesToKValues(simKinships)
extractKValue(kValues, id1 = "A", id2 = "F", simulation = 1:n)
#>  [1] "sim_1"  "sim_2"  "sim_3"  "sim_4"  "sim_5"  "sim_6"  "sim_7"  "sim_8" 
#>  [9] "sim_9"  "sim_10"
accummulatedCounts <- countKinshipValues(kValues, counts)
```
