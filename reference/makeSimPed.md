# Make a simulated pedigree from representative sires and dams

For each `id` in `allSimParents` with one or more unknown parents each
unknown parent is replaced with a random sire or dam as needed from the
corresponding parent vector (`sires` or `dams`).

## Usage

``` r
makeSimPed(ped, allSimParents, verbose = FALSE)
```

## Arguments

- ped:

  pedigree information in data.frame format

- allSimParents:

  list made up of lists where the internal list has the offspring ID
  `id`, a vector of representative sires (`sires`), and a vector of
  representative dams (`dams`).

- verbose:

  logical vector of length one that indicates whether or not to print
  out when an animal is missing a sire or a dam.

## Value

simulated pedigree in data.frame format with the id, sire, and dam.

## Details

The algorithm assigns parents randomly from the lists of possible sires
and dams and does not prevent a dam from being selected more than once
within the same breeding period. While this is probably not introducing
a large error, it is not ideal.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
## For each id below, any unknown sire/dam is replaced by a random
## draw from the supplied representative sires and dams.
allSimParents <- list(
  list(
    id = "A",
    sires = c("s1_1", "s1_2", "s1_3"),
    dams = c("d1_1", "d1_2", "d1_3", "d1_4")
  ),
  list(
    id = "B",
    sires = c("s2_1", "s2_2", "s2_3"),
    dams = c("d2_1", "d2_2", "d2_3", "d2_4")
  ),
  list(
    id = "E",
    sires = c("s3_1", "s3_2", "s3_3"),
    dams = c("d3_1", "d3_2", "d3_3", "d3_4")
  )
)
set.seed(1)
simPed <- makeSimPed(ped, allSimParents)
simPed
#>        id   sire    dam   gen population
#>    <char> <char> <char> <num>     <lgcl>
#> 1:      A   s1_1   d1_2     0       TRUE
#> 2:      B   s2_2   d2_4     0       TRUE
#> 3:      C      A      B     1       TRUE
#> 4:      D      A      B     1       TRUE
#> 5:      E   s3_1   d3_4     0       TRUE
#> 6:      F      D      E     2       TRUE
#> 7:      G      D      E     2       TRUE
```
