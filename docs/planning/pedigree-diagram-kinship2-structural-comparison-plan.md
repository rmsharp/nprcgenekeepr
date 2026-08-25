# Plan — A Programmatic Structural/Topological Pedigree-Diagram Comparison Against kinship2

**Status:** DRAFT plan. No implementation code in this session (`SESSION_RUNNER.md` Planning
Sessions: "the plan is the deliverable; do not start implementing it").
**Session:** S632, 2026-08-25. **Deliverable:** this document.
**Workstream:** `ARCHITECTURE_WORKSTREAM.md` (interface-first design for a new internal capability),
plus `SESSION_RUNNER.md`'s Planning Session requirements.

## 0. Origin and scope

S631 (2026-08-25) found, on direct owner correction, that every "nprcgenekeepr's pedigree diagram
matches kinship2's" claim in this repo rests on two independently-rendered static images and prose
— never on a programmatic check. `vignettes/articles/kinship2-fidelity-validation.qmd` now carries
a caveat (added S631) stating this plainly, and `BACKLOG.md`'s top "Up Next" item names the fix, in
the owner's own words:

> "A future session needs to (a) fix a known `chromote` race condition in this article's own
> generation script... (b) regenerate every image against current code, and (c) **build an actual
> structural/topological comparison — extract the parent-child/mate-pair edge set from both
> kinship2's `pedigree` object and nprcgenekeepr's `makePedigreeMatingLayout()` output and diff them
> programmatically** — before this article's diagram claims can be trusted again."

**This plan designs (c) only.** (a) and (b) are already fully and mechanically scoped in
`BACKLOG.md` (a known one-line-conceptual chromote fix, `PROJECT_LEARNINGS.md` Learning 643; a
screenshot regen) — they involve no design decision and are orthogonal to this plan's subject: a
pure structural diff needs no rendering at all, only `kinship2::pedigree()`'s own object fields plus
`makePedigreeMatingLayout()`'s own `$nodes`/`$edges`/`$duplicateToReal` return value (confirmed
§1.2/§1.3 below). They are carried here only as **Track D**, for scope-tracking (§4.4), not
redesigned.

Per `SESSION_RUNNER.md`, this document is the deliverable; implementation is 1 or more separate
sessions (§4 below slices the work into 4 session-sized tracks).

---

## 1. Evidence base

Gathered via a 5-agent research fan-out (kinship2 internals, `makePedigreeDiagramData.R`'s output
structure, existing tests/fixtures, prior planning docs, a grep-based inventory), with the two most
load-bearing structural claims (§1.2, §1.3) independently re-verified by direct source reading in
this session before being relied on below — not accepted from agent report alone.

### 1.1 kinship2's `pedigree` object (verified live: kinship2 1.9.6.2, installed locally, not a
project dependency — see §1.5)

A plain S3 list, always exactly one row per real individual (no plot-time duplication baked into the
object itself):

| field | type | meaning |
|---|---|---|
| `id` | vector | subject ids, in exactly input order, no reordering |
| `findex` | integer | 1-based position in `id` of the father, or `0` if none |
| `mindex` | integer | 1-based position in `id` of the mother, or `0` if none |
| `sex` | factor | levels `male, female, unknown, terminated` |
| `relation` | data frame, **optional** (absent entirely if not supplied) | `indx1, indx2` (1-based positions into `id`) + `code` (factor: `MZ twin, DZ twin, UZ twin, spouse`) — the twin/paired-without-offspring carrier |
| `hints` | **absent** unless a caller attaches it after construction | plotting-order hints; `autohint()` computes on demand, never mutates the object |

Verified live (`str()`, `unclass()`) on a hand-built 7-subject/2-mating/1-MZ-twin-pair fixture, and
cross-checked against the repo's own 10-subject `fam1` Track-A fixture (12 parent-child edges, 4
distinct mate pairs — both counts matched independent hand derivation).

**No exported helper extracts a mate-pair list.** `as.data.frame.pedigree()` (exported) already does
the parent-child extraction in wide form (`dadid`/`momid` columns, rebuilt from `findex`/`mindex` —
read via `print(kinship2:::as.data.frame.pedigree)`, source quoted in the research transcript). The
mate-pair derivation exists only *inside* `align.pedigree()`'s unexported internals:
```r
if (any(dad > 0 & mom > 0)) {
    who <- which(dad > 0 & mom > 0)
    spouselist <- rbind(spouselist, cbind(dad[who], mom[who], 0, 0))
}
hash <- spouselist[, 1] * n + spouselist[, 2]
spouselist <- spouselist[!duplicated(hash), , drop = F]
```
(`dad`/`mom` are local aliases for `findex`/`mindex`.) This is exactly the derivation independently
re-implemented and verified in the research (`findex>0 & mindex>0` → unique `(findex,mindex)` pairs)
— confirmed correct by matching kinship2's own canonical internal logic, not invented.

