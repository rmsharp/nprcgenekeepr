# Recursively create a character vector of ancestors for an individual ID.

Part of Pedigree Sampling From PedigreeSampling.R 2016-01-28

## Usage

``` r
getAncestors(id, ptree)
```

## Arguments

- id:

  character vector of length 1 having the ID of interest

- ptree:

  a list of lists forming a pedigree tree as constructed by
  `createPedTree(ped)` where `ped` is a standard pedigree dataframe.

## Value

A character vector of ancestors for an individual ID.

## Details

Contains functions to build pedigrees from sub-samples of genotyped
individuals.

The goal of sampling is to reduce the number of inbreeding loops in the
resulting pedigree, and thus, reduce the amount of time required to
perform calculations with SIMWALK2 or similar programs.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::qcPed
ped <- qcStudbook(ped, minParentAge = 0)
pedTree <- createPedTree(ped)
pedLoops <- findLoops(pedTree)
ids <- names(pedTree)
allAncestors <- list()

for (i in seq_along(ids)) {
  id <- ids[[i]]
  anc <- getAncestors(id, pedTree)
  allAncestors[[id]] <- anc
}
head(allAncestors)
#> $`0DXI08`
#> character(0)
#> 
#> $`0RZ5LL`
#> character(0)
#> 
#> $`1B71NB`
#> character(0)
#> 
#> $`2FU86J`
#> character(0)
#> 
#> $`2HEFGM`
#> character(0)
#> 
#> $`4LFS70`
#> character(0)
#> 
countOfAncestors <- unlist(lapply(allAncestors, length))
idsWithMostAncestors <-
  names(allAncestors)[countOfAncestors == max(countOfAncestors)]
allAncestors[idsWithMostAncestors]
#> $HLI95R
#>  [1] "WMUJC5" "H00H7D" "ZWBMTP" "HRBVOE" "RD6KMA" "K7QBLH" "UL1ZA5" "VHXHVH"
#>  [9] "NY9FEC" "ZWBMTP" "HRBVOE" "RD6KMA" "TINMGJ" "UKKA3A" "6MXDVM" "AXDMJM"
#> [17] "L6D4ZC" "5EP5AL" "HB9B30" "I31V3S" "3O7TMT" "WORLYK" "FHY041" "43TUN9"
#> [25] "5EP5AL" "HB9B30" "I31V3S" "8G72QV"
#> 
#> $I9TQ0T
#>  [1] "CN4GMN" "QBLTI6" "F0YSEE" "SA1ZC1" "ZXJQQ5" "6MIRJI" "UKK94T" "596J7E"
#>  [9] "82IE3M" "F0YSEE" "SA1ZC1" "ZXJQQ5" "JNWPY2" "MQB1AE" "ZXJQQ5" "BNMWNZ"
#> [17] "DZ3B9K" "CQMWGX" "N2XF08" "P9GZ32" "HKOSVZ" "ZQ0DRX" "RX08B3" "N2XF08"
#> [25] "P9GZ32" "HKOSVZ" "1B71NB" "BRLQFI"
#> 
```
