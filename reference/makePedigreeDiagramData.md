# Convert a pedigree data frame into visNetwork-ready diagram data

Builds the node and edge tables consumed by
[`visNetwork::visNetwork()`](https://rdrr.io/pkg/visNetwork/man/visNetwork.html)
from a pedigree data frame: one node per individual, sex-coded to a node
shape, positioned by generation; one directed edge per known sire and
one per known dam, pointing from parent to child.

## Usage

``` r
makePedigreeDiagramData(ped)
```

## Arguments

- ped:

  data frame with `id`, `sire`, `dam`, `sex`, and `gen` columns
  (`sire`/`dam` `NA` for unknown parents; `gen` an integer generation
  number, 0 for founders, as produced by
  [`findGeneration`](https://github.com/rmsharp/nprcgenekeepr/reference/findGeneration.md)).

## Value

A list with two data frames: `nodes` (`id`, `label`, `shape`, `level`)
and `edges` (`from`, `to`).

## Examples

``` r
library(nprcgenekeepr)
diagramData <- makePedigreeDiagramData(nprcgenekeepr::examplePedigree)
```
