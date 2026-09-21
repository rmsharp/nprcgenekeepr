## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Issue #167 — Longitudinal Genetic-Health Monitoring: Scope-Narrowing Decision Record

**Status:** Scope-narrowing decision record (Session 755, 2026-09-21). Docs-only session —
zero `R/`/`tests/`/`man/` changes. This document is **not** the issue #167 design plan; it
records the owner's scope decision that #167's own closing gate line requires before any
implementation, plus the evidence inventory the future design-plan session starts from. The
design plan itself (`docs/planning/issue167-longitudinal-monitoring-plan.md`) is a separate,
later session's deliverable, and implementation is gated on that plan being ratified —
matching the #148 scoping precedent
(`docs/planning/issue148-mhc-haplotype-scoping-2026-09-17.md`) and the
#133/#136/#137/#145/#146/#147/#149/#150/#151/#152/#153 design-first mold.

---

## 1. The decision

**Owner decision (2026-09-21, S755, via `AskUserQuestion`): "Design-first, same issue."**

Issue #167 advances design-first *without* filing a new sub-issue: the next #167 session
writes `docs/planning/issue167-longitudinal-monitoring-plan.md` in the #152/#153 mold
(numbered design decisions, vertical-slice list, per-slice completion criteria, each slice a
separate strict-TDD session), and implementation slices follow only after that plan is
ratified. An issue comment on #167 records this narrowing so the issue's full-feature body is
read through this gate from now on.

