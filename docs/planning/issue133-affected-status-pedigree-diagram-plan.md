# Issue #133 Plan — Affected/Phenotype/Genotype Status Encoding for the Pedigree Diagram

**Status:** Design/scoping document (Pre-RED) — no `R/`/`tests/`/`man/` content changes this session.
**Session:** S485 (2026-08-08).
**Origin:** GitHub issue #133 ("Add affected/phenotype/genotype status encoding to the pedigree
diagram (data-model gated)"); `docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`
Finding #2 / Recommendation #4; `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`
Tier 2, first in the owner's standing order #133 > #136 > #137 > #138 (set S436).
**Touches (planned, future sessions):** `R/columnSchema.R`, `R/getPossibleCols.R`,
`R/makePedigreeDiagramData.R`, `R/modPedigree.R`, `tests/testthat/test_makePedigreeDiagramData.R`,
`tests/testthat/test_makePedigreeMatingLayout.R`, `tests/testthat/test_modPedigree.R`,
`inst/extdata/examples/` (one new sibling fixture), `NEWS.Rmd`,
`vignettes/manual_components/_pedigree_browser.Rmd` and/or `vignettes/articles/colony-manager-guide.qmd`.
**Does NOT touch:** `R/appServer.R`, `R/modInput.R`, `R/qcStudbook.R`, `R/checkRequiredCols.R`,
`R/fixColumnNames.R` — confirmed this session that the central pedigree-loading/validation path
already passes an unrecognized column through untouched (§2.2); no code there needs to change for
an optional `affected` column to reach the Diagram tab.

> **Scope.** This document is a design/architecture plan only. It changes no `R/`, `tests/`, or
> `man/` content by itself. Implementation happens in future session(s) against the slice contracts
> ratified in §4.

> **RATIFIED this session (S485, 2026-08-08) via `AskUserQuestion`** — all 8 decisions (D1-D8) and
> the 2-slice implementation plan (§4) ratified as written, no changes requested.

---

## 1. Context

### 1.1 What issue #133 says (verbatim)

> kinship2 lets a caller pass up to 4 simultaneous affected-trait indicators per subject, each
> rendered as a shaded section of the node symbol with matching `pedigree.legend()` support.
> nprcgenekeepr's `makePedigreeDiagramData()` reads only `id`, `sire`, `dam`, `sex`, `gen` and has
> no color/fill/shading channel of any kind -- this is a two-layer gap: the pedigree data model has
> no affected/phenotype field to begin with, so the rendering gap is downstream of a data-model gap.
>
> **Impact:** A geneticist doing disease-risk or genetic-value work cannot see which animals in a
> displayed pedigree are affected by a condition of interest directly on the diagram -- they would
> need a separate table lookup.
>
> **Audit disposition:** the audit itself recommended no action in the immediate term... Revisit
> only if phenotype-aware pedigrees become a real need, starting at the data-model layer before
> extending the diagram's node encoding to consume it.
>
> **Domain-convention note (owner-directed, session 436):** ...adopt kinship2's own naming/domain
> definitions rather than inventing new ones from scratch -- kinship2's `affected` argument accepts
> up to 4 affected-trait indicator columns per subject, each independently shaded on the plotted
> symbol. Implementation will also need test pedigree fixtures augmented with the added
> affected-status column(s) to exercise the new behavior; none of the package's current example/test
> pedigrees carry one.
>
> **Owner-directed priority order (session 436):** Recommendation #2, #3, #4 (this issue), #1, #8,
> #7, then #5, then #6 (#6 explicitly deprioritized/delayed). This issue is position 3 of 8 in that
> order.

A later owner comment (added same session) adds a documentation-checklist obligation: any
implementing plan must include updating `vignettes/articles/colony-manager-guide.qmd` and/or
`vignettes/manual_components/_pedigree_browser.Rmd`, per `CLAUDE.md`'s "Tutorial/article
documentation checklist."

### 1.2 What is already decided (do not re-litigate)

