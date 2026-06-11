# Makes a list object containing kinship summary statistics using the list object from **createSimKinships**.

`cumulateSimKinships` creates a named list of length 4 is generated
where the first element is the mean of the simulated kinships, the
second element is the standard deviation of the simulated kinships the
third element is the minimum value of the kinships, and the forth
element is the maximum value of the kinships.

## Usage

``` r
cumulateSimKinships(ped, allSimParents, pop = NULL, n = 10L)
```

## Arguments

- ped:

  The pedigree information in data.frame format

- allSimParents:

  list made up of lists where the internal list has the offspring ID
  `id`, a vector of representative sires (`sires`), and a vector of
  representative dams(`dams`).

- pop:

  Character vector with animal IDs to consider as the population of
  interest. The default is NULL.

- n:

  integer value of the number of simulated pedigrees to generate. Must
  be at least 1 (`n < 1` is an error); the standard deviation requires
  `n >= 2`.

## Value

List object containing the meanKinship, sdKinship, minKinship, and
maxKinship. `sdKinship` is the sample standard deviation across the `n`
simulations; it is undefined for a single simulation, so when `n < 2` it
is returned as `NA` (with a warning), as base R
[`sd()`](https://rdrr.io/r/stats/sd.html) does for a length-one vector.

## Examples

``` r
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
