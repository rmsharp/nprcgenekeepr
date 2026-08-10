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
makePedigreeMatingLayout(
  ped,
  edgeStyle = c("direct", "rectilinear"),
  twinRelations = NULL,
  orderBySex = TRUE
)
```

## Arguments

- ped:

  data frame with `id`, `sire`, `dam`, `sex`, and `gen` columns, same
  contract as
  [`makePedigreeDiagramData`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md).

- edgeStyle:

  one of `"direct"` (default – a straight edge from each parent to their
  mating unit and from each mating unit to each child, matching this
  function's own original, still-default behavior) or `"rectilinear"`
  (issue \#142 – routes mate-line and sibship-bar edges through
  invisible waypoint nodes via `.addRectilinearWaypoints()` so they
  render as a strict right angle, kinship2-style, instead of a direct
  diagonal/straight segment).

- twinRelations:

  optional data.frame with columns `id1`, `id2`, `code` (see
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md))
  – issue \#137 D1/D6/D7. Not validated here; validate with
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)
  first. `NULL` (default) adds no connector edges and leaves `edges`
  unchanged from the pre-#137 contract. A connector always targets the
  two individuals' REAL node ids (D7) and always renders as a direct
  edge regardless of `edgeStyle` (D9).

- orderBySex:

  issue \#145 Slice 1 (D8 option (b)):
  `docs/planning/issue145-sire-dam-left-right-placement-plan.md`. When
  `TRUE` (the default), every simple two-real-parent mating unit
  (mate-count exactly 1 each, unambiguous `"M"`/`"F"` sex codes, neither
  parent with a D5 direct child of their own) is rendered with the male
  parent to the left and the female parent to the right, matching common
  pedigree-drawing convention – an additive, new default, not a bug fix
  (multi-mate/"crowded" families are unaffected, out of scope). `FALSE`
  reproduces the pre-#145, sex-agnostic default unchanged.

## Value

A list with `nodes` (`id`, `label`, `shape`, `title`, `size`, `x`, `y`),
`edges` (`from`, `to`, `dashes`, plus `label`/`color` when
`twinRelations` is supplied – D10, found never wired at S494, fixed
S506), and `duplicateToReal` (a named character vector, duplicate node
id -\> real individual id). Under `edgeStyle = "rectilinear"`, `nodes`
gains `color.background`/`color.border` and `edges` unconditionally
gains `color` (see `.addRectilinearWaypoints()`) – an already-set edge
`color` (e.g. the twin connector's) is preserved, not reset.

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
