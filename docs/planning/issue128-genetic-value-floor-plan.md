# Issue #128 Plan — Genetic-value floor as an alternative breeding-group inclusion criterion

**Tracks:** GitHub issue **#128** (filed S422, 2026-07-29, from
`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md` Dimension 2 / the
audit's Summary item #8). Distinct from issue #125 (ranking-priority scheme + multiple
breeding-group candidates) — issue #128's own body confirms no overlap: "specifically
about the breeding-group *inclusion threshold mechanism*, not the ranking scheme or
candidate-group multiplicity." Both of #125's slices are already shipped (S424/S425,
closed).

**Authored:** Session 426 (2026-07-29), **planning session**. TDD phases (RED/GREEN/
REFACTOR) are inapplicable to this document — it is a plan, per this project's own
S423 precedent for the sibling issue #125 plan. The one implementation slice below is
its own strict-TDD session (RED -> GREEN -> REFACTOR).

**Evidence base:** a 4-agent research workflow (`wf_9eb79cd3-488`) read every file in
scope firsthand, current on-disk state (post issue #125 Slices 1 and 2) —
`R/modBreedingGroups.R` (entire, 631 lines), `R/modGeneticValue.R` (entire, 546 lines),
`R/appServer.R` (lines 300-429), `R/orderReport.R`, `R/rankSubjects.R`, `R/reportGV.R`,
`R/groupAddAssign.R`, `R/groupMembersReturn.R`, `R/filterThreshold.R`, `R/filterPairs.R`,
`R/filterAge.R`, `R/getAnimalsWithHighKinship.R`, `docs/architecture/module-contract.md`,
`tests/testthat/test_modBreedingGroups.R`, plus a full repo grep for every "top-N"/
"top 20"/literal-default-20 hit in a breeding-group context. This session's own
follow-up read of `R/reportGV.R:144-149` confirmed a population-scope nuance the
workflow didn't surface on its own (§2C, §6 Dragon P1).

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `man/`, `NAMESPACE`,
> or `data/` content is changed by writing it.**

> **RATIFIED this session (2026-07-29), via `AskUserQuestion`.** See §7 for the record.
> §3 documents the ratified decisions directly (not as open recommendations) since
> ratification happened before this document was written.

---

## 1. Context

### What issue #128 says

> The 2015 NHP Genetics and Genomics Working Group PDF recommends threshold-based
> exclusion of low-genetic-value animals from breeding-group formation.
> `nprcgenekeepr` currently offers only a **top-N** cutoff (`R/modBreedingGroups.R:40-
> 53,253-258`, default 20) on the ranked id list — not a genetic-value floor. A
> mediocre top-20 (by colony-wide standards) all pass regardless of absolute genetic
> value, and conversely a genuinely viable animal ranked just outside the top-N is
> excluded regardless of its actual value.
>
> **Scope note:** this is a design question, not a quick fix — does a value floor
> replace top-N, supplement it (both constraints applied), or become a user-selectable
> alternative? Needs a design decision before implementation.

### What this session's research confirmed and corrected about the picture

- **Citation drift, already corrected here.** The audit/issue's `:253-258` half no
  longer points at the top-N logic (those lines are now just the comment block
  introducing `runFormation <- eventReactive(...)`). The actual cutoff logic today
  lives at **`R/modBreedingGroups.R:269-275`**. This plan cites the current lines
  throughout §2.
- **The top-N slice is purely positional.** It never reads `rank` or `value` — it
  trusts whatever row order `geneticValues()` left the report in (§2A). Under the
  app's default "combined" ranking scheme, the row order and the `value` label can
  disagree (§2C) — worth knowing since this plan's floor design reuses `value`.
- **No genetic-value floor exists anywhere in the group-formation call chain today**
  — confirmed by reading `groupAddAssign()`'s full parameter list and all three
  existing filters (`filterThreshold`/`filterPairs`/`filterAge`): every one of them
  screens by kinship, sex, or age. None reads `gu`, `zScores`, or `value` (§2B).
- **A signal already exists to reuse, from issue #125 Slice 1.** `guCutoff`/
  `zScoreCutoff` (added to `orderReport()`/`reportGV()`) already materialize a `value`
  column (`"Low Value"` iff an animal fails both cutoffs) that is stable across
  ranking schemes (§2C) — a floor does not need a new numeric concept.
- **Side finding, out of scope for this plan.** The "Upload list" (`custom`)
  `animalSource` radio choice has no `fileInput` or handling anywhere in
  `modBreedingGroups.R` — selecting it silently behaves identically to "All
  available." This plan's design does not fix that gap (a pre-existing, unrelated
  defect); it only means that today, "Upload list" and "All available" are the same
  code path, so this plan's "applies to all three sources" decision (§3 D4) affects
  them identically until that separate gap is fixed. Recommend filing it as its own
  small issue, not folding it in here.

