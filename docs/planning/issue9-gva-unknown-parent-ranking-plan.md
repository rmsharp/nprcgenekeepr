# Issue #9 Plan — Animals missing a parent falsely top-rank in the Genetic Value Analysis

**Tracks:** GitHub issue **#9** ("Animals missing one parent assignment"). Part of the parent-ID cluster (sibling closed umbrella #45; #28 still open/gated). #9 is distinct from #28: #28 *identifies* parents; #9 *consumes* parentage state in the GVA ranking.

**Authored:** Session 174 (2026-06-22), **planning session**. The TDD code-phases (RED / GREEN / REFACTOR) are **inapplicable to this document** — it is a plan. Each implementation slice below is its own strict-TDD session (RED -> GREEN -> REFACTOR), one slice per session (FM #18/#25: do not bundle plan + implementation, do not bundle slices).

**Evidence base:** every claim below carries a firsthand `file:line`. Sources: (1) a 6-agent understanding workflow (`wf_e8ff66e0-7ed`) that mapped founder creation, mean kinship, genome uniqueness + ranking, the results table + tests, and **adversarially verified the top-rank premise against real data**; (2) my own firsthand re-reads of the load-bearing structural claims (`R/reportGV.R:85-154`, `R/modGeneticValue.R:195-214`, `R/orderReport.R:27-85`, `tests/testthat/test_orderReport.R`); (3) firsthand `git grep` inventory of the full blast radius (§2).

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `man/`, `NAMESPACE`, or `data/` content is changed by writing it.** The owner chose to cover **all three** issue solutions (S1 + S2 + S3) via this plan, implemented one slice per session in subsequent sessions. The design decisions in §3 carry my recommendations and are **flagged for owner ratification before the first implementation slice declares RED**.

> **RATIFIED — read §8 first.** Session 177 ratified §7 via `/grill-me`. **§8 is the authoritative record and overrides §3/§4/§6 where they differ.** Two things every later session must know: (1) the displayed GVA rank is **dominated by genome uniqueness, not mean kinship**, so the Slice 2 mean-kinship fix corrects the number but does NOT change the visible top-of-list (§8-A); (2) Slice 2 was re-scoped to **one-unknown animals only** with a **per-focal peer-cohort** substitution and a **species/sex breeding-age table** (§8-C/D/E). Both-unknown founders + the `gu` axis moved into an expanded Slice 3 (§8-F).

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
- **(B) The Shiny module overrides (A).** `report$rank <- rank(report$indivMeanKin - report$gu)`, then re-orders and re-sequences (`R/modGeneticValue.R:204-206`). **The table users actually see ignores `orderReport`'s categories** and ranks by `indivMeanKin - gu` directly. A missing-parent animal has both low `indivMeanKin` and high `gu`, so this formula drives it to the very top. **Consequence:** a fix at the math layer (choke point) corrects both paths; a fix only in `orderReport` is invisible in the app (see D7). **NOTE (§8-A, S177): the DISPLAYED rank is dominated by `gu`, not mean kinship (3-4 orders of magnitude) — the Slice 2 mean-kinship fix corrects the number but does NOT move the visible top-of-list. See §8-A.**

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

**>> RATIFIED S177 — several items below were REVISED at ratification; §8 (and the §7 checklist) is authoritative. See the per-item SUPERSEDED banners.**

**D1 — Where to substitute (level of the fix).**
Options: (a) at the **mean-kinship scalar** level inside `reportGV` (after `meanKinship()`, `R/reportGV.R:93`); (b) at the **kinship-matrix** level (replace the unknown-parent placeholder contribution, `R/kinship.R:83-88`).
**Recommend (a).** Rationale: matches the owner's wording ("mean kinship of breeding-age animals"); both rank paths consume `indivMeanKin`, so one change fixes both; leaves shared `kinship()` (5 callers, §2) untouched, so breeding groups / summary stats / simulations are unaffected. *Load-bearing — ratify.*

**D2 — The substitution formula (replace vs blend; the deepest decision).**
**>> SUPERSEDED by §8-B/C (S177):** per-focal contemporaneous peer cohort (NOT a global mean); **one-unknown animals only** in Slice 2 (both-unknown deferred to Slice 3, no F3 in Slice 2); formula `MK_corrected = pmin(MK_current + sexMean/2, 1)`, `sexMean` = mean of the cohort's individual mean-kinships.
For an animal missing **one** parent, it still has one known parent (real kinship). Candidate formulas (operating at the `indivMeanKin` scalar):
  - **F1 (blend):** `mk_corrected = 0.5 * mk_knownParentSide + 0.5 * sexMean`, where `sexMean` is the mean kinship of breeding-age animals of the missing parent's sex, and `mk_knownParentSide` is the contribution from the known lineage. (Requires isolating the known-parent half — non-trivial from `colMeans`.)
  - **F2 (replace the unknown half with a floor):** keep the animal's computed `indivMeanKin` but **add** the missing contribution: raise it by the amount the zero-placeholder suppressed it, using `sexMean` as the unknown parent's stand-in. Concretely, give the unknown parent a stand-in mean kinship of `sexMean` and recompute the offspring's mean as the average of the known parent's and the stand-in's.
  - **F3 (both-unknown / genuine founder):** for an animal with **both** parents unknown, set `mk = mean(sireSexMean, damSexMean)` (or leave as a flagged founder per S2).
**Recommend:** specify the formula as **F2** for one-unknown-parent animals and **F3** for both-unknown, computed at the scalar level. *This is the #1 "here be dragons" decision and the most genetics-laden — strongly consider a `/grill-me` to nail the exact algebra with the owner before Slice 1. The RED test's expected numbers depend entirely on this.*

**D3 — Candidate population for "breeding-age animals of the appropriate sex."**
**>> SUPERSEDED by §8-C/D (S177):** the per-focal contemporaneous peer cohort, breeding age via the species/sex table (`getSpeciesMinBreedingAge`); the scalar `minParentAge` is NOT threaded into `reportGV`.
Options: whole pedigree / analysis probands / living animals / `getPotentialParents`-style date+exit filtered, relative to the focal animal's birth.
**Recommend:** breeding-age animals of the appropriate sex over the **analysis population (`probands`)**, with the breeding-age window reused from `getPotentialParents` (`birth <= focal_birth - 365*minParentAge`, `R/getPotentialParents.R:84`). Factor the breeding-age + sex selection into a small, unit-testable helper reused by both. *Dragon: depends on birth dates; the trimmed ped (`R/modGeneticValue.R:173`) may lack columns -> guard against empty candidate sets and silent fallback (R3).*

**D4 — Reuse the Monte-Carlo toolkit vs. a direct mean.**
**Recommend: direct sex-stratified mean** (deterministic, easily unit-tested, matches the owner's "mean kinship of breeding-age animals" wording). Note `createSimKinships`/`makeSimPed`/`cumulateSimKinships` exist as a tested alternative if a simulation-based imputation is later preferred. *Ratify.*

**D5 — Scope.** Owner chose **S1 + S2 + S3** (recorded; no decision needed). Recommended slice ordering in §4.

**D6 — The genome-uniqueness axis.**
**>> SUPERSEDED by §8-A/F (S177): `gu` is IN-SCOPE for #9** (folded into the expanded Slice 3), NOT out of scope / a separate issue; the mean-kinship fix alone moves NOTHING visible (§8-A), so #9 does not close on Slice 2.
The displayed rank is `indivMeanKin - gu` (`R/modGeneticValue.R:204`); founders also inflate `gu` (gene-drop gives them own "rare" alleles). The owner's 2020 comment addresses **mean kinship only**. **Recommend:** keep `gu` handling **out of scope for #9 v1**, but document in the slice notes that fixing mean kinship alone will *reduce but may not fully eliminate* the elevation because `gu` still inflates. *Ratify — if the owner wants `gu` addressed too, that likely belongs in a new issue.*

**D7 — Reconcile the two rank paths (required for S2 to be visible).**
`R/modGeneticValue.R:204-206` overwrites `orderReport`'s category rank. **Recommend:** keep the `indivMeanKin - gu` formula but make it **classification-aware** — flagged/Undetermined animals are preserved (not silently re-ranked into the top) and either excluded from the `rank()` ordering or ranked last with their flag shown. *Ratify whether to unify on `orderReport`'s categories instead.*

**D8 — The `test_orderReport` golden counts.**
**>> SUPERSEDED by §8-E/F (S177): Slice 2 does NOT change `:24,42`** (those count both-unknown U-stubs on a frozen fixture — verified S177); the golden-count change moves to Slice 3.
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
**>> SUPERSEDED by §8-E (Ratification Record, S177). Implement §8-E, not this subsection.** Key changes: per-focal peer cohort (not global); one-unknown animals only (both-unknown -> Slice 3); species/sex breeding-age table replaces the scalar `minParentAge`; `test_orderReport` golden counts are NOT changed by Slice 2. The RED/GREEN below is the pre-ratification draft, retained for history.
**Prerequisite:** ~~D1-D4, D8 ratified~~ — **DONE (S177, §8).** Ratified design is §8-E.
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

**>> Several risks below were REVISED at ratification (S177) — §8 / §7 are authoritative; see the per-item SUPERSEDED banners.**

- **R1 — Two rank paths.** The app ignores `orderReport`'s ranking (`R/modGeneticValue.R:204-206`). Fix the math layer (Slice 2) to affect both; never assume an `orderReport`-only change is visible.
- **R2 — `test_orderReport` encodes the bug.** `:24,42` (34/21 U-ids in top) will break by design; update intentionally (D8) or the suite looks regressed. **>> SUPERSEDED S177: NOT in Slice 2** — Slice 2 leaves `:24,42` unchanged (verified); this applies to Slice 3.
- **R3 — Silent fallback.** Breeding-age candidate selection depends on birth/exit columns the trimmed analysis ped may lack -> empty candidate set -> silent reversion to current behavior. Guard explicitly and test the empty case.
- **R4 — `[0,1]` invariant.** Substituted mean kinship must stay in `[0,1]` (`test_modGeneticValue.R:703-745`).
- **R5 — Shared `kinship()`.** 5 R/ callers (§2) — out of bounds for this work.
- **R6 — The `gu` axis (D6).** Mean-kinship-only fix may not fully de-elevate founders because `gu` still inflates; set expectations / consider a follow-up issue. **>> REVISED S177: `gu` is IN-SCOPE for #9 (expanded Slice 3), not a separate issue; on real data the mean-kinship fix moves NOTHING visible (§8-A), not merely "may not fully".**
- **R7 — D2 is genetics, not code.** The exact substitution algebra is the owner's methodology call; a wrong formula produces plausible-but-wrong rankings. Strongly consider `/grill-me` before Slice 2 RED.

## 7. Owner ratification checklist (resolve before Slice 2 RED)

**RATIFIED Session 177 (2026-06-22) via `/grill-me` — see §8 for the authoritative record. Several recommendations were REVISED by the owner during the grill; the boxes below reflect the FINAL decision, not the original recommendation.**

- [x] **D1** — fix at the `reportGV` mean-kinship scalar level (after `meanKinship()`), never shared `kinship()`. *(as recommended)*
- [x] **D2** — substitution at the scalar level; `MK_corrected = MK_current + sexMean/2` per missing parent. **REVISED:** `sexMean` is computed over a **per-focal contemporaneous peer cohort**, NOT a global mean (era-specificity, §8-B2); `sexMean` = mean of the cohort's **individual** mean-kinships; the self-term moves to `(1+sexMean)/2`. **Slice 2 corrects ONE-unknown animals only** (both-unknown deferred to Slice 3).
- [x] **D3** — candidate population = the per-focal peer cohort (contemporaneous, sex-appropriate, breeding-age via the species/sex table, present at conception). *(settled by D2)*
- [x] **D4** — direct mean of the peer cohort. *(as recommended; Monte-Carlo toolkit unused)*
- [x] **D6** — **REVISED: `gu` axis is IN-SCOPE for #9**, folded into the expanded **Slice 3** (not out of scope). The mean-kinship fix alone does NOT move the displayed top (§8-A); #9 cannot close on Slice 2 alone.
- [x] **D7** — keep `indivMeanKin - gu` but make it classification-aware. **Deferred to Slice 3** (N/A for Slice 2). *(as recommended, deferred)*
- [x] **D8** — **REVISED: Slice 2 does NOT change `test_orderReport:24,42`** (those count both-unknown U-stubs on a frozen fixture — verified S177). Slice 2 adds NEW behavior tests; the golden-count change moves to **Slice 3**.
- [x] **Slice order** — S3 (done) -> **Slice 2 (one-unknown peer-substitution, this ratified design)** -> Slice 3 (expanded: classify both-unknown + `gu` axis + `origin` import distinction + D7).
- [x] **minParentAge** — **REVISED: NOT threaded as a scalar.** Breeding age comes from a species/sex table (`getSpeciesMinBreedingAge`), §8-D.
- [x] **Empty-cohort fallback + clamp** — strict peer cohort -> nearest-earlier same-era cohort -> flag-uncorrected (add 0); NEVER NA, NEVER a cross-era global mean. Clamp corrected MK to `[0,1]` (`pmin`). §8-C.
- [x] **New issue (§8-G) FILED as #73** — species breeding-age table generalization (all common colony NHP) + user-configurable override.

---

## 8. Ratification Record (Session 177, 2026-06-22)

Ratified by the owner (repo owner / geneticist) via `/grill-me`, grounded by a pre-compute workflow on real `qcPed` data (`wf_7f819b92-a12`) that produced verified numbers and an adversarial check of the algebra/invariants. **This section is authoritative; where it conflicts with §3/§4/§6, §8 wins.**

### A. Load-bearing finding (reframes #9)

**The displayed GVA ranking is dominated by genome uniqueness (`gu`, scale 0..50), not mean kinship (~0.003..0.017), by 3-4 orders of magnitude.** On `qcPed` the mean-kinship substitution moves NOTHING in the app top-20 (the same 20 both-unknown founders stay at ranks 1-20); the de-elevation is real but visible **only on a kinship-only ranking** AND **only after the BOTH-unknown founders are corrected (Slice 3)** — in the precompute workflow's projection (`wf_7f819b92-a12`) those founders drop from ranks 1-20 to ~89-135 and known-parentage animals fill the top-20. **A Slice 2 (one-unknown-only) fix moves NOTHING in the app top-20**, whose 20 rows are all both-unknown founders that Slice 2 leaves untouched; the 1-20 -> 89-135 figure is a workflow projection, not derivable from the frozen test fixture. The real `orderReport` scheme (a `gu > 10` tier ranked by descending `gu`, above the kinship tiers) makes `gu`-dominance **stronger**, not weaker. **Consequence:** the false top-ranking in #9 has TWO causes — deflated mean kinship AND inflated `gu` (gene-drop hands U-id "parents" their own "rare" alleles). The owner's 2020 mean-kinship remedy fixes only the first.

### B. Root target + the two genetics calls that reshaped D2

- **B1 — Target = hybrid A+B, sequenced.** Slice 2 ships as the mean-kinship **correctness** fix (NOT advertised as fixing the visible top-ranking, because it does not). **D6 flips IN-SCOPE for #9**: the `gu` artifact is owned by the expanded Slice 3. #9 must not close on Slice 2 alone.
- **B2 — Per-focal peer cohort, NOT a global mean.** These are long-lived, **non-randomly-bred** colonies (e.g., SNPRC baboons under near-exclusive line-breeding for ~half the colony over a decade); the inbreeding distribution drifts across management eras. A colony-wide `sexMean` would import the wrong era's relatedness. So the missing-parent stand-in must be estimated from the animal's **contemporaneous breeding peers** (the `getPotentialParents`-style window: breeding-age AND present in the colony at the focal's conception), of the appropriate sex.
- **B3 — `sexMean` definition + self-term.** `sexMean` = **mean of the peer cohort's individual mean-kinships** (definition i), not mean pairwise kinship. The correction is applied as a **scalar floor at the `indivMeanKin` level — a modeling choice, NOT a rebuild of the kinship matrix.** The unknown parent is modeled as a typical contemporaneous opposite-sex peer contributing `sexMean` to the focal's relatedness, so the focal's off-diagonal mean rises by `sexMean/2` and its self-term (inbreeding) moves from `0.5` to `(1+sexMean)/2`; both contributions equal `sexMean/2`, so the per-parent add is `+sexMean/2`. Implied inbreeding = `sexMean` is the random-mating expectation (offspring of a known parent and a typical opposite-sex colony member). **Caveat for the test author:** the workflow's `8e-18` figure verifies the scalar arithmetic's **self-consistency** (the two `sexMean/2` contributions agree), NOT agreement with a re-run of `kinship()` — a full matrix rebuild with a real cohort-average stand-in row differs by ~`1e-2`. Do NOT write a RED test expecting an `8e-18` match against a matrix rebuild; assert the scalar formula directly.

### C. The Slice 2 substitution (authoritative formula)

For each **one-unknown** animal (exactly one parent missing/U-id; the other parent known):
- `sexMean = mean( indivMeanKin of the focal's contemporaneous breeding-age peers of the MISSING parent's sex )`.
- `MK_corrected = pmin( MK_current + sexMean / 2 , 1 )`.
- Fully-known-parentage animals: **unchanged**. Both-unknown founders: **unchanged in Slice 2** (deferred to Slice 3).
- **Targeting:** identify the one-unknown set with a U-id-aware predicate (`is.na(x) | isGeneratedUnknownId(x)` on sire/dam), or normalize U-ids to NA before `getIdsWithOneParent` — the raw `is.na()` predicates return 0 on un-normalized `qcPed` (adversary-confirmed trap).
- **Fallback (total function):** strict contemporaneous peer cohort -> if empty, nearest-earlier breeding cohort of that sex on the same era side -> if still none (e.g., no birth date), **leave the animal uncorrected and flag it** (add 0). **NEVER inject NA** (poisons the ranking) and **NEVER fall back to a cross-era global/colony mean** (defeats B2). On `qcPed` the fallback never fires (all 43 one-unknown animals have births and non-empty cohorts).

### D. Species/sex breeding-age table (new infrastructure for Slice 2)

- **Extend** the bundled `speciesGestation` table with two columns: `minMaleBreedingAge`, `minFemaleBreedingAge` (years). Seed the rhesus row: **gestation 210 (existing), min male 4, min female 3.** Regenerate via `data-raw/speciesGestation.R` (real + idempotent), AND update the `\describe{}` roxygen block in `R/data.R` (the `speciesGestation` doc currently lists only `species`/`gestation`) + regen `man/speciesGestation.Rd` — otherwise `devtools::check` throws a documentation-mismatch NOTE and the §8-E `0/0/0` gate fails.
- **Add** accessor `getSpeciesMinBreedingAge(species, sex, default = 2L)`. "Mirrors `getSpeciesGestation`" means the same **lookup/fallback structure** (case/whitespace-insensitive species match, scalar default), NOT the same default value — gestation's default is `210`, this one's is `2`. **Unknown-species fallback = 2** for both sexes (preserves legacy behavior; becomes user-configurable via the new issue, §G).
- Used by the peer-cohort selection (min male age for a missing sire, min female age for a missing dam), keyed to the pedigree's `species` column. **CRITICAL — the `species` column is often ABSENT** (neither `qcPed` nor `qcStudbook`'s `breederPed` carries one). The peer-cohort helper MUST derive the species vector defensively, mirroring `R/getPotentialParents.R:64-68`: `spp <- if ("species" %in% names(ped)) ped$species else rep(NA_character_, nrow(ped))`, then `getSpeciesMinBreedingAge(spp, sex)` returns the default `2` for absent/NA species. **Consequence: on `qcPed` (no `species` column) the seeded rhesus 4/3 row is NEVER exercised — the cohort uses breeding-age cutoff 2.** Exercising the rhesus 4/3 path requires a fixture that carries a `species` column.
- **Scope:** Slice 2 only. **Do NOT** retrofit `getPotentialParents`/`checkParentAge` (they run on a scalar `minParentAge` today; changing them touches breeding-group formation — out of scope). Unifying breeding-age determination package-wide is a follow-up.

### E. Slice 2 spec — RATIFIED (supersedes §4 "Slice 2 = S1")

**Scope:** correct the mean kinship of **one-unknown (partial-parentage) animals only**, via the per-focal peer-cohort substitution above. This grew from the plan's "one line in `reportGV`" to a real vertical slice: a species/sex breeding-age table + accessor + a per-focal peer-cohort helper + the scalar substitution (clamp + fallback). **Biggest dragon: scope size — do not let it sprawl into Slice 3's both-unknown/`gu` work.**

- **RED:** (a) unit test for `getSpeciesMinBreedingAge` — rhesus male 4 / female 3; **unknown species OR absent `species` column -> default 2**. (b) unit test for the peer-cohort helper on a small fixture (deterministic cohort + hand-computed `sexMean`), covering BOTH a **column-absent** case (cutoff 2) and a **`species`-present** case (rhesus cutoff 4). (c) unit test for the scalar substitution: a one-unknown fixture animal's `MK_corrected == pmin(MK_current + sexMean/2, 1)`, clamp holds, known + both-unknown animals unchanged, empty-cohort -> flagged-not-NA. **Include a missing-DAM fixture animal** so the female-cohort branch is exercised (`qcPed` has none — all 43 are missing-sire). (d) integration: on `qcPed`, each of the 43 one-unknown animals' `indivMeanKin` rises by exactly `sexMean/2` of its **missing parent's-sex** cohort — and because `qcPed` has **no `species` column the cohort cutoff is the default 2, NOT rhesus 4**, and all 43 are missing-sire so only the male branch runs; known + both-unknown animals are untouched. **Do NOT** assert a change in `test_orderReport:24,42` (verified unchanged).
- **GREEN:** extend `speciesGestation` (+ `data-raw` regen + the `R/data.R` `\describe{}` update + `man/speciesGestation.Rd` regen, §8-D), add `getSpeciesMinBreedingAge`, add the peer-cohort helper (**with the absent-`species`-column guard**, §8-D), inject the substitution at the `indivMeanKin` scalar in `reportGV` (`R/reportGV.R:93-95`) for one-unknown animals only, **branching on which parent is missing**. Keep `kinship()` untouched (5 callers).
- **DONE looks like:** one-unknown animals receive the peer-based `+sexMean/2`; `indivMeanKin` stays in `[0,1]`; known + both-unknown animals unchanged; new tests green; `test_orderReport`/`test_modGeneticValue` invariant tests still green. **The displayed app top-20 will NOT change — that is expected (A); do not treat it as a failure.**
- **Verify:** targeted test files green; clean regression read (`!grepl("test-app-|test-e2e-", file)`, `sum(failed)`+`sum(error)`); build-equivalent `devtools::check(vignettes = FALSE)` = 0/0/0 (Learning 161). No `runModularApp()` smoke needed (no visible/runtime ranking change in Slice 2).
- **Session boundary:** one session. Close out. **NEWS** entry required (user-facing: corrected mean kinship for partial-parentage animals) folded into the publish PR (Learning 157a).

### F. Expanded Slice 3 charter (was "S2: classify")

Slice 3 now owns BOTH the original classification AND the `gu` axis: (1) classify unknown-parent animals (flag both-unknown founders; distinguish genuine **imports** via `origin` from ONPRC-born missing-data stubs); (2) address the `gu` inflation that actually pins them at the top (D6); (3) reconcile the two rank paths so the classification/`gu` fix survives the Shiny `rank(indivMeanKin - gu)` override (D7); (4) update `test_orderReport:24,42` golden counts -> behavior assertions (D8). Requires a `runModularApp()` Phase-3E smoke (changes the displayed ranking). Needs a fixture **with** an `origin` column (`qcPed` lacks it).

### G. New issue to file (owner-requested)

*"Provide minimum male/female breeding-age values for all common colony NHP species in the species reproductive-parameter table, and make those values user-configurable."* Generalizes §D beyond the single seeded rhesus row and adds a user override path. **Filed as issue #73 (S177).**
