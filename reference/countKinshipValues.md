# Count kinship-value occurrences across simulated pedigrees

Count kinship-value occurrences across simulated pedigrees

## Usage

``` r
countKinshipValues(kinshipValues, accummulatedKValueCounts = NULL)
```

## Arguments

- kinshipValues:

  data.table of kinship values from simulated pedigrees, as returned by
  [`kinshipMatricesToKValues`](https://github.com/rmsharp/nprcgenekeepr/reference/kinshipMatricesToKValues.md):
  columns `id_1` and `id_2` identify a pair of individuals and each
  remaining column holds the kinship values from one simulated pedigree.

- accummulatedKValueCounts:

  list object with same structure as that returned by this function,
  from an earlier call. Its ID pairs must be the same, in the same
  order, as those in `kinshipValues`; the new counts are added to its
  counts.

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

# A second, independent set of simulations is added to the first counts
n <- 10
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
kValues <- kinshipMatricesToKValues(simKinships)
extractKValue(kValues, id1 = "A", id2 = "F", simulation = 1:n)
#>  [1] "sim_1"  "sim_2"  "sim_3"  "sim_4"  "sim_5"  "sim_6"  "sim_7"  "sim_8" 
#>  [9] "sim_9"  "sim_10"
accummulatedCounts <- countKinshipValues(kValues, counts)
```