### Prior process history (relevant precedent, reused throughout)

- Issue #125's planning session (S423) established this project's pattern for a
  "design question, not a quick fix" issue: research workflow first, ratify the
  load-bearing decisions via one `AskUserQuestion` call, then write the plan. This
  document follows that same pattern (§7).
- Issue #125 Slice 1 (S424) established the `NULL`-defaulting-parameter convention
  this plan's `value` column depends on (`guCutoff`/`zScoreCutoff`, resolved once
  inside `orderReport()`'s own body — see that plan's Dragon R2 for why). This plan
  does not touch `orderReport()` again; it only *reads* the `value` column that
  mechanism already produces.
- Issue #125 Slice 2 (S425) established the `req(geneticValues())` / backward-compat-
  by-default pattern this plan reuses for the new `inclusionCriterion` control (§4).

---

## 2. Evidence-based inventory (firsthand, this session's research workflow)

### 2A. `R/modBreedingGroups.R` — current top-N mechanism, exact lines

UI (`modBreedingGroupsUI()`):
```r
40  radioButtons(ns("animalSource"), "Source:",
41               choices = c("Top ranked" = "topRanked",
42                           "Upload list" = "custom",
43                           "All available" = "all")),
44  conditionalPanel(
45    condition = "input.animalSource == 'topRanked'",
46    ns = ns,
47    numericInput(ns("nTopAnimals"), "Number of top animals:",
48                 value = 20L, min = 5L, max = 100L)
49  ),
```
(line numbers 44-53 in the audit's original citation; the block above spans 40-49/53
depending on comment lines — content confirmed unchanged since the audit.)

Cutoff application, inside the single `runFormation <- eventReactive(input$formGroups,
{...})` block (lines 259-412) — a local variable, not a separate reactive:
```r
269  candidateIds <- if (input$animalSource == "topRanked") {
270    req(geneticValues())
271    gv <- geneticValues()
272    gv$id[seq_len(min(input$nTopAnimals, length(gv$id)))]
273  } else {
274    ped$id
275  }
```
- `gv$id[...]` is a **positional head-slice** of whatever order `geneticValues()` left
  the report in — no re-sort, no `rank`/`value` read.
- `candidateIds` is mutated once more, unrelated to the cutoff, at line 323
  (`candidateIds <- setdiff(candidateIds, unlist(currentGroups))`), then passed to
  `groupAddAssign(candidates = candidateIds, ...)` at line 349.
- The other two `animalSource` choices (`"custom"`, `"all"`) both fall through to
  `ped$id` — **every** pedigree id, no genetic-value filtering of any kind today.
- `geneticValues` is an optional reactive parameter to `modBreedingGroupsServer()`
  (documented lines 154-156, declared 198-200): "optional reactive returning genetic
  value results from `modGeneticValueServer()` ... unrelated to kinship."
- Robustness gap (pre-existing, not introduced by this plan): `min(input$nTopAnimals,
  length(gv$id))` bounds the upper end only; an `NA`/negative `nTopAnimals` would
  error inside `seq_len()` rather than degrade gracefully. Not in this plan's scope
  to fix, noted for awareness only.

### 2B. `groupAddAssign()` / filter chain — confirmed: no existing genetic-value filter