**Rejected alternatives** (recorded so a future session doesn't re-litigate from scratch):

- **Split into a design-only sub-issue:** same work plus one more issue to track and close.
  Declined for #148 (S703) as unnecessary ceremony and declined again here — every prior
  design-first issue in this family kept design + implementation under one issue number with
  a plan doc in `docs/planning/`.
- **Implement as filed:** against the issue's own closing gate line ("Define the snapshot
  schema, consistent-cohort rules, and trend outputs in a Pre-RED design session before
  implementation") — the schema/cohort/comparability decisions in §4 would otherwise be made
  ad hoc mid-implementation.
- **Defer / park:** not chosen — the capability audit rates this gap **High** (tied with
  #147, above every Medium item), and #167 is the sequencing-audit Finding-#1 cluster's
  natural next item.

**Divergence from the S703 precedent, deliberate:** no new `BACKLOG.md` item is added for
the design-plan session. S753 (which filed #167/#168) moved this cluster's tracking out of
`BACKLOG.md` and onto the issues themselves; the issue plus this record plus the session
handoff make the next step discoverable without regrowing a mandated-read file (FM #28).

## 2. Source context

### 2.1 What issue #167 asks for (verbatim body, filed 2026-09-21, S753)

> **Source:** `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md`: Priority gap
> analysis, High — "Longitudinal genetic-health monitoring"; filed per
> `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` Finding #1 /
> Recommendation 2.
>
> The package's genetic-health summaries (genetic value analysis, kinship, founder
> representation, the Genetic Diversity dashboard) are one-time snapshots. The reference PDF
> emphasizes trajectory within a colony; one-time summaries cannot show drift or improvement
> across breeding seasons.
>
> Add a longitudinal monitoring workflow: persist dated colony genetic-health snapshots
> under a defined schema; define consistent-cohort rules so successive snapshots compare
> like with like rather than reflecting membership churn; and report trends over time (e.g.,
> mean kinship, founder representation, genome uniqueness) so a colony manager can see
> whether genetic health is improving or eroding.
>
> Define the snapshot schema, consistent-cohort rules, and trend outputs in a Pre-RED design
> session before implementation (same gate as #147).

### 2.2 Why the gate exists

The capability audit's priority table
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md`, "Priority gap analysis")
names the appropriate next step itself: *"Define snapshot schema, consistent-cohort rules,
and trend outputs before implementation."* The sequencing audit's Recommendation 2
(`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md:309`) directed that both
unticketed High gaps be *"filed as full-feature requests gated on a Pre-RED design session,
matching #147's own shape."* S753 filed the issue with exactly that gate line; this record
is the gate being exercised.

## 3. Evidence inventory — what exists now (grep-verified 2026-09-21)

Everything the issue calls a "one-time snapshot" genuinely exists and is the computation
source of truth a snapshot would record. Nothing longitudinal exists: `grep -rn -iE
"snapshot|longitudinal|trend|time.?series|season" R/` matches only unrelated
export-preview comments, one UI placeholder bullet (row below), and a gene-drop cohort
comment — no persistence, no trend computation, no as-of-date population reconstruction.

| Building block | Status | Evidence |
|---|---|---|
| Colony-level genetic-health scalars | **Exist.** `reportGV()` returns `fe`, `fg`, `fgSE`, `neGD` (gene diversity, #118), `neSexRatio`, `neVariance`, `nMaleFounders`/`nFemaleFounders`/`total` in one call | `R/reportGV.R:72-109` (`@return`), `:149` (signature) |
| Per-animal metrics | **Exist.** `report` dataframe: `value` (rank-ordered), `gu` + `guSE`, `flagged` (#127); kinship matrix returned alongside | `R/reportGV.R:72-109`; `R/normalizeGvReport.R` |
| Mean kinship | **Exists.** `meanKinship(kmat)` per-animal averages; colony mean is one step away | `R/meanKinship.R:28` |
| Distribution-shape statistics (#126) | **Exist.** `calcSkewness`, `calcKurtosis` (both exported), already summarized colony-wide for MK and GU | `R/calcSkewness.R:32`, `R/calcKurtosis.R:34`, `R/makeGeneticSummaryTable.R:63-66` |
| Founder representation | **Exists.** `calcFounderContributions()` (named founder mean-contribution vector), `makeFounderStatsTable()` | `R/calcFounderContributions.R:26`, `R/makeFounderStatsTable.R:37` |
| Group-level health summary (the Genetic Diversity dashboard, #112) | **Exists.** `getGeneticDiversityStats()` — one row per breeding group, color indices for Value/Origin/Production/Inbreeding; takes `currentDate` (age/production window only, not population reconstruction) | `R/getGeneticDiversityStats.R:45-52`; `R/makeGeneticDiversityHeatmap.R` |
| Population / membership designation | **Exists.** `setPopulation()` / `getGVPopulation()` (focal population column), `getLivingBreeders()` | `R/setPopulation.R:29`, `R/getGVPopulation.R:29`, `R/getLivingBreeders.R:18` |
| Monte Carlo convergence machinery (#2) | **Exists.** `gvaConvergence(..., seed)` — the only seed-pinnable entry point; `reportGV()` itself exposes **no seed parameter** | `R/gvaConvergence.R:112-119,189` |
| Dated-file export precedent | **Exists.** `getDatedFilename()`, `saveDataframesAsFiles()`; user-initiated `downloadHandler` is the app's only write path | `R/getDatedFileName.R:16`, `R/saveDataframesAsFiles.R:30`, `R/modGeneticValue.R:505-513`, `R/modBreedingGroups.R:718-726`, `R/modMatePair.R:237` |
| CSV reader + sibling-validator pattern | **Established.** `readKinshipOverrides`/`checkKinshipOverrides`, `readTwinRelations`/`checkTwinRelations`, `checkMhcHaplotypeFile` — the mold for a snapshot-history reader/validator | `R/readKinshipOverrides.R:35`, `R/readTwinRelations.R:35`, `R/checkMhcHaplotypeFile.R` |
| Site-config / home-directory precedent | **Exists.** `getSiteInfo()` carries `homeDir`; config-file discovery in `getConfigFileName()` | `R/getSiteInfo.R:60`, `R/getConfigFileName.R:16-18` |
| A trend surface already promised to users | **Placeholder only.** ORIP Reporting tab's "Coming Soon" list includes *"Inbreeding trends over time"* | `R/modORIPReporting.R:95-115` (bullet at `:108`) |
| Curator-controlled export gate for identifying tables (#150) | **Exists and reused** (#152 D7, #153 D9, #148 plan) | `R/modDeidentifiedExport.R` |
| Snapshot persistence, consistent-cohort rules, trend computation/reporting | **Missing** — the actual #167 gap | greps above |

## 4. Open design questions the plan session must decide (not decided here)

Numbered as questions (Q), deliberately *not* as ratified decisions (D) — ratifying them is
the design-plan session's deliverable, in the #152/#153 mold:

1. **Q1 — Snapshot content schema.** Which metrics constitute one dated colony snapshot?
   Natural candidates are exactly `reportGV()`'s colony-level scalars (fe, fg, fgSE, neGD,
   neSexRatio, neVariance, founder counts) plus colony aggregates of per-animal metrics
   (mean/median MK and GU, the #126 shape statistics) plus population-composition counts
   (N, by sex, living breeders). Sub-question with privacy and size implications: aggregate
   rows only, or optional per-animal detail rows (which would enable richer retrospection
   but drags in the #150 export gate — Q8)?
2. **Q2 — Persistence mechanism and format.** The app writes only through user-initiated
   `downloadHandler`s, and CRAN policy forbids writing outside user-designated locations
   without consent — persistence must be user-directed. Candidates: (a) one
   snapshot-history CSV the user maintains (append/merge via an exported function +
   `checkSnapshotFile()`-style sibling validator — the kinship-overrides mold); (b) one
   file per snapshot in a user-chosen directory (`saveDataframesAsFiles`/`getDatedFilename`
   mold); (c) an optional configured snapshot directory via the existing site-config
   (`homeDir` precedent). Format: CSV (every sibling reader is CSV) vs. RDS/JSON; either
   way the schema needs an explicit version column.
3. **Q3 — Consistent-cohort rules.** The issue's core scientific demand: successive
   snapshots must compare like with like despite membership churn. Candidates: (a) record
   the **membership rule** in the snapshot (e.g., "living focal-population animals",
   "living breeders", age-filtered) so re-applying the same rule at each date defines
   comparable populations; (b) record the **id set** itself and compute trends over fixed
   intersections; (c) both — rule recorded as schema fields, membership optionally recorded
   as detail rows. **Vocabulary discipline required:** "cohort" already means the
   breeding-age peer cohort in `correctUnknownParentMeanKinship.R:37` (`getBreedingPeerCohort`)
   and the fRoh comparison cohort (`R/computeGenomicROH.R:27`); the plan must pick a
   non-colliding term (e.g., "comparison population" / "membership rule") or explicitly
   reserve wording, as #148 did for "haplotype" vs. #153's "block".
4. **Q4 — Comparability and stochasticity guards.** `gu`/`fg` are Monte Carlo estimates;
   `reportGV()` exposes no seed, so two runs on identical input differ within sampling
   error (`guSE`/`fgSE` quantify it; `gvaConvergence()` measures it). What must the schema
   record for two snapshots to be trend-comparable (guIter, guThresh, population rule,
   package version, pedigree source/row-count fingerprint?) — and does the trend view
   refuse, flag, or annotate mixed-parameter series? Should trend plots carry SE ribbons so
   sampling noise is not read as drift?
5. **Q5 — Retrospective backfill vs. prospective-only.** Can a manager generate historical
   snapshots from today's studbook (birth/exit dates permit approximate as-of-date
   population reconstruction), or are snapshots only recorded as generated? Retrospective
   gives an immediate trend from one studbook but inherits exit-data incompleteness and
   cannot reconstruct historical breeder flags or genotype panels; prospective-only is
   honest but takes seasons to accumulate. A middle path: ship prospective recording, plus
   a clearly-caveated retrospective generator as a separate slice.
6. **Q6 — Trend outputs.** Which deliverables: per-metric time-series plots (ggplot2 is an
   Import), a delta table between chosen snapshots, threshold-based improving/eroding
   flags? Plain-language presentation for the colony-manager reader (NEWS.Rmd criterion
   S628 applies to the eventual entries); any *new* displayed statistic triggers the
   citation checklist (issue #120: `population_genetics_terms.html` + roxygen
   `@references` in the shipping session).
7. **Q7 — Surface placement.** A new tab vs. extending an existing one. The ORIP Reporting
   tab already promises "Inbreeding trends over time" in its Coming Soon placeholder
   (`R/modORIPReporting.R:108`) — is that the home, or does longitudinal monitoring deserve
   its own module (the app has 15 top-level tabs, `R/appUI.R:74-319`)? The #153 D6 "zero
   changes to existing tabs" constraint presumably carries over to whichever choice.
   Script-callable exported functions are required regardless (the `a2interactive.Rmd`
   checklist covers them at the deferred documentation pass).
8. **Q8 — Export/identifying-data gating.** Aggregate-only snapshots carry no per-animal
   identifiers and presumably bypass the #150 curator-controlled gate; per-animal detail
   rows (Q1) would not. Confirm the boundary in the plan and write any warning text in the
   established mold.
9. **Q9 — Slice decomposition.** Expected shape (subject to the plan): schema + validator/
   reader/writer slice (fixtures first); snapshot-generation slice (compute + record from
   current analysis state); trend-computation slice (comparability guards + statistics);
   UI/reporting slice (plots, tables, downloads). Each slice one session, strict TDD,
   `AskUserQuestion`-gated phases.

**Hard constraints carried into the plan regardless of Q answers:** snapshots record the
outputs of the existing estimators (`reportGV()`, `meanKinship()`, `calcFounderContributions()`)
and never fork or reimplement them; no writes outside user-designated locations (CRAN
policy — user-directed persistence only); Monte Carlo uncertainty is surfaced, never
hidden, wherever `gu`/`fg` trends are shown; "cohort" is not used bare for the
membership-consistency concept without the Q3 vocabulary decision; the existing one-time
summaries (GVA report, Genetic Diversity dashboard, Summary Statistics) change zero
behavior.

## 5. Next actions

1. **Next #167 session:** write `docs/planning/issue167-longitudinal-monitoring-plan.md`
   answering Q1–Q9 as ratified, numbered decisions with a vertical-slice list and per-slice
   completion criteria (the #152/#153 mold). That session is a planning session: the plan
   is the deliverable; close out without implementing (SESSION_RUNNER FM #18/#19).
2. **Implementation sessions:** one slice per session, strict TDD, only after the plan is
   ratified.
3. This session (S755) comments the narrowing onto issue #167 (owner-approved text) and
   closes out. Deliberately no new `BACKLOG.md` item (§1, divergence note).
