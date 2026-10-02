# Combine the mating-unit forest into visNetwork-ready diagram data

Builds a kinship2-style pedigree layout in which each mating (a sire and
dam pair) is drawn as a union node between the parents and their
offspring. Returns the same `list(nodes, edges)` shape that
[`makePedigreeDiagramData`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md)
returns, plus a lookup table that maps each duplicate node id to the
real individual it stands for.
[`makePedigreeDiagramData`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md)
itself is unaffected; this is a separate function.

## Usage

``` r
makePedigreeMatingLayout(
  ped,
  edgeStyle = c("rectilinear", "direct"),
  twinRelations = NULL,
  kinshipMatrix = NULL
)
```

## Arguments

- ped:

  data frame with `id`, `sire`, `dam`, `sex`, and `gen` columns, same
  contract as
  [`makePedigreeDiagramData`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md).

- edgeStyle:

  one of `"rectilinear"` (default), which routes mate-line and
  sibship-bar edges through invisible waypoint nodes so they render as a
  strict right angle, kinship2-style, or `"direct"`, which draws a
  straight edge from each parent to their mating unit and from each
  mating unit to each child.

- twinRelations:

  optional data.frame with columns `id1`, `id2`, `code` (see
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)).
  Not validated here; validate with
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)
  first. `NULL` (default) adds no connector edges. A connector always
  targets the two individuals' real node ids and always renders as a
  direct edge regardless of `edgeStyle`.

- kinshipMatrix:

  optional precomputed kinship matrix (a base `matrix` or a `Matrix`)
  with row AND column names set to individual ids. When supplied, it
  replaces this function's internal
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  call as the sole source of the consanguineous-mating-unit flags
  (`kinshipMatrix[sire, dam] > 0`): `twinRelations` then drives twin
  connector edges only, so a caller wanting twin-corrected consanguinity
  must bake it into the matrix (e.g.
  `kinship(..., twinRelations = ...)`). A sire/dam id absent from the
  matrix's dimnames leaves that unit at the safe `FALSE` default,
  exactly as a dangling parent does on the default path. `NULL`
  (default) computes
  `kinship(ped$id, ped$sire, ped$dam, ped$gen, twinRelations = twinRelations)`.

## Value

A list with `nodes` (`id`, `label`, `shape`, `title`, `size`,
`color.background`, `x`, `y`; `color.border` is added under
`edgeStyle = "rectilinear"`), `edges` (`from`, `to`, `dashes`,
`smooth.enabled`, `smooth.type`, `smooth.roundness`, `color`, `width`;
the `color` and `width` columns are always present once any mating unit
exists: a consanguineous mating unit's (`kinship(sire, dam) > 0`) 2
spouse-to-union edges get `"#D55E00"`/`4`, an Okabe-Ito colorblind-safe
vermillion in kinship2's doubled/thickened mate-line convention, and
every other edge gets `NA`; `label` is added when `twinRelations` is
supplied), and `duplicateToReal` (a named character vector, duplicate
node id -\> real individual id). Under `edgeStyle = "rectilinear"`, an
already-set edge `color` (e.g. the twin connector's or the consanguinity
marker's) is preserved when the edge is kept as-is; a marked mate edge
that gets replaced by a right-angle projection currently falls back to
the generic routing color and width. Also `isolatedIds`, a character
vector of ids suppressed from `nodes`/`edges` because they have no known
parent, are never a parent, and are not connected by `twinRelations`; it
is `character(0)` when nothing was suppressed. When every individual in
`ped` is isolated, `nodes`/`edges` are both 0-row and `duplicateToReal`
is empty.

## Details

Mating-unit nodes render as a small, unlabeled dot with an
offspring-count tooltip, visually distinct from the 5 sex-coded shapes.
An individual who has to appear more than once in the layout gets
duplicate nodes. A duplicate node keeps the real individual's own shape,
label and tooltip content (plus a cue that it is a duplicate), so it
reads as that individual, and is connected to it by a dashed edge.

In the default `"rectilinear"` edge style, mate-line and sibship-bar
edges are routed through invisible waypoint nodes so they render as
strict right angles, as kinship2 draws them. In the `"direct"` edge
style, edges are straight segments from each parent to the mating unit
and from the mating unit to each child.

A simple two-real-parent mating unit (each parent has exactly one mate
and both have unambiguous `"M"`/`"F"` sex codes) is drawn with the male
parent to the left of the female parent. The final horizontal positions
come from a joint quadratic program that preserves each row's
provisional left-to-right order, so this rule carries into the rendered
layout. It cannot be turned off.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::smallPed
layout <- makePedigreeMatingLayout(ped)
```
