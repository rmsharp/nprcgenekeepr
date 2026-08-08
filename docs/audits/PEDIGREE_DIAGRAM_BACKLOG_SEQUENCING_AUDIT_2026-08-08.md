# Pedigree Diagram Backlog Sequencing Audit

**Date:** 2026-08-08 · **Session:** S480 · **Type:** capability-informed sequencing audit (not a
defect audit — recommends an implementation *order* for already-filed items; files no new issues
itself, per the established "audit recommends, a later session files" precedent set by
`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`)

**Question asked (user-directed, not from `BACKLOG.md`'s own sequencing chain):** examine the
recently-added pedigree-drawing-related backlog items and propose an optimal implementation order,
informed by (a) kinship2's documented pedigree-drawing capabilities and (b) the standardized human
pedigree nomenclature reference document held locally at `inst/extdata/reference/Standardized Human
Pedigree Nomenclature...html`.

---

## Method

Built on two existing artifacts rather than re-deriving kinship2's capabilities from scratch:
- `docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md` — a 17-dimension, independently-
  sourced feature comparison between the shipped Diagram tab and kinship2 v1.9.6.2, produced by a
  3-agent research-then-synthesize workflow with several claims independently re-verified via live
  `WebFetch` against CRAN/GitHub.
- `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` — a worked, apples-to-apples
  visual comparison rendering 3 real example pedigrees through both packages, which is where the
  (now-fixed) founder-positioning defect was originally found.

New research this session: fetched full text for the 6 candidate GitHub issues (`gh issue view
133,136,137,138,141,145 --json title,body,labels,createdAt`); ran a 2-agent background workflow
(one agent read the nomenclature reference document in full and extracted its actual drawing-
convention content; a second agent grep-swept `BACKLOG.md` end-to-end for every open pedigree-
drawing item and cross-checked each against the 6 issues for duplication). Spot-verified in-session
rather than trusted solely from the workflow: the nomenclature document's title/authors/DOI (direct
`grep`) and its copyright footer (confirms it is the same Wiley "all rights reserved" page S479
already gitignored — no change to that disposition). Also verified directly against source: whether
`R/makePedigreeDiagramData.R`'s positioning code (`.buildMatingUnitForest()`,
`.positionMatingUnitForest()`) contains any sex-based left/right ordering rule today — it does not
(see Finding #1).

**Coverage:** all 6 open GitHub issues in scope, plus 9 open `BACKLOG.md`-only items the sweep
found with no issue number of their own. No item skipped.

---

## Inventory — the "recently added" pedigree-drawing set

### GitHub issues (all filed 2026-07-30 to 2026-08-05; none has a `BACKLOG.md` entry, per this
project's established issues-are-primary convention)

| # | Title | Category | Filed | Notes |
|---|---|---|---|---|
| #133 | Affected/phenotype/genotype status encoding (data-model gated) | feature, data-model gated | 2026-07-30 | From ISSUE_129 audit Finding #2/Rec #4 |
| #136 | Show names (not just ID) as node labels (data-model gated) | feature, data-model gated | 2026-07-30 | From ISSUE_129 audit Finding #8/Rec #7 |
| #137 | Twin/zygosity encoding (data-model gated) | feature, data-model gated | 2026-07-30 | From ISSUE_129 audit Finding #5/Rec #5 |
| #138 | Full-colony rendering beyond 1,500-node cap | feature, `low priority` label | 2026-07-30 | From ISSUE_129 audit Finding #7/Rec #6; owner-deprioritized |
| #141 | Upgrade D3 tree-positioning merge to Buchheim-Jünger-Leipert | perf, `premature optimization` label | 2026-08-02 | Explicitly "do not implement speculatively" |
| #145 | Correct sire/dam left-right placement | layout convention request | 2026-08-05 | Not from the ISSUE_129 audit lineage; independently filed |

### `BACKLOG.md`-only items (no GitHub issue number; found incidentally during the #142/#143/#144
implementation lineage, S465-S473)

