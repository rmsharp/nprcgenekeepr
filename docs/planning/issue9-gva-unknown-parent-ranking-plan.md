# Issue #9 Plan — Animals missing a parent falsely top-rank in the Genetic Value Analysis

**Tracks:** GitHub issue **#9** ("Animals missing one parent assignment"). Part of the parent-ID cluster (sibling closed umbrella #45; #28 still open/gated). #9 is distinct from #28: #28 *identifies* parents; #9 *consumes* parentage state in the GVA ranking.

**Authored:** Session 174 (2026-06-22), **planning session**. The TDD code-phases (RED / GREEN / REFACTOR) are **inapplicable to this document** — it is a plan. Each implementation slice below is its own strict-TDD session (RED -> GREEN -> REFACTOR), one slice per session (FM #18/#25: do not bundle plan + implementation, do not bundle slices).

**Evidence base:** every claim below carries a firsthand `file:line`. Sources: (1) a 6-agent understanding workflow (`wf_e8ff66e0-7ed`) that mapped founder creation, mean kinship, genome uniqueness + ranking, the results table + tests, and **adversarially verified the top-rank premise against real data**; (2) my own firsthand re-reads of the load-bearing structural claims (`R/reportGV.R:85-154`, `R/modGeneticValue.R:195-214`, `R/orderReport.R:27-85`, `tests/testthat/test_orderReport.R`); (3) firsthand `git grep` inventory of the full blast radius (§2).

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `man/`, `NAMESPACE`, or `data/` content is changed by writing it.** The owner chose to cover **all three** issue solutions (S1 + S2 + S3) via this plan, implemented one slice per session in subsequent sessions. The design decisions in §3 carry my recommendations and are **flagged for owner ratification before the first implementation slice declares RED**.

---

## 1. Context

### What issue #9 says

> Animals without either parent assigned are determined to be "founders" and have U IDs (unknown), which falsely elevates animals to top of ranks by genetic value.
> Possible solutions:
> - **(S1-seed)** Assign colony mean kinship value for unknown parent
> - **(S2-seed)** Flagged or different classification for animals lacking parentage
> - **(S3-seed)** Add Sire and Dam columns in results table

**Owner's refinement (2020-11-10 comment) — the authoritative remedy for S1:**
> Instead of using the colony mean kinship for the unknown parent, calculate the mean kinship coefficient for all animals of breeding age of the appropriate sex for the missing parent. So that there is a mean coefficient for the potential sires and another for the potential dams.

### The premise is real — adversarially verified

On the shipped `qcPed`, the **top-20 GVA-ranked animals are 100% founders** (both parents NA) with mean kinship 0.0027-0.0035 vs. colony mean 0.0066 (workflow premise agent, real-data run). Animals with unknown parents are genuinely *unrelated to the colony* (a true genetic fact), but the ranking equates "unrelated" with "high genetic value," so they rise to the top. That is exactly #9.

### Confirmed mechanism (missing parent -> false top rank)

1. **Missing parent becomes a U-id founder.** `qcStudbook` runs `addUIds` then `addParents` (`R/qcStudbook.R:198-199`). `addUIds` (`R/addUIds.R:42-62`) fills a missing sire/dam with a generated `U####` id; `addParents` (`R/addParents.R:30-63`) then creates a stub record with **both** parents NA. The stub is now a true founder.
2. **Founder classification.** `isFounder` = `is.na(sire) & is.na(dam)` (`R/isFounder.R:28-30`); `getFounders` returns those ids (`R/getFounders.R:28-30`). U-id stubs and genuine founders both qualify.
3. **Kinship.** `kinship()` gives every founder self-kinship 0.5 and **zero** kinship to all others; a parent id not in the id vector maps to a placeholder index `n+1` forced to 0 (`R/kinship.R:77-88`), and offspring rows are the Mendelian average of the two parents' rows (`R/kinship.R:103-104`). So a U-id founder is unrelated to everyone, and its offspring inherit a row pulled toward zero.
4. **Single choke point.** `indivMeanKin <- meanKinship(kmat)` then `zScores <- scale(indivMeanKin)` (`R/reportGV.R:93-95`). Unrelated founders get the lowest mean kinship and most-negative z-scores. **Both downstream rank paths consume this one value.**
5. **Genome-uniqueness reinforcement.** Gene-drop gives U-id founders their own founder alleles, which `calcGU`/`calcA` count as "rare" (`R/reportGV.R:98-113`, `R/calcGU.R:82-98`). So founders **also** score high genome uniqueness — a second false-elevation axis (see D6).

### Two distinct rank paths (both fed by `indivMeanKin`)

- **(A) `reportGV` -> `orderReport`** (`R/reportGV.R:148-150`). `orderReport` (`R/orderReport.R:27-85`) partitions into `imports` / `noParentage` / `highGu(>10%)` / `lowMk(zScores<=0.25)` / `lowVal`, and `rankSubjects` (`R/rankSubjects.R:27-51`) assigns sequential ranks, giving `noParentage` the value "Undetermined" and rank NA. **The only protection** for missing-parent animals is the `noParentage` bucket, which fires *only* when `is.na(origin) & totalOffspring == 0 & id %in% founders` (`R/orderReport.R:46-47`). A U-id stub that has offspring, or an import (`origin` not NA), escapes it and top-ranks via `lowMk`. (This `noParentage` bucket shipped under the separate, closed issue #8 — not #9.)
- **(B) The Shiny module overrides (A).** `report$rank <- rank(report$indivMeanKin - report$gu)`, then re-orders and re-sequences (`R/modGeneticValue.R:204-206`). **The table users actually see ignores `orderReport`'s categories** and ranks by `indivMeanKin - gu` directly. A missing-parent animal has both low `indivMeanKin` and high `gu`, so this formula drives it to the very top. **Consequence:** a fix at the math layer (choke point) corrects both paths; a fix only in `orderReport` is invisible in the app (see D7).

### Prior process history

`docs/audits/IMPLEMENTED_BUT_OPEN_AUDIT_2026-06-16.md:65-68` already classifies #9 as a **policy-hold needing an owner decision**, and notes a Monte-Carlo kinship-imputation toolkit (`createSimKinships` / `makeSimPed` / `cumulateSimKinships`) **exists but is unwired** from `reportGV` (see D4). The `noParentage` classification that does exist shipped under issue #8, not #9.

---

## 2. Evidence-based inventory (firsthand `git grep`)

### `kinship()` — real R/ callers (blast radius if changed at the matrix level)

`R/reportGV.R:87`, `R/modBreedingGroups.R:173`, `R/modSummaryStats.R:357`, `R/createSimKinships.R:58`, `R/cumulateSimKinships.R:61`. (All other hits are roxygen `@examples`.) **Implication:** changing `kinship()` behavior/signature affects breeding-group formation, summary stats, and simulations — not just GVA. **Confine the S1 fix to `reportGV`** (see D1).

### S1 (mean-kinship substitution) touch points

- `R/reportGV.R:93-95` — `indivMeanKin <- meanKinship(kmat)` then `scale()`. **Primary injection point.**
- `R/meanKinship.R:22-24` — `meanKinship <- function(kmat) colMeans(...)`. Per-animal scalar.
- `R/reportGV.R:72` — signature `reportGV <- function(ped, guIter = 5000L, guThresh = 1L, pop = NULL, ...)`. **`minParentAge` is NOT a parameter today** — threading it changes the signature + man page + the call site `R/modGeneticValue.R:185`.
- Breeding-age + sex template to reuse: `R/getPotentialParents.R:39` (signature), `:84` breeding-age filter `birth <= (focal_birth - dYear*minParentAge)`, sex `M`/`F` stratification. `dYear` = 365. Default `minParentAge` = 2 in the `qcStudbook`/`getPotentialParents` convention (note `getProductionStatus` uses 3, `checkParentAge` uses 2 — `R/getProductionStatus.R:54`, `R/checkParentAge.R:38`).
- Founder/unknown predicates: `R/isFounder.R:28-30`, `R/getFounders.R:28-30`, `R/autoIdFormat.R:112-114` (`isGeneratedUnknownId`).
- "One unknown parent" detector exists: `R/getIdsWithOneParent.R` (per grep) — candidate reuse for the partial-parentage mask.

### S2 (flag/classify) touch points

- `R/orderReport.R:30,46-54` (`noParentage` predicate + bucket), `R/rankSubjects.R:37-48` (value/rank assignment).
- `R/modGeneticValue.R:204-206` — the rank override that must be made classification-aware (D7), else any classification is invisible in the app.

### S3 (sire/dam columns) touch points

- `R/getIncludeColumns.R:14-19` — currently `id, sex, age, birth, exit, population, condition, origin, first_name, second_name` (**no sire/dam**). Consumed at `R/reportGV.R:125` (`intersect(getIncludeColumns(), names(ped))`) and pinned by `tests/testthat/test_getIncludeColumns.R`.
- `R/reportGV.R:125-129,148` — demographics subset -> `cbind` into `finalData`.
- Displayed table + CSV export: `R/modGeneticValue.R:318` (renames `indivMeanKin`->`meanKinship`, `gu`->`genomeUniqueness` in `geneticValues()`), `R/modGeneticValue.R:302` (`downloadRankings` writes `gvResults()`), `R/modGeneticValue.R:308` (`downloadGVASubset` writes `gvaView()`). New columns must survive these reactives or they vanish from table/CSV.

### Tests that pin current behavior (TDD anchors / must-update)

| Test | What it pins | Affected by |
|---|---|---|
| `tests/testthat/test_orderReport.R:24,42` | `countUnk(top 100) == 34` (and `21` in top 50) — **encodes the buggy ranking** | S1, S2 (D8) |
| `tests/testthat/test_reportGV.R:12-17` | exact report column set | S3 |
| `tests/testthat/test_getIncludeColumns.R` | exact column set | S3 (if `getIncludeColumns` changed) |
| `tests/testthat/test_modGeneticValue.R:703-745` | `indivMeanKin` in `[0,1]`, `gu >= 0` | S1 (must keep invariant) |
| `tests/testthat/test_meanKinship.R`, `test_isFounder.R`, `test_getFounders.R` | helper semantics | S1 (regression guard) |
| `tests/testthat/test_rankSubjects.R` | value/rank labels | S2 |

---

## 3. Design decisions (recommendations for owner ratification)

These must be settled before the first implementation slice declares RED — a RED test cannot assert a number until D1-D3 are fixed. Each shows options and my **recommendation**. The owner ratifies (edit this doc, or a focused `/grill-me`).

**D1 — Where to substitute (level of the fix).**
Options: (a) at the **mean-kinship scalar** level inside `reportGV` (after `meanKinship()`, `R/reportGV.R:93`); (b) at the **kinship-matrix** level (replace the unknown-parent placeholder contribution, `R/kinship.R:83-88`).
**Recommend (a).** Rationale: matches the owner's wording ("mean kinship of breeding-age animals"); both rank paths consume `indivMeanKin`, so one change fixes both; leaves shared `kinship()` (5 callers, §2) untouched, so breeding groups / summary stats / simulations are unaffected. *Load-bearing — ratify.*

**D2 — The substitution formula (replace vs blend; the deepest decision).**
For an animal missing **one** parent, it still has one known parent (real kinship). Candidate formulas (operating at the `indivMeanKin` scalar):
  - **F1 (blend):** `mk_corrected = 0.5 * mk_knownParentSide + 0.5 * sexMean`, where `sexMean` is the mean kinship of breeding-age animals of the missing parent's sex, and `mk_knownParentSide` is the contribution from the known lineage. (Requires isolating the known-parent half — non-trivial from `colMeans`.)
  - **F2 (replace the unknown half with a floor):** keep the animal's computed `indivMeanKin` but **add** the missing contribution: raise it by the amount the zero-placeholder suppressed it, using `sexMean` as the unknown parent's stand-in. Concretely, give the unknown parent a stand-in mean kinship of `sexMean` and recompute the offspring's mean as the average of the known parent's and the stand-in's.
  - **F3 (both-unknown / genuine founder):** for an animal with **both** parents unknown, set `mk = mean(sireSexMean, damSexMean)` (or leave as a flagged founder per S2).
**Recommend:** specify the formula as **F2** for one-unknown-parent animals and **F3** for both-unknown, computed at the scalar level. *This is the #1 "here be dragons" decision and the most genetics-laden — strongly consider a `/grill-me` to nail the exact algebra with the owner before Slice 1. The RED test's expected numbers depend entirely on this.*

**D3 — Candidate population for "breeding-age animals of the appropriate sex."**
Options: whole pedigree / analysis probands / living animals / `getPotentialParents`-style date+exit filtered, relative to the focal animal's birth.
**Recommend:** breeding-age animals of the appropriate sex over the **analysis population (`probands`)**, with the breeding-age window reused from `getPotentialParents` (`birth <= focal_birth - 365*minParentAge`, `R/getPotentialParents.R:84`). Factor the breeding-age + sex selection into a small, unit-testable helper reused by both. *Dragon: depends on birth dates; the trimmed ped (`R/modGeneticValue.R:173`) may lack columns -> guard against empty candidate sets and silent fallback (R3).*

**D4 — Reuse the Monte-Carlo toolkit vs. a direct mean.**
**Recommend: direct sex-stratified mean** (deterministic, easily unit-tested, matches the owner's "mean kinship of breeding-age animals" wording). Note `createSimKinships`/`makeSimPed`/`cumulateSimKinships` exist as a tested alternative if a simulation-based imputation is later preferred. *Ratify.*

**D5 — Scope.** Owner chose **S1 + S2 + S3** (recorded; no decision needed). Recommended slice ordering in §4.

**D6 — The genome-uniqueness axis.**
The displayed rank is `indivMeanKin - gu` (`R/modGeneticValue.R:204`); founders also inflate `gu` (gene-drop gives them own "rare" alleles). The owner's 2020 comment addresses **mean kinship only**. **Recommend:** keep `gu` handling **out of scope for #9 v1**, but document in the slice notes that fixing mean kinship alone will *reduce but may not fully eliminate* the elevation because `gu` still inflates. *Ratify — if the owner wants `gu` addressed too, that likely belongs in a new issue.*

**D7 — Reconcile the two rank paths (required for S2 to be visible).**
`R/modGeneticValue.R:204-206` overwrites `orderReport`'s category rank. **Recommend:** keep the `indivMeanKin - gu` formula but make it **classification-aware** — flagged/Undetermined animals are preserved (not silently re-ranked into the top) and either excluded from the `rank()` ordering or ranked last with their flag shown. *Ratify whether to unify on `orderReport`'s categories instead.*

**D8 — The `test_orderReport` golden counts.**
`tests/testthat/test_orderReport.R:24,42` assert `countUnk(top 100) == 34`. A correct S1/S2 fix **will** change these by design. **Recommend:** replace the brittle count assertions with behavior assertions (a fixture pedigree with a known partial-parentage animal that must **not** appear in the top-N after the fix) **and** update the golden counts to the new measured values. *Confirm these are accepted to change.*

---

## 4. Implementation plan — vertical slices (one session each)

Vertical, not horizontal (FM #25): each slice ships a working, end-to-end narrow path. "If I stop after this slice, does something work?" — yes for each. Recommended order puts the lowest-risk visibility aid first (so the owner can *see* the U-id animals in real output before the math changes), then the core fix, then classification.

### Slice 1 (recommended first) = S3: Sire/Dam columns in the GVA report + CSV
**Why first:** pure additive visibility, lowest risk, independent of S1/S2, and it lets the owner verify the problem (which top-ranked animals have `U####` parents) in real output before any ranking math changes — a tracer bullet.
**RED:** extend `test_reportGV.R` to assert `sire`,`dam` appear in `report` columns; add a `test_modGeneticValue.R` assertion that `geneticValues()` / `gvaView()` carry them; (if `getIncludeColumns` is the chosen mechanism) update `test_getIncludeColumns.R`.
**GREEN:** add `sire`,`dam` to the demographics carried into `finalData` (either via `getIncludeColumns()` + `R/reportGV.R:125-129`, or by adding directly to the demographics subset to avoid changing the exported `getIncludeColumns` contract — pick in D-note), and ensure they survive the `geneticValues()` rename (`R/modGeneticValue.R:318`) and both CSV handlers (`:302`, `:308`).
**DONE looks like:** the GVA report data frame and both CSV exports include `sire` and `dam`; new tests green; no other column assertion broken.
**Verify:** `Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_reportGV.R", reporter="summary")'` (repeat for `test_getIncludeColumns.R`, `test_modGeneticValue.R`); then build-equivalent `devtools::check(vignettes = FALSE)` -> 0/0/0 (Learning 161).
**Session boundary:** one session. Close out when done.
**Dragons:** `getIncludeColumns()` is exported and described as "superset of columns that can be in a pedigree file" — changing it shifts its public contract + its test. Prefer adding sire/dam to the reportGV demographics subset *without* changing `getIncludeColumns` unless the owner wants the superset broadened.

### Slice 2 = S1: sex-stratified breeding-age mean-kinship substitution (the core fix)
**Prerequisite:** D1-D4, D8 ratified (especially the D2 formula). Do **not** start RED until the formula is fixed.
**RED:** (a) a unit test for the new helper computing the sex-appropriate breeding-age mean kinship for a focal animal on a small fixture pedigree (deterministic expected value hand-computed from the fixture); (b) an integration test on a fixture pedigree with a known partial-parentage animal asserting it **no longer top-ranks** after the fix; (c) update `test_orderReport.R:24,42` golden counts (D8) to the new measured values / behavior assertion.
**GREEN:** add the helper (breeding-age + sex selection, reusing the `getPotentialParents` window per D3); inject the substitution at `R/reportGV.R:93-95` per the D2 formula; thread `minParentAge` into `reportGV` (signature `R/reportGV.R:72`, call site `R/modGeneticValue.R:185`, default 2).
**DONE looks like:** partial-parentage and U-id animals receive the substituted mean kinship; the fixture animal drops out of the top; both rank paths reflect it (because the choke point feeds both); `indivMeanKin` stays in `[0,1]` (`test_modGeneticValue.R:703-745`).
**Verify:** the targeted test files green; full clean regression read `as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))` then check `sum(failed)` + `sum(error)` isolating `!grepl("test-app-|test-e2e-", file)`; build-equivalent `devtools::check(vignettes = FALSE)` -> 0/0/0.
**Session boundary:** one session. Close out when done.
**Dragons:** (1) keep `kinship()` untouched (5 callers, §2). (2) Do not reintroduce spurious relatedness that `R/kinship.R:83-84` deliberately prevents — two animals sharing an unknown parent must stay unrelated to each other (the substitution is a per-animal scalar floor, not a pairwise edge). (3) Trimmed ped may lack birth/exit -> guard empty candidate sets, do not silently fall back to the buggy value (R3). (4) Threading `minParentAge` changes the exported `reportGV` signature + man + examples.

### Slice 3 = S2: flag/classify unknown-parent animals + reconcile the displayed rank
**Prerequisite:** D7 ratified.
**RED:** a test asserting partial-parentage / U-id-stub animals carry the chosen classification (e.g. "Undetermined" or a new flag) in the report; an assertion that the **Shiny-displayed** rank (`modGeneticValue` server) preserves the flag rather than re-ranking flagged rows into the top.
**GREEN:** broaden the `noParentage` predicate (`R/orderReport.R:46-47`) and/or add a bucket + value/rank in `rankSubjects` (`R/rankSubjects.R:37-48`); make `R/modGeneticValue.R:204-206` classification-aware (preserve flagged rows per D7).
**DONE looks like:** unknown-parent animals are visibly flagged in both the `reportGV`/`orderReport` output **and** the app table; no flagged animal silently top-ranks.
**Verify:** targeted tests green; clean regression read; build-equivalent 0/0/0; **Phase-3E runtime smoke is required for this slice** (it changes Shiny runtime behavior) — launch `runModularApp()`, load a pedigree with a partial-parentage animal, confirm the flag shows in the Genetic Value tab.
**Session boundary:** one session. Close out when done.
**Dragons:** the displayed table uses path (B), not `orderReport` — a classification added only in `orderReport` is invisible until `modGeneticValue.R:204-206` is updated. This is the easiest place to "fix" the wrong path and see no UI effect.

---

## 5. Cross-slice notes

- **Ordering rationale:** S3 (visibility) -> S1 (core math) -> S2 (classification + path reconciliation). S1 and S3 are independent; S2 interacts with S1 (both touch ranking) and owns the rank-path reconciliation (D7). If the owner prefers the core fix first, S1 can precede S3 with no rework.
- **Each slice is a full RED -> GREEN -> REFACTOR session** with the phase-gate `AskUserQuestion` at every transition (project Development Process Contract). Publish (PR -> CI -> merge) is the standard separate step per the project's publish convention; a NEWS entry is required for S1 and S3 (user-facing: changed ranking; new columns) and folded into the same PR (Learning 157a).
- **No slice changes `kinship()`** — that is the load-bearing blast-radius boundary.

## 6. Here be dragons (consolidated load-bearing risks)

- **R1 — Two rank paths.** The app ignores `orderReport`'s ranking (`R/modGeneticValue.R:204-206`). Fix the math layer (Slice 2) to affect both; never assume an `orderReport`-only change is visible.
- **R2 — `test_orderReport` encodes the bug.** `:24,42` (34/21 U-ids in top) will break by design; update intentionally (D8) or the suite looks regressed.
- **R3 — Silent fallback.** Breeding-age candidate selection depends on birth/exit columns the trimmed analysis ped may lack -> empty candidate set -> silent reversion to current behavior. Guard explicitly and test the empty case.
- **R4 — `[0,1]` invariant.** Substituted mean kinship must stay in `[0,1]` (`test_modGeneticValue.R:703-745`).
- **R5 — Shared `kinship()`.** 5 R/ callers (§2) — out of bounds for this work.
- **R6 — The `gu` axis (D6).** Mean-kinship-only fix may not fully de-elevate founders because `gu` still inflates; set expectations / consider a follow-up issue.
- **R7 — D2 is genetics, not code.** The exact substitution algebra is the owner's methodology call; a wrong formula produces plausible-but-wrong rankings. Strongly consider `/grill-me` before Slice 2 RED.

## 7. Owner ratification checklist (resolve before Slice 2 RED)

- [ ] **D1** — fix at the `reportGV` mean-kinship level (recommended), not in shared `kinship()`.
- [ ] **D2** — the substitution formula (F2 one-unknown / F3 both-unknown recommended). **Highest-stakes; grill candidate.**
- [ ] **D3** — candidate population = breeding-age, sex-appropriate, over probands, `getPotentialParents` window (recommended).
- [ ] **D4** — direct mean (recommended) vs. Monte-Carlo toolkit.
- [ ] **D6** — `gu` axis out of scope for #9 v1 (recommended)?
- [ ] **D7** — keep `indivMeanKin - gu` formula but make it classification-aware (recommended)?
- [ ] **D8** — accept changing the `test_orderReport` golden counts; replace with behavior assertions (recommended).
- [ ] **Slice order** — S3 -> S1 -> S2 (recommended) vs. S1 first.
</content>
</invoke>