`groupAddAssign()`'s full signature (`R/groupAddAssign.R:130-138`):
```r
groupAddAssign <- function(candidates, kmat, ped, currentGroups = list(character(0L)),
                           threshold = 0.015625, ignore = list(c("F", "F")),
                           minAge = 1.0, iter = 1000L, numGp = 1L, harem = FALSE,
                           sexRatio = 0.0, withKin = FALSE, updateProgress = NULL) {
```
- `threshold` (default `0.015625`) — a **pairwise kinship** floor (relatedness), not
  an individual genetic-value floor.
- `minAge` (default `1.0`) — an **age** floor on which kinship *pairs* count.
- `ignore`/`harem`/`sexRatio` — **sex**-based constraints.
- None of the 11 parameters references `gu`, `zScores`, or `value`. Confirmed by
  grepping `groupAddAssign.R`/`groupMembersReturn.R`: neither calls or references
  `reportGV()` anywhere.

The three existing filters, called from `getAnimalsWithHighKinship()`
(`R/getAnimalsWithHighKinship.R:41-59`, invoked from `groupAddAssign.R:146-149`):
- `filterThreshold()` (`R/filterThreshold.R:28-34`) — filters the long-format pair
  table by **pairwise kinship coefficient**.
- `filterPairs()` (`R/filterPairs.R:34-64`) — filters by **sex combination** of the
  pair.
- `filterAge()` (`R/filterAge.R:17-34`) — filters by **age** of both pair members.

All three operate on the long-format `(id1, id2, kinship)` pair table — a
per-**relationship** shape. A genetic-value floor is a per-**animal**, unary
predicate ("is this one animal's own value below the floor?") that does not fit that
pair-table shape and does not need the kinship-pair machinery at all.

**Design implication (this plan's call, not escalated to the owner — an
implementation-architecture detail, not a preference):** the floor is implemented as
a pre-filter on the plain `candidateIds` character vector, **in `modBreedingGroups.R`,
before calling `groupAddAssign()`** — not as a new `groupAddAssign()` parameter.
Rationale: `groupAddAssign()` is an exported, documented package function usable
outside Shiny; the `value` column it would need to filter on is a
`reportGV()`/Shiny-reporting-layer concept, not something a bare `candidates`-vector
caller should be forced to understand. `groupAddAssign()` already treats `candidates`
as a finished, pre-computed list (exactly as today) — zero signature change, zero new
test burden on that exported function's documented contract.

### 2C. Ranking fields available (post issue #125) and the population-scope nuance

`reportGV()` builds `finalData <- cbind(demographics, indivMeanKin, zScores, gu,
guSE, offspring, parentage)` (`R/reportGV.R:293-295`), then `orderReport()` /
`rankSubjects()` add `value` and `rank`:
- `value` (`R/rankSubjects.R:41-47`): `"Low Value"` (fails both axis cutoffs),
  `"Undetermined"` (both-unknown parentage, no recorded origin — a data-quality
  bucket), `"High Value"` (everything else). **Stable regardless of `axisPriority`**
  (only decides *which* tier a dual-qualifying animal is filed under, not whether it
  lands in `lowVal` at all — `R/orderReport.R:97-100`) and **stable regardless of
  `rankScheme`**: the app's default "combined" scheme (`R/modGeneticValue.R:341-348`)
  overrides `report$rank` with `rank(indivMeanKin - gu)` and re-sorts, but **never
  touches `report$value`** — it survives from `orderReport()`/`rankSubjects()`
  unchanged either way. This is exactly why `value` is the right, already-stable
  signal to reuse (ratified §3 D2).
- Existing per-axis cutoffs from issue #125 Slice 1: `guCutoff` (default `10L`,
  `gu > guCutoff`) and `zScoreCutoff` (default `0.25`, `zScores <= zScoreCutoff`) —
  `R/orderReport.R:20-30,43-55`. An animal is `"Low Value"` iff it fails **both**.