- **Priority order.** #133 is first of the remaining Tier 2 items (`docs/audits/
  PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md` Finding #4, itself preserving the S436
  owner order verbatim). This document does not re-derive that ordering.
- **kinship2-naming-convention overlay.** The owner directed (S436) that where nprcgenekeepr adds a
  data-model concept kinship2 already names, it should reuse kinship2's own naming rather than
  invent new terms. This governs Decision D1 below.
- **Simulated test data is in scope.** The owner directed this session (mid-turn, before the design
  doc was drafted) that the design include a concrete plan for simulated affected/unaffected test
  pedigree data — echoing the issue's own note that no current fixture carries one. See §2.4/§3 D5.
- **Documentation-checklist obligations apply.** Tutorial/article (owner comment on #133) and
  `NEWS.Rmd` (`CLAUDE.md`'s standing checklist) are owed in the implementing session(s), not
  deferred. See §5.
- **The Vertical Slice Session allowance does not yet apply.** No prior session pre-declared a layer
  contract for #133 (`SESSION_RUNNER.md` §Vertical Slice Sessions, gate (a)) — this document *is*
  that pre-declaration. A future implementing session may claim vertical-slice status only against
  the slice contracts in §4, re-verified unchanged at its own Orient.

### 1.3 What this session's research confirmed

Five parallel investigations (kinship2's actual `affected` semantics from source; visNetwork/vis.js
rendering options; the R data/rendering pipeline; a fixture-design survey; and this project's own
prior-planning-doc house style) plus this session's own direct follow-up verification (§2.5) ground
every decision below in source, not description. Two findings were surprises relative to how the
issue and the original comparison audit framed the problem:

1. **The "up to 4 traits" ceiling is a caller-overridable default, not a hard kinship2 limit** (§2.1)
   — worth knowing before it's cited as a hard constraint in a future session.
2. **`makePedigreeDiagramData()` is not what actually renders the live Diagram tab.**
   `R/modPedigree.R:446` calls the sibling, independently-implemented `makePedigreeMatingLayout()`
   (confirmed this session: `grep -n "makePedigreeMatingLayout\|makePedigreeDiagramData"
   R/modPedigree.R` returns exactly one hit, `446:makePedigreeMatingLayout(...)`). Any
   affected-status rendering must touch **both** functions to actually ship on the live app (§2.2,
   §3 D4).

---

## 2. Evidence-based inventory

### 2.1 kinship2's actual `affected` convention (verified against installed source, not the Rd
summary alone)

kinship2 1.9.6.2 is installed locally (`packageVersion("kinship2")` confirmed this session). Its
compiled package ships no plain-text `R/*.R` (only a lazy-load DB), so the research this session
loaded the namespace and deparsed each closure directly (`asNamespace("kinship2")$pedigree`, etc.)
and cross-checked against the package's own author-written vignettes (`doc/plot_code_details.Rmd`,
`doc/pedigree_code_details.Rmd`) — full dump preserved in this session's transcript for any future
session that wants to re-verify.

**Data contract** (`pedigree()` constructor):
- `affected` is **optional** — omitting it means `ped$affected` does not exist at all
  (`missing(affected)` short-circuits the whole block).
- Shape: a plain vector (one trait) **or** a matrix with one column per trait. The constructor
  itself enforces **no column-count ceiling**.
- Coercion: logical/factor/integer all convert to 0/1; the function then auto-rebases so the lower
  code becomes 0, **but only if the non-missing values aren't already identical** — a same-valued
  vector that isn't already all-0 throws `"Invalid code for affected status"`. `NA` is explicitly
  permitted and passes through unchanged (`affected==0 | affected==1 | is.na(affected)`).
- The stored representation is whatever shape was passed in — the constructor does not normalize a
  vector into a 1-column matrix.

**Rendering** (`plot.pedigree()`): re-implements the same coercion logic independently (not shared
code with the constructor), always forces the result into a matrix, and recodes `NA` to a private
`-1` sentinel used only inside the plotting call (never persisted on the pedigree object). Each
symbol (square=male, circle=female, diamond=unknown, triangle=terminated — the same 4 shapes this
project already uses for its own 5-code sex vocabulary, F/M/H/U/other) is pre-divided into
`ncol(affected)` pie-slice polygons starting at 6 o'clock, going clockwise — an arbitrary historical
choice the package's own vignette admits has no design rationale ("there was no particular reason...
but it is now established as history"). Each slice: unfilled if 0, `polygon(..., density=, angle=)`
hatch-filled if 1, unfilled **plus a literal `"?"` glyph** at the slice centroid if it was `NA`.

**The "4" ceiling, precisely:** `plot.pedigree()` errors if `ncol(affected) > length(angle) ||
ncol(affected) > length(density)`, and the *default* `angle`/`density` vectors both happen to have
length 4 — so "up to 4" is the out-of-the-box default, not an enforced maximum (confirmed
empirically: a 5-column matrix plots successfully once 5-element `angle=`/`density=` vectors are
supplied). `pedigree.legend()` doesn't even error past 4 — it silently recycles the default vectors,
which would produce a visually ambiguous legend for a 5th trait if a caller forgot to lengthen it
there too.

**`affected` vs. `status` (vital status) are fully independent kinship2 concepts** with different
rendering: `status` draws one diagonal slash across the *entire* symbol (deceased/censored marker,
binary, no `NA` support — `NA %in% status` is a hard error) regardless of `affected`'s state. This
matters directly for D1 below, because this project's own schema already has an unrelated
column named `status` (§2.5).

**Analytic-layer inconsistency worth knowing:** `pedigree.shrink()`/`findAvailAffected()` (kinship2's
own trimming/informativeness utilities) assume `ped$affected` is a single scalar-per-subject vector
and do raw `==`/`is.na()` comparisons with no matrix awareness — the multi-column convention is a
**plotting/legend-layer-only** concept inside kinship2 itself, not a data-model requirement even
kinship2 enforces consistently. This directly supports Decision D2 (single-trait v1 scope) — a
multi-column `affected` matrix isn't even a first-class concept throughout kinship2's own codebase.

### 2.2 Current pedigree-diagram data/rendering pipeline

Two independent node-producing functions live in `R/makePedigreeDiagramData.R`:

- **`makePedigreeDiagramData()`** (defined at line 25) — the simpler, originally-shipped (issue
  #129) layout. Required input columns: `id`, `sire`, `dam`, `sex`, `gen` (line 29 guard). Output
  `nodes`: `id`, `label`, `shape`, `level`, `title`. `shape` is the *only* trait visually encoded
  today (`shapeMap <- c(F="dot", M="square", H="star", U="triangle")`, line 37, diamond fallback for
  unmapped codes); `title` is a pre-built HTML tooltip string added for issue #135 (lines 41-58).
  **No `color` field is set anywhere in this function** — its nodes render at vis.js's default blue.
- **`makePedigreeMatingLayout()`** (defined at line 765) — the kinship2-parity "Option 2" layout, and
  **the function actually wired into the live Diagram tab** (`R/modPedigree.R:446`, confirmed this
  session via direct grep, one hit). It duplicates — does not call — the same required-column guard,
  `shapeMap`/`sexLabelMap`, and title-builder (`.shapeForVec`/`.titleForIds`, lines 800-819) inside
  its own closure, then builds `realNodes`/`dupNodes`/`unitNodes` (lines 821-855, confirmed read this
  session) independently. Only its `edgeStyle="rectilinear"` path (`.addRectilinearWaypoints()`) sets
  `color.background`/`color.border` today — used solely to make waypoint nodes fully transparent
  (`rgba(0,0,0,0)`). **This is the one existing precedent for a per-node `color` column reaching
  vis.js**, confirming the idiom works and is the natural mechanism to extend (D3).

**The duplication is real, pre-existing, and issue #135 already had to work within it**: its hover
tooltips only appear on the live Diagram tab because #135 touched *both* functions, not just the
originally-shipped one — `makePedigreeMatingLayout()`'s own `.titleForIds()` closure (line 807-819)
independently reproduces the same sex-label/HTML-escaping logic `makePedigreeDiagramData()`'s does
(lines 41-58). Any #133 implementation inherits the same obligation (D4) — this is scoped as a
deliberate continuation of an established (if imperfect) pattern, not a de-duplication opportunity to
chase mid-feature (`SAFEGUARDS.md` §The Two-Mode Problem — flagged in §8 Dragon #1, not fixed here).

**Data entry / central validation is not a blocker.** `shared$currentPedigree` (`appServer.R:47-54,
164, 299-301`) is the single reactive object feeding the Diagram tab *and* Genetic Value
Analysis/Marker Genetics/Breeding Groups identically — an `affected` column, once present, is
automatically visible everywhere with zero extra plumbing. Three validation layers were confirmed
this session to pass unrecognized columns through untouched rather than dropping them:
`fixColumnNames()` (normalizes names only), `checkRequiredCols()` (checks only the required set),
and `qcStudbook()`'s own possible/novel-column split (`R/qcStudbook.R:316-319` — unknown columns are
reordered to the end, never dropped). The only reason to touch `R/columnSchema.R` is to make
`affected` a *recognized, first-class* column (stable ordering, `getPossibleCols()` documentation,
`getIncludeColumns()`-propagation *if* wanted) — not because omitting that step would break anything.

### 2.3 visNetwork/vis.js rendering options surveyed

The installed stack (`visNetwork` R package v2.1.4, bundling vis-network.js v9.1.0, confirmed via
the installed package's `htmlwidgets/lib/vis/visNetwork.yaml`) has no native kinship2-style
pie-slice node primitive. Options surveyed, ranked by fidelity vs. cost:

| # | Option | New dep? | Custom JS? | Fidelity to kinship2 | Composes with #131/#132/#135? |
|---|---|---|---|---|---|
| 0 | Tooltip-only: add an "Affected: …" line to the existing `title` string | none | none | On-demand only, not at-a-glance | Perfect — pure extension of `.titleForIds()`/`title` build |
| **1** | **Single dominant-trait `color.background`, keep `shape`=sex** | none | none | Low (1 trait) | Good — one more `visLegend()`/`addNodes` row-set in the *same* panel |
| 2 | Add `color.border` as a 2nd simultaneous channel | none | none | Low-moderate (2 traits, color-only) | Strained — a single swatch legend can't cleanly show a 2-axis color combination |
| 3 | True kinship2-style pie glyph: per-unique-combination inline SVG data-URI, `shape="image"`/`"circularImage"` | none (base R `utils::URLencode()`) | none | High (true N-trait pie) | **Collides** — `shape` is now consumed by the image, displacing sex; #132's legend needs a redesign |
| 4 | `visNodes(ctxRenderer = JS(...))` hand-drawn canvas glyph (shape + pie together) | none (ships in bundled vis-network 9.1.0) | **Yes — substantial** (arc math, hit-testing, redraw-on-hover) | Highest | Best visual outcome, far outside this project's shipped JS footprint (currently one `visEvents(click=...)` one-liner) |

**Decision: Option 1 + Option 0 together for v1** (§3 D3) — reasoning is in §3, not repeated here.

### 2.4 Existing fixtures and the RED-phase testing pattern to reuse

No CSV or bundled `.RData` fixture anywhere in the package carries an affected-status column today
(confirmed this session: `grep -rn "affected" R/ tests/testthat/ inst/extdata/examples/` returns
zero real hits — only the unrelated word "un**affected**"), matching the issue's own note exactly.

| File | Rows | Columns | Role |
|---|---|---|---|
| `inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv` | 375 | `id,sire,dam,sex,gen,birth,exit,age` | **The** fixture reused across nearly every e2e/`shinytest2` test and many unit tests; 248F/127M/0 other-code, no `H`/`U` in real data |
| `inst/extdata/examples/rhesusPedigree_fromCenter.csv` | 375 | same + `fromCenter` | Byte-identical animal data to the file above (BACKLOG.md finding B8) |
| `inst/extdata/examples/ExamplePedigree.csv` | 3,694 | `id,sire,dam,sex,gen,birth,exit,age,ancestry,origin,status` | Source of the bundled `examplePedigree` object |
| Bundled `data/*.RData` (`smallPed` 17 rows, `pedSix`/`pedGood` 8 rows, etc.) | ≤17 | Varies | Hand-built tiny fixtures, unit tests only |

`tests/testthat/test_makePedigreeDiagramData.R` (confirmed read this session, lines 96-185, the
issue #135 test block) is the direct RED-phase precedent: small, inline `data.frame()` literals
built per `test_that()`, e.g. a 3-row founders+child trio with `sex = factor(c("M","F","M"),
levels=c("F","M","H","U"))`. An `affected` column slots into this exact pattern with zero new test
infrastructure.

### 2.5 Column-naming collision check (this session's own follow-up, beyond the 5 research agents'
scope)

Before finalizing D1's column name, this session independently checked whether nprcgenekeepr's
*existing* schema (`.nprcColumnSchema$possible` in `R/columnSchema.R`) already has a column that
means, or could be repurposed to mean, "affected/phenotype/genotype status" — since a same-named or
near-same-meaning existing column would change the whole design. It does not, but two existing
columns are close enough in name to be worth explicitly ruling out:

- **`condition`** (`R/getPossibleCols.R:39`, `R/qcStudbook.R:41` roxygen): *"character vector or
  `NA` (optional) that indicates the **restricted status** of an animal. 'Nonrestricted' animals are
  generally assumed to be naive."* This is a research-protocol/colony-management concept (SPF-study
  eligibility), unrelated to disease/genotype status. It is recognized in the schema and has a UI
  display name (`headerDisplayNames.R:44`, `"Condition"`) but **is not consumed anywhere else in the
  codebase** (no reference in `modPedigree.R`, `makePedigreeDiagramData.R`, or any test beyond the
  schema-pin tests) — effectively a reserved-but-unwired column. **Do not repurpose it for #133** —
  the semantic mismatch would be a real defect, not just a naming preference.
- **`status`** (`R/getPossibleCols.R:36`, `R/convertStatusCodes.R`): factor with levels `ALIVE`,
  `DECEASED`, `SHIPPED`, `UNKNOWN` — this project's existing vital-status concept, and it maps
  cleanly onto kinship2's own **separate** `status` argument (§2.1), not kinship2's `affected`.
  Confirms the two projects' domain vocabularies already agree here by coincidence; no action needed,
  but a future reader should not confuse this project's `status` with kinship2's `affected`.

Neither existing column is a fit. A genuinely new `affected` column is required, exactly as the
original audit and issue #133 assumed — this check closes off "did we miss an existing home for
this" as a possibility rather than leaving it implicit.

---

## 3. Design decisions

**D1 — Column name and type: `affected`, logical (`TRUE`/`FALSE`/`NA`).**
Matches kinship2's own argument name exactly (owner's S436 naming-overlay directive, §1.2) and
converts to kinship2's 0/1 encoding for free if this project's own data model is ever fed into a
kinship2 call. Logical needs no factor-level table and mirrors this project's own existing
logical-column precedent (`population`, `fromCenter`).
*Declined:* reusing `condition` (§2.5 — different concept, restricted/research-protocol status, real
semantic collision risk). *Declined:* reusing/repurposing `status` (§2.5 — already means vital
status, and correctly maps onto kinship2's own separate `status` concept instead). *Declined:*
factor type (logical already gets kinship2's own accepted-input coercion for free per §2.1; a factor
adds a level table for no present benefit).

**D2 — v1 scope: a single trait, not a multi-column matrix.**
Nothing in issue #133's own framing ("affected by a condition of interest") or this project's actual
use case calls for more than one trait in v1. kinship2's own multi-column convention is confirmed
(§2.1) to be a plotting/legend-layer affordance that its own analytic layer (`pedigree.shrink()`,
`findAvailAffected()`) doesn't consistently support either — so "match kinship2" does not obligate a
matrix here. *Declined:* pre-building `affected`/`affected2`/`affected3`/`affected4` columns upfront
— speculative multi-trait support with no identified need is the astronaut-architecture anti-pattern
(`ARCHITECTURE_WORKSTREAM.md` #2); a second trait, if it ever arises, is a purely additive v2 column
with no breaking change to v1's contract.

**D3 — Rendering: Option 1 (single dominant-trait `color.background`) + Option 0 (tooltip line),
shipped together.**
Zero new dependencies, zero custom JS, trivially unit-testable as a plain data-frame column
assertion, and reuses the exact `color.*`-column idiom already shipped and proven in
`.addRectilinearWaypoints()` (§2.2) — maximally consistent with this project's established
"compose with existing visNetwork capability" convention (#131/#135's own precedent, per the house
style at §2 of the research). *Declined:* Option 2 (dual-channel color+border) — no second trait to
encode yet (D2 makes this moot for v1; revisit only if/when a real second trait is added).
*Declined:* Option 3 (SVG pie data-URI via `shape="image"`) — the `shape` channel is already spoken
for by sex (#129's own convention); repurposing it would force a redesign of #132's already-shipped
shape-to-sex legend, disproportionate to an audit whose own disposition was "no action in the
immediate term." *Declined:* Option 4 (`ctxRenderer` custom canvas glyph) — the only option that
preserves both channels at full kinship2 fidelity, but requires real hand-written JavaScript (arc
math, hit-testing, redraw-on-hover) far beyond this project's shipped JS footprint (currently one
`visEvents(click=...)` one-liner) and is difficult to cover under this project's strict `R`/`testthat`
TDD contract — correctness would live inside a JS string, verifiable mainly via `shinytest2`
renders, not unit assertions.

**D4 — Implement in *both* `makePedigreeDiagramData()` and `makePedigreeMatingLayout()`, following
the issue #135 precedent exactly (duplicated logic, not shared).**
`makePedigreeMatingLayout()` is what actually renders the live Diagram tab (§2.2); stopping at
`makePedigreeDiagramData()` alone would ship a feature invisible in the app. This matches how #135's
hover tooltips already had to be implemented in both places. *Declined: de-duplicate the two
functions first.* A cross-module refactor requires its own `SAFEGUARDS.md`-gated plan-mode session
(`ARCHITECTURE_WORKSTREAM.md`'s Refactor Heuristics — the Deletion Test would need to run as its own
exercise, not folded into a feature session) and is explicitly out of scope here; flagged as
pre-existing technical debt in §8 Dragon #1, not fixed inline (`SAFEGUARDS.md` §The Two-Mode
Problem — spotting a shallow/duplicated module mid-feature is a mode-switch trigger, not license to
refactor).

**D5 — Fixture strategy: a new sibling CSV, not an in-place column add.**
Add `inst/extdata/examples/obfuscated_rhesus_mhc_ped_affected.csv` — the same 375 already-obfuscated
individuals (`id`/`sire`/`dam`/`birth` reused verbatim, no fresh obfuscation pass needed) plus one
fabricated `affected` column (~20% `TRUE` / ~70% `FALSE` / ~10% `NA`, seeded RNG documented in a new
`data-raw/*.R` script, explicit "100% fabricated, not derived from any real record" disclosure
matching the `a2interactive.Rmd` synthetic-pedigree footnote precedent). *Declined:* adding `affected`
directly to the existing `obfuscated_rhesus_mhc_ped.csv` — that file is read by roughly 20 existing
test files, several of which pin exact column/row counts; an in-place add risks silently perturbing
tests unrelated to this feature. A sibling file isolates the change to only the tests that opt into
it. RED-phase unit tests use the existing small-inline-`data.frame()` pattern (§2.4), not this
fixture — the sibling CSV's role is live/e2e smoke verification (Phase 3E) and any GREEN-phase test
that wants realistic scale.

**D6 — Legend: extend the single existing `visLegend()`/`addNodes` call with one new row, not a
second panel.**
`visLegend()`'s R source assigns `graph$x$legend` as a single scalar slot — a second call overwrites
rather than stacks (confirmed by this session's research reading `R/modPedigree.R:476-497`, the
issue #132 legend). The new "Affected" swatch must be an additional row in the *same* `addNodes`
data frame passed to the one `visLegend()` call already present.

**D7 — `status` (vital/deceased) stays explicitly out of scope.**
kinship2's `status` argument (§2.1) and this project's own existing `status` column (§2.5) are both
distinct, pre-existing, unrelated concepts. This document does not touch either — a future session
should not conflate "wire up affected-status shading" with "wire up vital-status shading," which
would be a different, separately-scoped feature.

**D8 — Exact fill color(s) are a Pre-RED decision for the implementing session, not fixed here.**
No shared, documented colorblind-safe node palette exists for the Diagram tab today (checked this
session: only ad hoc inline hex values scattered across UI panel backgrounds, e.g.
`R/modPedigree.R`'s own `#EDEDED` panel background, and `makePedigreeDiagramData.R:1010`'s
`edgeColor <- "#2B7CE9"` for waypoint edges — neither is a reusable "affected" token).
*Recommendation for the implementing session's Pre-RED, not a ratified decision:* pick a single
accessible hex distinct from (a) the Genetic Value Analysis heatmap's existing red/yellow/green
risk-level convention (`makeGeneticDiversityHeatmap.R`) — reusing those colors here would create a
false cross-tab association between "affected" and "genetic-diversity risk," and (b) the existing
`#2B7CE9` waypoint-edge blue. This is a visual-design judgment call (`DESIGN_WORKSTREAM.md` territory,
not architecture) deliberately left open rather than invented without evidence.

---

## 4. Implementation plan — vertical slices (one session each)

```
Slice 1 (data model + core rendering, both functions)
  `-- Slice 2 (legend + documentation)  -- depends on Slice 1 shipping a real `affected` column
```

### Slice 1 — Data model + core rendering

**Scope:** `affected` becomes a recognized, optional column; both `makePedigreeDiagramData()` and
`makePedigreeMatingLayout()` render it (Option 1 dominant-color + Option 0 tooltip line, D3/D4); the
new sibling fixture (D5) exists for live verification.

**What does NOT change:** the required-column guard in either function (still exactly
`id,sire,dam,sex,gen`); the shape-to-sex encoding; `R/appServer.R`/`R/modInput.R`/`R/qcStudbook.R`/
`R/checkRequiredCols.R`/`R/fixColumnNames.R` (§2.2 — no change needed for graceful optional-column
pass-through); the base `obfuscated_rhesus_mhc_ped.csv` fixture (D5 — sibling file, not an in-place
edit).

**Files to touch:**
- `R/columnSchema.R` — add `"affected"` to `.nprcColumnSchema$possible` (D2: single column, not 4).
  Decide at Pre-RED whether it also joins `include` (propagates into `reportGV()`/
  `gvaConvergence()`-driven outputs) — default recommendation: **not included** for v1 (display-only
  on the Diagram tab; §5 notes this as an open, deliberately-deferred question, not silently
  skipped).
- `R/getPossibleCols.R` — new `\item{affected}{...}` roxygen entry, matching the existing entries'
  style exactly (e.g. the `condition`/`spf` entries).
- `tests/testthat/test_getPossibleCols.R` — the exact-value `expect_identical()` pin must be updated
  in the same commit (§2.4 confirms this test exists and pins the full vector literally).
- `R/makePedigreeDiagramData.R:25-78` — optional-column branch: `if ("affected" %in% names(ped))`
  sets `nodes$color.background` for `TRUE` rows (D8 color TBD) and appends an "Affected: Yes/No/
  Unknown" line to each node's `title` (D3 Option 0); absent column ⇒ zero change to current output
  (backward compatible with every existing fixture/test). **Error contract:** the branch should
  defensively coerce via `as.logical(ped$affected)` rather than assume the caller already supplied a
  true logical vector — `affected` is not yet a recognized column in `qcStudbook()`'s possible-column
  list (§2.2), so a raw CSV import could hand it a character `"TRUE"`/`"FALSE"`/`"yes"`/`"no"` column;
  `as.logical()` handles the R-native spellings for free and coerces anything else to `NA` (matching
  kinship2's own "missing is fine, `NA`-tolerant" contract, §2.1) rather than erroring on an unusual
  input.
- `R/makePedigreeDiagramData.R:765-927` (`makePedigreeMatingLayout()`) — the equivalent branch inside
  `realNodes`/`dupNodes` construction (lines 821-841); `unitNodes` (the abstract mating-union glyph,
  lines 843-855) does **not** get `affected` coloring — it represents a union, not an individual.
- `tests/testthat/test_makePedigreeDiagramData.R` — RED: new `## Issue #133` block following the
  #135 pattern (§2.4, lines 96-185): field presence, `TRUE`/`FALSE`/`NA` → correct `color.background`
  presence/absence, tooltip content for each of the three states, and confirmation that an input
  `ped` with **no** `affected` column produces byte-identical output to today's (backward-compat
  regression guard).
- `tests/testthat/test_makePedigreeMatingLayout.R` — equivalent RED tests for the layout function,
  since it has its own independent implementation (D4).
- `data-raw/<new script>.R` + `inst/extdata/examples/obfuscated_rhesus_mhc_ped_affected.csv` (D5) —
  seeded-RNG fabricated `affected` column, documented disclosure header.

**RED:** write all unit tests above against functions/columns that don't exist yet; confirm they fail
for the right reason (missing column/field), not a typo or setup error.

**GREEN:** implement exactly enough to pass — the optional-column branch in both functions, the
schema entry, the new fixture script. No legend change, no documentation change (Slice 2).

**DONE looks like:** `devtools::check()` 0 errors/0 warnings; new unit tests pass; the full clean
regression read (`CLAUDE.md`'s documented recipe) shows no new failures; a live `shinytest2`/
`chromote` smoke test against the new sibling fixture confirms the Diagram tab visibly shades
`affected=TRUE` individuals differently from `FALSE`/absent, with no console error; loading the
*existing* `obfuscated_rhesus_mhc_ped.csv` (no `affected` column) renders pixel-for-pixel unchanged
from today (backward-compat spot check, not just a unit-test assertion).

**Verify:** targeted test file runs (both new test files); full clean regression read; full
`devtools::check()`; live `shinytest2`/`chromote` E2E smoke test per Phase 3E, on both the new sibling
fixture (affected coloring visible) and the base fixture (no visual change).

**Session boundary:** this slice is one session. Close out when Slice 1's DONE criteria are met.
Slice 2 is a separate future session.

### Slice 2 — Legend + documentation

**Scope:** extend the existing `visLegend()` call with an "Affected" swatch row (D6); documentation
checklist obligations (D-nothing new here, just execution of standing checklists).

**What does NOT change:** `makePedigreeDiagramData()`/`makePedigreeMatingLayout()`'s own rendering
logic (Slice 1 already shipped it) — this slice is UI-discoverability + docs only.

**Files to touch:**
- `R/modPedigree.R:476-497` (`visLegend()`/`addNodes`) — one new row (label + the same color used in
  Slice 1's D8 choice), added to the *same* `addNodes` data frame (D6 — never a second `visLegend()`
  call).
- `tests/testthat/test_modPedigree.R` — widget-JSON assertion following the #132 legend test's own
  pattern (grep the serialized JSON payload for the new label/color, same file, cite the existing
  #132 test's line range at Pre-RED).
- `NEWS.Rmd` — new entry in the current development-version section (`CLAUDE.md`'s checklist).
- `vignettes/manual_components/_pedigree_browser.Rmd` and/or `vignettes/articles/
  colony-manager-guide.qmd` — describe the new affected-status shading + legend entry (owner's
  comment on #133; `CLAUDE.md`'s tutorial/article checklist).
- `inst/extdata/ui_guidance/population_genetics_terms.html` + the new schema entry's `@references` —
  **only if** the implementing session judges `affected` a new *displayed statistic/estimator*
  (issue #120's citation checklist trigger); this document's own read is that a raw input flag is
  not a computed statistic and likely does **not** trigger this checklist, but the Pre-RED should
  confirm rather than silently skip it (§5).
- `BACKLOG.md` — remove/close this cluster's #133 tracking line; `gh issue close 133` with a comment
  citing the shipping commit(s), per the GitHub issue close-out checklist.

**RED:** widget-JSON legend test (new row present, correct label/shape/color) written against the
not-yet-changed `visLegend()` call; confirm it fails.

**GREEN:** the `addNodes` row addition; documentation edits (docs aren't RED/GREEN-gated the same
way, but should land in the same session per the standing checklists, matching the issue142/issue130
precedent of folding documentation into the shipping slice rather than deferring it).

**DONE looks like:** `devtools::check()` 0 errors/0 warnings; new widget-JSON test passes; full clean
regression read unchanged; live `shinytest2`/`chromote` smoke test confirms the legend panel renders
the new row without breaking the existing 5 sex-legend rows or the "Export Diagram (PNG)" button
beneath it (per the existing `width`/`stepY` tuning notes in `R/modPedigree.R`, a 6th row may need
its own `stepY` re-tune — flagged in §8 Dragon #4); `NEWS.Rmd`/tutorial-article entries exist;
`BACKLOG.md`/issue #133 closed.

**Verify:** targeted test run; full clean regression read; `devtools::check()`; live E2E smoke test;
citation-checklist judgment call recorded explicitly (not silently skipped) per §5.

**Session boundary:** this slice is one session, and depends on Slice 1 having shipped (needs a real
`affected` column and its chosen color to reference). Close out when Slice 2's DONE criteria are met.

---

## 5. Cross-slice notes

- **Documentation checklists, named explicitly, owed same-session as the user-visible change (not
  deferred):** `CLAUDE.md`'s "Tutorial/article documentation checklist" (Session 436) and "NEWS.Rmd
  entry checklist" (Session 448) both apply to Slice 2, the session that ships the user-visible
  legend/shading. Issue #139 (the standing cautionary precedent — issue #129's own Diagram tab
  shipped with zero tutorial coverage for a full session before being caught) is the reason this is
  called out rather than assumed.
- **Column-schema `include` question is deliberately left open, not silently defaulted.** Slice 1's
  Pre-RED should explicitly decide (and record the reasoning, even if the answer is "no, not yet")
  whether `affected` joins `.nprcColumnSchema$include` — this document's own recommendation is "not
  yet" (display-only v1, §4 Slice 1), but this is a real design choice with downstream consequences
  (`reportGV()`/`gvaConvergence()` output columns) that a future session should not silently inherit
  without re-confirming it's still the right call.
- **Citation checklist (issue #120) applicability is a judgment call, not a silent skip.** This
  document's read (§4 Slice 2) is that a raw display flag isn't a "new displayed statistic/
  estimator" in the sense issue #120 targets — but the implementing session should state that
  conclusion explicitly in its own close-out rather than simply not mentioning the checklist at all
  (matching this project's own "report, don't silently omit" convention for judgment calls).
- **`a2interactive.Rmd` demonstration is out of scope for both slices**, per `CLAUDE.md`'s own
  "deferred, not same-session" `a2interactive.Rmd` checklist — a future dedicated documentation pass
  adds a demonstration section once the feature has stabilized, not either shipping session.

---

## 6. Impact Analysis

| System | Impact | Action Required |
|---|---|---|
| `makePedigreeDiagramData()` (exported) | New optional output field (`color.background` on affected nodes) when `affected` is present in input; byte-identical output when absent | Slice 1 |
| `makePedigreeMatingLayout()` (exported, live-wired) | Same, independently implemented (D4) | Slice 1 |
| Diagram tab (`R/modPedigree.R`) | Visible shading on affected individuals once fixture/real data carries the column; legend gains one row (Slice 2) | Slice 1 (rendering) + Slice 2 (legend) |
| Genetic Value Analysis / Marker Genetics / Breeding Groups tabs | None — `affected` reaches `shared$currentPedigree` automatically (§2.2) but nothing there consumes it unless `include` is later opted in (§5) | None, unless a future session opts `affected` into `include` |
| `qcStudbook()` / `fixColumnNames()` / `checkRequiredCols()` | None — confirmed this session these already pass unknown columns through untouched | None |
| Existing test suite (~20 files reading `obfuscated_rhesus_mhc_ped.csv`) | None if D5 (sibling fixture) is followed | Slice 1 — verify with the full clean regression read, not just the new tests |
| `visExport()` PNG export (issue #131) | Low risk — Option 1 only sets `color.background`, not `shape`/`image`; html2canvas already renders solid-fill nodes correctly today | Spot-check at Slice 1's Phase 3E live verification (§8 Dragon #3) |
| kinship2 interoperability | None — this project does not currently construct `kinship2::pedigree()` objects from its own data; D1's naming choice is forward-compatible if that ever changes | None |

---

## 7. Verification Plan

- **Slice 1:** targeted `test_makePedigreeDiagramData.R` + `test_makePedigreeMatingLayout.R` runs;
  full clean regression read (`CLAUDE.md`'s documented recipe, `!grepl("test-app-|test-e2e-", file)`
  isolation); `devtools::check()` 0 errors/0 warnings; live `shinytest2`/`chromote` smoke test on both
  the new sibling fixture (shading visible) and the base fixture (no visual change) — this dual check
  is the backward-compatibility proof, not just a unit-test assertion.
- **Slice 2:** targeted `test_modPedigree.R` run; full clean regression read; `devtools::check()`;
  live `shinytest2`/`chromote` smoke test confirming the 6-row legend renders correctly (no clipping,
  matching #132's own hands-on-tuned `width`/`stepY` precedent) and the Export/search/hover features
  shipped by #131/#135 remain unaffected.
- **Both slices:** this document's own `AskUserQuestion` ratification record (below) stands as the
  Pre-RED scope-decision gate `CLAUDE.md`'s Development Process Contract requires before either
  slice's implementing session declares RED.

---

## 8. Here be dragons

1. **The `makePedigreeDiagramData()`/`makePedigreeMatingLayout()` duplication is real and this
   design deliberately extends it rather than fixing it (D4).** A future implementing session must
   write the affected-status branch twice, once per function, and must resist the temptation to
   "just deduplicate while I'm in here" — that is a cross-module refactor requiring its own
   `SAFEGUARDS.md`-gated plan-mode session, not a corollary of this feature.
2. **D8's exact fill color is not fixed by this document.** The Slice 1 implementing session's
   Pre-RED must pick one, explicitly avoiding the GVA heatmap's red/yellow/green convention and the
   existing `#2B7CE9` waypoint-edge blue (§3 D8) — an uncritical color choice risks a false semantic
   association with an unrelated tab's existing color language.
3. **`visExport()`'s html2canvas PNG capture is not hands-on re-verified for a `color.background`-only
   node in this session** — Option 1 was deliberately chosen partly *because* it avoids the
   `shape`/`image` channel risk that Options 3/4 would have carried here, but Slice 1's Pre-RED
   should still do a quick live spot-check (export a diagram with an affected node, confirm the PNG
   shows the color) rather than assume solid-fill compatibility is automatic.
4. **A 6th legend row may not fit the existing tuned `width`/`stepY` values without adjustment.**
   `R/modPedigree.R`'s current `visLegend()` call (`width=0.28`, `stepY=65L`) was hands-on-tuned for
   exactly 5 rows (§2.2/D6) — Slice 2's Pre-RED should verify a 6th row renders without clipping
   before assuming the existing tuning just works.
5. **This document's kinship2-source research relied on deparsing the installed package's compiled
   closures** (no plain-text `R/*.R` ships in the installed 1.9.6.2 build) rather than reading a
   pristine source tarball. Cross-validated against the package's own vignette prose and confirmed
   empirically against live function calls this session, but a future session that wants to
   re-verify a specific claim should know the citation format (`pedigree_src.R:NNN`) refers to a
   deparsed reconstruction, not an original file — re-run `asNamespace("kinship2")$pedigree` locally
   rather than searching for a matching line in a downloaded kinship2 source tree.

---

## Owner ratification record

- [x] D1 — column name/type: `affected`, logical
- [x] D2 — v1 scope: single trait, not a matrix
- [x] D3 — rendering: Option 1 (dominant-color) + Option 0 (tooltip)
- [x] D4 — implement in both `makePedigreeDiagramData()` and `makePedigreeMatingLayout()`
- [x] D5 — fixture strategy: new sibling CSV
- [x] D6 — legend: one new row in the existing `visLegend()` call
- [x] D7 — `status`/vital-status stays out of scope
- [x] D8 — exact fill color deferred to Slice 1's own Pre-RED
- [x] Slice boundary: Slice 1 (data model + core rendering) / Slice 2 (legend + documentation), as
      described in §4

_Ratified via `AskUserQuestion`, Session 485, 2026-08-08 — approved as written, no changes
requested._
