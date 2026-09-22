## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Issue #167 Plan — Longitudinal Genetic-Health Monitoring (Colony Snapshots and Trend Reporting)

**Session:** S756 (2026-09-21) · **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
· **Type:** design/architecture document, matching the #133/#136/#137/#145/#146/#147/#149/#150/#151/#152/#153
precedent — **zero `R/`/`tests/`/`man/` changes this session.** This plan answers the nine open
design questions (Q1–Q9) recorded in the S755 scope-narrowing record
(`docs/planning/issue167-longitudinal-monitoring-scoping-2026-09-21.md` §4) as ratified,
numbered decisions. Implementation is gated on §11's ratification; each §5 slice is a separate
strict-TDD session.

---

## 1. Context

### 1.1 What issue #167 asks for

The verbatim issue body is quoted in full in the scoping record (§2.1) and is not repeated
here. In one sentence: the package's genetic-health summaries are one-time snapshots; #167
asks for a longitudinal workflow — persist dated colony snapshots under a defined schema,
define membership-consistency rules so successive snapshots compare like with like, and
report trends over time (mean kinship, founder representation, genome uniqueness) so a
colony manager can see whether genetic health is improving or eroding. The issue's own
closing gate line requires this design before implementation; the S755 narrowing comment
(issue #167 comment 5767523393) records that the design and implementation stay under this
one issue number.

### 1.2 What is already decided (do not re-litigate)

- **Design-first, same issue** (S755 owner decision, scoping record §1): this plan is the
  gate being satisfied; implementation slices follow only after §11 ratification.
- **Hard constraints carried in regardless of any Q answer** (scoping record, end of §4):
  snapshots record the outputs of the existing estimators and never fork or reimplement
  them; no writes outside user-designated locations (CRAN policy — user-directed
  persistence only); Monte Carlo uncertainty is surfaced, never hidden, wherever `gu`/`fg`
  trends are shown; "cohort" is never used bare for the membership-consistency concept
  (D3); the existing one-time summaries (GVA report, Genetic Diversity dashboard, Summary
  Statistics) change zero behavior.
- **The reader/validator mold** (`readKinshipOverrides()`/`checkKinshipOverrides()`,
  `readTwinRelations()`/`checkTwinRelations()`, `checkMhcHaplotypeFile()`) is the
  established shape for a user-maintained CSV sidecar: reader handles CSV/Excel, validator
  `stop()`s with a specific violation and returns the coerced table.
- **The app's only write path is a user-initiated `downloadHandler`** (e.g.
  `R/modGeneticValue.R:505-516`) — verified again this session; any persistence design must
  respect it.
