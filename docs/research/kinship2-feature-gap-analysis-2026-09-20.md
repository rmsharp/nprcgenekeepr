# kinship2 Feature-Gap Analysis — nprcgenekeepr Coverage of kinship2's Exported Surface

**Date:** 2026-09-20 · **Session:** S741 · **Type:** capability-gap analysis (step 1 of the
S739 BACKLOG item "Discuss making a kinship2-similar standalone package from code within
this repository," `BACKLOG.md:95`; step 2 — the owner discussion — is out of scope here)

**Question asked:** for every feature kinship2 exports, does nprcgenekeepr have an
(a) **equivalent** (name the function), (b) **partial** analog (name the gap), or
(c) nothing (**absent**)? The result feeds the step-2 owner decision on whether a
kinship2-similar standalone package built from this repo's code is worth building, and at
what scope.

---

## Method

- **kinship2's surface was enumerated live at analysis time** from the installed package
  (v1.9.6.2, this project's renv library) via `getNamespaceExports("kinship2")` — **25
  exports** — plus `getNamespaceInfo(ns, "S3methods")` — **11 S3 method registrations, 4
  of them not in the export list** (`[.pedigreeList`, `kinship.pedigree`,
  `kinship.pedigreeList`, `print.pedigreeList`) — plus `data(package = "kinship2")` —
  **3 datasets** (`minnbreast`, `sample.ped`, `testped1`). The BACKLOG item's embedded
  feature list was treated as the unverified hint its own caveat says it is; the
  enumeration above is the authoritative scope. (The hint was close but not exact: it
  named 11 of the 25 and omitted e.g. `fixParents`, `ibdMatrix`, `kindepth`,
  `makekinship`, `pedigree.unrelated`, and the three `findAvail*`/`findUnavailable`
  helpers.)
- **Every nprcgenekeepr-side claim was verified against the live source this session**
  (file:line citations below), not carried from prior docs.
- **Prior art reused, not redone:**
  `docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md` (S435; drawing-only,
  17-point) — **stale on the drawing rows**: its eight kinship2-only drawing gaps were
  subsequently filed as issues #131–#137 and, together with #145, are **all now CLOSED**
  (verified via `gh issue view` this session), so the drawing rows below reflect the
  current shipped state, not S435's;
  `docs/planning/kinship2-supplement-full-reproduction-plan.md` (Tracks A/B/C — Tracks A
  and B shipped: `kinship(chrtype = "x")` and `shrinkPedigree()`, confirmed in
  `NEWS.Rmd:230-235` and in the live code);
  `docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md` (S482
  kinship2 source-read spike).

**Coverage: 25 of 25 exports classified, plus the 4 extra S3 registrations and the
datasets as supplementary rows. Nothing skipped.**

---

## Summary

| Classification | Count | Exports |
|---|---|---|
| **Equivalent** (incl. equivalent-different-approach and native-by-design) | **15** | `pedigree`, `print.pedigree`, `as.data.frame.pedigree`, `align.pedigree`, `fixParents`, `kindepth`, `kinship`, `kinship.default`, `legendPlot`, `makefamid`, `pedigree.legend`, `pedigree.shrink`, `pedigree.trim`, `pedigree.unrelated`, `plot.pedigree` |
| **Partial** | **8** | `autohint`, `bitSize`, `findAvailAffected`, `findAvailNonInform`, `findUnavailable`, `makekinship`, `plot.pedigree.shrink`, `print.pedigree.shrink` |
| **Absent** | **2** | `familycheck`, `ibdMatrix` |

The two absences are minor utilities. Every substantive kinship2 capability — kinship
computation (autosomal, X-linked, MZ-twin-aware), pedigree construction/validation,
generation depth, family/component identification, parent repair, informative-subset
shrinking, trimming, unrelated-set selection, layout, plotting with affected-status /
twin / loop / legend / label support — has an equivalent or a deliberate
different-approach counterpart in this repository today. Most of the 8 partials are one
export away from equivalent (they exist as internals of `shrinkPedigree()`).

---

## Gap Table — kinship2's 25 exports

Classes: **EQ** = equivalent (function named) · **EQ-D** = equivalent via a deliberately
different approach · **EQ-N** = provided natively by the data-frame representation (no
function needed) · **PARTIAL** = analog exists, gap named · **ABSENT** = nothing.

| # | kinship2 export | What it does | Class | nprcgenekeepr analog / gap | Evidence |
|---|---|---|---|---|---|
| 1 | `pedigree()` | Constructor: validates ids/parents/sex, builds `pedigree` S3 object; enforces "both parents or neither" | **EQ-D** | `qcStudbook()` — validating constructor over a plain data frame (`id`/`sire`/`dam`/`sex`/`gen`…): sex-vs-parentage checks, date/format QC, far broader than `pedigree()`'s checks. Deliberate difference: **no ped object class**, and partial parentage (one known parent) is legal ordinary data here, where `pedigree()` forbids it | `R/qcStudbook.R:186`; the partial-parentage contrast is documented at `R/shrinkPedigree.R` roxygen (tier-2 note) and `R/getIdsWithOneParent.R:27` |
| 2 | `print.pedigree` | Compact object print | **EQ-N** | Pedigrees are data frames; base printing applies | data-frame representation throughout `R/` |
| 3 | `as.data.frame.pedigree` | Convert ped object → data frame | **EQ-N** | Already data frames; nothing to convert | same |
| 4 | `align.pedigree` | Layout alignment: positions per generation row (`plist`), spouse/sibling packing, 4-stage algorithm | **EQ-D** | `makePedigreeMatingLayout()` + the `positionTreeApportion.R` engine — computes mating-unit forest + node coordinates for the vis.js renderer instead of a `plist`; kinship2-fidelity was specifically audited and remediated (issues #143/#144/#145; S482 spike corrected the record on kinship2's own sire/dam placement behavior) | `R/makePedigreeDiagramData.R:1665`; `R/positionTreeApportion.R`; `docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md` |
| 5 | `autohint` | Computes/improves sibling+spouse ordering hints to reduce line crossings; user may also hand-supply hints | **PARTIAL** | Automatic ordering is built into the layout engine, but there is **no user-suppliable hint mechanism**: `makePedigreeMatingLayout(ped, edgeStyle, twinRelations)` exposes no ordering-override argument | `R/makePedigreeDiagramData.R:1665-1667` (signature) |
| 6 | `bitSize` | Pedigree complexity metric `2·nNonFounder − nFounder` | **PARTIAL** | Implemented as internal `.bitSizeOf()` and reported in `shrinkPedigree()`'s return value; **not separately exported** | `R/shrinkPedigree.R:227` (helper), `:151`/`:182-186` (use), roxygen `bitSize` return field |
| 7 | `familycheck` | Cross-check a user-supplied `famid` against computed connected components; report join/split errors | **ABSENT** | No analog: the data model has no user-supplied family-id column to validate. `findPedigreeNumber()` computes components (the `makefamid` half) but nothing compares a declared grouping against it | no hits for `familycheck` in `R/` (grep, this session) |
| 8 | `findAvailAffected` | Shrink helper: pick affected-status-prioritized removal candidate | **PARTIAL** | Ported as internal `.findAvailAffected()`; not exported standalone | `R/shrinkPedigree.R:363` |
| 9 | `findAvailNonInform` | Shrink helper: find genotyped-but-uninformative subjects | **PARTIAL** | Ported as internal `.findAvailNonInform()`; not exported standalone | `R/shrinkPedigree.R:337` |
| 10 | `findUnavailable` | Shrink helper: find unavailable/uninformative subjects to trim | **PARTIAL** | Ported as internal `.findUnavailable()` (+ `.excludeUnavailFounders()`, `.strayMarryinIds()`); not exported standalone | `R/shrinkPedigree.R:250`, `:281`, `:326` |
| 11 | `fixParents` | Data repair: add missing parent rows, fix parent sex to match role | **EQ** | `addParents()` (adds missing parent rows), `correctParentSex()` (role-vs-sex repair), `addBackSecondParents()`, `getIdsWithOneParent()` — a strictly richer repair suite inside the `qcStudbook()` pipeline | `R/addParents.R:30`, `R/correctParentSex.R:67`, `R/addBackSecondParents.R:34`, `R/getIdsWithOneParent.R:27` |
| 12 | `ibdMatrix` | Build a (sparse) IBD matrix from external ibd/solar-style pairwise estimates | **ABSENT** | No reader/assembler for externally computed pedigree-IBD estimates. Adjacent but distinct capability exists on the *marker* side: `markerKinship()` (genotype-based realized kinship) and `computeGenomicROH()` — these compute from genotypes rather than ingesting an external IBD file, so they are not the same feature | no `ibd` hits in `R/` (grep, this session); `R/markerKinship.R`, `R/computeGenomicROH.R` |
| 13 | `kindepth` | Generation depth per subject (with an optional parent-alignment variant for plotting) | **EQ** | `findGeneration()` — computes the `gen` column consumed package-wide. The plot-oriented `align_parents` variant has no separate analog (the layout engine handles its own depth adjustments internally) | `R/findGeneration.R:40` |
| 14 | `kinship` (generic) | Kinship matrix | **EQ** | `kinship()` — same Therneau lineage, and **exceeds** kinship2 on twins: MZ-twin correction propagates transitively and to later-depth relatives; also autosomal + X-linked in one function | `R/kinship.R:104` |
| 15 | `kinship.default` | id/mom/dad-vector method; `chrtype = "autosome"/"X"` | **EQ** | `kinship(id, father.id, mother.id, pdepth, sparse, twinRelations, chrtype, sex)` — `chrtype = "x"` ported from kinship2's own X-linked branch (Track A of the supplement-reproduction plan, shipped) | `R/kinship.R:104-105`; `NEWS.Rmd:230-234` |
| 16 | `legendPlot` | Plot + legend wrapper | **EQ-D** | In-app legend rendered with the diagram (issue #132): `visNetwork::visLegend()` shape-to-sex key plus twin-connector legend rows (issue #137 Slice 3) | `R/modPedigree.R:686`, `:649-660` |
| 17 | `makefamid` | Family id from pedigree connected components | **EQ** | `findPedigreeNumber()` — connected-component/pedigree-number assignment | `R/findPedigreeNumber.R:36` |
| 18 | `makekinship` | Blockwise **sparse** kinship over many families (`Matrix::bdiag`-style assembly keyed by famid) | **PARTIAL** | The whole-population dense matrix from `kinship()` contains the same information (cross-family cells are 0), and `kinship(sparse = TRUE)` only sparsifies the identity seed — there is **no block-diagonal sparse assembly**, so the memory saving that is `makekinship`'s point is absent. Component ids are available (`findPedigreeNumber()`) for a caller-side loop | `R/kinship.R:28-30`, `:128`, `:137`; `R/findPedigreeNumber.R:36` |
| 19 | `pedigree.legend` | Corner-placed affected-status key | **EQ-D** | Affected-status encoding + legend shipped with issue #133/#132 in the Diagram tab (color/tooltip channel + in-app key) | `R/modPedigree.R:682-694`; issues #132/#133 CLOSED (verified this session) |
| 20 | `pedigree.shrink` | Shrink pedigree to an informative subset within a bit-size budget | **EQ** | `shrinkPedigree()` — full port of the orchestrator + its 5 helpers from the installed namespace, with two documented, deliberate deviations: deterministic tie-break (kinship2 uses `runif()`, confirmed non-reproducible run-to-run by live multi-seed comparison) and a defined rule for partial-parentage subjects kinship2's input model cannot express | `R/shrinkPedigree.R:122` + roxygen |
| 21 | `pedigree.trim` | Remove listed subjects from a ped object | **EQ** | `trimPedigree()` (proband-driven, with `removeUninformative` option), `removeUnknownAnimals()`, `removeUninformativeFounders()`; plus the port inside `shrinkPedigree()` | `R/trimPedigree.R:51`, `R/removeUnknownAnimals.R:21`, `R/removeUninformativeFounders.R:30` |
| 22 | `pedigree.unrelated` | Maximal set of available, mutually unrelated subjects | **EQ-D** | `groupAddAssign()` — maximal-independent-set search for groups of unrelated animals, kinship-threshold-configurable, multi-group capable; a superset of the single-set, fixed-threshold `pedigree.unrelated` use case | `R/groupAddAssign.R` roxygen ("maximal independent set (MIS) algorithm to find groups of unrelated animals") |
| 23 | `plot.pedigree` | Static base-graphics pedigree drawing: sex shapes, affected shading, deceased slash, twin brackets, loop duplicate-with-arc | **EQ-D** | The Diagram tab pipeline: `makePedigreeDiagramData()` + `makePedigreeMatingLayout()` + visNetwork module. Since the S435 comparison, its eight kinship2-only drawing gaps closed: image export #131, in-app legend #132, affected-status encoding #133, loop rendering verified #134, hover tooltips + search/highlight #135, name labels #136, twin/zygosity encoding #137, sire/dam placement #145 — all CLOSED. Interactivity (click-to-navigate, pan/zoom, search) remains nprcgenekeepr-only. Remaining kinship2-only rendering details: deceased-status slash overlay (no death-status channel in the diagram node model) and duplicate-instance dashed-arc convention (this engine renders one node per id, verified acceptable under #134) | `R/makePedigreeDiagramData.R`; `R/modPedigree.R:675-694`, `:741-790`; issues #131–#137/#145 CLOSED (verified via `gh issue view` this session) |
| 24 | `plot.pedigree.shrink` | Plot the shrunken pedigree with trim highlighting | **PARTIAL** | No dedicated method; a shrunken pedigree is an ordinary data frame renderable through the standard diagram pipeline, but nothing visually distinguishes trimmed-away subjects | `R/shrinkPedigree.R` return shape (data frame + metadata fields) |
| 25 | `print.pedigree.shrink` | Print shrink result summary | **PARTIAL** | No dedicated method; the same information (ids trimmed per tier, bit-size trajectory) is returned as plain fields the caller can print | `R/shrinkPedigree.R` roxygen return fields (`bitSize` trajectory etc.) |

### Supplementary rows — S3 registrations not in the export list, and datasets

| Item | Class | Note |
|---|---|---|
| `[.pedigree` / `[.pedigreeList` | **EQ-N/EQ-D** | Data-frame subsetting is native; semantic subsetting via `trimPedigree()` (`R/trimPedigree.R:51`), `getProbandPedigree()` (`R/getProbandPedigree.R:24`), `getDescendantPedigree()` (`R/getDescendantPedigree.R:26`) |
| `kinship.pedigree` / `kinship.pedigreeList` | **PARTIAL** | No ped-object methods (no ped class); the pedigreeList method's per-family blocked computation is the same gap as `makekinship` (#18) |
| `print.pedigreeList` | **EQ-N** | Native data-frame printing |
| Datasets (`minnbreast`, `sample.ped`, `testped1`) | **EQ-D** | 25+ bundled datasets serve the same example/testing role (`data/`: `examplePedigree`, `lacy1989Ped`+alleles, `qcPed`, `rhesusPedigree`, `smallPed`, `smallPedTree`, …) |
| kinship2's twin input (`relation` argument on `pedigree()`) | **EQ** | `readTwinRelations()` (`R/readTwinRelations.R:35`) + `checkTwinRelations()` (`R/checkTwinRelations.R:50`) + `twinRelations` parameters on `kinship()` and `makePedigreeMatingLayout()`; MZ handling exceeds kinship2 (transitive propagation) |

---

## Findings

### Finding #1: Only two kinship2 exports have no analog at all, and both are minor
- **Exports:** `familycheck`, `ibdMatrix`.
- **Why minor here:** `familycheck` validates a *user-supplied* family-id column — a data
  shape this package's pipeline never ingests (components are always computed, via
  `findPedigreeNumber()`); `ibdMatrix` ingests externally computed IBD estimates
  (ibd/solar tooling), a workflow adjacent to but distinct from this package's own
  genotype-based `markerKinship()`/`computeGenomicROH()`.
- **Step-2 relevance:** if full kinship2 parity were the goal, both are small, standalone
  ports; neither blocks or shapes the packaging decision.

### Finding #2: Most "partial" classifications are one export statement away from equivalent
- Six of the eight partials (`bitSize`, `findAvailAffected`, `findAvailNonInform`,
  `findUnavailable`, and the two `*.pedigree.shrink` methods' underlying data) already
  exist as working, tested internals of `shrinkPedigree()`
  (`R/shrinkPedigree.R:227-380`). kinship2 exports its shrink helpers; this package
  deliberately kept them internal (Track B design). A standalone package aiming at
  kinship2's *surface* (not just its capability) would export them; nothing new needs
  writing.
- The genuinely substantive partials are two: **user-suppliable layout hints**
  (`autohint`'s second half — the engine auto-orders but accepts no override) and
  **block-sparse multi-family kinship** (`makekinship` — matters only at population
  sizes where a dense matrix hurts; this package routinely builds dense whole-colony
  matrices today).

### Finding #3: The drawing-side comparison has inverted since S435
- The S435 audit found seven kinship2-only drawing capabilities. Eight follow-up issues
  later (#131–#137, #145 — all CLOSED, all strict-TDD with design docs), the current
  diagram pipeline matches or exceeds `plot.pedigree` on every axis the owner
  prioritized, while keeping the interactivity kinship2 architecturally cannot offer.
  The only kinship2-only rendering details left are the deceased-status slash overlay
  (data-model-gated: no death-status channel in the diagram node model) and the
  duplicate-instance-with-dashed-arc convention for loops (a different, verified-adequate
  convention is used here: one node per id, issue #134).

### Finding #4: The feature equivalents live on two different surfaces — this is the real step-2 question
- The **computation** equivalents (`kinship`, `shrinkPedigree`, `trimPedigree`,
  `findGeneration`, `findPedigreeNumber`, `groupAddAssign`, repair suite) are exported,
  script-callable functions — directly extractable.
- The **drawing** equivalents beyond raw layout (legend #132, image export #131,
  tooltips/search #135) live inside the Shiny module `R/modPedigree.R:675-790`, not on
  the exported surface: `makePedigreeDiagramData()`/`makePedigreeMatingLayout()` produce
  the data, but the visNetwork decoration calls are module-bound. A standalone package
  promising kinship2-style *plotting* would need those decorations lifted into a
  script-callable render function (mechanically straightforward — visNetwork htmlwidgets
  render outside Shiny — but real, unscoped work).
- Prep steps D-1/D-2/D-3 (`BACKLOG.md:71-94`, queued from the S738 disposition) remain
  step 0 of any extraction; D-1 (invert the `kinship()` back-reference at
  `R/makePedigreeDiagramData.R:1755`) is exactly the boundary a standalone package
  would need.

---

## Structural observations

1. **This repository has already reproduced kinship2's compute core, deliberately and
   with provenance.** `kinship()` is the same Therneau lineage with kinship2 cited in
   `@references`; `shrinkPedigree()` and `chrtype = "x"` were ported from the installed
   namespace under a ratified plan with documented deviations. The gap analysis is
   therefore mostly a *packaging* question, not a *capability* question.
2. **Where this package differs from kinship2, it is usually by documented decision, not
   omission** — no ped S3 class (plain validated data frames), partial parentage legal,
   deterministic shrink tie-breaks, one-node-per-id loop convention. A standalone package
   would have to choose between keeping these (a "kinship2-similar in spirit" package)
   or adding a compatibility layer (true drop-in parity) — that choice, not feature
   count, is the main step-2 scope decision.
3. **The ecosystem-argument context from the scoping doc still holds** (`docs/research/
   pedigree-diagram-package-split-scoping-2026-09-02.md` §2.7): kinship2 1.9.6.2 is
   maintained with no CRAN deprecation notice; nothing on CRAN offers a vis.js-targeted
   kinship2-parity layout. What a package from this repo would uniquely add is the
   interactive drawing surface plus the twin-aware/X-linked kinship extensions.

---

## Recommendations (input to step 2 — decisions are the owner's)

1. **Frame step 2 around packaging shape, not feature gaps.** Coverage is 15 EQ / 8
   PARTIAL / 2 ABSENT — capability parity is effectively done. The open choices are:
   (a) data-frame API as-is vs kinship2-compatibility layer; (b) whether the drawing
   decorations get lifted out of `modPedigree.R` into a script-callable renderer;
   (c) whether the shrink internals get exported to mirror kinship2's surface.
2. **If parity completeness matters for the pitch:** the cheap closers are exporting the
   shrink helpers + `bitSize` (Finding #2) and small ports of `familycheck`/`ibdMatrix`
   (Finding #1). The substantive ones are layout hints and block-sparse kinship — both
   worth explicit in/out decisions rather than default inclusion.
3. **Sequencing is already queued:** prep D-1/D-2/D-3 precede any extraction; the S738
   disposition's revisit conditions (engine-stability, CRAN release accepted) still gate
   it. This analysis supplies the condition-3 "ecosystem argument" evidence the
   disposition asked for.
