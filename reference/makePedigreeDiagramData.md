# Convert a pedigree data frame into visNetwork-ready diagram data

Builds the node and edge tables consumed by
[`visNetwork::visNetwork()`](https://rdrr.io/pkg/visNetwork/man/visNetwork.html)
from a pedigree data frame: one node per individual, sex-coded to a node
shape, positioned by generation; one directed edge per known sire and
one per known dam, pointing from parent to child.

## Usage

``` r
makePedigreeDiagramData(ped, twinRelations = NULL)
```

## Arguments

- ped:

  data frame with `id`, `sire`, `dam`, `sex`, and `gen` columns
  (`sire`/`dam` `NA` for unknown parents; `gen` an integer generation
  number, 0 for founders, as produced by
  [`findGeneration`](https://github.com/rmsharp/nprcgenekeepr/reference/findGeneration.md)).

- twinRelations:

  optional data.frame with columns `id1`, `id2`, `code` (see
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md))
  – issue \#137 D1/D6. Not validated here; validate with
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)
  first. `NULL` (default) adds no connector edges and leaves `edges`
  unchanged from the pre-#137 contract (`from`, `to` only).

## Value

A list with two data frames: `nodes` (`id`, `label`, `shape`, `level`,
`title`) and `edges` (`from`, `to`, plus `dashes`/`label`/`color` when
`twinRelations` is supplied). `title` is an HTML hover-tooltip string
(issue \#135) giving ID, sex, generation, sire, and dam.

## Examples

``` r
library(nprcgenekeepr)
diagramData <- makePedigreeDiagramData(nprcgenekeepr::examplePedigree)
```