**Population-scope nuance (found this session, not in the workflow's own report —
flagged as Dragon P1, §6):** `reportGV()` restricts its `probands` to
`ped$id[ped$population]` (`R/reportGV.R:144-149`), and `getGVPopulation()` /
`modGeneticValue.R:268-278` default that population to **all living animals**
(`ped$population <- is.na(ped$exit)`) unless the user has explicitly narrowed it via
`pop`. So `geneticValues()$id` is **not** guaranteed to cover every id in `ped$id` —
deceased animals, in particular, are excluded from the GV report by default. Since
`animalSource == "all"` sets `candidateIds <- ped$id` (**every** pedigree animal,
living or not), a "genetic-value floor" applied to that pool will routinely
encounter ids absent from `geneticValues()$id` entirely — a materially different
case from the `"Undetermined"` label (§3 D3), which only applies to ids **present**
in the report. This needs an explicit, tested decision in the implementing session
(recommendation below, §4 RED).

Module wiring — a shared `reactiveValues` bridge, not a direct return-value
consumption (`R/appServer.R`):
```r
47   shared <- reactiveValues(..., geneticValues = NULL, ...)
...
317  gvResults <- modGeneticValueServer("geneticValue", ...)
...
324  observe({
325    req(gvResults$geneticValues())
326    shared$geneticValues <- gvResults$geneticValues()
327  })
...
404  bgResults <- modBreedingGroupsServer("breedingGroups", ...,
407                                       geneticValues = reactive(shared$geneticValues), ...)
```
`shared$geneticValues` starts `NULL` and stays `NULL` until the user has run the
Genetic Value Analysis tab at least once. Today, only the `"topRanked"` branch gates
on `req(geneticValues())` (line 270); `"custom"`/`"all"` need no GV run at all. This
plan's floor mode necessarily adds a `req(geneticValues())` gate to those two
branches too, but **only when the floor is actually selected** (§4) — preserving
today's "form groups from all available animals with zero GV run" workflow when the
new control is left at its default.

### 2D. Module contract conventions (`docs/architecture/module-contract.md`)

Six rules (lines 24-45): (1) every server data argument is a `reactive()`; (2) every
returned element is a `reactive()`; (3) stable, canonical vocabulary, never renamed
per-consumer; (4) a returned reactive must have a real consumer; (5) `req()` for
upstream *absence*, but upstream *malformedness* must surface as a real error — no
blanket `tryCatch(..., error = function(e) NULL)` at a module seam; (6) every declared
parameter is read, every returned element documented. No separate UI-vs-config-file
policy exists beyond "either way, wrap it in `reactive()`" (Rule 1). This plan adds no
new returned reactive to `modBreedingGroupsServer()` — the new control is purely an
internal `input$` read feeding the existing `candidateIds` computation — so Rules 2-4
are not implicated; Rule 1 (`geneticValues` already arrives as a `reactive()`) and
Rule 5 (`req()`, not `tryCatch`, for the "no GV run yet" case) are the ones this
plan's design must keep honoring.

### 2E. Existing test inventory (regression risk zone)

`tests/testthat/test_modBreedingGroups.R`:
- Lines 49-69 — asserts the `nTopAnimals` `conditionalPanel`'s `data-display-if`
  condition string is the unprefixed `input.animalSource == 'topRanked'`. **Will need
  updating**: this plan's design changes that condition to also require
  `input.inclusionCriterion == 'topN'` (§4).