- **`docs/architecture/module-contract.md`** (issue #122) governs any new Shiny module:
  reactive-in/reactive-out, stable return vocabulary, `req()` for upstream absence vs. a
  surfaced error for malformedness, every parameter and return documented.

### 1.3 What this session verified directly

Every load-bearing claim below was re-read from source this session (not trusted from the
scoping record). Two corrections to the scoping inventory surfaced and are incorporated:

- `calcFounderContributions()` is **internal** (`@noRd`, `R/calcFounderContributions.R:26`),
  and so is `getLivingBreeders()` (`@noRd`, `R/getLivingBreeders.R:17`). The scoping
  record's "hard constraints" sentence names `calcFounderContributions()` as an estimator
  snapshots record outputs of — that stays true, but **via `reportGV()`'s returned
  `fe`/`fg`/founder-count fields**, which already embed it; no slice may export or fork the
  internals (§7 Dragon 2).
- The canonical per-animal report columns are **`indivMeanKin`/`gu`**
  (`R/normalizeGvReport.R:6-26`); the colony-wide Summary Statistics aggregates are
  `summary()` six-number summaries plus `calcSkewness()`/`calcKurtosis()` over exactly
  those columns (`R/makeGeneticSummaryTable.R:31-67`). D1's aggregate fields reuse these
  definitions unchanged.

Also verified: `reportGV()` returns the colony scalars `fe`, `fg`, `fgSE`, `neGD`,
`neSexRatio`, `neVariance`, `nMaleFounders`/`nFemaleFounders`/`total` and the per-animal
`report` (with `guSE`, `flagged`) plus the kinship matrix, and exposes **no seed
parameter** (`R/reportGV.R:72-109,149`; only `gvaConvergence()` takes `seed`,
`R/gvaConvergence.R:121`); the ORIP Reporting tab's Coming Soon list promises "Inbreeding
trends over time" (`R/modORIPReporting.R:108`); `reportGV()` output flows through the app
as the `shared$geneticValues` reactive (`R/appServer.R:339-471`) — the natural upstream for
in-app snapshot generation; the app has 15 top-level tabs (`R/appUI.R`);
`makeFounderStatsTable()` and `getGeneticDiversityStats()` are exported; `ggplot2` is
already an Import (`DESCRIPTION:45`); no function, file, or symbol named
`*snapshot*`/`*Snapshot*`/`membershipRule` exists in `R/` (comments only) — the D-series
names below are collision-free; no `schemaVersion` precedent exists anywhere in the
package (this design introduces the first).

---

## 2. Evidence-based inventory

The scoping record §3 carries the full 14-row grep-verified inventory (2026-09-21, S755);
this session re-verified the load-bearing rows directly (§1.3) rather than duplicating the
table. Net: **every metric a snapshot records already exists and is computed by
`reportGV()`/`meanKinship()`/the #126 shape statistics; nothing longitudinal exists — no
persistence, no trend computation, no as-of-date reconstruction.** The additional facts this
plan rests on beyond that table are exactly the §1.3 verifications above.

---

## 3. Design decisions

Nine decisions, answering Q1–Q9 one-for-one. D3, D4, D8, D9 are **forced or
evidence-determined** — listed with their reasoning for the implementing sessions' benefit.
D1, D2, D5, D7 are **genuine judgment calls**, ratified via a single `AskUserQuestion`
round in §11. D6 has a judgment sliver (threshold flags) folded into its own framing rather
than voted separately, matching the #152 precedent for narrow-consequence choices.

**D1 (judgment call — answers Q1). Snapshot content: aggregate-only, one row per
snapshot.** One snapshot is a single wide row with three field groups:

- *Provenance/comparability fields (D4):* `schemaVersion` (integer, starts at `1L`),
  `snapshotDate` (ISO-8601 date), `packageVersion`, `membershipRule` (D3), `guIter`,
  `guThresh`, `nAnimals`, `nMales`, `nFemales` (composition counts double as a population
  fingerprint).
- *Colony scalars, verbatim from `reportGV()`:* `fe`, `fg`, `fgSE`, `neGD`, `neSexRatio`,
  `neVariance`, `nMaleFounders`, `nFemaleFounders`, `nFounders`.
- *Colony aggregates of per-animal metrics, using the Summary Statistics definitions
  unchanged (§1.3):* mean/median of `indivMeanKin`, mean/median of `gu`, mean `guSE`, and
  the #126 shape statistics (`calcSkewness()`/`calcKurtosis()`) for both `indivMeanKin`
  and `gu`.

The exact final column list (names, order, types) is Slice 1's RED-phase deliverable; this
decision fixes the three groups, the sources, and the rule that **every metric field is a
value `reportGV()`/`meanKinship()`/`calcSkewness()`/`calcKurtosis()` already produces** —
no new estimator. The issue's three named trend examples are covered: mean kinship (mean
`indivMeanKin`), founder representation (`fe`/`fg`/`neGD` — the package's existing
aggregate founder-representation measures), genome uniqueness (mean `gu`).
**Recommended: aggregate-only.** **Declined alternative:** optional per-animal detail rows
(richer retrospection, e.g. per-animal MK trajectories) — drags per-animal identifiers into
the persistence path and with them the #150 curator-controlled export gate (Q8), roughly
doubles Slice 1's schema surface, and is additive later without breaking the v1 schema
(detail rows would be a sibling table, not a schema change; a future issue can add them
with their own Pre-RED gate).

**D2 (judgment call — answers Q2). Persistence: one user-maintained snapshot-history CSV,
read/validated/appended through exported functions; the app writes it only through a
user-initiated `downloadHandler`.** Concretely: `readSnapshotHistory()` +
`checkSnapshotHistory()` follow the kinship-overrides reader/validator mold exactly;
`appendColonySnapshot()` is a **pure function** (history + new row in, merged history out —
it writes nothing). Script users persist with `write.csv()` wherever they choose; the app's
Slice-4 tab offers "download updated history" (`downloadHandler`, the established
`R/modGeneticValue.R:505` shape). Format: CSV (every sibling reader is CSV), full-precision
numeric writing (§7 Dragon 5), `schemaVersion` column from day one. **Recommended: single
history CSV.** **Declined alternatives:** (b) one file per snapshot in a directory
(`saveDataframesAsFiles()`/`getDatedFilename()` mold) — pushes the merge/ordering problem
onto every reader, and a directory of dated files is harder to validate as one schema'd
object; (c) an auto-managed snapshot directory via the site-config `homeDir` precedent
(`R/getSiteInfo.R:60`) — an app that writes on its own schedule to a configured location
sits exactly on the CRAN write-policy line the hard constraints rule out; nothing stops a
*user* pointing their own scripts at a configured directory later.

