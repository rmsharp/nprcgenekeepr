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

  one of `"rectilinear"` (default since Track 2,
  docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md –
  issue \#142's routing of mate-line and sibship-bar edges through
  invisible waypoint nodes via `.addRectilinearWaypoints()` so they
  render as a strict right angle, kinship2-style, instead of a direct
  diagonal/straight segment) or `"direct"` (this function's own original
  behavior – a straight edge from each parent to their mating unit and
  from each mating unit to each child).

- twinRelations:

  optional data.frame with columns `id1`, `id2`, `code` (see
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md))
  – issue \#137 D1/D6/D7. Not validated here; validate with
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)
  first. `NULL` (default) adds no connector edges and leaves `edges`
  unchanged from the pre-#137 contract. A connector always targets the
  two individuals' REAL node ids (D7) and always renders as a direct
  edge regardless of `edgeStyle` (D9).

- kinshipMatrix:

  optional precomputed kinship matrix (a base `matrix` or a `Matrix`)
  with row AND column names set to individual ids – Prep D-1 (S744;
  package-split scoping doc
  `docs/research/pedigree-diagram-package-split-scoping-2026-09-02.md`
  §4 D3 option ii, the dependency inversion). When supplied, it replaces
  this function's internal
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  call as the SOLE source of the consanguineous-mating-unit flags
  (`kinshipMatrix[sire, dam] > 0`): `twinRelations` then drives twin
  CONNECTOR edges only, so a caller wanting twin-corrected consanguinity
  must bake it into the matrix (e.g.
  `kinship(..., twinRelations = ...)`). A sire/dam id absent from the
  matrix's dimnames leaves that unit at the safe `FALSE` default,
  exactly like the dangling-parent guard on the default path. `NULL`
  (default) computes
  `kinship(ped$id, ped$sire, ped$dam, ped$gen, twinRelations = twinRelations)`
  exactly as before, so no existing caller changes.

## Value

A list with `nodes` (`id`, `label`, `shape`, `title`, `size`, `x`, `y`),
`edges` (`from`, `to`, `dashes`, `color`, `width` – the latter 2 ALWAYS
present once any mating unit exists, S549 Finding \#2 fixed S555: a
consanguineous mating unit's (`kinship(sire, dam) > 0`) 2
spouse-to-union edges get `"#D55E00"`/`4` (an Okabe-Ito colorblind-safe
vermillion, kinship2's own doubled/ thickened mate-line convention),
every other edge `NA`; plus `label` when `twinRelations` is supplied –
D10, found never wired at S494, fixed S506), and `duplicateToReal` (a
named character vector, duplicate node id -\> real individual id). Under
`edgeStyle = "rectilinear"`, `nodes` gains
`color.background`/`color.border` and `edges` unconditionally gains
`color` (see `.addRectilinearWaypoints()`) – an already-set edge `color`
(e.g. the twin connector's or the consanguinity marker's) is preserved
when the edge is KEPT as-is; a marked mate edge that gets replaced by a
D2 dogleg projection currently falls back to the generic routing
color/width (edgeStyle = "rectilinear" propagation is a deferred
follow-up, BACKLOG.md Housekeeping). Also `isolatedIds` (issue \#164 /
P5-suppression plan, Dragon 2-3, RATIFIED S643): a character vector of
ids suppressed from `nodes`/`edges` because they have no known parent,
are never a parent, and are not `twinRelations`-connected –
`character(0)` when nothing was suppressed. When every individual in
`ped` is isolated, `nodes`/`edges` are both 0-row and `duplicateToReal`
is empty (this is also issue \#164's fix – the function no longer
crashes on an all-isolated `ped`).

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

Male-left/female-right ordering (issue \#145) – every simple two-real-
parent mating unit (mate-count exactly 1 each, unambiguous `"M"`/`"F"`
sex codes, neither parent with a D5 direct child of their own) renders
with the male parent to the left of the female parent – is now
unconditional, folded directly into the positioning engine's own
provisional-seeding rules (`.positionMatingUnitForest()`, an internal
function – the S666 conditional-shift pass's sex-sign rule and Decision
1's order-consistent seeding side rule); since the QP migration
(`docs/planning/pedigree-diagram-joint-qp-solver-plan.md`) the final x
for every node comes from `.solveJointQP()`, which preserves each row's
provisional left-to-right order, so the rule survives into the rendered
layout. The former `orderBySex` parameter that toggled this is removed:
the Phase 1b design note found the mechanism "restructured, not
preserved unchanged – eliminated as a separate pass," with no way to
disable it in the new engine, and this function had zero real callers
ever passing `orderBySex = FALSE` (grep-confirmed).

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::smallPed
layout <- makePedigreeMatingLayout(ped)
```