- Lines 198-240 (`"modBreedingGroupsServer forms groups with topRanked source"`),
  795-831/833-869/871-907 (three `nTopAnimals` round-trip tests, values 10/5/100) —
  all set/consume `nTopAnimals` and/or trigger formation with the **default**
  `inclusionCriterion` (`"topN"`, unstated today since the control doesn't exist yet).
  Must stay green **unchanged** — they are this plan's primary backward-compatibility
  pin (§4 RED explicitly re-asserts this).
- No existing test asserts actual candidate-set membership/size from the slice
  (only `input$nTopAnimals` echoes and, once, the resulting group *count*) — a
  pre-existing gap, not something this plan is obligated to backfill beyond its own
  new RED tests.

Repo-wide grep confirmed zero references to `nTopAnimals`/"top ranked"/"top 20" in
`vignettes/manual_components/_breeding_group_algorithm.Rmd` or
`vignettes/articles/breeding-group-formation.qmd` — only the older
`vignettes/manual_components/_breeding_group_formation.Rmd:26,30-31` (source, pulled
into `vignettes/a3manual.Rmd:45` as a child) documents this control today. That is
the minimum doc surface this plan's slice must update.

---

## 3. Design decisions — RATIFIED (Session 426, 2026-07-29, via `AskUserQuestion`)

**D1 — Mechanism. RATIFIED: user-selectable alternative**, not a permanent replacement
and not a simple supplement. A new `inclusionCriterion` control lets the user choose,
per formation run: `"Top N ranked"` (today's exact behavior, default, unchanged) or
`"Genetic-value floor"` (new). Choosing the floor **bypasses** the `nTopAnimals`
count entirely for the `"topRanked"` source — this is what fixes *both* of issue
#128's complaints (a mediocre top-20 no longer automatically passes; a viable animal
ranked outside any fixed N is no longer automatically excluded), which a pure
"supplement" (floor stacked on top of top-N) could not do for the second complaint.

**D2 — Floor signal. RATIFIED: reuse the already-computed `value` column** (§2C) —
an animal passes iff `report$value != "Low Value"`. No new numeric cutoff parameter;
this stays in sync automatically if a center later changes issue #125's
`guCutoff`/`zScoreCutoff`.

**D3 — "Undetermined" animals. RATIFIED: pass the floor.** These animals are a
data-quality bucket (both parents unknown, no recorded origin), not a genetic
judgment — existing data does not call them low-value, so a value-based floor
should not treat missing information as if it were poor genetic value. (See §2C/§6
Dragon P1 for the **distinct** case of an animal missing from the report *entirely*
— not the same as being present and labeled `"Undetermined"`.)

**D4 — Scope of application. RATIFIED: all three `animalSource` choices** ("Top
ranked" / "Upload list" / "All available"), not just the `"topRanked"` path where
top-N already lives. A genetic-value floor is about individual eligibility, not
about how the candidate pool was sourced. (Practical note: "Upload list" is
currently vestigial/non-functional — §1 — so today this decision's practical effect
is identical for "Upload list" and "All available," until that separate gap is
fixed.)

---

## 4. Implementation plan — one vertical slice

Vertical, not horizontal (FM #25): this slice ships a working, end-to-end path for
one capability. "If I stop after this slice, does something work?" — yes.

### Slice 1 (only) = Genetic-value floor as an alternative inclusion criterion

**Scope:** `R/modBreedingGroups.R` only —
- UI (near lines 40-53): add
  `radioButtons(ns("inclusionCriterion"), "Include animals by:", choices = c("Top N ranked" = "topN", "Genetic-value floor" = "valueFloor"), selected = "topN")`,
  placed after the existing `"Source:"` radio, visible regardless of
  `animalSource` (D4). Extend the existing `nTopAnimals` `conditionalPanel`'s
  condition to `"input.animalSource == 'topRanked' && input.inclusionCriterion == 'topN'"`.
- Server (lines 269-275): restructure the `candidateIds` computation into two steps
  — (a) establish the raw pool per `animalSource` exactly as today (`topRanked` ->
  full ranked `gv$id`, in report order; `custom`/`all` -> `ped$id`); (b) narrow that
  pool by `inclusionCriterion`: `"topN"` (default) applies the **existing** unchanged
  positional slice for `topRanked` only (identical to today for all three sources —
  `custom`/`all` still get zero narrowing, exactly as today); `"valueFloor"` requires
  `req(geneticValues())` **regardless of `animalSource`** and keeps only ids where
  `value != "Low Value"` **and** the id is actually present in `geneticValues()$id`
  (§6 Dragon P1 — an id absent from the report entirely fails the floor, a fail-safe
  default distinct from the `"Undetermined"`-passes rule, which only applies to ids
  present with that label).
- Docs: `vignettes/manual_components/_breeding_group_formation.Rmd:26,30-31` — add a
  bullet describing the new "Include animals by:" control and the floor's semantics
  (reuses `value`, `"Undetermined"` passes, ids outside the GV report fail).
- `NEWS.Rmd` entry (user-facing: new inclusion-criterion control).

**What does NOT change (explicit scope boundary):** `R/groupAddAssign.R`,
`R/groupMembersReturn.R`, `R/filterThreshold.R`, `R/filterPairs.R`, `R/filterAge.R`,
`R/getAnimalsWithHighKinship.R` (§2B — the floor is a caller-side pre-filter on the
plain `candidates` vector, zero signature/behavior change to any of these); the
"Upload list" (`custom`) source's own vestigial-implementation gap (§1 — recommend a
separate issue, not touched here); `R/orderReport.R`/`R/rankSubjects.R`/
`R/reportGV.R` (§2C — this plan only *reads* the `value` column those already
produce, post issue #125 Slice 1); `R/modGeneticValue.R` (unrelated module, not
touched).

**RED:**
- `test_modBreedingGroups.R`: (a) **backward-compat pin** — with `inclusionCriterion`
  left unset/default (`"topN"`), formation behavior for all three `animalSource`
  values is byte-identical to today (reuse/extend the existing topRanked-formation
  and three `nTopAnimals` round-trip tests, §2E, confirming they still pass
  unmodified); (b) a value-floor test on `"topRanked"`: a fixture with a mix of
  `"High Value"`/`"Low Value"`/`"Undetermined"` animals confirms `"Low Value"` ids
  are excluded, `"Undetermined"` ids are included, and the `nTopAnimals` count is
  **not** applied (more than `nTopAnimals` candidates can be admitted); (c) the same
  value-floor assertion repeated for `animalSource == "all"` (a fixture where
  `ped$id` includes ids **not present in `geneticValues()$id`** — confirming those
  ids are excluded, per the Dragon P1 fail-safe default) and for `animalSource ==
  "custom"` (today identical to `"all"`); (d) a `conditionalPanel` test update for
  the new compound condition (extend §2E's existing test rather than replace it).
- Audit `test_modBreedingGroups.R` and `test_modBreedingGroups_groupAddAssign.R` for
  any assertion on `candidateIds`' exact contents or count that a value-floor branch
  could break — none identified in this session's evidence-gathering (§2E), but not
  exhaustively ruled out; re-check during RED before writing new assertions.

**GREEN:** implement the `inclusionCriterion` UI control and the restructured
two-step `candidateIds` computation described in Scope above, including the
`req(geneticValues())` gate extension and the not-in-report-fails-the-floor rule.

**DONE looks like:** a user can select "Genetic-value floor" for any of the three
`animalSource` choices and see low-value/report-absent animals excluded from
candidacy, with `"Undetermined"` animals included and no fixed-N truncation;
leaving `inclusionCriterion` at its default ("Top N ranked") reproduces today's
exact behavior for all three sources, with all pre-existing tests (§2E) green
unmodified.

**Verify:** targeted test file green (`Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_modBreedingGroups.R", reporter="summary")'` with `NOT_CRAN=true`); clean regression read
(`pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))`,
checking `sum(failed)`+`sum(error)`, isolating `!grepl("test-app-|test-e2e-", file)`);
build-equivalent `devtools::check()` -> 0 errors/0 warnings; **Phase-3E runtime smoke
required** (Shiny wiring change): launch the app, run a small synthetic pedigree
through Genetic Value Analysis (Learning 395 — do not use the full bundled example),
form breeding groups with "Top N ranked" (confirm unchanged), then with
"Genetic-value floor" for each of the three `animalSource` choices, confirming the
candidate pool visibly differs and no fixed-count truncation applies in floor mode.

**Session boundary:** one session. **Closes #128** when shipped. **NEWS entry
required** (user-facing: new inclusion-criterion control on the Breeding Groups tab).

**Dragons:** P1 (ids absent from the GV report entirely — distinct from
"Undetermined" — must fail the floor, not silently pass or error; needs its own RED
test), P2 (`req(geneticValues())` must gate `custom`/`all` **only** when
`inclusionCriterion == "valueFloor"` — gating them unconditionally would break
today's "form groups from all available animals with zero GV run" workflow), P3 (the
`conditionalPanel` test at `test_modBreedingGroups.R:49-69` needs its condition
string updated to match the new compound condition — do not just add a new test
alongside a now-stale one), P4 (do not touch `groupAddAssign()`'s signature — the
floor is entirely a caller-side `modBreedingGroups.R` concern, per §2B's rationale;
touching the exported function's contract would be unnecessary scope expansion).

---

## 5. Notes

- **No independence question to record** — unlike issue #125 (two slices, two
  modules), this is a single slice touching a single file
  (`R/modBreedingGroups.R`) plus one vignette fragment and `NEWS.Rmd`.
- **Backward-compatibility is the load-bearing invariant**, exactly as both #125
  slices established: the new control defaults to `"topN"`, reproducing today's
  literal behavior for all three `animalSource` choices with zero visible change
  unless a user actively selects "Genetic-value floor."

## 6. Here be dragons (consolidated load-bearing risks)

- **P1 — Ids absent from the GV report entirely.** `reportGV()` scopes its report to
  `ped$id[ped$population]` (default: all *living* animals, `R/reportGV.R:144-149`,
  `R/modGeneticValue.R:268-278`) — not necessarily every id in `ped$id`. Since
  `animalSource == "all"` sets `candidateIds <- ped$id` (literally every pedigree
  animal), a value-floor pass over that pool will routinely meet ids with **no**
  corresponding row in `geneticValues()$id` at all — a different case from
  `"Undetermined"` (§3 D3), which only covers ids **present** in the report with
  that label. This plan's fail-safe default: an id missing from the report entirely
  **fails** the floor (only ids affirmatively confirmed `!= "Low Value"` pass). Get
  this wrong and a "genetic-value floor" could silently admit animals with no
  genetic-value evidence at all, defeating the feature's purpose.
- **P2 — Conditional `req(geneticValues())` gating.** Today, only the `"topRanked"`
  branch needs a prior GV run; `"custom"`/`"all"` need none. This plan's floor mode
  must extend the `req()` gate to those two branches, but **only** when
  `inclusionCriterion == "valueFloor"` — an unconditional gate would break the
  existing "form groups from all available animals, no GV analysis required"
  workflow that today's tests (§2E) and users rely on.
- **P3 — Stale `conditionalPanel` test.** `test_modBreedingGroups.R:49-69` asserts
  the *current* single-condition string. This plan's UI change makes that condition
  compound (`animalSource == 'topRanked' && inclusionCriterion == 'topN'`) — update
  the existing test's expected string in place; do not leave it asserting a now-
  wrong condition alongside a new, separate test.
- **P4 — Do not touch `groupAddAssign()`'s exported signature.** §2B's rationale
  (the floor is a `reportGV()`/Shiny-layer concept, not a bare-`candidates`-vector
  concern) means the entire feature lives in `modBreedingGroups.R`. A future session
  tempted to add a `valueFloor` parameter to `groupAddAssign()` itself would be
  expanding this plan's ratified scope (D1-D4 say nothing about the exported
  function) and adding an unnecessary maintenance surface to a documented,
  externally-usable API.

## 7. Owner ratification record

Ratified by the owner (repo owner / geneticist) via `AskUserQuestion`, Session 426
(2026-07-29), grounded in this session's firsthand research workflow findings (§2).

- [x] **D1** — mechanism = user-selectable alternative (not replace, not supplement).
- [x] **D2** — floor signal = reuse the already-computed `value` column (not a new
  independent numeric cutoff).
- [x] **D3** — "Undetermined" animals pass the floor.
- [x] **D4** — floor applies to all three `animalSource` choices (Top ranked / Upload
  list / All available), not just "Top ranked."
