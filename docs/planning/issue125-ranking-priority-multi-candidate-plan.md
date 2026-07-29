# Issue #125 Plan — Configurable genetic-value ranking-priority scheme + surface multiple breeding-group candidates

**Tracks:** GitHub issue **#125** (filed S422, 2026-07-29, from
`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md` Dimensions 1 & 2 / the
audit's Recommendation #1). Distinct from issue #128 (breeding-group top-N-vs-value-floor
inclusion threshold) — confirmed no overlap; #128 stays its own issue.

**Authored:** Session 423 (2026-07-29), **planning session**. TDD phases (RED/GREEN/
REFACTOR) are inapplicable to this document — it is a plan. Each implementation slice
below is its own strict-TDD session (RED -> GREEN -> REFACTOR), one slice per session
(FM #18/#25: do not bundle plan + implementation, do not bundle slices).

**Evidence base:** a 6-agent research workflow (`wf_cdbcc7a5-22c`) read every file in
scope firsthand — `R/orderReport.R`, `R/rankSubjects.R`, `R/modGeneticValue.R`,
`R/groupAddAssign.R`, `R/groupMembersReturn.R`, `R/modBreedingGroups.R`,
`R/loadSiteConfig.R`/`R/defaultSiteParams.R`/`R/getConfigApiKey.R`/
`R/getPedigreeSource.R`, `docs/architecture/module-contract.md` — plus a full `git grep`
call-site inventory. This session's own follow-up reads confirmed the exact
`reportGV()`/`orderReport()` call sites and signatures, `test_orderReport.R` in full, and
disambiguated `guThresh` (existing, unrelated) from the new cutoff parameters (see
Dragon R1).

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `man/`, `NAMESPACE`,
> or `data/` content is changed by writing it.**

> **RATIFIED this session (2026-07-29), via `AskUserQuestion`.** See §7 for the record.
> §3 documents the ratified decisions directly (not as open recommendations) since
> ratification happened before this document was written.

---

## 1. Context

### What issue #125 says

> 1. **Configurable ranking-priority scheme.** The PDF frames ranking priority
>    (mean-kinship+z-score vs. genome uniqueness vs. a blend) as a per-center choice.
>    `R/orderReport.R:31-98` implements one fixed tier order with hardcoded cutoffs
>    (`gu > 10`, `zScores <= 0.25`) — no argument or UI control lets a center
>    reprioritize. `R/rankSubjects.R:41-47`'s High Value / Low Value / Undetermined
>    labeling uses the same hardcoded cutoffs, with no adjustable threshold.
> 2. **Multiple breeding-group candidates.** The PDF's best practice is to derive all
>    possible valid combinations so a human can apply behavioral/dominance criteria
>    before choosing. `R/groupAddAssign.R:164-186` runs up to 1000 random trials
>    internally, but `R/groupMembersReturn.R:19-33` keeps only the single
>    highest-scoring trial — every other valid candidate grouping is discarded.

The issue bundles these as one because both are "the ranking/grouping engine only ever
returns one fixed answer" gaps. Architecturally they are two independent subsystems
(the Genetic Value module vs. the Breeding Groups module) with no shared dependency —
this plan covers both (one issue, one plan document) but implements them as two
separate vertical slices (§4), per the ratified slice order.

### What this session's research changed about the picture

The audit's framing (and the issue text above) describes `orderReport.R`'s tier logic
as *the* hardcoded ranking scheme. **It is not what users see.** Two independent
schemes exist today:

1. **The categorical scheme** (`R/orderReport.R` + `R/rankSubjects.R`, Vinson & Raboin
   2015): partitions animals into `imports` -> `highGu` (`gu > 10`, sorted
   descending) -> `lowMk` (`zScores <= 0.25` on the `highGu`-excluded remainder,
   sorted ascending) -> `lowVal` (remainder) -> `noParentage` (both-unknown, no
   origin — labeled "Undetermined", `rank = NA`). Feeds `reportGV()`'s returned
   `$report` and `gvaConvergence()`'s ranking diagnostic.
2. **The app's displayed scheme** (`R/modGeneticValue.R:294`): **unconditionally
   overrides** (1) with `report$rank <- rank(report$indivMeanKin - report$gu)` — a
   continuous combined score — then demotes `"Undetermined"` rows to the bottom and
   resequences (lines 295-301). This is what the Shiny table, both CSV exports, and
   `gvaConvergence()`'s own comparison target (indirectly, via `reportGV()`) all
   actually reflect for a live user session.

Genome uniqueness is hardcoded to strictly outrank mean kinship in scheme (1): an
animal with `gu = 15, zScores = 0.1` lands in `highGu` (ranked by `gu`), never in
`lowMk`, because it is removed from the pool (line 75, `gu <= 10L`) before the
`zScores` test ever runs (line 78). There is no blend/weighted-combination formula in
either file. This is exactly the gap issue #125 targets, and it is one level "deeper"
in the code than the audit's own citation implied — the owner's ratified scope (§3, D1)
now covers both layers.

### Prior process history (relevant precedent, reused throughout)

- `docs/planning/issue9-gva-unknown-parent-ranking-plan.md` — the last plan to touch
  `orderReport.R`/`rankSubjects.R`/`modGeneticValue.R`'s rank-override block. Confirmed
  via `git show 3be9f818`/`7d1e9b4f` that neither issue #9 Slice 3 (classification) nor
  issue #76 (gu de-inflation) touched the `gu > 10` / `zScores <= 0.25` cutoffs or the
  tier-order vector — the current file content this plan cites is not stale relative to
  either.
- `docs/planning/issue73-part2-user-configurable-plan.md` — established this
  codebase's `NULL`-default override-threading idiom (`reportGV(..., breedingTable =
  NULL, gestationTable = NULL, breedingAgeDefault = NULL, gestationDefault = NULL)`,
  already shipped, `R/reportGV.R:124-125`) and its **R2 dragon**: a wrapper threading a
  `NULL` override into a *pre-existing* accessor with its own baked-in default must not
  pass a bare `NULL` into that accessor's `default =` argument (it breaks the
  accessor). This plan's Slice 1 does **not** hit that trap — see Dragon R2 for why.

---

## 2. Evidence-based inventory (firsthand, this session + the research workflow)

### 2A. `orderReport()` / `rankSubjects()` — exact current structure

`R/orderReport.R:31-99` (`orderReport <- function(rpt, ped)`, internal `@noRd`, **2 real
production callers**: `R/reportGV.R:282`, `R/gvaConvergence.R:198`; test-only access via
`nprcgenekeepr:::orderReport`):

| Step | Lines | Logic |
|---|---|---|
| Classification split (unrelated to genetic value) | 39-70 | `imports` (both-unknown WITH origin) vs. `noParentage` (both-unknown, NO origin → "Undetermined", `rank = NA`) |
| GU cutoff | 73 | `highGu <- rpt[(rpt$gu > 10L), ]` — **hardcoded 10** |
| GU tier sort | 74 | descending `gu`, tie-break ascending `zScores` |
| GU complement | 75 | `rpt <- rpt[(rpt$gu <= 10L), ]` |
| MK cutoff | 78 | `lowMk <- rpt[(rpt$zScores <= 0.25), ]` — **hardcoded 0.25**, applied only to the GU-excluded remainder |
| MK tier sort | 79 | ascending `zScores` |
| MK complement | 81 | `rpt <- rpt[(rpt$zScores > 0.25), ]` |
| Remainder | 84 | `lowVal` = whatever's left, ascending `zScores` |
| **Tier stacking order** | 87-90 | literal vector `c("imports","highGu","lowMk","lowVal","noParentage")` — controls both display order and (via `rankSubjects()`) rank-number sequencing |
| Reindex + delegate | 94-95 | `finalRpt[includeCols]`, then `rankSubjects(finalRpt)` |

`R/rankSubjects.R:33-57` (exported): walks the list in whatever order it's given
(lines 36, no opinion on order), assigns `value` = `"Low Value"`/`"Undetermined"`/
`"High Value"` per bucket name (41-47), assigns sequential `rank` via a running
counter *except* `noParentage`, which gets `rank = NA` (49-50). **Not modified by this
plan** — it has no cutoffs or order logic of its own; both are fully owned by
`orderReport()`.

### 2B. The app's display override — `R/modGeneticValue.R`

- `gvResults <- eventReactive(input$runAnalysis, {...})`, the `reportGV()` call at
  lines 266-277 (confirmed this session):
  ```r
  gvReport <- reportGV(
    ped, guIter = input$nIterations, guThresh = guThreshold(), byID = TRUE,
    updateProgress = updateProgress,
    breedingTable = ov$breedingTable, gestationTable = ov$gestationTable,
    breedingAgeDefault = ov$breedingAgeDefault, gestationDefault = ov$gestationDefault,
    kinshipOverrides = kinshipOverrideData()
  )
  ```
- Rank-override block, lines 294-301 (quoted in full — this is the exact code the
  Slice 1 branch wraps):
  ```r
  report$rank <- rank(report$indivMeanKin - report$gu)
  demote <- if ("value" %in% names(report)) {
    !is.na(report$value) & report$value == "Undetermined"
  } else {
    rep(FALSE, nrow(report))
  }
  report <- report[order(demote, report$rank), ]
  report$rank <- seq_len(nrow(report))
  ```
- **Reusable UI/reactive template** — `guThreshold` (lines 168-173):
  ```r
  guThreshold <- reactive({
    thr <- input$threshold
    if (is.null(thr)) 4L else as.integer(thr)
  })
  ```
  paired with `selectInput(ns("threshold"), "Genome Uniqueness Threshold:", choices =
  c(1L,2L,3L,4L,5L), selected = 4L)` (UI lines 41-43). This is the exact idiom Slice 1
  reuses for `rankScheme`/`axisPriority`/`guCutoff`/`zScoreCutoff`.
- Table render (`output$rankingsTable`, lines 332-337) and both CSV export
  `downloadHandler`s (`downloadRankings` 444-447 full export, `downloadGVASubset`
  449-454 filtered export) all consume `report$rank`/`report$value` generically —
  **neither needs code changes**; they display whatever the active scheme produced.

### 2C. `groupAddAssign()` / `groupMembersReturn()` — exact current structure

`R/groupAddAssign.R:164-186` (exported, 195 lines total; **1 real production caller**:
`R/modBreedingGroups.R:332`):
```r
savedScore <- -1L
savedGroupMembers <- list()
for (k in 1L:iter) {                              # iter default 1000L (line 126)
  groupMembers <- fillGroupMembers(candidates, currentGroups, kin, ped, harem,
                                   minAge, numGp, sexRatio)
  score <- min(lengths(groupMembers))              # smallest group's size
  if (score > savedScore) {                        # STRICT >, ties not retained
    savedGroupMembers <- groupMembers
    savedScore <- score
  }
  if (!is.null(updateProgress)) updateProgress()
}
```
Then `addGroupOfUnusedAnimals(savedGroupMembers, ...)` (188-191, runs once, on the
single winner only) and `groupMembersReturn(savedGroupMembers, savedScore, withKin,
kmat)` (193).

`R/groupMembersReturn.R:19-33` (internal `@noRd`, **1 production call site**, **zero
direct tests** — only transitively exercised via `groupAddAssign()`'s own tests) is
pure packaging, not the discard logic:
```r
groupMembersReturn <- function(savedGroupMembers, savedScore, withKin, kmat) {
  if (withKin) {
    groupKin <- list()
    for (i in seq_along(savedGroupMembers)) groupKin[[i]] <- filterKinMatrix(savedGroupMembers[[i]], kmat)
    value <- list(group = savedGroupMembers, score = savedScore, groupKin = groupKin)
  } else {
    value <- list(group = savedGroupMembers, score = savedScore)
  }
  value
}
```
Shape of one trial: a plain list of `numGp` (+1 after `addGroupOfUnusedAnimals`)
character vectors of animal IDs, confirmed via `groupAddAssign.R:175`
(`min(lengths(groupMembers))`) and `groupMembersReturn.R:22-24`
(`savedGroupMembers[[i]]` passed to `filterKinMatrix`).

### 2D. `R/modBreedingGroups.R` — module wiring

- `modBreedingGroupsUI(id)` (line 27) / `modBreedingGroupsServer(id, pedigree,
  geneticValues = NULL, kinshipMatrix = NULL, kinshipOverrides = NULL)` (187-189).
- Mounted at `R/appUI.R:218-222` / `R/appServer.R:404-410`; consumed at
  `R/appServer.R:415-417` (`shared$breedingGroups <- bgResults$groups()`), feeding
  `modGeneticDiversityServer` (`R/appServer.R:422-424`).
- The single result: `groupResults <- reactiveVal(NULL)` (line 193);
  `breedingGroups <- eventReactive(input$formGroups, {...})` (243-393) calls
  `groupAddAssign()` once (331-346), stores the packaged result via `groupResults(...)`
  (374-381), and **returns just `validGroups`** (line 391) — the single winner's
  group-membership list.
- Display: `groupsDisplay` (409-424, one DT panel per group), `groupStats` (441-457,
  one row per group), Group Detail tab's `selectInput(ns("viewGrp"), "Group to view:",
  choices = NULL)` (UI line 98) + `selectedGroup` reactive (464-468, clamps
  `input$viewGrp` to `[1, length(breedingGroups())]`) + an `observe()` (473-484) that
  calls `updateSelectInput(...)` whenever `breedingGroups()`'s length changes — **this
  is the exact, already-proven "pick among N computed things" pattern Slice 2 reuses
  one level up** (picking among candidate *solutions* instead of groups *within* one
  solution).
- Exports: `downloadGroup`/`downloadGroupKin` (516-531) write only the
  currently-selected group within the single stored solution.
- The top-N cutoff issue #128 describes (`R/modBreedingGroups.R:40-53,253-259`,
  `numericInput(ns("nTopAnimals"), ..., value = 20L)` gating `candidateIds <-
  gv$id[seq_len(min(input$nTopAnimals, length(gv$id)))]`) is **confirmed unaffected by
  this plan** — it runs upstream of `groupAddAssign()`, unrelated to how many
  *candidate groupings* are retained from the trials it produces.
- **Reusable conditional-UI template** — `conditionalPanel(condition =
  "input.animalSource == 'topRanked'", ns = ns, numericInput(ns("nTopAnimals"), ...))`
  (UI lines 44-53) is the exact idiom Slice 1 reuses for the axis-priority/cutoff
  sub-controls, and a candidate for Slice 2's "compare candidates" UI framing too.

### 2E. Config/adapter precedent surveyed (not used directly, but ruled out D2)

- `R/loadSiteConfig.R`/`R/defaultSiteParams.R`/`R/getConfigApiKey.R`: the optional
  config-file-key pattern (fail-soft to bundled defaults, `NULL`/`""` sentinel on
  absence) — this is the mechanism issue #73 used for *per-center* config. **Ratified
  against** for this issue (§3, D2) in favor of a live Shiny control, since ranking
  scheme is a natural per-analysis-run choice (like `guThreshold` already is), not a
  colony-wide constant requiring a config-file edit + app restart to change.
- `R/getPedigreeSource.R`: `match.arg`-dispatched provider seam (`labkey` | `dataframe`
  | `file`) — the template `orderReport()`'s new `axisPriority` parameter's
  `match.arg(axisPriority, c("gu", "mk"))` validation follows.
- `docs/architecture/module-contract.md`'s 6 rules — see §3 D2/D3 and §6 Dragons for
  which apply to this plan's module changes.

### 2F. Tests that pin current behavior (TDD anchors / must-update)

| Test | What it pins | Affected by |
|---|---|---|
| `tests/testthat/test_orderReport.R` (87 lines, read in full) | row-preservation invariants (2 tests); #9 Slice 3 classification (Undetermined/imports/one-unknown/known); the `getFounders`-fallback branch when `parentage` is absent | Slice 1 — **must stay green unmodified** (no test here asserts the `gu`/`zScores` cutoff *values*, so adding `NULL`-default cutoff params cannot break any of these 5 `test_that` blocks) |
| `tests/testthat/test_rankSubjects.R` | exact tiered output on the bundled `finalRpt` fixture (row counts, `value`/`rank` values) | Not touched — `rankSubjects.R` unchanged |
| `tests/testthat/test_reportGV.R` (~700+ lines) | dozens of `reportGV(ped, guIter = 20L, ...)` calls; **already contains the exact override-vs-baseline template** Slice 1 reuses (e.g. lines 269-270: `over <- reportGV(ped, guIter = 20L, breedingAgeDefault = 4); base <- reportGV(ped, guIter = 20L)`) | Slice 1 (new `guCutoff`/`zScoreCutoff`/`axisPriority` override-threading tests, same template) |
| `tests/testthat/test_modGeneticValue.R` | `testServer(modGeneticValueServer, ...)` harness; `skip_on_cran()` | Slice 1 (new `rankScheme`/`axisPriority` UI-threading tests) |
| `tests/testthat/test_groupAddAssign.R` | exact group sizes/`groupKin` shape on seeded fixtures; **gated `skip_if_not(Sys.info()[...user...] == "rmsharp")`, maintainer-machine only** | Slice 2 (new dedup/top-5/backward-compat tests, same gate) |
| `tests/testthat/test_modBreedingGroups_groupAddAssign.R` (14 `test_that` blocks) | `groupAddAssign()`'s integration behavior via `testServer`; includes a `local_mocked_bindings()` template (line 356) for asserting exact arguments threaded through | Slice 2 (new solution-selector tests; the mock template is reusable for asserting `groupAddAssign()` is *not* re-invoked on a selector-only change) |
| `tests/testthat/test_modBreedingGroups.R` | RNG-seeded (`options(nprcgenekeepr.bg_seed = 1L)`) integration tests of group formation, topRanked source, CSV download | Slice 2 (regression guard; verify none use an exact-field-set `expect_named()` on `groupAddAssign()`'s return that a new top-level field would break — see Dragon R5) |
| `tests/testthat/test_gvaConvergence.R` | ranks through the real `orderReport()` pipeline (indirect pin) | Not touched — `gvaConvergence()` stays on `orderReport()`'s built-in defaults (see §4 Slice 1 "what does not change") |
| `vignettes/articles/genetic-value-analysis.qmd:133-134` | prose: "The `rank` and `value` columns come from the ranking scheme in `orderReport()`" | **Slice 1 — this prose is already stale today** (the app has overridden `orderReport()`'s scheme since issue #9 Slice 3) and must be corrected to describe both schemes once the toggle ships (Learning #7/#10-style cross-reference fix, caught in evidence-gathering rather than left for a later audit) |

---

## 3. Design decisions — RATIFIED (Session 423, 2026-07-29, via `AskUserQuestion`)

**D1 — Depth of ranking-scheme configurability. RATIFIED: also expose internal
cutoffs** (not just a combined-vs-categorical toggle). Concretely, `orderReport()`
gains three new parameters, each `NULL`-defaulting to today's literal behavior:
- `guCutoff = NULL` (resolves to `10L` when `NULL`) — replaces the hardcoded `10` at
  lines 73/75.
- `zScoreCutoff = NULL` (resolves to `0.25` when `NULL`) — replaces the hardcoded
  `0.25` at lines 78/81.
- `axisPriority = NULL` (resolves to `"gu"` when `NULL`, `match.arg`-validated against
  `c("gu", "mk")`) — controls **both** which cutoff-filter runs first (determining tier
  *membership*: an animal qualifying for both axes is claimed by whichever axis has
  priority) **and** the tier stacking order (determining rank-number *sequencing*):
  - `"gu"` (default, current behavior): `highGu` filtered first, tier order `imports,
    highGu, lowMk, lowVal, noParentage`.
  - `"mk"`: `lowMk` filtered first (on the *unfiltered* pool), tier order `imports,
    lowMk, highGu, lowVal, noParentage`.
  These two aspects are coupled deliberately — "priority" means the same axis wins both
  contests. See Dragon R3 for why they must not be allowed to drift independently.
- The app's combined-score scheme is exposed alongside as a peer choice, not replaced:
  `modGeneticValueServer` gains a `rankScheme` reactive (`"combined"` default | `"categorical"`)
  that branches the lines-294-301 block: `"combined"` keeps that block verbatim;
  `"categorical"` uses `report$rank`/`report$value` exactly as `reportGV()` already
  returns them (no recomputation needed — `orderReport()`/`rankSubjects()` already
  produce a correctly-ordered, correctly-`NA`-ranked report; see §2B).

**D2 — Mechanism. RATIFIED: Shiny UI control**, not a config-file key. New controls in
`modGeneticValueUI`, placed directly after the existing `threshold` `selectInput`
(lines 41-43), following the `guThreshold` reactive template (§2B) exactly:
- `selectInput(ns("rankScheme"), "Ranking Scheme:", choices = c("Combined (kinship -
  uniqueness)" = "combined", "Categorical (priority order)" = "categorical"), selected
  = "combined")`.
- A `conditionalPanel(condition = "input.rankScheme == 'categorical'", ns = ns, ...)`
  (reusing the exact idiom at `R/modBreedingGroups.R:44-53`) wrapping:
  `selectInput(ns("axisPriority"), "Priority axis:", choices = c("Genome uniqueness
  first" = "gu", "Mean kinship first" = "mk"), selected = "gu")`,
  `numericInput(ns("guCutoff"), "High-uniqueness cutoff:", value = 10, min = 0)`,
  `numericInput(ns("zScoreCutoff"), "Low-kinship z-score cutoff:", value = 0.25, step =
  0.05)`.
- Each paired with a `NULL`-safe reactive mirroring `guThreshold` exactly (e.g.
  `rankScheme <- reactive({ rs <- input$rankScheme; if (is.null(rs)) "combined" else rs
  })`), threaded into the `reportGV(...)` call (§2B) as three new arguments.

**D3 — Breeding-group candidate count. RATIFIED: top 5 distinct-scoring candidates**,
deduplicated by partition content (not merely by score value — two trials with the
same score but different membership both count; two trials with identical membership,
regardless of score-computation order, count once). See §4 Slice 2 and Dragon R4 for
the canonicalization/equality mechanics.

**D4 — Slice order. RATIFIED: ranking-scheme configurability first** (Slice 1, smaller
and lower-risk — one module, one new UI control set, threading through 2 existing
functions), **multi-candidate breeding groups second** (Slice 2, larger — a retention-
policy refactor spanning 3 files plus a new UI selector pattern).

---

## 4. Implementation plan — vertical slices (one session each)

Vertical, not horizontal (FM #25): each slice ships a working, end-to-end path for one
capability. "If I stop after this slice, does something work?" — yes for each.

### Slice 1 (first, ratified) = Configurable ranking-priority scheme

**Scope:** `R/orderReport.R` (new `guCutoff`/`zScoreCutoff`/`axisPriority` params,
`NULL`-resolved internally — see Dragon R2 for why this differs from the
`correctUnknownParentMeanKinship`-style call-site branching used elsewhere in this
codebase), `R/reportGV.R` (thread the same 3 params straight through to `orderReport()`
at line 282, no branching needed at this layer), `R/modGeneticValue.R` (4 new UI
controls + 4 new `NULL`-safe reactives + the `rankScheme`-branched lines 294-301 block),
`vignettes/articles/genetic-value-analysis.qmd:133-134` (correct the now-doubly-stale
prose to describe both schemes).

**What does NOT change (explicit scope boundary):** `rankSubjects.R` (no cutoffs/order
logic of its own — nothing to parameterize); `R/gvaConvergence.R`'s `orderReport()`
call at line 198 (stays on the built-in defaults deliberately — it is a diagnostic
measuring rank-stability of the *default* algorithm under varying gene-drop iteration
counts, not a reflection of a live per-session UI choice); both CSV export
`downloadHandler`s and the table renderer (already scheme-agnostic, §2B).

**RED:**
- `test_orderReport.R`: (a) a no-override call (`orderReport(rpt, ped)`, 2 args)
  produces byte-identical output to today — explicit backward-compat regression test;
  (b) `axisPriority = "mk"` on a small fixture with an animal qualifying for both
  `gu > 10` and `zScores <= 0.25` flips which tier claims it, and flips the two tiers'
  relative stacking order; (c) custom `guCutoff`/`zScoreCutoff` values change tier
  membership on a fixture where the default and custom cutoffs bucket differently.
- `test_reportGV.R`: an override-vs-baseline pair using the existing template (§2F) —
  `over <- reportGV(ped, guIter = 20L, guCutoff = 5); base <- reportGV(ped, guIter =
  20L)` — asserting `over$report`'s tier membership differs from `base$report`'s on a
  fixture built for the difference to matter; a no-override identity test.
- `test_modGeneticValue.R`: a `testServer` test with `input$rankScheme <- "categorical"`
  confirming the displayed `rank`/`value` match `reportGV()`'s native output (not
  `rank(indivMeanKin - gu)`); a default-unset test confirming `rankScheme` absent still
  produces today's combined-score behavior (backward compat).

**GREEN:** implement the 3-param `orderReport()` extension (internal `NULL`-resolution
+ the two-branch filter/tier-order restructure per D1), the `reportGV()` pass-through,
and the `modGeneticValue.R` UI/reactive/branch additions per D1/D2. Fix the vignette
prose (§2F).

**DONE looks like:** a user can pick "Categorical" from a new dropdown, tune the axis
priority and both cutoffs, and see the displayed/exported table reflect
`orderReport()`'s native tiered scheme instead of the combined score; leaving the
dropdown on "Combined" (the default) is byte-identical to today's behavior; all 5
existing `test_orderReport.R` blocks and the full `test_reportGV.R`/
`test_modGeneticValue.R` suites stay green.

**Verify:** targeted test files green (`Rscript -e
'suppressMessages(pkgload::load_all(".", quiet=TRUE));
testthat::test_file("tests/testthat/test_orderReport.R", reporter="summary")'`, repeat
for `test_reportGV.R`, `test_modGeneticValue.R` with `NOT_CRAN=true`); clean regression
read (`pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat",
reporter="silent", stop_on_failure=FALSE))`, check `sum(failed)`+`sum(error)`,
isolating `!grepl("test-app-|test-e2e-", file)`); build-equivalent `devtools::check()` ->
0 errors/0 warnings; **Phase-3E runtime smoke required** (Shiny wiring change): launch
`runModularApp()`, run a GVA on a pedigree, toggle to "Categorical", change the axis
priority and cutoffs, confirm the table changes and re-exports correctly; toggle back
to "Combined", confirm it matches pre-change behavior.

**Session boundary:** one session. The heavier of the two slices (`orderReport()`'s
internal restructure + 3-layer threading + 4 new UI controls + reactive wiring).
Close out when done. **NEWS entry required** (user-facing: new ranking-scheme control).

**Dragons:** R1 (name collision with the unrelated existing `guThresh`), R2 (why
`orderReport()`'s `NULL`-resolution differs from the `correctUnknownParentMeanKinship`
precedent), R3 (axisPriority couples membership + stacking order — do not let a future
change decouple them silently).

### Slice 2 = Surface multiple breeding-group candidates

**Scope:** `R/groupAddAssign.R` (replace the single-best scalar accumulator with a
bounded, deduped top-5 retention list; run `addGroupOfUnusedAnimals()` per retained
candidate), `R/groupMembersReturn.R` (accept a list of candidates; return both the
**unchanged top-level `group`/`score`[/`groupKin`]** fields — aliased to the best
candidate, for backward compatibility — **and** a new `candidates` list field),
`R/modBreedingGroups.R` (a new "which candidate" selector reusing the `viewGrp`/
`selectedGroup` pattern one level up, a new comparison view, `breedingGroups()`
re-derived from the selected candidate rather than fixed to the single winner).

**What does NOT change (explicit scope boundary):** `R/appServer.R:415-417` /
`modGeneticDiversityServer` — `bgResults$groups()` keeps returning exactly one
solution's groups (the currently-selected candidate, defaulting to the best), so a
session that never touches the new selector sees identical behavior to today;
`groupAddAssign()`'s top-level `group`/`score`/`groupKin` return fields (unchanged
meaning, still "the single best solution"); the top-N cutoff (issue #128, confirmed
unrelated in §2D).

**RED:**
- `test_groupAddAssign.R` (maintainer-gated, keep the existing `skip_if_not` guard): a
  dedup test (a scenario producing many identical-partition trials — confirm
  `result$candidates` contains no duplicate partitions); a boundedness test
  (`length(result$candidates) <= 5`); a backward-compat test (`result$group`/
  `result$score` unchanged in shape and equal to `result$candidates[[1]]$group`/`$score`).
- `test_modBreedingGroups_groupAddAssign.R` / `test_modBreedingGroups.R`: a new
  candidate-selector test (`updateSelectInput` populates the expected candidate count);
  a test that changing the candidate selection re-renders the displayed groups
  **without** re-invoking `groupAddAssign()` (reuse the `local_mocked_bindings()`
  template at line 356 to assert call count); a regression test that `groups()`'s
  exported behavior (what `appServer.R` consumes) is unchanged when the selector is
  left at its default.
- Audit `test_groupAddAssign.R`/`test_modBreedingGroups_groupAddAssign.R` for any
  `expect_named(x, c(...))` exact-match assertion on `groupAddAssign()`'s return value
  before implementing — see Dragon R5.

**GREEN:** implement the bounded/deduped retention list in `groupAddAssign.R` (compare
each new trial's canonical partition signature against only the current up-to-5
retained candidates, not all prior trials — O(iter × 5), not O(iter²)); restructure
`groupMembersReturn()` per the backward-compatible shape in §3 D3/§4 scope; add the
candidate selector + comparison view + re-derived `breedingGroups()` to
`modBreedingGroups.R`.

**DONE looks like:** after "Form Groups," the module shows up to 5 distinct candidate
groupings; the user can select among them (Groups/Statistics/Group Detail views all
re-point at the selection without re-running the algorithm); a comparison view lists
all retained candidates' scores; leaving the selector at its default is byte-identical
to today's single-solution behavior; `appServer.R`'s downstream consumption
(`modGeneticDiversityServer`) is unaffected.

**Verify:** targeted test files green (maintainer machine for `test_groupAddAssign.R`,
`NOT_CRAN=true` for the `testServer` files); clean regression read; build-equivalent
0 errors/0 warnings; **Phase-3E runtime smoke required**: launch `runModularApp()`,
form breeding groups, confirm multiple candidates appear, switch between them, confirm
downstream Genetic Diversity tab still reflects the selected candidate.

**Session boundary:** one session. Close out when done. **Closes #125** when both
slices are published. **NEWS entry required** (user-facing: multiple candidate
groupings; `groupAddAssign()`'s public return shape gains a field).

**Dragons:** R4 (partition-equality canonicalization for dedup), R5 (exact-match
`expect_named()` risk on `groupAddAssign()`'s expanded return shape), R6 (module-contract
Rules 2/3/4 — any newly-exposed module return element must be reactive-wrapped, use
stable vocabulary, and have a real consumer before it's added).

---

## 5. Cross-slice notes

- **Independence:** Slice 1 (Genetic Value module) and Slice 2 (Breeding Groups module)
  touch disjoint files with no shared dependency — the ratified order (D4) is a
  risk/size choice, not a technical constraint. Either could ship without the other.
- **Each slice is a full RED -> GREEN -> REFACTOR session** with the phase-gate
  `AskUserQuestion` at every transition (Development Process Contract). A NEWS entry is
  required for each slice (user-facing changes), folded into the same PR (Learning
  157a). Slice 1's PR uses "Relates to #125"; Slice 2's (the last part) uses "Closes
  #125".
- **Backward-compatibility is the load-bearing invariant across both slices:** Slice 1
  — all new `orderReport()`/`reportGV()` parameters default to `NULL` and resolve to
  today's literal behavior; the app's default `rankScheme` stays `"combined"`. Slice 2
  — `groupAddAssign()`'s existing top-level return fields are unchanged in shape and
  meaning; `appServer.R`'s consumption is unaffected. Both slices need an explicit
  no-override/default-selector test proving this.

## 6. Here be dragons (consolidated load-bearing risks)

- **R1 — Name collision trap.** `reportGV()` already has a `guThresh` parameter
  (`R/reportGV.R:122`, threaded into `calcGU()`/`calcGUSE()` — the allele-rarity
  threshold used to *compute* the `gu` metric itself via gene-drop). This plan's new
  `guCutoff` is a **completely different concept** — it *classifies* an
  already-computed `gu` value into the `highGu` ranking tier. Do not conflate them, do
  not rename one to look like the other, and do not let a future session assume
  `guThresh` already covers this gap.
- **R2 — Why `orderReport()`'s `NULL`-resolution differs from the established
  `correctUnknownParentMeanKinship`/`getSpeciesMinBreedingAge` precedent (issue #73's
  R2 dragon).** That precedent's rule — "the wrapper must not pass a bare `NULL` into
  the accessor's `default =` argument, because the accessor's own signature does not
  guard `NULL`" — applies when a wrapper threads an override into a **pre-existing**
  accessor whose contract cannot change. Here, `orderReport()` **is** the function
  gaining the new parameters; it is not a wrapper around some other pre-existing
  accessor. So `orderReport()` may (and should) resolve `guCutoff`/`zScoreCutoff`/
  `axisPriority`'s `NULL` internally, at the top of its own body, exactly once —
  `reportGV()` and `gvaConvergence()` pass whatever they have straight through with no
  branching. Do not copy the call-site `if (is.null(...))` branching pattern here; it
  would be redundant and is not what the precedent's rule requires in this shape.
- **R3 — `axisPriority` couples two things, not one.** It controls both which
  cutoff-filter runs first (tier *membership*) and the tier stacking order (rank
  *sequencing*). A future change that lets these drift independently (e.g. flipping
  membership priority but leaving the old stacking order) would produce a
  self-contradictory report — an animal in the `lowMk` tier ranked *after* the `highGu`
  tier even though `axisPriority = "mk"` says mean-kinship should win. Keep them a
  single decision, branched together.
- **R4 — Partition-equality canonicalization (Slice 2 dedup).** Two trials are "the
  same candidate" only after canonicalizing away (a) group *order* (a trial's list of
  groups has no meaningful index — two trials that partition IDs identically but list
  the groups in a different order are duplicates) and (b) within-group ID vector order.
  Canonicalize each trial as a sorted-IDs-per-group, then groups-sorted-by-signature,
  before comparing. Getting this wrong either under-dedups (near-identical candidates
  shown as distinct, confusing the user) or over-dedups (genuinely different candidates
  silently merged).
- **R5 — Exact-field-set test risk (Slice 2).** Adding a new top-level `candidates`
  field to `groupAddAssign()`'s return value is additive and backward-compatible for
  any test that reads specific named fields (`result$group`, `result$score`), but would
  break a test asserting the return value's *exact* field set via
  `expect_named(x, c("group", "score"))` (exact match, no `ignore.order`/superset
  tolerance). Grep `test_groupAddAssign.R` and `test_modBreedingGroups_groupAddAssign.R`
  for such an assertion before implementing; none was identified in this session's
  evidence-gathering, but neither was it exhaustively ruled out.
- **R6 — Module-contract compliance (Slice 2, `docs/architecture/module-contract.md`).**
  Rule 2 (every returned element is `reactive()`) — any new element added to
  `modBreedingGroupsServer`'s return list (e.g. an `nCandidates` reactive) must be
  wrapped. Rule 4 (no dangling unread reactive) — do not add a returned reactive with
  no real consumer; since `appServer.R` doesn't currently need multi-candidate
  visibility, keep new state internal to the module unless a concrete consumer is
  identified. Rule 3 (stable vocabulary) — if new elements are exposed, name them
  plainly (`candidates`, `selectedCandidate`), not per-consumer-renamed.

## 7. Owner ratification record

Ratified by the owner (repo owner / geneticist) via `AskUserQuestion`, Session 423
(2026-07-29), grounded in this session's firsthand research workflow findings (§2).

- [x] **D1** — depth = also expose internal cutoffs (`guCutoff`, `zScoreCutoff`,
  `axisPriority`), not just a combined-vs-categorical toggle.
- [x] **D2** — mechanism = Shiny UI control (per-analysis-run), not a config-file key.
- [x] **D3** — breeding-group candidates = top 5, deduplicated by partition content.
- [x] **D4** — slice order = ranking-scheme configurability (Slice 1) first,
  multi-candidate breeding groups (Slice 2) second.