**D3 (forced — answers Q3). Membership-consistency vocabulary and mechanism: the term is
"membership rule," recorded in the snapshot as an enumerated `membershipRule` field;
trend comparability is established by grouping on it.** The word "cohort" is never used
for this concept — it already means the breeding-age peer cohort
(`R/correctUnknownParentMeanKinship.R`, `getBreedingPeerCohort`) and the fRoh comparison
cohort (`R/computeGenomicROH.R:27`); the collision was flagged at scoping (Q3) and the
reservation follows the #152 D4 / #153 D1 vocabulary-discipline precedent. The v1
enumeration is fixed by Slice 2's RED phase from what the generation path can actually
guarantee (at minimum: the whole passed pedigree, and the focal population per
`getGVPopulation()`); the schema field is a string, so new rule names are additive. The
id-set-recording variant (Q3 option b) travels with per-animal detail rows and is declined
with them (D1). Composition counts (`nAnimals`, `nMales`, `nFemales`) are recorded beside
the rule as a cross-check, because a rule name alone cannot prove two snapshots' populations
were assembled consistently (§7 Dragon 3).

**D4 (forced — answers Q4). Comparability and stochasticity guards: record `guIter`,
`guThresh`, `membershipRule`, `packageVersion`, and the composition counts in every
snapshot; the trend surface annotates/flags mixed-provenance series rather than refusing
them; SE ribbons are mandatory wherever a `gu`- or `fg`-derived trend is drawn.**
`reportGV()` exposes no seed (§1.3), so successive snapshots differ within Monte Carlo
sampling error even on identical input; `fgSE`/mean `guSE` are already in the schema (D1)
and quantify exactly that. Flag-don't-refuse because refusing punishes legitimate
long-horizon series (a colony manager upgrading the package or raising `guIter` mid-series
should see a marked discontinuity, not lose their history); the flag must be visible in
both the script output (a comparability column/attribute from Slice 3's trend functions)
and the Slice 4 UI (plot annotation + table column). This is the "Monte Carlo uncertainty
is surfaced, never hidden" hard constraint made mechanical.

**D5 (judgment call — answers Q5). Prospective-only in v1; retrospective backfill is
deferred to a clearly-caveated optional Slice 5 with its own fresh Pre-RED gate, not part
of this ratification.** Snapshots are recorded as generated, from the analysis state the
user is looking at. **Recommended: prospective-only.** **Declined alternative (for v1):**
shipping a retrospective generator now — as-of-date population reconstruction from
birth/exit dates inherits exit-data incompleteness, cannot reconstruct historical breeder
flags or focal-population designations (so `neSexRatio`/`neVariance` and focal-rule
snapshots would be silently wrong, not just approximate), and is exactly the kind of
scientifically-caveated feature that deserves its own design round once real prospective
series exist. The middle path from scoping (ship prospective, retrospective later) is
adopted as the slice structure itself.

**D6 (evidence-determined, with one folded judgment — answers Q6). Trend outputs for v1:
per-metric time-series plots (ggplot2, already an Import) with SE ribbons per D4, plus a
delta table between any two user-chosen snapshots. Threshold-based improving/eroding
verdicts are declined for v1.** The folded judgment: an automatic "your colony's genetic
health is eroding" verdict requires a scientifically defensible threshold per metric that
neither the issue, the reference PDF summary, nor any existing package precedent supplies —
shipping one ad hoc would put unowned scientific judgment into a displayed conclusion.
Plots + deltas + the D4 comparability flags give the colony manager the trajectory; the
verdict stays human. A future issue can add thresholds with literature grounding. All v1
trend displays are existing statistics displayed over time — the Slice 4 session still
runs the issue #120 citation checklist to confirm no *new* displayed statistic slipped in
(§9), and the plain-language NEWS.Rmd criterion (S628) applies to every shipping entry.

**D7 (judgment call — answers Q7). Surface: a new, dedicated module and top-level tab
(working name `modSnapshotTrends`, user-facing label "Genetic-Health Trends"), not a home
inside the ORIP Reporting tab.** The workflow needs an upload (history CSV), a
generate-snapshot action fed by the `shared$geneticValues` reactive (`R/appServer.R:339`),
trend plots/tables, and two downloads (updated history; trend table) — a full
upload-compute-download workflow, which is the one-feature-one-module convention
(#149/#150/#151) rather than a section of someone else's report page. The ORIP tab's
"Inbreeding trends over time" Coming Soon bullet (`R/modORIPReporting.R:108`) is **left
untouched in v1** — the #153 D6 "zero changes to existing tabs" constraint carries over
verbatim; once the new tab ships, a separate one-line follow-up (ordinary Housekeeping) may
update that placeholder to point at it, gated by its own session. Becomes the 16th
top-level tab. **Recommended: new module.** **Declined alternative:** extend
`modORIPReporting.R` — it puts an interactive workflow inside a static reporting module,
couples #167's ship date to ORIP-report styling concerns, and violates the
zero-changes-to-existing-tabs constraint in the very slice that ships the feature.

**D8 (forced — answers Q8). Export gating: aggregate-only snapshots (D1) carry no
per-animal identifiers, so the snapshot history and every v1 trend output bypass the #150
curator-controlled de-identification gate — and the boundary is recorded here: any future
per-animal detail rows (D1's declined alternative) MUST route through the #150 gate, in
the `obfuscateTwinRelations()` sidecar mold, as a precondition of that future design.**
Colony-level scalars (mean kinship, `fe`, `fg`, counts by sex) are population statistics of
the whole managed colony, not per-individual genetic data; the Homer-et-al-style
aggregate-reidentification concern documented for #152's sequence data (marker-genetics
plan §2.7) targets per-individual genotype membership and does not attach to a dozen
pedigree-derived colony scalars. Slice 4's downloads therefore use plain
`downloadHandler`s, matching the existing GVA-report download precedent.

**D9 (forced shape — answers Q9). Slice decomposition: four v1 slices (schema/IO →
generation → trends → UI), each one session, strict TDD, `AskUserQuestion`-gated phases,
plus the deferred optional Slice 5 (retrospective, own Pre-RED).** Detailed in §5. The
order is dependency-forced: generation writes rows the schema defines; trends read what
generation writes; the UI wires all three. Each slice leaves the package shippable
(script-callable value accrues from Slice 2 onward, before any UI exists) — the vertical
slicing FM #25 test ("if I stop here, is something working?") passes at every boundary.

---

## 4. Interface catalog (proposed — for the implementing sessions, not built this session)

| Interface | Kind | Input | Output | Error | Consumers |
|---|---|---|---|---|---|
| `checkSnapshotHistory(history)` | New `@export`ed validator (D2), `checkKinshipOverrides()` mold | snapshot-history data.frame | the coerced history, invisibly usable; `stop()` with a specific violation otherwise | missing columns, non-numeric metric fields, unknown `schemaVersion`, duplicate (`snapshotDate`, `membershipRule`) pairs, malformed dates | `readSnapshotHistory()` callers, Slice 4 tab, script users |
| `readSnapshotHistory(fileName, sep = ",")` | New `@export`ed reader (D2), `readKinshipOverrides()` mold (CSV/Excel) | file path | raw data.frame (validated separately by `checkSnapshotHistory()`, matching the sibling-pair convention) | file-level read errors surface as-is | Slice 4 tab, script users |
| `createColonySnapshot(ped, geneticValue, membershipRule, snapshotDate = Sys.Date())` | New `@export`ed generator (D1/D3/D4) | pedigree df; an `nprcgenekeeprGV` object (from `reportGV()`); rule string; date | one-row data.frame in the D1 schema | `stop()` on a malformed/incomplete `geneticValue` object or unknown `membershipRule`; never recomputes or forks estimators | Slice 4 tab, script users |
| `appendColonySnapshot(history, snapshot)` | New `@export`ed pure merge (D2) | validated history (or NULL/empty for a first snapshot); one-row snapshot | merged history, date-ordered | `stop()` on schema-version mismatch or duplicate (`snapshotDate`, `membershipRule`) | Slice 4 tab, script users |
| `calcSnapshotDeltas(history, from, to)` | New `@export`ed trend function (D6) | validated history; two snapshot dates | per-metric delta table with the D4 comparability flag column | `stop()` when either date is absent | Slice 4 tab, script users |
| `plotSnapshotTrends(history, metrics = NULL)` | New `@export`ed plot function (D4/D6) | validated history; optional metric subset | ggplot object(s): time series, SE ribbons where `fgSE`/mean-`guSE` apply, mixed-provenance annotation | `stop()` on empty/single-row history (a trend needs ≥ 2 points — message says so) | Slice 4 tab, script users |
| `modSnapshotTrendsUI(id)` / `modSnapshotTrendsServer(id, pedigree, geneticValues, ...)` | New Shiny module + 16th top-level tab (D7), module-contract-compliant | namespace id; the existing `pedigree`/`geneticValues` reactives (`R/appServer.R` wiring) | named list of reactives (stable vocabulary fixed at Slice 4 RED); history upload, generate/append actions, trend plots/tables, two `downloadHandler`s | `req()` for upstream absence; surfaced errors for malformed uploads (rule 5) | `R/appUI.R`, `R/appServer.R` |

Vocabulary note (D3): no interface, column, or doc uses bare "cohort" for the
membership-consistency concept.

Implementation note (S758, 2026-09-21 — Slice 2 shipped): the ratified signature is
`createColonySnapshot(ped, geneticValue, membershipRule, guIter, guThresh,
snapshotDate = Sys.Date())` — `guIter`/`guThresh` are **required, no-default**
arguments (owner decision via `AskUserQuestion`) because the `nprcgenekeeprGV`
object does not carry them and this plan's impact table keeps `reportGV()`
unchanged; a default could silently record false D4 provenance. The claimed
`membershipRule` (v1 enumeration: `wholePedigree`, `focalPopulation`) is verified
against `ped`/report ids and a contradiction `stop()`s (second owner decision).
Slice 4's module wiring must pass the app's own `reportGV()` call-site
`guIter`/`guThresh` values through.

Implementation note (S759, 2026-09-21 — Slice 3 shipped): the ratified
signature is `calcSnapshotDeltas(history, from, to, membershipRule = NULL)`
— the `membershipRule` argument was added to this catalog's signature
(owner decision via `AskUserQuestion`) because a snapshot is identified by
the (`snapshotDate`, `membershipRule`) pair and the Slice 1 fixture's own
shared-date/different-rule pair proves date-only selection ambiguous;
`NULL` auto-resolves a single-rule history, and deltas never cross rules
(D3). The delta table carries 21 rows (18 metrics + the 3 composition
counts, Dragon 3) with a per-metric `comparabilityFlag` whose sets are
evidence-based: `guIter` → the 8 gene-drop metrics (`fg`/`fgSE`/`neGD` +
the 5 `gu` aggregates), `guThresh` → the 5 `gu` aggregates only,
`packageVersion` → all rows. `plotSnapshotTrends()` returns ONE faceted
ggplot; plot verification is structural inspection (recorded choice —
vdiffr NOT added to Suggests). Slice 4's wiring consequence: the module
must supply `membershipRule` for delta computation (e.g. a rule selector
fed from the uploaded history) in addition to the S758
`guIter`/`guThresh` pass-through above.

Implementation note (S760, 2026-09-22 — Slice 4 shipped): the ratified
signature is `modSnapshotTrendsServer(id, snapshotSource)` — the
`pedigree`/`geneticValues` reactives this catalog row proposed are
superseded by ONE new reactive, `snapshotSource`, added to
`modGeneticValueServer`'s own return list (owner decision via
`AskUserQuestion`): a list `(ped, geneticValue, guIter, guThresh)`
captured atomically inside `modGeneticValueServer`'s `gvResults()`
eventReactive body, mirroring `modDeidentifiedExportServer`'s
exportRaw params-snapshot pattern (issue #150) so a slider changed
after a run can never make the recorded provenance drift from what
was actually analyzed — this resolves both S758's and S759's wiring
consequences above (`guIter`/`guThresh` pass-through; `geneticValue`
itself) from a single upstream reactive, and satisfies module-contract
rule 6 (every declared parameter read) where the original two-reactive
signature would have left `pedigree`/`geneticValues` unread. The
generated snapshot's `membershipRule` is auto-derived from
`snapshotSource()$ped$population` (second owner decision) rather than
a user-set dropdown, satisfying the interface catalog's D7 intent
without the delta comparison's own user-facing rule selector (S759's
consequence) changing shape.

---

## 5. Implementation plan — vertical slices (each its own future session)

**This design session implements no slice.** Every slice: strict TDD
(RED→GREEN→REFACTOR, `AskUserQuestion`-gated), full-suite regression + lint close-out
checklists per `CLAUDE.md`. Per-slice completion criteria name their verification surface;
none of these surfaces exercises LabKey-connected operation, which no slice claims.

### Slice 1 — Schema + history IO (script-callable only)
**Touches:** new `R/checkSnapshotHistory.R`, `R/readSnapshotHistory.R`,
`R/appendColonySnapshot.R` + tests; a committed example fixture
`inst/extdata/examples/example_snapshot_history.csv` (hand-authored, ≥ 3 snapshots, ≥ 2
`membershipRule` values, a deliberate mixed-`guIter` pair for D4 testing); `_pkgdown.yml`
entries; NEWS.Rmd entry. RED phase fixes the exact D1 column list.
**Done when:** validator accepts the fixture and rejects each violation class with a
specific message (per-violation tests); `appendColonySnapshot()` round-trips
(read → append → write.csv → read → identical); full suite + `lintr` clean.
**Surface:** local test suite (`NOT_CRAN=true`) + `devtools::check()`. This surface cannot
demonstrate app behavior — none is claimed until Slice 4.

### Slice 2 — Snapshot generation (script-callable only)
**Touches:** new `R/createColonySnapshot.R` + tests; NEWS.Rmd; `_pkgdown.yml`.
**Done when:** on the `examplePedigree`/`qcPed` fixtures, every field of the generated row
equals the hand-derived value from the same `reportGV()` object (exact for scalars/counts;
the aggregate fields must equal `summary()`/`calcSkewness()`/`calcKurtosis()` applied to
the report columns — proving reuse, not reimplementation); a grep-based proof that no
estimator internals are duplicated (no new kinship/gene-drop math anywhere in the diff);
error paths tested (malformed GV object, unknown rule); full suite + lint clean.
**Surface:** local test suite + `devtools::check()`, as Slice 1.

### Slice 3 — Trend computation (script-callable only)
**Touches:** new `R/calcSnapshotDeltas.R`, `R/plotSnapshotTrends.R` + tests; NEWS.Rmd;
`_pkgdown.yml`.
**Done when:** deltas match hand-computed values on the Slice 1 fixture; the
mixed-`guIter` fixture pair is flagged (D4) in both the delta table and the plot
annotation (vdiffr or structural ggplot inspection — the implementing session chooses and
records which); SE ribbons present exactly on `fg`- and `gu`-derived metrics; the ≥ 2-point
guard tested; full suite + lint clean; issue #120 citation check run against the outputs
(expected result: no new displayed statistic — record the check, not just the expectation).
**Surface:** local test suite + `devtools::check()`. Plot rendering is verified as ggplot
object structure/snapshot, not human visual review — said plainly here so Slice 4's live
look is the first human-eyes surface.

### Slice 4 — Module, wiring, downloads, documentation
**Touches:** new `R/modSnapshotTrends.R`; `R/appUI.R` (16th tab), `R/appServer.R` (wire
`pedigree`/`geneticValues` reactives in, matching `R/appServer.R:339-471` conventions);
tests incl. module-contract mechanical test; `shinytest2` e2e; NEWS.Rmd (plain-language,
S628); tutorial/article checklist (S436: `vignettes/articles/colony-manager-guide.qmd`
and/or matching manual component); `_pkgdown.yml`; issue #120 citation checklist re-run on
the shipped UI.
**Done when:** `shinytest2` drives the full path — upload fixture history → generate a
snapshot from loaded example data → append → download updated history → trend plot/table
render with the D4 flag visible — with zero console errors; existing 15 tabs byte-unchanged
(the D7 zero-changes constraint, verified by diff scope); full suite + lint clean.
**Surface:** `shinytest2` headless Chrome (the Phase 3E bar for this cluster) + local
suite + `devtools::check()`. This surface cannot enforce LabKey-connected behavior or
non-headless browser quirks; neither is claimed. **Close-out includes commenting on issue
#167** that v1 is shipped (the issue stays open only if Slice 5 is still contemplated —
that session's owner call, made explicitly at its close-out).

### Slice 5 (deferred, optional — NOT ratified by this plan) — Retrospective backfill
A clearly-caveated generator reconstructing approximate historical snapshots from
birth/exit dates. **Requires its own fresh Pre-RED design gate** (D5): the caveat model
(what cannot be reconstructed: historical breeder flags, focal designations, exit-data
gaps) is its central design problem, not an implementation detail. Do not start it from
this plan alone.

---

## 6. Impact analysis

| System | Impact | Action required |
|---|---|---|
| `reportGV()` / `meanKinship()` / `calcSkewness()` / `calcKurtosis()` | **Unchanged** — consumed, never modified or forked (D1, Slice 2's grep proof). | None. |
| `calcFounderContributions()` / `getLivingBreeders()` (internal) | **Unchanged and never exported** — their outputs reach snapshots only through `reportGV()`'s return fields (§1.3 correction). | Slice 2 must not `@export` or duplicate them. |
| Existing one-time summaries (GVA report, Genetic Diversity dashboard, Summary Statistics, ORIP tab) | **Zero behavior change** (hard constraint; D7 leaves the ORIP placeholder untouched). | Slice 4 verifies by diff scope. |
| `modORIPReporting.R` Coming Soon bullet | Untouched in v1; a later one-line Housekeeping follow-up may point it at the new tab. | None this cluster. |
| `appUI.R` / `appServer.R` | 16th tab + module wiring at Slice 4 only. | Module-contract compliance check. |
| `DESCRIPTION` | **Unchanged** — CSV IO is base/utils; plots use `ggplot2` (already an Import). | Re-confirm no new dependency at each slice close-out. |
| #150 export gate (`modDeidentifiedExport.R`) | Untouched in v1 (D8); named precondition for any future per-animal detail. | None. |
| Issue #168 (ancestry guardrails, future) | No shared surface; both consume existing kinship machinery read-only. | None — informational. |
| CRAN policy posture | No new write path: pure functions + `downloadHandler` only (D2). | Slice reviewers check no `write.*` lands outside tests/examples' tempdir. |

---

## 7. Here be dragons

1. **No seed in `reportGV()` means no two snapshots are exactly reproducible** — `gu`/`fg`
   fields carry sampling noise by construction. D4's guards make the noise *visible*
   (`fgSE`/mean `guSE`, SE ribbons, provenance fields) but cannot remove it; a user
   comparing two close-together snapshots may see pure Monte Carlo motion. The Slice 3/4
   sessions must not "fix" this by adding a seed to `reportGV()` — that reopens a
   signature-stability question far beyond #167's scope; if trend users need
   reproducibility, `gvaConvergence(seed=)` guidance belongs in the documentation, and a
   `reportGV()` seed parameter would be its own issue.
2. **Internal-function temptation (§1.3):** `getLivingBreeders()` and
   `calcFounderContributions()` are `@noRd`. A generation-slice session tempted to call or
   export them directly for extra composition fields (e.g. `nLivingBreeders`) is making an
   API change this plan did not ratify — bring it back to an `AskUserQuestion` instead.
   The v1 composition counts (D1) are computable from the population data.frame alone.
3. **A `membershipRule` string cannot prove consistency.** Two "focal population"
   snapshots depend on what the user had designated focal at each generation time
   (`setPopulation()` state). The composition counts are a cross-check, not a proof; the
   documentation (Slice 4's article section) must say plainly that rule + counts is a
   consistency *aid*, and radical membership churn between snapshots is visible in
   `nAnimals`, not prevented by the schema.
4. **Schema evolution has no precedent in this package.** `schemaVersion` starts at `1L`
   and `checkSnapshotHistory()` must reject versions it does not know — the cheap
   insurance that makes every later schema change (per-animal detail, new rules, new
   metrics) additive instead of silently misread. Slice 1 tests the unknown-version
   rejection explicitly.
5. **CSV numeric round-trip:** a rounded write (e.g. default `format()` behavior in a
   hand-rolled writer) would inject artificial deltas into trends. D2 requires
   full-precision writing (`write.csv` default is adequate; the round-trip test in Slice 1
   is the guard). Excel-edited histories may still lose precision — the validator cannot
   detect that; the article's user guidance should warn against editing metric columns by
   hand.
6. **The 16th top-level tab** adds to an already-wide navbar (15 tabs, `R/appUI.R`).
   Cosmetic overflow behavior on narrow windows is possible; Slice 4's `shinytest2` pass
   should include one viewport-width sanity check, and a genuinely crowded result is a
   note for the app-navigation Housekeeping thread, not a reason to bury the feature in an
   existing tab.

---

## 8. Alternatives considered

| Alternative | Pros | Cons | Why rejected |
|---|---|---|---|
| Per-animal detail rows in v1 (Q1) | Richer retrospection (per-animal MK trajectories) | Identifiers in the persistence path → #150 gate required; double schema surface; not needed for any issue-named trend | D1 — aggregate-only; detail additive later behind its own gate (D8) |
| Per-snapshot files in a directory (Q2b) | Matches `getDatedFilename()` export habit | Merge/order/validation pushed onto every consumer; no single schema'd object | D2 — one history CSV |
| Site-config auto-persistence (Q2c) | Zero-click convenience | Sits on the CRAN unattended-write line the hard constraints rule out | D2 — user-directed only; users may still script their own configured location |
| Record id sets per snapshot (Q3b) | Exact fixed-membership trend intersections | Identifiers in persistence (same #150 drag as detail rows); large rows | D3 — rule + composition counts in v1 |
| Refuse mixed-provenance trend series (Q4) | Simplest correctness story | Punishes legitimate long series (package upgrades, guIter changes); loses history | D4 — flag/annotate, never hide |
| Retrospective backfill in v1 (Q5) | Immediate trend from one studbook | Silently-wrong reconstructed fields (breeder flags, focal sets); its caveat model is a design problem of its own | D5 — deferred Slice 5, own Pre-RED |
| Threshold improving/eroding verdicts (Q6) | Instant answer to the manager's question | No defensible threshold exists in issue, PDF, or package precedent; unowned scientific judgment in a displayed conclusion | D6 — plots + deltas + flags; verdict stays human |
| Home the feature in the ORIP tab (Q7) | The Coming Soon bullet already points there | Interactive workflow inside a static reporting module; violates zero-changes-to-existing-tabs in the shipping slice | D7 — dedicated module, ORIP placeholder untouched |

---

## 9. Close-out checklist mapping

Design-only session — no `R/`/`tests/`/`man/` changes, so every checklist is **N/A this
session**, owed at the §5 slices:

- **NEWS.Rmd (plain-language, S628):** owed at Slices 1–4 (each ships exported functions
  or the tab).
- **`_pkgdown.yml` reference coverage:** owed at Slices 1–4 (every new `@export`).
- **Citation checklist (issue #120):** run at Slices 3 and 4; expected N/A (no new
  displayed statistic — D6), recorded, not assumed.
- **Tutorial/article checklist (S436):** owed at Slice 4 (the user-facing tab).
- **`a2interactive.Rmd` checklist:** deferred to the standing documentation pass, per its
  own rule (new exported functions from Slices 1–3 join that pass's inventory).
- **Lint close-out:** every slice (each touches `.R` files).
- **Issue close-out:** #167 stays open through the slices; the Slice 4 close-out makes the
  explicit open/close call (§5).

---

## 10. Provenance

Built from the S755 scoping record (`docs/planning/issue167-longitudinal-monitoring-scoping-2026-09-21.md`)
— issue body, audit gate context, evidence inventory, Q1–Q9 — plus this session's direct
source verification of every load-bearing claim (§1.3): `R/reportGV.R` (returns, signature,
no seed), `R/normalizeGvReport.R` + `R/makeGeneticSummaryTable.R` (canonical columns and
aggregate definitions), `R/meanKinship.R`, `R/calcFounderContributions.R` +
`R/getLivingBreeders.R` (`@noRd` — the two inventory corrections),
`R/gvaConvergence.R` (`seed`), `R/modORIPReporting.R:95-115` (placeholder),
`R/appServer.R:339-471` (`shared$geneticValues` wiring), `R/appUI.R` (15 top-level tabs),
`R/readKinshipOverrides.R` + `R/checkKinshipOverrides.R` (the IO mold),
`R/getSiteInfo.R:55-70`, `R/getDatedFileName.R`, `R/saveDataframesAsFiles.R`,
`R/modGeneticValue.R:505-516` (`downloadHandler` write path),
`R/getGeneticDiversityStats.R` + `R/makeFounderStatsTable.R` (export status),
`DESCRIPTION:45` (`ggplot2`), and a repo-wide collision grep for the proposed
`*Snapshot*`/`membershipRule` names (comments only — clear). Mold documents read in full
or in structural part: `docs/planning/issue152-sequence-input-genetic-metrics-plan.md`
(in full), `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md` (decision/slice
structure). No decision above rests on an unverified claim.

---

## 11. Ratification status — forced vs. judgment-call decisions

**Forced / evidence-determined (no vote; listed for the implementing sessions):** D3
(vocabulary collision is documented fact; rule-in-schema is the only variant that survives
D1), D4 (direct consequence of the no-seed fact + the surfaced-uncertainty hard
constraint), D8 (aggregate-only rows carry no identifiers; the future-detail precondition
is recorded, not decided), D9 (dependency-forced order), D6 (evidence-determined output
set; its folded threshold-verdict decline is narrow-consequence — a future issue can add
thresholds without reopening anything here).

**Genuine judgment calls put to the owner in one `AskUserQuestion` round:** D1 (schema
breadth: aggregate-only vs. + per-animal detail), D2 (persistence: one history CSV vs.
per-snapshot files vs. site-config directory), D5 (prospective-only v1 vs. retrospective
in v1), D7 (surface: dedicated new module/tab vs. ORIP-tab home).

### Ratification outcome (2026-09-21, this session)

Owner selected this document's own recommended option in all four cases, via a single
`AskUserQuestion` round:

- **D1 — aggregate-only snapshot rows.** No per-animal identifiers in v1 persistence; the
  #150 gate stays out of scope, and per-animal detail remains additive later behind its
  own Pre-RED gate (D8's recorded precondition).
- **D2 — one user-maintained snapshot-history CSV.** Reader/validator/pure-append exported
  functions in the kinship-overrides mold; the app writes only through a user-initiated
  `downloadHandler`; `schemaVersion` from day one.
- **D5 — prospective-only v1.** Retrospective backfill stays a deferred, optional Slice 5
  requiring its own fresh Pre-RED design gate — it is NOT ratified by this plan.
- **D7 — new dedicated module + 16th top-level tab** (working name `modSnapshotTrends`,
  label "Genetic-Health Trends"). The ORIP Coming Soon placeholder is untouched in v1.

No changes requested to any recommended design. **This design is ratified and ready for
Slice 1 implementation in a future session** — matching the
#133/#136/#137/#145/#146/#147/#149/#150/#151/#152/#153 precedent of a design-only session
with zero `R/`/`tests/`/`man/` changes. Issue #167 stays intentionally open (design
ratified, not yet implemented); no `gh issue close` this session.
