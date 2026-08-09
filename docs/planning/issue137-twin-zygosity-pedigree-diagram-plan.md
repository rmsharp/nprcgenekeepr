# Issue #137 Plan — Twin/Zygosity Encoding for the Pedigree Diagram (Data-Model Gated)

**Status:** RATIFIED (2026-08-09, this session). All four judgment-call decisions (D1, D6, D7, D11) were ratified via `AskUserQuestion`; the owner selected this document's own recommended option for all four, with no changes requested. See §10 for the recorded outcome. This plan is ready for Slice 1 implementation in a future session.
**Session:** S491 (2026-08-09)
**Origin:** GitHub issue #137, Tier 2 sequencing cluster `#133 > #136 > #137 > #138` (owner priority order for #133/#136/#138 was explicit; #137's position in that order was Session 436's *inference*, not a stated owner ranking — `PROJECT_LEARNINGS.md` Learning 411). Source audit Finding #5/Recommendation #5 scored "No action — data-model gated, low practical relevance to macaque colonies"; the owner overrode that disposition to file it as a tracked issue anyway, without reversing the audit's own reasoning (preserved verbatim in the issue body).
**Touches (planned, future sessions):** `R/checkTwinRelations.R` (new), `R/obfuscateTwinRelations.R` (new), `R/makePedigreeDiagramData.R`, `R/modPedigree.R`, `R/appServer.R`, `R/modInput.R` (Slice 3, mechanism TBD — §6 Dragon 1), `tests/testthat/test_checkTwinRelations.R` (new), `tests/testthat/test_obfuscateTwinRelations.R` (new), `tests/testthat/test_makePedigreeDiagramData.R`, `tests/testthat/test_makePedigreeMatingLayout.R`, `tests/testthat/test_modPedigree.R`, `inst/extdata/examples/` (two new sibling fixtures — a pedigree CSV and a twin-relations sidecar CSV), `data-raw/` (fixture generator script), `NEWS.Rmd`, `vignettes/manual_components/_pedigree_browser.Rmd` and/or `vignettes/articles/colony-manager-guide.qmd`.
**Does NOT touch:** `R/columnSchema.R`, `R/getPossibleCols.R`, `R/qcStudbook.R`, `R/checkRequiredCols.R`, `R/fixColumnNames.R`, `R/removeDuplicates.R` — confirmed this session that all six exist solely to recognize/validate/dedupe columns on the single per-individual pedigree data frame; D1 (§3) keeps twin/zygosity data in a wholly separate sidecar object that never enters that pipeline, so none of the six needs to change. This is a direct, checkable consequence of D1 and a point of contrast with #133/#136, both of which *did* touch `R/columnSchema.R` for their per-individual columns.
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` — same rationale #136 used: a data-model and rendering-contract change, not a UI layout/zone design.

> **Scope.** Design (not implement) how twin/zygosity relationships enter nprcgenekeepr's data model and render on the pedigree Diagram tab, following kinship2's own `relation` convention per the owner's S436 naming-overlay directive. This document proposes a specific architecture, argues for it over the alternatives the research surfaced, and separates decisions the evidence already forces from decisions that remain genuine judgment calls the owner must ratify (§10) before implementation begins.

---

## 1. Context

### 1.1 What issue #137 says (verbatim)

> **Source:** `docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`, Finding #5 (Recommendation #5).
>
> kinship2 has a dedicated `relation` argument with numeric codes for monozygotic/dizygotic/unknown-zygosity twins, rendered as diverging lines from a shared point (a connecting line for MZ, a question mark for unknown zygosity). nprcgenekeepr's diagram has no twin concept anywhere in its data model, code, plan, tests, or `NEWS.md` — twins would render as ordinary same-generation siblings with no marker.
>
> **Impact:** Low-to-moderate for this project's typical subject species — macaques rarely produce twins, unlike the human-pedigree use case kinship2 was primarily built for — but any twin births in a colony would be visually indistinguishable from non-twin siblings.
>
> **Audit disposition:** the audit recommended **no action** — out of scope for issue #129, and the underlying pedigree data model has no twin/zygosity field to encode regardless of rendering choice. Filed here per owner direction (session 436) to track the idea for future consideration. Revisit only if a future data-model change adds twin-relationship tracking.
>
> **Domain-convention note (owner-directed, session 436):** part of this project's broader goal is to overlay kinship2-style genetics-domain conventions onto the existing pedigree data model where applicable. If/when this is implemented, adopt kinship2's own naming/coding convention rather than inventing a new one — kinship2's `relation` argument records a subject pair plus a numeric zygosity code (1=MZ twin, 2=DZ twin, 3=unknown-zygosity twin). Implementation will also need test pedigree fixtures augmented with the added twin/relation column(s) to exercise the new behavior; none of the package's current example/test pedigrees carry one.
>
> **Owner-directed priority order (session 436):** the owner's explicit ordering named Recommendation #2, #3, #4, #1, #8, #7 (6 items) plus #6 (explicitly deprioritized/delayed) — this issue (Recommendation #5) was not given an explicit position. Placed last-but-one here (position 7 of 8) as the next-lowest-signal item, since #6 was the only one explicitly called out as delayed; this placement is an inference by the filing session, not a stated owner decision — flag for owner confirmation if exact ordering among the unranked items matters.
>
> *Triage decision authored by an AI agent during session 436 — review before relying on this for human-facing work.*

Owner comment (added after initial filing, session 436):

> **Documentation scope (owner-directed, session 436, added after initial filing):** if this issue is implemented, the plan must include updating `vignettes/articles/colony-manager-guide.qmd` and/or `vignettes/manual_components/_pedigree_browser.Rmd` to describe the new capability's purpose and use — not just code + tests + `NEWS.md`. This convention is now recorded in `CLAUDE.md`'s "Tutorial/article documentation checklist"; see also issue #139, which tracks that the base Diagram-tab feature (issue #129) itself currently has zero tutorial/article coverage.

Both quotes are the real, live issue body/comment (confirmed via `gh issue view 137 --json title,body,labels,comments` at this session's Phase 0/1, not reconstructed from a research summary).

### 1.2 What is already decided (do not re-litigate)

- **Priority/position:** #137 sits in the owner's Tier 2 sequencing cluster as `#133 > #136 > #137 > #138`. #133 and #136 have both shipped (Sessions 485-490); #137 is next. Its exact position within the *unranked* remainder of the owner's original priority list was Session 436's inference, not a stated ranking (Learning 411) — this affects only *when* #137 gets picked up, not anything in this document's design.
- **Naming/coding convention, if implemented:** must adopt kinship2's own convention (subject-pair-plus-numeric-zygosity-code, 1=MZ/2=DZ/3=unknown-zygosity) rather than inventing a new one — the same S436 directive that produced #133's `affected` column name.
- **Test fixtures:** implementation needs pedigree fixtures augmented with twin structure; none of the package's current fixtures carry any (confirmed independently this session, §2.7 — zero twin-like `(sire, dam, birth)` triples in either bundled example pedigree).
- **Documentation scope:** any implementing plan must update `vignettes/articles/colony-manager-guide.qmd` and/or `vignettes/manual_components/_pedigree_browser.Rmd` (owner's issue comment above, now `CLAUDE.md`'s "Tutorial/article documentation checklist").
- **Audit disposition preserved, not reversed:** the source audit's "no action, data-model gated" reasoning still stands as the honest baseline — filing #137 tracks the idea; it does not mean the audit was wrong that this is a genuinely marginal feature for macaque colony management. This document's own recommendations (§3, §6) lean toward the smallest defensible implementation for exactly that reason.

### 1.3 What this session's research confirmed — and where the issue is wrong

The issue's own description of kinship2's codes (1=MZ, 2=DZ, 3=unknown-zygosity) is **incomplete**. Both kinship2's help page and its source (`pedigree()`, deparsed from the installed namespace) document a **4th code**: `4 = Spouse`, used to force a marriage/mate line to render for a childless couple. This is a non-twin relationship type living in the *same* `relation` argument and the *same* 3-column `(id1, id2, code)` shape. This document scopes #137 to twins only (codes 1-3) and treats code 4 as explicitly out of scope (§3 D2) — but any future session extending this mechanism to general relationship annotation (e.g., "spouse with no children" as its own feature) should know the shape already accommodates it for free, because of how D1/D2 are structured.