`kinship()` computes only the coefficient matrix (no edge/mate list exposed).
`familycheck()`/`makefamid()` do connected-component clustering, not edge listing.

### 1.2 `makePedigreeMatingLayout()`'s output (re-verified directly, `R/makePedigreeDiagramData.R`)

Returns `list(nodes, edges, duplicateToReal)`. **Verified directly** (this session, not from agent
report alone) at `R/makePedigreeDiagramData.R:1085-1234`, `:460-522`:

- `edges <- rbind(childEdgesOut, mateEdges, dupEdges[, twinEdges if supplied])` is built **once**,
  identically regardless of `edgeStyle` (lines 1172-1209) — the `edgeStyle == "rectilinear"` branch
  (lines 1213-1234) only runs *after* this, rewriting `nodes`/`edges` via `.addRectilinearWaypoints()`
  + `.resolveEdgeNodeCollisions()` into waypoint-routed chains (`__bar_`/`__drop_`/`__proj_`/`__jog_`
  ids). **When `edgeStyle == "direct"`, `nodes`/`edges` are returned exactly as first built** — no
  waypoint rewriting.
- `mateEdges$to` is **always** a `__union_N` id (line 1120) — no other edge type ever has `to` be a
  union id.
- `childEdgesOut$from` (`R/makePedigreeDiagramData.R:514-519`, re-verified directly) is **either** a
  `__union_N` id (both parents known — the common case) **or** a real/dup parent id directly (the D5
  single-known-parent fallback, `ifelse(hasSire[oneParent], sire[oneParent], dam[oneParent])`) — no
  other edge type has `from` be a union id, and no other edge type has this from/to shape without one
  of the two markers below.
- `dupEdges` (dashed real↔duplicate connectors, **not** a real relationship) are uniquely marked by
  `dashes == TRUE & smooth.type == "curvedCW"` — no other edge type sets these.
- A founder (0 known parents) gets **no** incoming child edge at all (`R/makePedigreeDiagramData.R:509`,
  `unitOfRow`/`oneParent` only cover `hasBoth`/`oneParent` rows) — matching kinship2's own
  `findex==0 & mindex==0` founder convention exactly.
- `duplicateToReal <- stats::setNames(duplicates$realId, duplicates$id)` (line 1211) — a named vector,
  `__dup_X_N` → real id `X`. This is the **only** existing resolver in the codebase, and it is not a
  callable function — its one production call site is `R/modPedigree.R:773-775`.