| # | `BACKLOG.md` lines | Summary | Found | Category |
|---|---|---|---|---|
| B1 | 561-575 | `devtools::check()` spelling NOTE drift — 6 words missing from `inst/WORDLIST` | S465 | doc/build housekeeping |
| B2 | 1080-1092 | "Candidate C" connector/dogleg visual-signposting idea (evaluated, not adopted for #144) | S473 | feature, needs fresh owner sign-off |
| B3 | 1093-1101 | `.addRectilinearWaypoints()` D2 loop crashes ("subscript out of bounds") on a dangling, never-duplicated non-anchor parent | S473 | **crash bug** |
| B4 | 1102-1116 | Two more dangling-parent-edge crashes: `ped$gen = NA` → "invalid 'times' argument"; both-parents-dangling → `mergeSubtrees()` crash on empty `rootIds` | S473 | **crash bug** |
| B5 | 1117-1129 | `pedigree-diagram-kinship2-reference-comparison.qmd`'s worked examples stale from #143/#144 | S473 | doc staleness |
| B6 | 1130-1146 | `.positionMatingUnitForest()`'s free-pass filter stricter than `.buildMatingUnitForest()`'s own duplicate-decision — reachability on real data unconfirmed | S471 | possible bug (unconfirmed) |
| B7 | 1147-1164 | Live app's QC'd `obfuscated_rhesus_mhc_ped.csv` copy produces 1 fewer node than the bundled CSV read directly | S472 | data-fixture issue |
| B8 | 1165-1180 | `data-raw/rhesusPedigree.R` docstring claims an independent raw source; fixture is byte-identical to the obfuscated one | S470 | data-fixture / doc mismatch |
| B9 | 1272-1286 | `highlightNearest` degree=6 mitigation (issue #142) is bounded, not a full fix, for very wide sibships | S468 | known limitation, follow-up |

None of B1–B9 duplicate or reference #133/#136/#137/#138/#141/#145 — this is a genuinely separate
set from the "recently added GitHub issues" set, tied instead to the #142→#143→#144 implementation
lineage's own incidental findings.

---

## Evidence base

### kinship2's documented capabilities (condensed from the existing 17-dimension comparison)

kinship2 has purpose-built, precedented support for: affected-status shading (up to 4 traits per
node, `affected=` matrix), twin/zygosity notation (`relation=` codes 1-3), inbreeding-loop duplicate-
node rendering (`arcconnect()`), a manual `hints`/spouse-matrix override for left-right ordering, and
substitutable node labels (any string, including names). It has **no** interactivity of any kind —
click, pan/zoom, hover, and search are architecturally absent, which is precisely the shipped
feature's own core differentiator (already delivered, issue #129).

### The standardized nomenclature reference document — what it actually contains

**Important finding, not assumed going in:** the local file
(`inst/extdata/reference/Standardized Human Pedigree Nomenclature...html`) is Bennett, French, Resta
& Doyle, *"Standardized Human Pedigree Nomenclature: Update and Assessment of the Recommendations of
the National Society of Genetic Counselors,"* *Journal of Genetic Counseling* 17(5):424-433 (2008),
DOI 10.1007/s10897-008-9169-9 — a **commentary/adoption-survey article about a 1995 standard**
(Bennett et al., *Am J Hum Genet* 56:745-752, not itself part of this file), not a from-scratch
symbol catalog. Its four figures — the actual comprehensive symbol/line/ART/genetic-testing tables —
are embedded as **un-transcribed raster images** with only a generic `alt` placeholder, not
extractable text. Confirmed by direct read of every line of the document (not delegated blindly).

What the document's *extractable prose* does and does not support:

| Supported in text | NOT stated in text (image-only) |
|---|---|
| Overall standard status: described as "the only consistently acknowledged standard," used in ABGC-accredited training and internationally | Base square=male/circle=female shape assignment |
| Altering birth order, gender, or affected status is explicitly discouraged — cited as hindering recognition of "anticipation, parent-of-origin effects, sex-linked or sex-limited expression, or in utero lethality" | Deceased-individual slash marking |
| "Relationship lines depicting biologic relationships and degrees of relatedness (including consanguinity)" named as a required "risk assessment" function a pedigree should serve | Twin (MZ/DZ/unknown) notation and connecting-line geometry |
| Legend/key inclusion recommended for "ease of reading by multiple users" | Consanguinity double-line convention |
| Diamond symbol use for unspecified/DSD/transgender individuals (with the caveat that using it to *mask* gender is discouraged) | Adoption bracket/dashed-line notation |
| Dashed descent line recommended for non-biological parentage (donor/surrogate) | **Left-right placement convention for male vs. female partners — not addressed anywhere in extractable text, including no stated exception for multiple partners/crowding** |
| — | Generation Roman-numeral / individual Arabic-numeral numbering scheme |

**This directly bears on issue #145's own framing** — see Finding #2 below.

---

## Findings

### Finding #1: Issue #145 requests a genuinely new layout rule, not a fix to an existing one
- **Description:** Issue #145's title ("Correct the placement...") and body ("the pedigree drawing
  layout **is to follow**... male on left, female on right") both frame this as a correctness gap in
  existing behavior. Direct inspection of `R/makePedigreeDiagramData.R` shows this is not the case:
  `sire`/`dam`/`sex` are used only as data columns and node-shape/label inputs; the x-coordinate
  positioning logic in `.buildMatingUnitForest()`/`.positionMatingUnitForest()` has **no sex-based
  ordering rule of any kind** — a mating unit's left/right member order today is an artifact of
  discovery/tree-structure order, not sex. (Confirmed by grep across the full file, not present.)
- **Evidence:** `R/makePedigreeDiagramData.R` — `sire`/`dam` referenced only for labels
  (lines 51-57, 754-759) and mating-unit-pair identity (lines 154-181, 465-476); zero references to
  `sex` inside `.positionMatingUnitForest()` (lines 373-680).
- **Impact:** This is properly scoped as **new feature design work** (a positioning heuristic to add),
  not a bug-fix session. It also means issue #145's own stated premise — "standard genetic counseling
  conventions" mandate male-left — cannot be verified against this project's own copy of the cited
  standard (see Finding #2), and kinship2 itself treats left-right ordering as `hints`/spouse-matrix-
  driven rather than an unconditional rule (per the existing ISSUE_129 comparison, row 8).
- **Recommendation:** Whoever picks up #145 should open with a short verification spike — check
  kinship2's actual *default* (no-hints) behavior directly (the project already has a one-off local
  `kinship2` install pattern for exactly this, see the `.qmd` comparison doc's Setup section) — before
  committing to "male-always-left" as a hard invariant versus a soft default that yields to crossing-
  minimization, which is what issue #145's own body already anticipates in its "Resolution of the
  Male-Left Rule Conflict" section.

### Finding #2: The nomenclature reference document does not textually confirm the male-left convention
- **Description:** The document extracted this session discusses pedigree *usage, ethics, and
  publication practice* at length, but its left-right partner-placement convention — if the standard
  states one at all — exists only inside the un-transcribed Figure 1/2 images, not in any sentence of
  readable text. Issue #145's citations ("[2]", "[3]", etc.) do not correspond to anything in this
  document's own reference list as read.
- **Evidence:** Full-document read (see Evidence base above); direct `grep` for "left"/"male" ordering
  language in the document's prose sections returned nothing describing a placement rule.
- **Impact:** Not a reason to decline #145 — male-left-female-right is a widely followed convention in
  practice, and kinship2's own worked examples in the `.qmd` comparison doc happen to follow it when
  drawn by kinship2's `hints`-free default in the one case checked — but this project should not cite
  *this specific document* as the source of a firm rule without an implementing session actually
  locating that rule in the primary 1995 paper or the image figures, or accepting it as a
  practitioner-convention default rather than a cited standard.
- **Recommendation:** When #145 is implemented, cite the convention as "common genetic-pedigree
  drawing practice, consistent with kinship2's own default output" rather than attributing it to this
  specific 2008 Bennett commentary article, unless a future session actually transcribes the relevant
  figure image or locates the primary 1995 source.

### Finding #3: Two dangling-parent crash bugs are unrelated to any pending feature and higher-risk than any of it
- **Description:** B3 and B4 are real crashes (`.addRectilinearWaypoints()` "subscript out of
  bounds"; `findGeneration`-adjacent "invalid 'times' argument"; `mergeSubtrees()` on empty
  `rootIds`) triggered by dangling parent references — a sire/dam ID with no own row in the pedigree.
  This is not a synthetic-data edge case: an animal whose parent was never entered into a colony's
  studbook is an ordinary real-world occurrence, the same class of "common, not contrived" case the
  `.qmd` comparison doc already documented for the (now-fixed) founder-positioning defect.
- **Evidence:** `BACKLOG.md:1093-1116`; both confirmed pre-existing on `master`, unrelated to any
  #144 candidate, per the S473 session that found them.
- **Impact:** Any user with a real dangling-parent pedigree hitting `edgeStyle="rectilinear"` (the
  now-default-adjacent style shipped via #142) can crash the Diagram tab today. This sits underneath
  every other item in this audit — new layout features built on top of an engine known to crash on
  realistic input compound the risk.
- **Recommendation:** Fix B3/B4 before starting any of #145/#133/#136/#137/#141's design work in the
  same code area.

### Finding #4: The owner already set an explicit priority order for #133/#136/#137/#138 — this audit must compose with it, not override it
- **Description:** Issue #133's own body records: *"Owner-directed priority order (session 436):
  Recommendation #2, #3, #4 (this issue), #1, #8, #7, then #5, then #6 (#6 explicitly deprioritized/
  delayed)."* Decoded against the ISSUE_129 audit's own Recommendations list: #1 (loop verification),
  #2 (image export), #3 (legend), #8 (hover/search-highlight) are all **already shipped** (issues
  #134, #131, and the legend/#135 work are closed). What remains open from that 8-item list is
  exactly #4 (=#133, affected status), #7 (=#136, node labels), #5 (=#137, twins), and #6 (=#138,
  full-colony, explicitly deprioritized) — in that order.
- **Evidence:** `gh issue view 133 --json body` (quoted above); `BACKLOG.md:671,695,715` (issues
  #131/#134/#135 marked DONE).
- **Impact:** This audit's job is to place the *new* items (#141, #145, B1-B9) into this already-
  decided sequence, not to re-derive an order for #133/#136/#137/#138 from scratch.
- **Recommendation:** Preserve #133 > #136 > #137 > #138 exactly as ordered by the owner.

---

## Recommended implementation order

**Tier 1 — Correctness in the existing renderer (fix before building anything new on top of it):**

1. **B3 + B4 — dangling-parent crash bugs** (`.addRectilinearWaypoints()` D2 loop; `gen = NA`;
   both-parents-dangling). Well-diagnosed already, no new design decisions needed, real crash risk on
   realistic data. *Effort: unknown/small, treat as urgent given the risk.*
2. **B6 — free-pass filter reachability check.** Same code family
   (`.positionMatingUnitForest()`/`.buildMatingUnitForest()`) as B3/B4 — investigate alongside the
   crash fixes rather than in a separate later session, since a fix to one may touch the same lines
   as the other. Fix only if confirmed reachable on real data; otherwise close with evidence.
3. **#145 — sire/dam left-right placement**, opened with the Finding #1/#2 verification spike above
   (check kinship2's actual unhinted default; do not assume the nomenclature document mandates it).
   Same code family as steps 1-2, so sequencing it immediately after is the natural continuation of
   one coherent work area rather than three separate context switches.
4. **B5 — refresh the stale `.qmd` comparison doc.** Do this *after* steps 1-3 land — it's already
   two generations stale (#143, #144) and is exactly the artifact that would demonstrate #145's
   resolution, so refreshing it once per this whole cluster (not once per item) is the efficient
   point to do it.
5. **B1, B7, B8 — opportunistic housekeeping** (spelling/`WORDLIST`, CSV node-count discrepancy,
   `rhesusPedigree.R` docstring mismatch). Small, independent, no design work — fold into whichever
   session in this tier has room, or a dedicated cleanup pass.

**Tier 2 — Data-model-gated features, owner's existing order preserved (Finding #4):**

6. **#133 — affected/phenotype/genotype status encoding.** Highest-ranked remaining feature; best
   kinship2 precedent of the three (`affected=` matrix, shaded pie-slices, well-documented); the
   nomenclature document's own "risk assessment"/anti-alteration language (Evidence base table)
   modestly reinforces treating accurate status display as the more clinically consequential of the
   three, without overriding the owner's own ranking.
7. **#136 — show names as node labels.** Owner-ranked next; smallest/lowest-risk of the three —
   purely additive display change once a name column exists, no new shading/symbol logic to design.
8. **#137 — twin/zygosity encoding.** Owner-ranked next; kinship2 precedent exists (`relation=`
   codes) but the issue's own text notes lowest practical relevance for a macaque colony.
9. **B9 — `highlightNearest` degree=6 full-fix investigation.** Opportunistic follow-up to the
   already-shipped #142 mitigation; start with the recommended pre-work (measure a real fixture's max
   sibship size) before deciding whether a full fix is warranted at all.

**Tier 3 — Explicitly deferred; do not schedule without new evidence:**

10. **#138 — full-colony rendering beyond 1,500 nodes.** Owner-deprioritized; `low priority` label.
11. **#141 — Buchheim-Jünger-Leipert algorithm upgrade.** `premature optimization` label; the issue
    itself says "do not implement speculatively" pending profiling evidence of real need.
12. **B2 — "Candidate C" connector/dogleg idea.** Explicitly evaluated-and-not-adopted for #144;
    needs a fresh, explicit owner product-level sign-off before it is even a scoped backlog item, not
    just an implementation slot.

---

## Structural observations

1. **Three of the twelve items above cluster in the same small code region**
   (`.buildMatingUnitForest()`/`.positionMatingUnitForest()`/`.addRectilinearWaypoints()`) —
   B3, B4, B6, and #145 all touch mating-unit forest construction/positioning, the same area the
   already-fixed founder-positioning defect lived in. Tackling them as one coherent work area (Tier 1)
   rather than four scattered sessions reduces the risk of one fix invalidating another's assumptions.
2. **The "recently added GitHub issues" and "recently added `BACKLOG.md` items" are two genuinely
   separate lineages that happen to share a subject area.** #133/#136/#137/#138/#141 all trace to the
   ISSUE_129 kinship2-comparison audit (S435-436); #145 is independent; B1-B9 all trace to the
   #142→#143→#144 implementation lineage (S465-473). Neither set references the other anywhere in
   `BACKLOG.md` or the issues themselves — treating them as one undifferentiated backlog would have
   missed the owner's already-stated priority order for the first set (Finding #4) and the shared-
   code-locality argument for part of the second (structural observation #1).
3. **The nomenclature reference document's practical value for this specific sequencing question was
   narrower than its title suggests.** It usefully reinforces *why* accurate consanguinity and
   affected-status display matter (supporting Tier 2's existing order, not overriding it), but cannot
   be cited as textual authority for the specific left-right placement rule issue #145 assumes
   (Finding #2) — its symbol/line tables exist only as un-transcribed images in this copy.

---

## Recommendations

1. File no new GitHub issues from this audit — B3/B4 (crash bugs) and B6 (possible bug) are strong
   candidates for their own issues once a session picks up Tier 1, matching the established "audit
   recommends, a later session files" pattern (ISSUE_129 → S436's #131-#139 filing pass) — left to
   that future session rather than done here, since this audit's own scope was sequencing, not
   triage.
2. When #145 is picked up, do not cite this repo's copy of the Bennett 2008 article as the source of
   the male-left rule (Finding #2) — cite kinship2's own observed default behavior and/or general
   practitioner convention instead, or first locate the rule in the primary 1995 source/figure images
   if a citable standard is genuinely required.
3. Sequence Tier 1 (items 1-5 above) as one coherent session or short session cluster before starting
   any Tier 2 data-model work, per Findings #1/#3 and structural observation #1.
4. Preserve the owner's existing #133 > #136 > #137 > #138 order (Finding #4) — this audit adds new
   items around it, it does not re-rank it.