The research also empirically confirmed (not merely read from Rd text) that kinship2 does **not** require twin-coded pairs to already share a sibling relationship for two of its four codes: UZ (unknown-zygosity) and spouse can be declared between *any* two pedigree members, with no sibling/parent precondition. Only MZ and DZ require the pair to already be declared full siblings (same `dadid` and `momid`) in kinship2's own underlying pedigree; MZ additionally requires matching sex. This asymmetry is load-bearing for D4 (§3): the validator this project builds should reproduce it exactly, not invent its own uniform rule.

Also confirmed: kinship2 has no visNetwork/vis.js analog anywhere in its own codebase — its twin rendering (wedge convergence, MZ crossbar, UZ "?" glyph) is base-graphics polyline math with no interactive-widget equivalent to port. Any nprcgenekeepr implementation is necessarily a **new**, hand-built visual language, not a translation of existing code (§2.1, §3 D6).

**Independently re-confirmed by this session's own direct verification** (not solely the research pass that produced §2, run separately as a cross-check): deparsed `pedigree()`'s source directly (`code <- factor(code, levels = 1:4, labels = c("MZ twin", "DZ twin", "UZ twin", "spouse"))`); read `align.pedigree()`'s branch that routes `relation[, 3] == 4` into `spouselist` and `relation[, 3] < 4` into the `twins` matrix; read `plot.pedigree()`'s drawing code and confirmed only `plist$twins[i, who] == 1` (MZ, an extra crossbar `segments()`) and `== 3` (UZ, a `text(..., "?")` glyph) get any additional visual mark — DZ (`== 2`) is clustered into the same shared convergence point as MZ/UZ but receives no additional line or symbol of its own. This matches §2.1 exactly and is one of the few facts in this document independently confirmed twice, by two separate investigative passes, with identical results.

---

## 2. Evidence-based inventory

### 2.1 kinship2's actual `relation` convention (verified against installed source, not the Rd summary alone)

