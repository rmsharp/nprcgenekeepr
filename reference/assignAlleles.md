# Assign parent alleles randomly

Assign parent alleles randomly

## Usage

``` r
assignAlleles(alleles, parentType, parent, id, n)
```

## Arguments

- alleles:

  a list with a list `alleles$alleles`, which is a list of list
  containing the alleles for each individual's sire and dam that have
  been assigned thus far and `alleles$counter` that is the counter used
  to track the lists of`alleles$alleles`.

- parentType:

  character vector of length one with value of `"sire"` or `"dam"`.

- parent:

  either `ped[id, "sire"]` or `ped[id, "dam"]`.

- id:

  character vector of length one containing the animal ID

- n:

  integer indicating the number of iterations to simulate.

## Value

The original list `alleles` passed into the function with newly randomly
assigned alleles to each `id` based on dam and sire genotypes.

## Examples

``` r
alleles <- list(alleles = list(), counter = 1)
alleles <- assignAlleles(alleles,
  parentType = "sire", parent = NA,
  id = "o1", n = 4
)
alleles
#> $alleles
#> $alleles$o1
#> $alleles$o1$sire
#> [1] 1 1 1 1
#> 
#> 
#> 
#> $counter
#> [1] 2
#> 
alleles <- assignAlleles(alleles,
  parentType = "dam", parent = NA,
  id = "o1", n = 4
)
alleles
#> $alleles
#> $alleles$o1
#> $alleles$o1$sire
#> [1] 1 1 1 1
#> 
#> $alleles$o1$dam
#> [1] 2 2 2 2
#> 
#> 
#> 
#> $counter
#> [1] 3
#> 
```
