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
  twinRelations = NULL
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
unconditional, folded directly into the Walker/BJL positioning engine's
own Tier 3 formula (`.positionMatingUnitForest()`, an internal function,
S8.1). The former `orderBySex` parameter that toggled this is removed:
the Phase 1b design note found the mechanism "restructured, not
preserved unchanged – eliminated as a separate pass," with no way to
disable it in the new engine, and this function had zero real callers
ever passing `orderBySex = FALSE` (grep-confirmed).

## Examples

``` r
library(nprcgenekeepr)
layout <- makePedigreeMatingLayout(nprcgenekeepr::examplePedigree)
#> makePedigreeMatingLayout(): 255 individual(s) with no recorded parents, mates, or offspring suppressed from the pedigree diagram: N54ICI, 2ZMHG7, SUCA1F, E48W9M, NWIXPA, Z4EY74, YSRHBD, Z84KGV, DZ6FVF, BTD2NZ, JHQPAP, BPI1HF, 6GWTJD, AYHHR5, BR14AQ, JDVB5M, 70T5GR, 4RXU2E, 9YTU7S, CJA95L, MCETJ8, 9Q766V, 4YHBRW, IZPCZZ, 8TBUP5, BKB6NF, BPE9NT, PW7W9T, F240HZ, 8TS6VW, Y6NNRB, AGWJ2R, TA1CKU, NBWMEY, FDXXBI, SSNP86, XGGREU, 7PABGY, VGPK53, JWIMX8, HZ95JQ, 0J5JEH, 8QH2I1, WQS9VQ, VMB6MK, WJLVT1, SBWT9S, B6W7HJ, APW1RV, NTYCL3, CT8DTM, Y3R9SM, F0AW25, 8VL35Z, B0BD97, KB1NXJ, K1GMK0, KFRNH9, DT5M1V, CUY46M, 3BR2DG, 3HGLEN, 493GGJ, 11Q5X6, Q8667V, XZH1WD, H7BDVI, NI7QQ2, L5E0K4, PW68MV, 10JVXT, ZUUZCM, D8XU5I, Z5CDUB, A4LVZ0, DPG4MS, YCLTFI, M9WMMU, 9A08HP, 3XE6E3, KJIIRT, Q3DARJ, HKX842, DEZZCQ, ZVYH2K, 7IFLW9, 1RPPRW, 3MJ3E7, 757BLD, EC4M69, ATN2K9, HL6YG6, 15FEBR, 2TXZPV, 5JDF5N, C3223L, R850T0, 0SQP8I, 0LHU4M, 986A3D, D9GR39, EE7DQV, C0A768, G5V5TU, Z528L9, VHHDHV, A10HCV, RU11VN, 18APRC, 9G91MC, 2Y7VDA, C9IK8M, TPTUYM, NF0DLQ, 9R4FAV, JC5PB5, 02GZ4L, ZZDSNV, F1ASM9, BLHKUT, EW4L95, 093AB5, XM4GY6, EBK34A, 8FR8EA, Z4UJIC, EC702Y, 01WY5E, NLGE61, 0SPRLB, 12AM87, 4V85VF, 5JNITD, VEC97H, LV8WIM, 100PFZ, Q3J24E, IC716S, SJD499, 0M6WB4, YJBY17, IDKQ3J, I3SU3W, CS5JWC, W69TQ7, 5C63F4, R0ZLR7, AUM3I5, HWTBFV, M30ER6, A4HWDT, 2KSL1E, Q204TU, GDN0LY, 5W3X92, VVEWCE, 7RLPEJ, 40RLGE, V7UUEH, NCD01L, GUDU9H, YPHZIJ, V1H5HL, CLGRHI, ASUZAZ, Z8Q2X9, ETUF6V, 8GRDXR, 9AWTC3, 1QBKW9, RKQMGF, EWX5XV, PBRGIF, ESNTV0, B267C6, QF30SN, XN5RG3, 489C6D, V6L8GF, 77EUZ7, Y3CJ5A, DGE0LV, RGQ8WZ, 8SG2BX, 9HS6C2, SK0UDE, B2I259, 2WMICB, 9XF3PS, SDBN6F, JZNCW3, ZUPBXP, W57X0M, IBQQQD, 88GL9Z, B7BMJM, PKLXCD, M07IM7, 8C4DFM, PSIK51, DXXRLM, N5Z0XZ, VKC95C, N43TAY, V205HB, L71BK6, YGAWEQ, XSC4NB, 5KWWYA, 3JUGDQ, 0CRGND, PEW6UW, 0QD4RS, 52Y0A2, JQBLVJ, 4P6AKL, F9U4FV, SPFBTK, 16V6FW, HQAB9U, T6VYXS, VDD1VM, XP47ES, YJ1PT7, FJL59A, 601GN4, Z2SLIV, 7TPAFF, 2Q4Q8M, JDD39A, 8KES7J, WK6MQT, RRYETA, VF341U, DL5GJM, I75S2W, 4BWI4P, 3LXEDN, PUXEBU, WRVEIX, F7NIBI, 0S7LIT, FDQMS5, CXHM36, PHD9HX, B6V285, CTX15V, FVTJH1, X6AA9D, 2Z6UAC, CQ0APY, QE8FY7, M4KYW2, KYAEVV, XBFLL2
#> Warning: makePedigreeMatingLayout(): 318 same-row edge-node collision(s) could not be fully resolved (residual after the repair-pass cap, or an unconfirmed curved-connector heuristic) -- rendered output may still show a straight or curved edge passing near an unrelated node.
```