- **Reserved node-id prefixes**, validated at construction (`R/makePedigreeDiagramData.R:359-365`, re-
  verified directly): `__union_`, `__dup_`, `__drop_`, `__bar_`, `__proj_` — a real id may never start
  with any of these. **`__jog_` (added by `.resolveEdgeNodeCollisions()`, Track 2/issue #160) is a 6th
  prefix, not covered by this validation regex and not yet in `vignettes/a2interactive.Rmd:500`'s
  documented 5-prefix set** — irrelevant to this plan (§1.2's `edgeStyle="direct"` choice never
  produces `__jog_` ids at all; noted here only because a future session touching the reserved-prefix
  set should know it's incomplete).

**No existing function resolves any prefix other than `__dup_`.** Building that general resolver is
exactly this plan's Track B (§4.2).

### 1.3 The four "same relationships, different picture" dragons (from
`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`, the single most load-bearing
prior-evidence document for this design)

1. **Crossing-driven duplication mismatch** — kinship2 also duplicates a *single*-mate individual
   purely to shorten a long layout-crossing edge (a plot-time-only decision inside `align.pedigree()`);
   nprcgenekeepr never does this (it duplicates only a real multi-mate anchor). **Resolved by
   construction, not extra logic**: §1.1 confirms kinship2's crossing-driven duplication never touches
   the `pedigree` object's own `id`/`findex`/`mindex` — sourcing ground truth from there (never from
   `align.pedigree()`'s plot-layout matrices) means this dragon simply never enters the comparison.
2. **Isolated-individual silent drop** — kinship2's `plot.pedigree()` can silently omit an individual
   with no mate and no children. **Resolved the same way**: `id`/`findex`/`mindex` retain every
   individual regardless of plot visibility.
3. **Multi-mate representation difference** — nprcgenekeepr: 2 nodes + dashed connector; kinship2: 1
   node, 2 mate-lines, for the *same* real individual. **Resolved by construction**: both extractors
   (§3.1, §3.2) emit relationships keyed by real-individual identity — nprcgenekeepr via
   `duplicateToReal` collapsing, kinship2 via its already-single-row-per-individual `id` array. A
   multi-mate individual naturally appears once, with N mate-pairs, on both sides.
4. **Twin/zygosity connector** — kinship2 has a relationship-code triangle connector; nprcgenekeepr's
   diagram has none (tracked, issue #137, unrelated missing-feature). **Out of Phase-1 scope** — see
   §2.4.

A fifth fact from the same document, not a "dragon" but a hard comparator-correctness requirement:
**neither package treats sire/dam left-right order as meaningful** (S482 spike, `docs/research/
issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`) — the comparator must never assert
positional/x-order equivalence, only unordered set equivalence (§3.3).

### 1.4 Fixture inventory (existing, reusable)

| Fixture | Where | Relevance |
|---|---|---|
| 9-subject "Track C" dogleg fixture (`P1,P2,A,Y,X,W,C1,C2,GC`) | `tests/testthat/test_makePedigreeMatingLayout.R:1276-1283`, reused verbatim in `data-raw/kinship2FidelityValidation.R:234-241` as `pedC` | Has one real consanguineous union (`A`×`Y`, `kinship=0.25`) and one real duplicate (`A` anchors `X`, is non-anchor with `Y`) — the natural small hand-verifiable fixture for Track C (§4.3). Already used for S631's own by-hand spot check. |
| Real 375-individual bundled fixture | `inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`, loaded via `system.file()` | The required real-scale check (Learning 596, §2.5) — 173 founders, up to 5-way multi-anchor individuals. |
| 10-subject `fam1`, 16-subject `pedB` | `data-raw/kinship2FidelityValidation.R:94-101,157-184` | Already kinship2-cross-validated numerically (Tracks A/B); available if Track C's own test suite wants extra coverage, not required. |
| **None** exercise kinship2's own crossing-driven duplication case | — | Gap — see D-7 (§2.6), Track C. |

### 1.5 `kinship2`'s dependency status (re-confirmed directly, both DESCRIPTION and CI)

- `DESCRIPTION` lists `kinship2` in **neither** `Imports` nor `Suggests` (confirmed by direct grep —
  no match). It is used only via `requireNamespace("kinship2", quietly = TRUE)`-guarded calls in
  `data-raw/kinship2FidelityValidation.R` (build-ignored) — the script's own header states explicitly:
  "never a Suggests dependency."
- **No `.github/workflows/*.yaml` installs `kinship2`** (confirmed by direct grep this session, zero
  matches) — any `testthat::skip_if_not_installed("kinship2")`-guarded test will skip cleanly in CI
  and run live only on a machine (such as this one) with kinship2 installed locally. This mirrors
  `test_shrinkPedigree.R`/`test_kinship.R`'s own established pattern, with one deliberate difference
  spelled out in D-6 (§2.7): those files hardcode expected values *derived once* from an offline
  kinship2 run; this plan's Track C tests call kinship2 **live**, because the whole point is ongoing
  regression protection against future layout-algorithm changes, not a one-time numeric fact.

---

## 2. Design decisions

Each decision states whether it is **forced** (only one option is actually correct, given §1's
verified facts) or a genuine **judgment call** (reasonable alternatives exist — routed to owner
ratification, §7).

### D-1 (forced) — kinship2 ground truth source: the `pedigree` object's `id`/`findex`/`mindex`/
`relation` fields only, never `align.pedigree()`'s plot-layout output or a rendered image's node set.

**Why forced:** this is the only source that resolves dragons 1 and 2 (§1.3) by construction rather
than by extra special-case logic. Any comparator sourcing from `align.pedigree()` or a screenshot
would need to reinvent handling for both — strictly worse, for no benefit.

### D-2 (forced) — nprcgenekeepr ground truth source: `makePedigreeMatingLayout(ped,
edgeStyle="direct", twinRelations=NULL)`'s `nodes`/`edges`/`duplicateToReal`, never `"rectilinear"`
style's waypoint-rewritten edges.

**Why forced:** §1.2 confirms the underlying relationship structure (`childEdgesOut`/`mateEdges`/
`dupEdges`) is built once, identically, before the `edgeStyle` branch — `"rectilinear"` only adds
presentation-layer waypoint routing on top. Comparing on `"direct"` output extracts the identical
relationship data with far simpler edge-disambiguation rules (§3.2), entirely avoiding `__bar_`/
`__drop_`/`__proj_`/`__jog_` chain-walking.

**Required verification, not an assumption:** this decision rests on "the two edge styles represent
the same relationships, just routed differently" being an actual invariant of the shipped code, not
merely something the source *looks* like it guarantees. Track B (§4.2) includes an explicit
edgeStyle-invariance property test — extract the canonical relationship set from both `"direct"` and
`"rectilinear"` output on the same fixtures and assert they're identical — **before** relying on D-2
for the cross-package comparison in Track C. This test needs no kinship2 at all.

### D-3 (forced) — comparison granularity: real-individual-level relationship sets (parent-child
pairs; mate-pairs with ≥1 child), canonicalized/unordered — not node counts, not x-order.

**Why forced:** matches the owner's own callout text exactly ("extract the parent-child/mate-pair
edge set... diff them"); resolves dragon 3 (§1.3) by construction once both extractors key by real
identity; §1.3's fifth fact makes positional/order comparison actively wrong, not just unnecessary.

### D-4 (judgment call) — twin/zygosity relation comparison: in Phase 1 scope, or deferred?

kinship2's `relation` field and nprcgenekeepr's `twinRelations` argument are both already
resolved-to-real-id inputs (§1.1, §1.2) — comparing them needs no layout parsing at all, just a
direct diff of two small data frames. This makes it cheap to add, but it is a distinct comparison
dimension (relationship *codes*, not parent-child/mate-pair *edges*) that the owner's callout text
does not name. **Recommendation: defer** (§7 Q2) — keeps Track C's scope matched exactly to the
callout, with a documented, trivial-to-implement extension point for later.

### D-5 (forced, mechanical) — kinship2's stricter sex-role validation (`dadid` must be male,
`momid` must be female; nprcgenekeepr enforces no such rule) is handled by a small fixture-
construction helper, `.toKinship2Pedigree(ped)`, that auto-detects and swaps a reversed row before
calling `kinship2::pedigree()` — generalizing the manual, comment-documented swap
`data-raw/kinship2FidelityValidation.R:242-256` already performs by hand for the Track C fixture's
`C2` row. This helper is a genuine kinship2 dependency (it calls `kinship2::pedigree()` directly) and
therefore lives in `data-raw/` (§2.7), never in `R/`.

### D-6 (judgment call) — where do the 3 core functions live?

| Option | Kinship2 dependency | Testable via `testthat` / CI | API commitment |
|---|---|---|---|
| **Internal `R/` helpers (`@noRd`) + dedicated test file — recommended** | None (operate on plain lists/data frames, not the `kinship2::pedigree` S3 class — see §3.1/§3.2 input contracts) | Yes — real, repeated regression coverage, exactly the "reusable, automated comparator rather than another one-off spot check" Learning 664 calls for | None — no new exported surface, no `NEWS.Rmd`/`_pkgdown.yml`/`a2interactive.Rmd` obligation (§5) |
| Script-only upgrade to `data-raw/kinship2FidelityValidation.R` | N/A | No | None, but **repeats the exact failure mode this task exists to fix** — stays ad hoc, no CI/testthat coverage, no protection against future layout-algorithm drift |
| New exported, user-facing function | Would need careful guarding to keep `kinship2` non-required at call time | Yes | Real — `NEWS.Rmd`, `_pkgdown.yml`, `a2interactive.Rmd` documentation checklists all trigger (`CLAUDE.md`), for a maintainer-verification tool the owner did not ask to expose to end users |

Recommendation routed to owner ratification (§7 Q1) despite being the obviously stronger option,
because it is a real, reasonable-alternatives judgment call about API surface and commitment level —
not something this plan should unilaterally decide.

### D-7 (judgment call) — a new fixture for kinship2's own crossing-driven duplication case

No existing repo fixture exercises the scenario in dragon 1 (§1.3): an individual with exactly one
mate, whom kinship2 would still duplicate at plot time for crossing minimization, that nprcgenekeepr
never duplicates. §1.1/D-1 establish this dragon is resolved *by construction* — but that claim is
currently unverified by any test. **Recommendation: add one small purpose-built fixture in Track C**
(§4.3) specifically to prove it, per Learning 596's "render/test the claim, don't just reason about
it" rule. Routed to owner ratification (§7 Q3).

### D-8 (forced) — validation discipline: toy fixture(s) AND the real 375-individual fixture,
per Learning 596.

A toy-only validation of this exact diagram-layout code has already produced a wrong conclusion once
(Learning 596, S588). Track C (§4.3) must run the comparator against both the small Track-C/D-7
fixtures **and** the real bundled fixture. **A non-empty diff on the real fixture is a genuine
finding to report, not silently reconcile** — it may reveal an actual, currently-unknown structural
discrepancy (a real bug) or a legitimate, uncatalogued convention difference (not a defect) — either
way, Track C's completion criteria (§4.3) require presenting any such finding to the owner, not
"fixing" it unilaterally mid-implementation (`SAFEGUARDS.md` mode-switch rule).

---

## 3. The comparator: interface-first design

Following `ARCHITECTURE_WORKSTREAM.md`'s interface-first principle — each function's contract is
fixed before any implementation.

### 3.1 `.extractKinship2Structure(pedLike)` — R/, `@noRd`, **zero kinship2 dependency**

**Input contract:** a plain list with `id` (vector), `findex` (integer vector, same length), `mindex`
(integer vector, same length), and optionally `relation` (data frame with `indx1`, `indx2`, `code`).
Deliberately **not** typed as `kinship2::pedigree` — dispatching on the S3 class would force a
`kinship2` dependency into `R/` package code for no benefit, since only these 3-4 plain fields are
ever read (§1.1). A real `kinship2::pedigree()` object satisfies this contract structurally (it's a
list with these exact names) without any special-casing.

**Output contract:**
```r
list(
  parentChildEdges = data.frame(child = character(), parent = character(), role = character()),
  matePairs         = data.frame(parent1 = character(), parent2 = character(), nChildren = integer())
)
```

**Algorithm** (re-implements kinship2's own `align.pedigree()` derivation verbatim — §1.1 — not
invented logic):
```r
hasFather <- pedLike$findex > 0
hasMother <- pedLike$mindex > 0
parentChildEdges <- rbind(
  data.frame(child = pedLike$id[hasFather], parent = pedLike$id[pedLike$findex[hasFather]], role = "father"),
  data.frame(child = pedLike$id[hasMother], parent = pedLike$id[pedLike$mindex[hasMother]], role = "mother")
)
hasBoth <- hasFather & hasMother
pairKey <- paste(pedLike$findex[hasBoth], pedLike$mindex[hasBoth], sep = "_")
keep <- !duplicated(pairKey)
matePairs <- data.frame(
  parent1 = pedLike$id[pedLike$findex[hasBoth][keep]],
  parent2 = pedLike$id[pedLike$mindex[hasBoth][keep]],
  nChildren = as.integer(table(pairKey)[pairKey[keep]])
)
```

**Test strategy:** fully unit-testable with a hand-built synthetic list (no kinship2 install needed)
— e.g. the 7-subject fixture already verified live in this session's research (§1.1), plus edge
cases (a founder with 0 parents; an individual with only 1 known parent; an individual with 2 mates).

### 3.2 `.extractNprcStructure(layout)` — R/, `@noRd`, **zero kinship2 dependency**

**Input contract:** the return value of `makePedigreeMatingLayout(ped, edgeStyle = "direct",
twinRelations = NULL)` — i.e. `list(nodes, edges, duplicateToReal)` as documented at §1.2. Callers
**must** use `edgeStyle="direct"` and omit `twinRelations` (D-2, D-4) — this function does not defend
against `"rectilinear"` input; that is Track B's own edgeStyle-invariance test's job, not this
function's runtime responsibility.

**Output contract:** identical shape to §3.1's — `list(parentChildEdges, matePairs)`, both keyed by
*real* individual ids (never `__dup_`/`__union_`/other synthetic ids).

**Algorithm** (the 3-way disambiguation established and verified at §1.2):
```r
resolveId <- function(id) ifelse(id %in% names(layout$duplicateToReal),
                                  layout$duplicateToReal[id], id)

isMateEdge  <- grepl("^__union_", layout$edges$to)                                    # to is always a union
isDupEdge   <- !isMateEdge & layout$edges$dashes & identical(layout$edges$smooth.type, "curvedCW")
isChildEdge <- !isMateEdge & !isDupEdge                                               # from may be a union (main case) or a real/dup id (D5 fallback)

mateEdges  <- layout$edges[isMateEdge, ]
childEdges <- layout$edges[isChildEdge, ]

# mate pairs: group parent-side (`from`) endpoints by the union (`to`) they share
matePairs <- do.call(rbind, lapply(split(mateEdges$from, mateEdges$to), function(parents) {
  parents <- resolveId(parents)
  if (length(parents) < 2L) return(NULL)   # dangling-parent unit (safely skipped, not a real mate pair)
  data.frame(parent1 = parents[1], parent2 = parents[2], nChildren = NA_integer_)
}))

# parent-child edges: expand a union-sourced edge into 2 rows (one per resolved mate); pass a
# D5-fallback real-parent edge through directly
parentChildEdges <- do.call(rbind, lapply(seq_len(nrow(childEdges)), function(i) {
  from <- childEdges$from[i]; child <- resolveId(childEdges$to[i])
  if (grepl("^__union_", from)) {
    parents <- resolveId(mateEdges$from[mateEdges$to == from])
    data.frame(child = child, parent = parents)
  } else {
    data.frame(child = child, parent = resolveId(from))
  }
}))
```
(Illustrative — the implementing session should vectorize/harden this, e.g. `nChildren` should be
counted from `parentChildEdges` after assembly, not left `NA`, and both loops should be written to
avoid `rbind` in a loop at real-fixture scale. Shown unrolled here for auditability against §1.2's
verified line-level claims, not as final code.)

**Test strategy:** fully unit-testable against `makePedigreeMatingLayout()`'s real, direct-style
output on every existing small fixture (§1.4) — no kinship2 needed. **Must also include** the
edgeStyle-invariance property test required by D-2: for each fixture, `.extractNprcStructure()`
applied to `"direct"`-style output must match a *separately-implemented* extraction from
`"rectilinear"`-style output (walking `__bar_`/`__drop_`/`__proj_`/`__jog_` chains — a harder, second
implementation whose only purpose is cross-checking D-2's invariance claim; it need not be
production-quality or reused anywhere else).

### 3.3 `.comparePedigreeStructures(a, b)` — R/, `@noRd`, **zero kinship2 dependency**

**Input contract:** two `list(parentChildEdges, matePairs)` structures in §3.1/§3.2's shared output
shape — deliberately agnostic to which side is kinship2 vs. nprcgenekeepr, so this function is
independently testable with two hand-built structures, no kinship2 or layout code involved at all.

**Output contract:**
```r
list(
  parentChildOnlyInA = data.frame(...), parentChildOnlyInB = data.frame(...),
  matePairsOnlyInA   = data.frame(...), matePairsOnlyInB   = data.frame(...),
  identical = logical(1)   # TRUE iff all 4 above are zero-row
)
```

**Algorithm:** canonicalize each row before comparing (per §1.3's fifth fact — order must never
matter): for `matePairs`, sort `parent1`/`parent2` alphabetically per row so `(A,B)` and `(B,A)`
compare equal; for both tables, sort rows canonically, then `dplyr::anti_join()`/`setdiff()`-style
set comparison in both directions (A-not-in-B, B-not-in-A) rather than positional `identical()`.

### 3.4 `.toKinship2Pedigree(ped)` + orchestration — `data-raw/kinship2FidelityValidation.R`,
**genuine kinship2 dependency, `requireNamespace()`-guarded**

Auto-swaps a reversed sire/dam row (D-5), then calls `kinship2::pedigree(id=, dadid=, momid=,
sex=, relation=)`. A thin orchestration wrapper (`compareAgainstKinship2(ped, ...)` or similar,
final naming left to the implementing session) then does:
```r
pedK2 <- .toKinship2Pedigree(ped)
kinship2Struct <- .extractKinship2Structure(pedK2)       # works unchanged -- pedK2 is a list with id/findex/mindex
nprcLayout <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
nprcStruct <- .extractNprcStructure(nprcLayout)
.comparePedigreeStructures(kinship2Struct, nprcStruct)
```

---

## 4. Session-sliceable tracks

Each track below is scoped to one session (`SESSION_RUNNER.md` Planning Sessions checklist: explicit
completion criteria, verification commands, session boundary). Strict dependency order: A → B → C →
D (§5).

### 4.1 Track A — kinship2-side extractor (`.extractKinship2Structure()`)

**Scope:** implement §3.1 exactly, in a new file (e.g. `R/comparePedigreeStructure.R` — final name
left to the implementing session) plus its test file. Zero kinship2 dependency; no
`skip_if_not_installed()` needed anywhere in this track.

**Done looks like:** the function exists, is unit-tested against ≥4 synthetic fixtures (founder;
single-parent; multi-mate; the 7-subject fixture from §1.1's own live verification), full clean
regression passes, `lintr::lint_package()` 0 lints on touched files.

**Verification commands:** `devtools::test()` / the fast single-file test command
(`CLAUDE.md` Build/Test/Verify); `lintr::lint_package()` after `pkgload::load_all()`.

**Effort:** S.

### 4.2 Track B — nprcgenekeepr-side extractor (`.extractNprcStructure()`) +
edgeStyle-invariance property test

**Scope:** implement §3.2 exactly. **Must include** the edgeStyle-invariance test required by D-2 —
this is the track that actually proves D-2's foundational claim, not merely assumes it.

**Done looks like:** the function exists, is unit-tested against every existing small fixture (§1.4)
via direct-style `makePedigreeMatingLayout()` output; the edgeStyle-invariance property test passes
on at least the Track-C fixture and the real 375-individual fixture (§1.4); full clean regression
passes; 0 lints.

**Verification commands:** same as Track A, plus explicit confirmation the invariance test actually
ran against the real fixture (not skipped/mocked).

**Effort:** S–M (the second, cross-checking `"rectilinear"`-side extraction implementation is real
work, even though it's throwaway/test-only).

### 4.3 Track C — comparator (`.comparePedigreeStructures()`) + new fixture (D-7) +
live kinship2 end-to-end tests + real-fixture run (D-8)

**Scope:** implement §3.3 and §3.4. Add the new crossing-duplication fixture (D-7, pending
ratification §7 Q3). Write `testthat::skip_if_not_installed("kinship2")`-guarded end-to-end tests
that build a real `kinship2::pedigree()` object (via `.toKinship2Pedigree()`) and assert
`.comparePedigreeStructures()` reports `identical = TRUE` for: the Track-C fixture, the new D-7
fixture (if ratified), and — separately — the real 375-individual bundled fixture.

**Done looks like:** all of the above pass locally (kinship2 installed); CI confirmed to skip these
tests cleanly (not silently fail) since kinship2 is absent there (§1.5); **any real-fixture diff is
written up and presented to the owner as a finding**, not silently patched (D-8) — this may mean
Track C's own session ends with an open question rather than a clean "identical" result, which is an
acceptable, even valuable, outcome, not a failure of the track.

**Verification commands:** same as Track A/B, plus a manual local run (kinship2 installed) confirming
the skip-vs-run behavior both ways is correct (e.g. temporarily renaming the local kinship2 library
to confirm a clean skip, or trusting `skip_if_not_installed()`'s own well-established semantics if a
manual check is judged unnecessary by the implementing session).

**Effort:** M.

### 4.4 Track D — close the loop: port the chromote fix, regenerate images, re-run Track C
against the vignette's own fixtures, remove the S631 caveats

**Scope:** entirely pre-existing, mechanical work already named in `BACKLOG.md`'s item — not
redesigned here. Port `PROJECT_LEARNINGS.md` Learning 643's `$go_to()` fix into
`data-raw/kinship2FidelityValidation.R`'s `screenshot_layout()`; regenerate every Track B/C image;
run Track C's new comparator against `vignettes/articles/kinship2-fidelity-validation.qmd`'s own
Track B/C fixtures specifically; only if that comparison reports `identical = TRUE` (or any diff is
explicitly resolved/accepted), remove the S631 caveats from both `kinship2-fidelity-validation.qmd`
and `pedigree-diagram-kinship2-reference-comparison.qmd` and update `NEWS.Rmd` (this step is the
first genuinely user-facing consequence of the whole effort, since it changes what the published
vignette claims).

**Done looks like:** fresh images committed; comparator run against the vignette's fixtures with a
recorded result; caveats removed only if the result supports it; `NEWS.Rmd` entry added
(plain-language criterion, `CLAUDE.md`).

**Effort:** S–M, contingent on Track C's own findings (a clean pass makes this small; a real
discrepancy found in Track C could make this larger or block caveat removal entirely, which is fine
— the caveats staying up is a correct outcome, not a failure).

Whether Track D belongs in this plan at all, vs. staying purely in `BACKLOG.md` as an independent
future pickup, is routed to owner ratification (§7 Q4).

---

## 5. Cross-track notes

- **Strict ordering, not just a recommendation:** unlike the sibling `kinship2-supplement-full-
  reproduction-plan.md` (whose 3 tracks were independently pickable), A → B → C → D is a **hard**
  dependency chain here — Track B's tests import Track A's output shape contract; Track C directly
  calls both; Track D consumes Track C's comparator as a black box.
- **Documentation obligations, checked against `CLAUDE.md`'s standing checklists — none apply to
  Tracks A-C as designed:** all 4 new functions are `@noRd`/internal (D-6 recommendation), so the
  `_pkgdown.yml` reference-coverage checklist and the `a2interactive.Rmd` script-callable-function
  checklist do not trigger (neither applies to non-exported functions). `NEWS.Rmd`'s checklist
  triggers only at Track D (§4.4), the first user-facing change (caveat removal). If the owner instead
  ratifies D-6's exported-function alternative (§7 Q1), all three obligations become live in
  whichever track ships the export — flagged here so a future session doesn't miss it if that path is
  chosen.
- **CI behavior is a deliberate, verified design point, not an oversight:** §1.5 confirms no workflow
  installs kinship2; Track C's live-kinship2 tests will report as skipped, not failed, in every CI
  run — this must be visually confirmed once (not just assumed) when Track C first lands, per this
  project's own "trust but verify" discipline (`SAFEGUARDS.md`).
- **`kinship2` stays local-only.** No track in this plan adds it to `DESCRIPTION` in any form —
  consistent with every existing precedent (`R/kinship.R`, `R/shrinkPedigree.R`,
  `data-raw/kinship2FidelityValidation.R`).

---

## 6. Alternatives considered

| Alternative | Pros | Cons | Why not chosen |
|---|---|---|---|
| Compare rendered images pixel-by-pixel (e.g. perceptual diff) | Would catch true visual regressions, not just relationship-graph ones | Doesn't address the owner's actual ask (structural/topological, not visual); reintroduces the chromote/screenshot dependency this plan deliberately avoids for the core comparison; extremely sensitive to legitimate, non-defect layout differences (§1.3's ordering non-rule alone would produce constant false positives) | Rejected outright — wrong tool for the stated problem |
| Compare against kinship2's `align.pedigree()` plot-layout output (`nid`/`pos`/`spouse` matrices) instead of the raw `pedigree` object | Slightly closer to "what actually gets drawn" | Reintroduces dragons 1 and 2 (§1.3) that D-1 otherwise resolves for free; `align.pedigree()`'s own layout-optimization internals are exactly the kind of "trust the implementation, don't re-derive" risk this whole task exists to eliminate | Rejected — D-1 (§2) |
| Build the resolver/comparator entirely inside `data-raw/kinship2FidelityValidation.R` (script-only) | Smallest footprint; no new `R/` surface | No `testthat`/CI coverage at all — literally repeats the "one-off, not a repeatable check" failure (Learning 664) this plan exists to fix | Rejected — D-6 (§2.7), though still offered as an option for owner ratification since it's a legitimate (if weaker) choice |
| Compare on `"rectilinear"` style output directly (walk waypoint chains for the real comparison, not just the invariance test) | Tests the actual default/shipped style directly | Substantially more complex edge-disambiguation (6 id-prefix families instead of 3 marker rules); D-2 shows this complexity buys nothing once edgeStyle-invariance is independently proven | Rejected — D-2 (§2) |

---

## 7. Open questions for owner ratification

The following are genuine judgment calls (§2), not forced by evidence — routed to the owner via
`AskUserQuestion` before this plan is finalized/committed, matching the established `kinship2-
supplement-full-reproduction-plan.md` (S562) ratification precedent.

- **Q1 (D-6, §2.7):** Where should the 3 core comparison functions live?
- **Q2 (D-4, §2.4):** Should Phase 1 also compare twin/zygosity relation data, or defer it?
- **Q3 (D-7, §2.6):** Add a new fixture for kinship2's own crossing-driven duplication case?
- **Q4 (Track D, §4.4):** Should Track D (close the loop on the vignette) stay part of this plan's
  tracked sequence, or move fully back to being an independent `BACKLOG.md` item?

### Ratification outcome (2026-08-25, this session)

All 4 questions ratified via `AskUserQuestion`, owner selected the recommended option in every case
(matching S562's own outcome pattern):

- **Q1 (D-6):** **Internal `R/` helpers + dedicated test file.** The 3 core functions
  (`.extractKinship2Structure()`, `.extractNprcStructure()`, `.comparePedigreeStructures()`) are
  `@noRd`, live in `R/`, get real `testthat` coverage. No new exported surface — the `NEWS.Rmd`/
  `_pkgdown.yml`/`a2interactive.Rmd` documentation checklists do not trigger for Tracks A-C.
- **Q2 (D-4):** **Deferred.** Phase 1 (Tracks A-C) compares only parent-child edges and mate pairs.
  Twin/zygosity relation comparison is confirmed out of scope, left as a documented, cheap-to-add
  future extension point (§2.4).
- **Q3 (D-7):** **Add the new fixture.** Track C (§4.3) includes a new, small, purpose-built fixture
  exercising kinship2's own crossing-driven single-mate duplication case, to prove (not merely
  assume) D-1's claim that this dragon is resolved by construction.
- **Q4 (Track D):** **Keep Track D in this plan's tracked sequence**, unchanged from §4.4 — no new
  design work, sequenced here for scope-tracking as the natural close-the-loop step once Track C
  ships.

No changes to §1-§6 are needed as a result — every ratified answer matches this document's own
stated recommendation, so §3/§4's designs stand as written.

---

## 8. Provenance

- kinship2 object structure (§1.1): live inspection this session, kinship2 1.9.6.2 installed locally;
  `kinship2::pedigree`, `kinship2:::as.data.frame.pedigree`, `kinship2::align.pedigree`,
  `kinship2::autohint` read via `print()`/`getAnywhere()`.
- `makePedigreeMatingLayout()` structure (§1.2): `R/makePedigreeDiagramData.R:32-138` (`makePedigreeDiagramData()`),
  `:347-523` (`.buildMatingUnitForest()`), `:893-1237` (`makePedigreeMatingLayout()`, re-verified
  directly this session at `:1085-1234` and `:460-522`), `:1301-1552` (`.addRectilinearWaypoints()`),
  `:1712-1834` (`.resolveEdgeNodeCollisions()`).
- S631's by-hand method (§0, §1.4): `SESSION_NOTES.md` "What Session 631 Did" (top of ACTIVE TASK);
  `PROJECT_LEARNINGS.md` Learning 664; `BACKLOG.md` "Up Next" top item; verbatim command/output
  recovered from the S631 session transcript.
- Dragons/settled facts (§1.3): `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`
  (Examples 2-4, summary table, lines 138-479); `docs/planning/pedigree-diagram-kinship2-fidelity-
  remediation-plan.md` (Tracks 1-6, §7a/§7b); `docs/planning/kinship2-supplement-full-reproduction-
  plan.md` (§1-§5); `vignettes/articles/kinship2-fidelity-validation.qmd` (owner-correction callout,
  lines 5-36; caveats, lines 227-254).
- Learning 596 (`PROJECT_LEARNINGS.md`, S588) — toy-and-real-scale validation discipline, D-8.
- Fixture/test inventory (§1.4): `tests/testthat/test_makePedigreeMatingLayout.R`,
  `tests/testthat/test_resolveEdgeNodeCollisions.R`, `data-raw/kinship2FidelityValidation.R`.
- DESCRIPTION/CI (§1.5): direct grep this session, `DESCRIPTION` and `.github/workflows/*.yaml`.
