# Combine the Option 2 mating-unit forest into visNetwork-ready diagram data

The exported wrapper for the kinship2-parity pedigree layout (Pedigree
Diagram Option 2,
`docs/planning/pedigree-diagram-option2-layout-design-plan.md`).
Combines `.buildMatingUnitForest()` (D1/D2) and
`.positionMatingUnitForest()` (D3/D4/D5) into the same
`list(nodes, edges)` shape
[`makePedigreeDiagramData`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md)
already returns, plus the `duplicateNodeId -> realId` lookup table D6
needs.
[`makePedigreeDiagramData`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md)
itself is unaffected – this is an additive sibling function (Migration
Path step 2).

## Usage

``` r
makePedigreeMatingLayout(ped)
```

## Arguments

- ped:

  data frame with `id`, `sire`, `dam`, `sex`, and `gen` columns, same
  contract as
  [`makePedigreeDiagramData`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md).

## Value

A list with `nodes` (`id`, `label`, `shape`, `title`, `size`, `x`, `y`),
`edges` (`from`, `to`, `dashes`), and `duplicateToReal` (a named
character vector, duplicate node id -\> real individual id).

## Details

Mating-unit nodes render as a small, unlabeled dot with an
offspring-count tooltip – visually distinct from the 5 sex-coded shapes
without a dedicated legend entry (D6, verified via a live `chromote`
render this session). Duplicate nodes keep their real individual's own
shape/label/tooltip content (plus a duplicate- occurrence cue) so they
read as that individual, connected to it by a dashed edge. Edges are
direct parent -\> mating-unit and mating-unit -\> child segments
(owner-directed, S461) – not the fully rectilinear mate-line/sibship-bar
waypoint style S457's original Case C2 proof-of-concept used; that style
is tracked as a deferred, additive follow-up (issue \#142) rather than
built speculatively here.

## Examples

``` r
library(nprcgenekeepr)
layout <- makePedigreeMatingLayout(nprcgenekeepr::examplePedigree)
```