`relation` is a 3-column matrix or data.frame (`id1`, `id2`, `code`); a 4th `famid` column is required only if `famid` is separately supplied to `pedigree()` (not applicable here — nprcgenekeepr's pedigree object has no `famid` concept, confirmed by the full read of `R/columnSchema.R`, §2.2). `code` accepts numeric 1-4 or the exact character labels `"MZ twin"`/`"DZ twin"`/`"UZ twin"`/`"spouse"`.

Rendering (`align.pedigree()`/`plot.pedigree()`, deparsed source): a `twins` matrix records the code at the *left-hand* member's grid slot for codes 1-3 only (code 4 routes through the ordinary `spouselist` mate-line path instead, never entering `twins` at all). At plot time, any run of twin-flagged adjacent siblings has its descent lines regrouped to converge on one shared midpoint below them (the "wedge") — this grouping happens for **all three** twin codes. On top of that shared wedge: MZ gets an *additional* horizontal crossbar; UZ gets an *additional* "?" text glyph at the same spot; DZ gets **no extra mark at all**, distinguished from ordinary siblings only by the wedge convergence itself. Validation (`pedigree()` source, confirmed by triggering each error branch): both ids must exist and differ (universal, all codes); MZ/DZ additionally require the pair to already share both `dadid` and `momid`; MZ additionally requires matching `sex`; UZ and spouse have no such precondition.

None of this — the `twins` matrix, the wedge-convergence grouping, the crossbar, the "?" glyph — has a mechanical analog anywhere in this package's own `visNetwork`-based renderer (§2.6). Every rendering decision in §3 is therefore a fresh design choice informed by, but not copied from, kinship2's approach.

### 2.2 The pedigree column schema — why it structurally cannot hold a pairwise fact

`.nprcColumnSchema` (`R/columnSchema.R:15-24`) has exactly three roles — `required`, `include`, `possible` — and **every** entry in every role is a single-individual column on one shared per-`id`-row data frame. There is no `id2`-shaped role or column anywhere in the file. Confirming that issues #133 and #136 are not hypothetical precedent but *already-shipped* features: `.nprcColumnSchema$possible` already contains `"affected"` and `"name"` (`:19-23`).

A pairwise fact — `id1` is a twin of `id2`, with code `X` — needs two id-slots plus a value. Nothing in `required`/`include`/`possible`, nor the underlying data frame's one-row-per-animal contract, has a second id dimension. **This is the structural fact that makes twin/zygosity encoding genuinely different in kind from #133's `affected` or #136's `name`, both single-individual attributes that could simply join `.nprcColumnSchema$possible`.** §3 D1 resolves this; the resolution has two already-working precedents in this exact codebase (below).

### 2.3 Existing precedent for pairwise data: `applyKinshipOverrides()` vs. `convertRelationships()`

Two existing mechanisms in this codebase already carry `(id1, id2, ...)`-shaped data, and they point in different directions:

- **`applyKinshipOverrides()`** (`R/applyKinshipOverrides.R`): its `overrides` parameter is a user-*supplied* `data.frame(id1, id2, kinship)`, validated by `checkKinshipOverrides()`, threaded through the app as its **own separate reactive** (`gvResults$kinshipOverrides`, wired at `R/appServer.R:344-363,409`) distinct from `shared$currentPedigree`, and consumed independently by `R/modSummaryStats.R`. This is **authored input** — a fact the user asserts from outside the pedigree's own topology, exactly the shape twin-zygosity needs (birth-date coincidence cannot prove zygosity; §2.4).
- **`convertRelationships()`** (`R/convertRelationships.R`): produces the same `(id1, id2, ..., relation)` long-form *output* shape, but it is **derived** — computed from `kinship()`/CEPH ancestor sets, not authored. This is the wrong precedent to imitate for twin-zygosity, because zygosity is not derivable from `id/sire/dam/birth` at all (two full-siblings sharing a birth date is consistent with, but not proof of, twin-ness; MZ-vs-DZ is not inferable from pedigree topology under any circumstance).

`applyKinshipOverrides()`'s shape is the load-bearing precedent for §3 D1.

### 2.4 The naming collision — two of them, not one

A bare `zygosity` identifier would silently collide with a heavily-used, unrelated, **pre-existing** vocabulary: `markerObservedHeterozygosity()`/`markerExpectedHeterozygosity()`, `markerFst()`, and the "Heterozygosity" tab in `R/modMarkerGenetics.R` all use "zygosity" in the genotype sense (allele-pair heterozygosity/homozygosity at a marker locus, issue #130's family) — ~30 hits across `R/`, tests, and vignettes, confirmed by grep, all in that sense, none about twins. This collision is not hypothetical or stale: it is *currently live*, added in the same #130 cluster (Sessions 442-447) immediately before this document, and `vignettes/articles/colony-manager-guide.qmd` already documents the Heterozygosity tab in prose — the exact document family Slice 3 of this plan will also touch.

A second, independent collision exists for the word `relation`: `convertRelationships()`, `makeRelationClassesTable()`, and the Summary Statistics "Export Relationships" feature already own that word for pedigree-derived relationship *classification* (Full-Siblings, Parent-Offspring, etc. — a completely different, derived concept from an authored twin fact).

**Resolution (§3 D2/D3):** the sidecar table's own columns are named literally `id1`, `id2`, `code` — kinship2's own names, verbatim, which sidesteps the `zygosity` collision by simply never using that word as an identifier. The R-level parameter/object is named `twinRelations` (not bare `relation`), and its validator `checkTwinRelations()` — both collision-free against the existing "relation" vocabulary. "Zygosity" remains available as ordinary English prose (UI legend text, roxygen prose, this document) — the collision risk is specifically about **identifiers** (column/parameter/function names), not about avoiding the word altogether. **Prose usage still needs explicit disambiguation, not just identifier-level avoidance** — see the added Slice 3 DONE criterion in §4 requiring any user-facing text to say "twin zygosity," never bare "zygosity," precisely because the Marker Genetics Heterozygosity tab (a different sense of the same root word) lives in the same documentation family this plan's Slice 3 touches.

### 2.5 `obfuscatePed()` — a single-data-frame scrubber, confirmed by full read

`obfuscatePed()` (56 lines, full read) scrubs exactly three things: `id`/`sire`/`dam` aliasing via an `alias` vector keyed by `ped$id` (`:31-34`); `name` dropped to `NA` rather than aliased (`:35-41`, added for #136); any `Date`-classed column plus recomputed `age` (`:42-50`). **Everything else passes through untouched**, and the function's signature takes exactly one pedigree data frame — it structurally cannot reach into a second, sidecar object.

Critically, `obfuscatePed(..., map = TRUE)` already returns `list(ped, map = alias)` (`:51-55`) — the exact id-remapping table a sidecar-table scrubber needs. No existing function in the codebase consumes that `map` for any purpose today (confirmed: `applyKinshipOverrides()`'s own `overrides` object is never run through `obfuscatePed()` anywhere in the codebase) — this is a **new** scrub obligation with no existing single-call precedent to copy, only raw material (`map`) to build on. §3 D5 proposes the new function (`obfuscateTwinRelations()`), and it is a required Slice 1 deliverable (§4), not a deferred risk — this is the single most important structural finding of this session's research, because a plan that named the constraint but didn't resolve it would ship a real PII gap identical in shape to the one #136 D8 was written to close for the `name` column.

### 2.6 Rendering pipeline — mating-union nodes, duplicate nodes, and the two `rbind` traps

`.buildMatingUnitForest()` (`R/makePedigreeDiagramData.R:267-466`) collapses every distinct `(sire, dam)` pair into one `__union_<n>` node; every child of that pair gets a single edge from the union node, not two edges to sire and dam separately (`childEdges`, `:457-462`). Same-generation full-siblings today are **not** drawn with a literal horizontal sibship bar in the default `edgeStyle = "direct"` layout — siblinghood is implied only by the shared union-node parent, not by any sibling-to-sibling visual element. A literal bar-with-drops geometry exists **only** under `edgeStyle = "rectilinear"`, built post-hoc by `.addRectilinearWaypoints()`'s "D1" block (`:1205-1233`).

Individuals who parent more than one mating unit get exactly one "free" real-node occurrence plus a synthesized `__dup_<id>_<n>` node per additional occurrence (`:410-445`); the reserved-prefix guard (`:279`) still holds (`__union_`, `__dup_`, `__drop_`, `__bar_`, `__proj_`), confirmed unchanged in kind, only shifted in line number since #136.

Two structurally identical traps live in `.addRectilinearWaypoints()`, both instances of the same pattern (`rbind(real, synthetic[, names(real)])`):

- **Node-level, line 1334:** `finalNodes <- rbind(keptNodes, newNodes[, names(keptNodes)])` — `newNodes` (the synthesized invisible waypoint rows) is built with a **fixed** column set (`:1318-1333`: `id, x, y, label, shape, title, size, color.background, color.border`). Any new column added upstream to `realNodes`/`dupNodes` breaks this line with "undefined columns selected" unless `newNodes`'s construction is updated in lockstep.
- **Edge-level, line 1301:** `finalEdges <- rbind(keptEdges, newEdges[, names(keptEdges)])` — `newEdges` is built with its own fixed set (`:1287-1300`): **`from, to, dashes, color, smooth.enabled, smooth.type, smooth.roundness`** — confirmed, no `label` column exists in that set today. Any new edge-level column trips this line the same way.

Both line numbers (1334, 1301) were independently confirmed twice this session (the research pass and a separate direct `grep`/read), superseding the `~1237` citation carried in earlier handoffs (#136-era) — the file has grown since then and the trap has moved, though its mechanism is unchanged.

§3 D6/D9 confirm which of the two traps a twin-connector design actually touches.

### 2.7 Existing fixtures — genuinely no twin structure, confirmed by direct inspection

Programmatically grouped `obfuscated_rhesus_mhc_ped.csv` (376 rows) and `ExamplePedigree.csv` (3,694 rows) by `(sire, dam, birth)` — **zero** groups with more than one row in either file. No bundled fixture anywhere in the package carries twin-like structure today; a twin design's fixture strategy must fabricate pairs from scratch (seeded RNG, disclosure header), exactly as `obfuscated_rhesus_mhc_ped_affected.csv`/`obfuscated_rhesus_mhc_ped_name.csv` did.

### 2.8 Structural traps table

| # | Trap | Where | Consequence if ignored | Addressed by |
|---|---|---|---|---|
| 1 | No `id2`-shaped role in `.nprcColumnSchema` | `R/columnSchema.R:15-24` | Cannot represent a pairwise fact on the existing schema at all | D1 (sidecar, bypasses schema entirely) |
| 2 | `zygosity` collides with marker-genetics vocabulary | `R/markerFst.R`, `R/modMarkerGenetics.R`, etc. | A `zygosity` column/parameter silently means two different things in the same package | D2/D3 (`code`, `twinRelations`, never bare `zygosity` as an identifier) + Slice 3's prose-disambiguation DONE criterion (§4) |
| 3 | `relation` collides with `convertRelationships()`/relationship-classification vocabulary | `R/convertRelationships.R` | A `relation` parameter silently means two different things (authored fact vs. derived classification) | D3 (`twinRelations`, not `relation`) |
| 4 | `obfuscatePed()` operates on exactly one data frame | `R/obfuscatePed.R` (56 lines) | A sidecar table is never de-identified; real ids leak in an exported "obfuscated" file | D5 (`obfuscateTwinRelations()` consuming `map`) — a required Slice 1 deliverable, not deferred |
| 5 | `finalEdges` rbind demands a fixed column set | `R/makePedigreeDiagramData.R:1287-1301` | Rectilinear mode crashes with "undefined columns selected" the moment a new edge column exists | D9 (patch `newEdges`'s construction) |
| 6 | `finalNodes` rbind, same pattern | `R/makePedigreeDiagramData.R:1318-1334` | Same crash, node-side | N/A this design — no new node columns proposed (D6) |
| 7 | `dupEdges` never connects to a third party's node | `R/makePedigreeDiagramData.R:1088-1096` | No existing mechanism to connect two *different* individuals' duplicate occurrences | D7 (real-nodes-only rule, sidesteps the gap rather than filling it) |
| 8 | Four duplicated copies of the required-column guard | `R/makePedigreeDiagramData.R:29,271,526,894` | N/A — this design adds no new *required* column | Confirmed not triggered (twin data is optional and external) |
| 9 | `dashes` has only ever held a single boolean per edge row in this codebase | `R/makePedigreeDiagramData.R` (`childEdgesOut`/`mateEdges`/`dupEdges`/`.addRectilinearWaypoints()`) | Achieving 3 visually distinct dash STYLES (not just a dashed/solid toggle) needs a list-column of numeric dash-pattern vectors, a technique never used here before | D6/D9 implementation note (§3) — confirmed feasible via a live test (`rbind()` of a logical column with an `I(list(...))` list-column coerces correctly; `jsonlite`/htmlwidgets serializes each row correctly), but the mechanism itself, not just the color choice, is new |
| 10 | `visLegend()` is called exactly once; a second call overwrites rather than stacks (confirmed S485, `R/modPedigree.R:524`) | `R/modPedigree.R:516-534` | A naively-added second `visLegend()` call for the twin legend would silently discard the existing sex-shape/Affected legend | Slice 3 DONE criterion (§4): add the twin legend via the SAME call's `addEdges` parameter (confirmed present in `visNetwork::visLegend()`'s formals), not a new call |

---

## 3. Design decisions

Twelve decisions, D1-D12. Each states whether it is forced by the evidence above (§2) or a genuine judgment call; §10 collects the judgment calls into a ratification round.

**D1 — Data model shape: a sidecar relations table `(id1, id2, code)`, threaded alongside — not merged into — the main pedigree data frame. Judgment call; requires ratification (§10 Q1).**

Twin-ness is pairwise; §2.2 established the existing single-frame schema structurally cannot hold it. Three shapes were considered:

| Option | Mechanism | Pros | Cons | Verdict |
|---|---|---|---|---|
| **(a) Sidecar table** `data.frame(id1, id2, code)` | Separate object threaded alongside the pedigree, mirroring kinship2's own `relation` arg and this project's existing `applyKinshipOverrides()` (§2.3) | Exact kinship2-convention match (S436 directive); real, already-shipped, in-repo precedent to imitate line-for-line; **zero** change to `.nprcColumnSchema`/`getPossibleCols()`/`qcStudbook()`/`checkRequiredCols()`/`fixColumnNames()`/`removeDuplicates()` (confirmed, top-of-doc "Does NOT touch"); a pairwise fact has exactly one row as its single source of truth — no symmetry-consistency problem | A second object to thread through app state (new reactive, `R/appServer.R` wiring, §3 D11); needs a companion de-identification function (§2.5) since `obfuscatePed()` can't reach it; needs a new validator | **Recommended** |
| **(b) Inferred/derived** — auto-detect candidate twins from existing `(sire, dam, birth)` co-occurrence, no new user-supplied column | Computed at render time from data already present in many colony records | Zero new data-entry burden; works retroactively on any pedigree that already has birth dates | **Cannot distinguish MZ/DZ/UZ at all** — same-birth-date co-occurrence is not proof of twin-ness, and zygosity is never inferable from pedigree topology under any circumstance (§2.1); silently wrong for colonies recording birth dates at month/batch precision; gives a colony manager who *knows* the actual verified zygosity (e.g. via genotyping) no way to input it — defeats the feature's own informational purpose; this is precisely the audit's own reasoning for its "no action" score | Rejected as primary; see §6 Dragon 6 for a possible opt-in secondary hint |
| **(c) Per-individual mirrored columns** — `twinOf` (co-twin's id) + a zygosity-coded column on each twin's own row | Self-referencing pair on the existing per-animal frame, like `sire`/`dam` | Stays inside `.nprcColumnSchema$possible`; no second data object; simplest possible CSV shape for a hand-editor | Redundant and inconsistifiable: both twins' rows must *independently* agree (A says twinOf=B; B must independently say twinOf=A) with zero existing validator precedent for 2-to-2 symmetric consistency (unlike `sire`/`dam`'s 1-to-many shape); kinship2's own >2-member (quadruplet) case (§2.1) has no natural single-column encoding — a `twinOf` slot can only ever name one partner; `obfuscatePed()`'s `alias` remap becomes a 4th special-cased branch | Rejected |
| **(d) Group-id column + satellite lookup** — a `twinGroup` id shared by all cohort members, zygosity recorded once per group in a small separate table | Handles >2-way groups more naturally than pairwise chaining | Still two data structures (not meaningfully simpler than (a)); diverges from kinship2's own pairwise convention, violating the S436 directive; no existing precedent anywhere in this codebase for this shape | Rejected |

**Recommendation: (a).** It is the only option that both survives §2.1's MZ/DZ/UZ distinction requirement and matches an already-shipped in-repo pattern rather than inventing a new one. This is nonetheless flagged as a judgment call, not a forced conclusion, because option (c) is not *impossible*, only worse on every axis the evidence surfaces — the owner may weigh "smaller CSV footprint for a hand-editor" ((c)'s one real advantage) differently. See §10 Q1.

**D2 — Sidecar table columns: `id1`, `id2`, `code` — kinship2's own literal names — with `code`'s domain restricted to `{"MZ twin", "DZ twin", "UZ twin"}` (codes 1-3 only). Forced, once D1 is chosen.**

Kinship2's own column names both satisfy the S436 naming-overlay directive exactly and sidestep the `zygosity` collision (§2.4) by never introducing that word as an identifier at all. A `famid` 4th column (required by kinship2 only when `famid` is separately supplied to `pedigree()`) does not apply — this package's pedigree object has no `famid` concept (confirmed, full read of `R/columnSchema.R`). Code 4 (`"spouse"`) is explicitly excluded from the domain: it is a non-twin relationship type outside #137's scope (§1.3); a future issue could reopen the domain to 4 values without changing the table's shape at all, since the shape already accommodates it.

**D3 — R-level naming: parameter/object `twinRelations` (never bare `relation`); validator `checkTwinRelations()` (mirroring `checkKinshipOverrides()`'s own naming pattern exactly). Forced by the confirmed collision (§2.4).**

Using bare `relation` would silently overload a term the Summary Statistics tab already owns for an unrelated, derived concept (`convertRelationships()`). `twinRelations` is unambiguous and self-documenting. This resolves the **identifier**-level collision only; §2.4/§4 additionally require **prose**-level disambiguation ("twin zygosity," never bare "zygosity") in any user-facing text, since the identifier fix alone does not stop a reader from conflating the two senses in documentation or the legend.

**D4 — Validator (`checkTwinRelations(ped, twinRelations)`) reproduces kinship2's own five validation rules exactly: both ids exist and differ (universal); MZ/DZ require the pair to already share both `sire` and `dam` in `ped`; MZ additionally requires matching `sex`; UZ has no sibling precondition. Forced by the owner's already-decided S436 "adopt kinship2's own convention" directive.**

A `twinRelations` table that would be rejected by a real kinship2 `pedigree()` call must never be silently accepted here — the validator's whole job is parity with kinship2's own acceptance criteria, confirmed empirically in this session's kinship2 investigation (§2.1) and independently re-confirmed (§1.3): `pedigree()`'s source applies the parent-match check only to `ncode < 3` (MZ/DZ, explicitly excluding UZ) and the sex-match check only to MZ specifically. Nothing about *how* the rules are implemented is forced (error message wording, R idiom) — only *which* rules exist and their code-dependent asymmetry (MZ/DZ constrained, UZ not).

**D5 — De-identification companion: `obfuscateTwinRelations(twinRelations, map)`, consuming the `map` alias vector `obfuscatePed(..., map = TRUE)` already returns. Forced given D1 (sidecar) plus `obfuscatePed()`'s confirmed single-data-frame limitation (§2.5).**

`id1`/`id2` are remapped through `map` the same way `obfuscatePed()` remaps `sire`/`dam` internally. A row whose `id1` or `id2` is absent from `map` should error rather than silently drop — `checkTwinRelations()`'s own universal existence rule (D4) should already have excluded that case upstream, so this is a defensive check, not the primary validation path. **This is a required Slice 1 deliverable** (§4: `R/obfuscateTwinRelations.R`, `tests/testthat/test_obfuscateTwinRelations.R`) — not a residual risk deferred to a later session. A plan that named this constraint without resolving it in the same slice as the sidecar table itself would ship the same PII gap #136 D8 was written to close for the `name` column.

**D6 — Rendering: a distinctly-styled, direct (non-rectilinear) edge between the twins' real nodes, carrying a new `label` column (the kinship2-code callback) plus the existing `dashes`/`color` columns — not an attempt to reproduce kinship2's wedge/crossbar/"?" geometry. Judgment call; requires ratification (§10 Q2).**

Proposed per-code styling:

| Code | `dashes` | `label` | Rationale |
|---|---|---|---|
| MZ (1) | `FALSE` (solid) | `"MZ"` | Solid = strongest-certainty relationship; reuses kinship2's own MZ-gets-something-extra asymmetry (§2.1) by giving MZ the "plainest," most emphatic line |
| DZ (2) | `TRUE`, short dash | `"DZ"` | Distinguishes visually from MZ without inventing a third dash pattern for UZ (both twin-of-known-zygosity codes share the dashed family) |
| UZ (3) | `TRUE`, sparse/long dash (or vis.js dotted, if the bundle supports it — unverified, §6 Dragon 4) | `"?"` | Reuses kinship2's own "?" glyph verbatim as the label text — a deliberate callback, not an arbitrary choice |

This departs deliberately from kinship2's converging-wedge geometry: reproducing it would require rewriting `.buildMatingUnitForest()`'s sibling-position-assignment math, which D8 rules out of scope on refactor-heuristics grounds. `label` is confirmed absent from `edges`' current fixed column set (§2.6, §2.8 trap #5) — this is the one genuinely new edge column the design introduces; `dashes`/`color` already exist and need no schema change.

**Implementation note (§2.8 trap #9):** DZ's "short dash" and UZ's "sparse/long dash" are two *distinct* non-boolean dash styles, not a binary dashed/solid toggle — this codebase's `dashes` column has never held anything but `TRUE`/`FALSE` before. Confirmed via a live test this session that `rbind()` of a plain logical `dashes` column with an `I(list(c(5,5)))`-style list-column coerces correctly, and `jsonlite`/htmlwidgets serializes each row's array into the exact form vis.js's `dashes` option expects — the mechanism is feasible, but Slice 2's implementing session must use the list-column technique explicitly, not assume the existing single-boolean column pattern extends for free.

*Declined: node-level marking only (a colored ring, no edge).* Cannot encode *which two* individuals are paired in a >2-member sibship with mixed zygosity (kinship2's own quadruplet case) — only an edge encodes a pairwise fact, matching D1's own logic.

**D7 — Duplicate-node resolution: a twin connector always targets the two individuals' real nodes; `__dup_<id>_<n>` occurrence nodes are never twin-connector endpoints. Judgment call; requires ratification (§10 Q3).**

No existing mechanism resolves "connect two different individuals' node occurrences" — `dupEdges` (`:1088-1096`) only ever connects a duplicate back to *its own* real individual, never to a third party (§2.8 trap #7). Connecting real nodes only sidesteps that gap entirely rather than filling it, at the cost of a possible long/awkward connector edge if one twin is also a heavily-duplicated multi-mate parent placed far away in the layout (flagged, §6 Dragon 3, not resolved empirically this session).

*Declined: connect every occurrence pair (real-real, real-dup, dup-dup).* Combinatorial multiplication with no existing precedent and unclear visual benefit — a viewer inspecting one specific duplicate occurrence of a parent is unlikely to also need a twin marker radiating from that exact occurrence.

**D8 — No changes to `.buildMatingUnitForest()`'s sibling-position-assignment logic; twins rely on the same shared-union-node convergence every full sibling already gets. Forced by scope (Deletion Test / refactor heuristics, matching #133 D4's citation of the same workstream doc).**

A position-averaging rewrite reproducing kinship2's wedge is a layout-algorithm change requiring its own `SAFEGUARDS.md`-gated session, not a feature slice. Full siblings (a precondition for MZ/DZ, §2.1) already visually converge on one shared `__union_<n>` node today under `edgeStyle = "direct"` — this is arguably a weaker signal than kinship2's own wedge (geometry, not just an added mark, differentiates twins from ordinary siblings there), but it is the smallest change consistent with the existing layout algorithm. Flagged as an explicit trade-off (§6 Dragon 2), not silently glossed over.

**D9 — `edgeStyle = "rectilinear"` support: the twin connector always renders as a direct edge regardless of the global `edgeStyle` setting; `.addRectilinearWaypoints()`'s `newEdges` construction (`R/makePedigreeDiagramData.R:1287-1300`) is extended to also stamp a placeholder `label` value (`NA_character_` or `""`) on every synthesized waypoint edge. Forced by the confirmed trap mechanics (§2.6, §2.8 trap #5), once D6 introduces `label`.**

Without this, `finalEdges <- rbind(keptEdges, newEdges[, names(keptEdges)])` (`:1301`) fails with "undefined columns selected" the moment any twin-relations data is present and rectilinear mode is on — confirmed by direct source reading, not a hypothetical. Rendering the connector itself as always-direct (never routed through drop/bar/projection waypoints) avoids needing any new waypoint-routing logic for the new edge type — the fix is purely "make the column exist on both sides of the rbind," not "make the connector rectilinear-aware."

**D10 — Exact hex colors, dash-pixel patterns, and label font styling: a Pre-RED decision for the implementing session, not fixed here. Explicitly deferred, not part of the §10 ratification round (mirrors #133's own D8 treatment of its fill color).**

No shared, documented colorblind-safe palette exists for the Diagram tab as a whole (§ inventory did not find one). The implementing session's Pre-RED should pick colors distinct from: the GVA heatmap's red/yellow/green risk convention, the existing `#2B7CE9` rectilinear-waypoint blue, and whatever #133's `affected`-status shading and #136's `name`-label styling ended up using by the time #137 is implemented (both may have claimed hues this document cannot know). This is `DESIGN_WORKSTREAM.md` territory (visual design), not an architecture question, and is deliberately left open rather than invented without evidence.

**D11 — Slice boundary for UI wiring: the `twinRelations` argument lands at the R-function level first (Slices 1-2, script-callable, no live UI); Shiny-side supply (file upload, toggle) is deferred to Slice 3, whose exact upload mechanism is TBD pending confirmation of how `applyKinshipOverrides()`'s own overrides currently reach the app (not verified this session). Judgment call; requires ratification (§10 Q4).**

This mirrors #133/#136's own slice-1/slice-2 split (data model and core rendering first, UI/documentation after) but is a genuinely open question here in a way it wasn't for either precedent: `affected`/`name` are single-CSV-column additions that flow through the *existing* upload path automatically (any unrecognized column in an uploaded CSV already passes through untouched, confirmed by both prior docs). A sidecar table is a **second file** — there is no confirmed existing "please also upload a second CSV" UI pattern in this app to copy; `gvResults$kinshipOverrides` is threaded through `R/appServer.R`, but this session did not verify whether its own *value* arrives via a Shiny file-upload control, a hardcoded programmatic path, or something else. Flagged as Dragon 1 (§6) rather than asserted.

**D12 — Multi-member (>2) twin groups are supported "for free" by D1's pairwise-row shape (kinship2's own quadruplet chaining convention: adjacent-pair codes, no special N-way encoding); no dedicated N-way rendering glyph is built. Forced by minimality-of-scope plus the audit's own "low practical relevance" framing (§1.2).**

A triplet+ group simply becomes multiple pairwise connector rows/edges (A-B, B-C, ...), each rendered independently per D6/D7 — no new code path. This has never been visually rendered by this research (§6 Dragon 5) but requires no additional design decision to support structurally.

---

## 4. Implementation plan — vertical slices (one session each)

```
Slice 1 (data model: twinRelations shape, checkTwinRelations(), obfuscateTwinRelations())
  `-- Slice 2 (core rendering: connector edges in both functions, rectilinear trap fix)
        `-- Slice 3 (UI wiring, legend, documentation)
```

### Slice 1 — Data model

**Scope:** `twinRelations` (a `data.frame(id1, id2, code)`) is defined as a concept; `checkTwinRelations()` validates it against kinship2's five rules (D4); `obfuscateTwinRelations()` de-identifies it (D5). No rendering change — pure data layer, script-callable only.

**What does NOT change:** any of the six files named "Does NOT touch" at the top of this document; the existing pedigree upload/QC path; any existing rendering output.

**Files to touch:**
- `R/checkTwinRelations.R` (new) — validator, D4.
- `R/obfuscateTwinRelations.R` (new) — de-identification companion, D5.
- `tests/testthat/test_checkTwinRelations.R` (new) — one test per kinship2 rule confirmed in §2.1 (existence, distinctness, MZ/DZ-shared-parents, MZ-matching-sex, UZ-no-precondition), modeled on `test_checkKinshipOverrides.R`'s structure.
- `tests/testthat/test_obfuscateTwinRelations.R` (new) — remapping correctness against `obfuscatePed(..., map = TRUE)`'s output, plus the fail-loud unmapped-id case.
- `inst/extdata/examples/obfuscated_rhesus_mhc_ped_twins.csv` (new fixture, sibling to `_affected`/`_name`) — fabricated twin pairs (seeded RNG, disclosure header, per §2.7).
- `inst/extdata/examples/obfuscated_rhesus_mhc_twin_relations.csv` (new sidecar fixture) — the corresponding `id1,id2,code` table, including at least one MZ, one DZ, one UZ pair, and (per §6 Dragon 3) at least one twin who is *also* a multi-mate parent, to exercise D7 in Slice 2.
- `data-raw/generate_twin_fixtures.R` (new generator script).

**RED:** all unit tests above, written against functions that don't exist yet; confirm they fail for the right reason (missing function), not a setup/typo error.

**GREEN:** implement exactly enough to pass — `checkTwinRelations()`, `obfuscateTwinRelations()`, the two new fixtures. No rendering change, no UI change (Slices 2-3).

**DONE looks like:** `devtools::check()` 0 errors/0 warnings; new unit tests pass; the full clean regression read (`CLAUDE.md`'s documented recipe) shows no new failures; the new fixtures load cleanly and validate correctly against `checkTwinRelations()`.

**Verify:** targeted test file runs (both new test files); full clean regression read; full `devtools::check()`.

**Session boundary:** one session. Close out when Slice 1's DONE criteria are met. Slice 2 is a separate future session.

### Slice 2 — Core rendering

**Scope:** both `makePedigreeDiagramData()` and `makePedigreeMatingLayout()` accept `twinRelations` and render connector edges per D6 (styling, including the list-column dash technique per §2.8 trap #9)/D7 (duplicate-node resolution); `.addRectilinearWaypoints()`'s `newEdges` construction is extended per D9 so rectilinear mode does not crash when twin data is present.

**What does NOT change:** `.buildMatingUnitForest()`'s position-assignment logic (D8); the required-column guard in either function (still exactly `id,sire,dam,sex,gen`); any existing node-level rendering (D6 adds no node columns, only edge columns); backward compatibility — a pedigree loaded without `twinRelations` must render pixel-for-pixel unchanged.

**Files to touch:**
- `R/makePedigreeDiagramData.R` — new `twinRelations` parameter on both functions (following the issue #135 both-functions-duplicated-logic precedent #133 D4 cites, since this is the same file/pair already following that pattern); connector-edge construction (D6, using an `I(list(...))` list-column for `dashes` where a non-boolean pattern is needed); real-node resolution (D7); `newEdges` column extension (D9).
- `tests/testthat/test_makePedigreeDiagramData.R` — connector edges appear with correct `label`/`dashes` per code; absent `twinRelations` produces zero change to existing assertions.
- `tests/testthat/test_makePedigreeMatingLayout.R` — same, at the layout-output level; specifically exercise the multi-mate-parent-who-is-also-a-twin fixture row (D7) and rectilinear mode with twin data present (D9, the crash this session confirmed by reading source, not yet by running a test).

**RED:** write all rendering-level tests above against the not-yet-existing `twinRelations` parameter; confirm they fail for the right reason.

**GREEN:** implement exactly enough to pass — the parameter, the connector-edge logic, the `newEdges` fix. No legend, no UI toggle, no documentation (Slice 3).

**DONE looks like:** connector edges render distinctly per code between resolved real nodes; `edgeStyle = "rectilinear"` with twin data present does not error (this is the single highest-value regression test in this slice — it is the one place this document predicts a crash from source reading alone, and Slice 2 is where that prediction gets checked against reality); the existing bundled fixtures (no `twinRelations` supplied) render pixel-for-pixel unchanged; a live `shinytest2`/`chromote` smoke test against the new Slice 1 fixture pair shows visible, distinctly-styled connectors with no console error, under both `edgeStyle` settings.

**Verify:** targeted test file runs (both files); full clean regression read; full `devtools::check()`; live `shinytest2`/`chromote` E2E smoke test per Phase 3E, on the new fixture pair (connectors visible, both edge styles) and the base fixtures (no visual change).

**Session boundary:** one session, separate from Slice 1 and Slice 3.

### Slice 3 — UI wiring, legend, documentation

**Scope:** Shiny-level wiring for supplying `twinRelations` to the app (mechanism per §10 Q4's ratification outcome); a "Show Twin Connectors" toggle in `R/modPedigree.R`'s existing `tagList(...)` (`:438-467`), following the self-referential-current-value pattern (Learning 490) already used for `pedigreeEdgeStyle`/`pedigreeShowNames`; a Diagram-tab legend entry explaining the MZ/DZ/UZ styling, added via the **existing** `visNetwork::visLegend()` call's `addEdges` parameter (`R/modPedigree.R:516-534`) — **not** a second `visLegend()` call, which the code's own S485 comment (`:524`) already documents as overwriting rather than stacking; documentation.

**Touches:** `R/appServer.R` (new reactive, modeled on `gvResults$kinshipOverrides`'s wiring), `R/modInput.R` (upload mechanism, TBD per §10 Q4), `R/modPedigree.R` (toggle + legend via `addEdges`), `NEWS.Rmd` → re-rendered `NEWS.md`, `vignettes/manual_components/_pedigree_browser.Rmd` and/or `vignettes/articles/colony-manager-guide.qmd`, `tests/testthat/test_modPedigree.R`.

**DONE looks like:**
- A user can supply a `twinRelations` sidecar (mechanism per Q4) and see connectors render live, with the toggle able to hide/show them without discarding other pedigree-diagram state on re-render (the Learning 490 pattern, correctly applied).
- The toggle survives an unrelated `renderUI()` re-render (a RED test pinning this, mirroring Session 490's own fix for the analogous `pedigreeShowNames` bug).
- Legend text is present, added via `visLegend()`'s `addEdges` parameter on the existing call (not a second call), and correctly describes MZ/DZ/UZ styling.
- **Every user-facing string this slice adds — legend text, tooltip/roxygen prose, tutorial/article copy — says "twin zygosity," never bare "zygosity,"** to avoid reader confusion with the Marker Genetics module's already-shipped "Heterozygosity" tab (§2.4 trap #2; the identifier-level fix in D3 does not by itself prevent this in prose).
- `NEWS.Rmd` and the tutorial/article doc both updated in this same session (not deferred).
- Citation checklist (#120) explicitly confirmed N/A in this session's own close-out (§8).

**Verification:** full clean regression read; `devtools::check()`; live `shinytest2`/`chromote` E2E smoke test of the actual upload-and-render flow; `lintr::lint_package()` clean on touched files (`CLAUDE.md`'s lint close-out checklist); `gh issue close 137 --reason completed --comment "..."` citing the `CHANGELOG.md` entry, per the established close-out checklist; a `CHANGELOG.md` entry in the current `[issue #137]`-tagged dated-ledger format (§8 item 7).

**Session boundary:** one session, separate from Slices 1-2.

---

## 5. Impact analysis

**Blast radius is small and mostly additive.** D1's sidecar choice means six files that #133/#136 both had to touch (`R/columnSchema.R`, `R/getPossibleCols.R`, `R/qcStudbook.R`, `R/checkRequiredCols.R`, `R/fixColumnNames.R`, `R/removeDuplicates.R`) are untouched here — a direct, checkable consequence of D1 worth treating as evidence *for* D1, not just a side note. The two rendering functions (`makePedigreeDiagramData()`/`makePedigreeMatingLayout()`) gain one new optional parameter each, defaulting to `NULL`/absent, so every existing caller (including every existing test) is unaffected until it opts in.

**Performance:** a twin-relations table is expected to be tiny relative to a colony pedigree (a small fraction of individuals are ever twins) — no performance concern identified, and none was investigated further since nothing in the evidence suggested one.

**Backward compatibility:** explicitly required and testable at each slice boundary (Slice 2's DONE criteria include a pixel-for-pixel unchanged check on the existing bundled fixtures).

**The structural traps (§2.6/§2.8) are real, not hypothetical, and are addressed in Slice 2, not deferred.** Unlike some traps in prior docs that were flagged for the implementing session to rediscover, D9 already specifies the exact fix (`newEdges`'s column set) because the evidence pinpointing it (source line numbers, exact column lists) was gathered this session and independently re-confirmed.

**Close-out checklists triggered** (`CLAUDE.md`): NEWS.Rmd and tutorial/article in Slice 3's own session (not deferred); `a2interactive.Rmd` deferred to a later documentation pass (§8 — `twinRelations` would be a new parameter on already-documented `makePedigreeDiagramData()`/`makePedigreeMatingLayout()`, which qualifies for the deferred obligation, not immediate); lint on touched files, each slice; `gh issue close 137` when Slice 3 ships; a `CHANGELOG.md` dated-ledger entry for each slice's own close-out. Citation checklist (#120): see §8 for the explicit disposition.

---

## 6. Here be dragons

1. **The Slice 3 UI-supply mechanism (D11) is not verified.** This session confirmed `gvResults$kinshipOverrides` is wired through `R/appServer.R`, but did **not** confirm whether its *value* arrives via a live Shiny file-upload control, a script-only/programmatic path, or something else — the closest available precedent for "how does a user hand the app a second, sidecar CSV" is unconfirmed. Slice 3's Pre-RED must resolve this by reading `R/modInput.R` and `R/appServer.R` directly before committing to a specific upload UI design. If no such precedent exists at all, Slice 3 may need to invent the app's *first* second-file-upload pattern, which is a larger scope question than this document currently credits.

2. **D8's reliance on existing union-node convergence is a weaker visual signal than kinship2's own wedge, and that trade-off has not been shown to anyone.** Full siblings already converge on one shared node today; the *only* new signal for twins specifically is the connector edge (D6). Whether that reads clearly enough in a real, populated pedigree diagram (as opposed to the small fabricated fixture) is unverified — this document recommends but cannot confirm it is visually sufficient.

3. **D7's real-nodes-only resolution can produce a long or visually awkward connector edge** if a twin is also a heavily-duplicated multi-mate parent placed elsewhere in the layout. The Slice 1 fixture is designed to include this exact combination specifically so Slice 2 can observe it empirically — but as of this document, it has not been observed even once.

4. **D6's exact dash pattern for UZ ("sparse/long dash, or dotted") assumes the bundled vis-network rendering supports more than one dash style distinctly enough to read as different from DZ's, AND requires a list-column `dashes` technique never used in this codebase before (§2.8 trap #9).** The list-column mechanism itself was confirmed feasible this session (a live `rbind()`/`jsonlite` test), but its *visual* distinguishability against the actual bundled vis-network minified bundle was not verified (the same category of risk #136's own Dragon 1 flagged for multi-line labels — "this project has twice had a design's rendering assumption fail exactly this way"). The implementing session's Slice 2 Pre-RED must verify hands-on before committing to three visually distinct dash patterns; if only two are reliably distinguishable, MZ/DZ may need to differ by `color` instead of `dashes`, with UZ keeping the "?" label as its primary distinguishing feature.

5. **D12's multi-member (>2) twin-group rendering has never been visually rendered, not even once, by any research this session.** kinship2's own rendering was confirmed via rendered-PNG inspection only; this package's own connector-edge mechanism has not been run against real vis.js output at all — no fixture, no screenshot, no live render, for any twin configuration, single-pair or multi-member. Everything in §3 D6/D7/D9 is source-level and validation-level confirmed, not visually confirmed. This is the single largest gap in this document's evidence base, and Slice 2's live `shinytest2`/`chromote` smoke test is the first point at which any of it gets checked against an actual rendered picture.

6. **D1's rejected option (b), inferred/derived twins, could plausibly return as a secondary, opt-in hint** (e.g., a non-authoritative "possible twin?" flag surfaced in a QC report, computed from `(sire, dam, birth)` co-occurrence, distinct from the authoritative `twinRelations` table) — this document rejects it as the *primary* mechanism (§3 D1) but did not fully explore whether a secondary advisory version is worth a future, separate issue. Not scoped here; noted only so a future session doesn't have to re-derive the idea from scratch.

---

## 7. Alternatives considered

Summary table for the judgment-call decisions not already given a full alternatives table in §3 (D1's own table is in §3 and not repeated here).

| Decision | Recommended | Rejected alternative(s) | Why rejected |
|---|---|---|---|
| D6 rendering mechanism | Distinctly-styled direct edge + `label` | Reproduce kinship2's wedge/crossbar/"?" geometry exactly | Requires a `.buildMatingUnitForest()` layout rewrite, out of scope per D8 |
| D6 rendering mechanism | Distinctly-styled direct edge + `label` | Node-level marking only (colored ring, no edge) | Cannot encode *which two* individuals are paired in a >2-member mixed-zygosity group |
| D7 duplicate-node resolution | Real nodes only | Connect every occurrence pair (real-real, real-dup, dup-dup) | No existing precedent; combinatorial multiplication; unclear visual benefit |
| D11 slice boundary | R-function level first, UI deferred to Slice 3 | Land UI wiring in the same slice as rendering | UI mechanism is itself unresolved (Dragon 1) — bundling it with Slice 2 risks blocking core rendering on an unrelated unresolved question |
| D11 slice boundary | R-function level first, UI deferred to Slice 3 | Skip UI wiring entirely (script-only feature) | Contradicts the tutorial/article checklist's premise (a user-facing Shiny feature) and the issue's own framing of this as a Diagram-tab capability |

---

## 8. Close-out checklist mapping

1. **Citation checklist (issue #120)** — this document's own read is that a twin/zygosity connector is a relationship marker/rendering convention, not a new displayed statistic or estimator, matching the precedent already set for #133's `affected` flag and #136's `name` label. **Likely N/A** — but per #133's own more cautious framing (rather than #136's flat one-line dismissal), the Slice 3 implementing session should state this conclusion explicitly in its own close-out rather than silently omitting the checklist, since #137's architecture (a second data object, not a single column) is novel enough that a confident "no" here deserves a one-line confirmation, not just silent omission.
2. **Tutorial/article documentation checklist (Session 436)** — applies, Slice 3, same session: `vignettes/manual_components/_pedigree_browser.Rmd` and/or `vignettes/articles/colony-manager-guide.qmd`, per the owner's issue comment (§1.1/§1.2), with the "twin zygosity" (not bare "zygosity") disambiguation from §4's Slice 3 DONE criteria.
3. **NEWS.Rmd entry checklist (Session 448)** — applies, Slice 3, same session, current development-version section, matching existing entry style.
4. **`a2interactive.Rmd` script-callable-function checklist (Session 450/478)** — **deferred, not same-session**, per its own standing rule. `twinRelations` becoming a new parameter on the already-documented `makePedigreeDiagramData()`/`makePedigreeMatingLayout()` qualifies it for this deferred obligation once the feature has stabilized — a future dedicated documentation pass, not any of Slices 1-3.
5. **GitHub issue close-out checklist** — `gh issue close 137 --reason completed --comment "..."` citing the `CHANGELOG.md` entry and verification evidence, in the same session Slice 3 ships (matching the #131/#134/#135/#139/#142/#143/#144 precedent).
6. **Lint close-out checklist** — `lintr::lint_package()` on touched files, each slice, before that slice's own close-out (not deferred to CI).
7. **CHANGELOG.md ledger-format resolution (Session 325)** — every slice's own close-out prepends a dated `### YYYY-MM-DD · [issue #137] ...` entry above `## Legacy history`, in the current post-Session-325 ledger format (matching the last 10 `[issue #13x]`-tagged entries for this same pedigree-diagram-tab family of work) — not merely referenced in passing as "the CHANGELOG.md entry" the way earlier drafting of this document under-specified it.

---

## 9. Provenance

This document synthesizes four research inputs gathered in Session S491 (2026-08-09), all quoted or summarized above with inline attribution:

1. An issue/audit/checklist research summary for GitHub issue #137 (priority position, owner directives, what's already decided vs. open, exact checklist trigger conditions) — cross-checked in this session's own finalization pass directly against the live issue body/comment via `gh issue view 137 --json`, which now appears verbatim in §1.1.
2. An empirical investigation of kinship2 v1.9.6.2's `relation`/twin-zygosity mechanism, run against the installed package on this system — source deparsed from `asNamespace("kinship2")` (no plain-text source shipped with the installed binary), help text read via `tools::Rd_db()`, and standalone `Rscript` test scripts actually executed (construction, validation-error triggering, PNG rendering, `align.pedigree()` internal-structure inspection). **Independently re-run** by this session's own direct verification pass (§1.3), with identical results both times.
3. A codebase inventory of this package's own data model, rendering pipeline, obfuscation logic, duplicate-node mechanism, and test fixtures, read directly from `master` at the start of S491 (clean working tree, no files modified during research). **Spot-checked** by this session's own direct reads of `R/columnSchema.R`, `R/obfuscatePed.R`, `R/modPedigree.R`, and the two `rbind` trap sites in `R/makePedigreeDiagramData.R`, all matching.
4. A structural/prose comparison of the two immediately-prior planning documents in this sequencing cluster, `docs/planning/issue133-affected-status-pedigree-diagram-plan.md` (S485) and `docs/planning/issue136-name-labels-pedigree-diagram-plan.md` (S488), both read in full.

An adversarial verification pass (three lenses: kinship2-mechanism claims, rendering/feasibility claims, and completeness-against-project-checklists) ran against the drafted document. Two of its three lenses' "blocking"/"should-fix" findings — that the draft never surfaces kinship2's 4th ("spouse") code, and that it never resolves `obfuscatePed()`'s single-frame limitation for the new sidecar table — turned out on reconciliation to be **false positives**: both are in fact addressed in the document (§1.3/§2.1/D2 for the former; §2.5/D5/Slice 1 for the latter), and the verify agents' own critique text quotes only a *later portion* of the document, consistent with those agents having received a truncated copy of the draft rather than a completeness gap in the actual content. This is recorded as an operational finding about this session's tooling (see the session's own `PROJECT_LEARNINGS.md` entry), not a defect in this document. Three genuinely new findings from that same pass survived reconciliation and are incorporated above: the CHANGELOG.md ledger-format item now explicit in §8 item 7; the "twin zygosity" prose-disambiguation requirement now in §2.4/§4/§8 item 2; and the `dashes` list-column technical note plus the `visLegend()` single-call/`addEdges` mechanical detail, both now in §2.8 (traps #9-10), §3 D6, and §4 Slice 3.

No `PROJECT_LEARNINGS.md` entries exist yet specific to twin/zygosity encoding or issue #137 (confirmed by grep for "twin," "zygosity," and "relation" — the only hits are unrelated homonyms). This document is therefore the first substantive design work on #137's actual topic; everything before it was filing/sequencing history.

---

## 10. Ratification status — forced vs. judgment-call decisions

**Forced by structural or kinship2-convention constraints (no real choice, not put to a vote):** D2 (kinship2's own column names, once D1 is chosen), D3 (naming-collision avoidance is forced by the confirmed §2.4 evidence), D4 (validator parity with kinship2 is forced by the owner's already-decided S436 directive), D5 (forced by D1 plus `obfuscatePed()`'s confirmed single-frame limitation), D8 (forced by scope/refactor-heuristics, matching #133 D4's own citation of the same workstream doc), D9 (forced by the confirmed `rbind` trap mechanics, once D6 introduces `label`), D12 (forced by minimality-of-scope plus the audit's own low-practical-relevance framing).

**Genuine judgment calls that must go through an `AskUserQuestion` ratification round before this plan is RATIFIED:**

**Q1 (D1) — How should twin/zygosity data enter the data model?**
- **Option A — Sidecar relations table** `data.frame(id1, id2, code)`, threaded alongside the pedigree, mirroring kinship2's own `relation` argument and this project's existing `applyKinshipOverrides()` precedent. *(This document's recommendation.)*
- **Option B — Inferred/derived from existing columns** (auto-detect same-`sire`+`dam`+`birth`-date siblings, no new user-supplied data at all). *(Rejected in this document — cannot distinguish MZ/DZ/UZ, non-authoritative.)*
- **Option C — Per-individual mirrored columns** (`twinOf` + a zygosity-coded column on each twin's own row). *(Rejected in this document — symmetry-consistency problem, no multi-member support.)*
- **Option D — Group-id column + satellite lookup table.** *(Rejected in this document — diverges from kinship2's pairwise convention, no simpler than Option A.)*

**Q2 (D6) — How should a twin connector actually render in the visNetwork diagram?**
- **Option A — Distinctly-dashed/labeled direct edge per code** (`label` = "MZ"/"DZ"/"?", `dashes` varying via a list-column), no attempt to reproduce kinship2's wedge geometry. *(This document's recommendation.)*
- **Option B — Attempt to reproduce kinship2's wedge/crossbar/"?" geometry**, requiring new position-averaging logic in `.buildMatingUnitForest()`. *(This document treats this as out of scope per D8, but it is a real option if the owner wants closer visual fidelity to kinship2 badly enough to fund a layout-algorithm change.)*
- **Option C — Node-level marking only** (e.g., a colored ring around each twin's node), no connector edge at all. *(Rejected in this document — cannot encode pairwise identity in >2-member groups.)*

**Q3 (D7) — Which node(s) does a twin connector target when a twin individual is also a duplicated multi-mate parent elsewhere in the diagram?**
- **Option A — Real nodes only**, always. *(This document's recommendation — simplest, no existing precedent to extend.)*
- **Option B — Every occurrence pair** (real-real, real-dup, dup-dup). *(Rejected in this document — combinatorial, no precedent.)*
- **Option C — Nearest occurrence by layout position** (a new heuristic not otherwise specified in this document). *(Not developed here — would need its own design pass if chosen.)*

**Q4 (D11) — When and how does Shiny-side UI wiring for supplying `twinRelations` happen?**
- **Option A — Defer to Slice 3, mechanism TBD**, resolved by directly reading `R/modInput.R`/`R/appServer.R` at that slice's own Pre-RED. *(This document's recommendation — avoids committing to an unverified mechanism now.)*
- **Option B — Investigate the upload mechanism now**, before ratifying the rest of this plan, as a short spike distinct from this design document. *(A legitimate alternative if the owner wants Slice 3's scope de-risked before committing to the 3-slice plan at all.)*
- **Option C — Script-callable only; no live Shiny UI in this feature's initial scope**, with UI wiring split into its own future issue. *(Narrows Slice 3 to documentation/legend only; changes the tutorial/article checklist's applicability — would need re-checking against the "ships a new user-facing Shiny feature" trigger.)*

Until Q1-Q4 are answered via `AskUserQuestion` (or the owner's plain-language equivalent) in an implementing or planning session, this document remains a **draft proposal**, not a ratified plan.

### Ratification outcome (2026-08-09, this session)

All four questions were posed via a single `AskUserQuestion` call (Q1-Q4 together, matching #136's own multi-round ratification precedent collapsed into one round here since all four options were independently answerable). The owner selected **this document's own recommended option in all four cases, with no changes requested**:

- **Q1 (D1):** Option A — sidecar relations table `(id1, id2, code)`. **RATIFIED.**
- **Q2 (D6):** Option A — distinctly-styled direct edge (`label`/`dashes`), no wedge-geometry reproduction. **RATIFIED.**
- **Q3 (D7):** Option A — real nodes only as connector endpoints. **RATIFIED.**
- **Q4 (D11):** Option A — defer Shiny UI wiring to Slice 3, mechanism TBD at that slice's own Pre-RED. **RATIFIED.**

This plan is now **RATIFIED** in full (all forced decisions D2-D5/D8/D9/D12 plus all four judgment calls D1/D6/D7/D11). Implementation begins with Slice 1 in a future session, per the vertical-slice plan in §4. The plan document itself changes no `R/`, `tests/`, or `man/` content — this remains true after ratification, matching #133's/#136's own precedent that ratification closes the *design* session, not the implementation one.
