# Find loops in a pedigree tree

Part of Pedigree Sampling From PedigreeSampling.R 2016-01-28

## Usage

``` r
findLoops(ptree)
```

## Arguments

- ptree:

  a list of lists forming a pedigree tree as constructed by
  `createPedTree(ped)` where `ped` is a standard pedigree dataframe.

## Value

A named list of logical values where each named element is named with an
`id` from `ptree`. The value of the list element is set to `TRUE` if the
`id` has a loop in the pedigree. Loops occur when an animal's sire and
dam have a common ancestor.

## Details

Contains functions to build pedigrees from sub-samples of genotyped
individuals.

The goal of sampling is to reduce the number of inbreeding loops in the
resulting pedigree, and thus, reduce the amount of time required to
perform calculations with SIMWALK2 or similar programs.

## Examples

``` r
data("examplePedigree")
exampleTree <- createPedTree(examplePedigree)
exampleLoops <- findLoops(exampleTree)
```
