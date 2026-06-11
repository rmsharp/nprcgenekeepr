# Count the number of loops in a pedigree tree.

Part of Pedigree Sampling From PedigreeSampling.R 2016-01-28

## Usage

``` r
countLoops(loops, ptree)
```

## Arguments

- loops:

  a named list of logical values where each named element is named with
  an `id` from `ptree`. The value of the list element is set to `TRUE`
  if the `id` has a loop in the pedigree. Loops occur when an animal's
  sire and dam have a common ancestor.

- ptree:

  a list of lists forming a pedigree tree as constructed by
  `createPedTree(ped)` where `ped` is a standard pedigree dataframe.

## Value

A list indexed with each ID in the pedigree tree (`ptree`) containing
the number of loops for each individual.

## Details

Contains functions to build pedigrees from sub-samples of genotyped
individuals.

The goal of sampling is to reduce the number of inbreeding loops in the
resulting pedigree, and thus, reduce the amount of time required to
perform calculations with SIMWALK2 or similar programs.

Uses the `loops` data structure and the list of all ancestors for each
individual to calculate the number of loops for each individual.

## Examples

``` r
library(nprcgenekeepr)
examplePedigree <- nprcgenekeepr::examplePedigree
exampleTree <- createPedTree(examplePedigree)
exampleLoops <- findLoops(exampleTree)
## You can count how many animals are in loops with the following code.
length(exampleLoops[exampleLoops == TRUE])
#> [1] 145
## You can count how many loops you have with the following code.
nLoops <- countLoops(exampleLoops, exampleTree)
sum(unlist(nLoops[nLoops > 0]))
#> [1] 258
## You can list the first 10 sets of ids, sires and dams in loops with
## the following line of code:
examplePedigree[exampleLoops == TRUE, c("id", "sire", "dam")][1:10, ]
#>          id   sire    dam
#> 2367 MRC4BF 7ZEGLB L1VRM7
#> 2369 SZ05LQ 7ZEGLB 4H5RS1
#> 2705 6FDURN B2CKHA L1VRM7
#> 2725 ZQFCR5 7ZEGLB DCJJYS
#> 2744 BWM2Z2 B2CKHA 4Y8JHT
#> 2747 FAPEMV 7ZEGLB 2SIP77
#> 2765 EZ2F8A 7ZEGLB DCJJYS
#> 2775 X4UZJS B2CKHA L1VRM7
#> 2956 L9SI7Z TYNVJP C1K9WN
#> 2969 3SKITJ 3PU50K G5SZDC
```
