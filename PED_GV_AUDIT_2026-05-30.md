# PED + GV Cluster Audit (Session 2)

**Closing the Session 1 coverage gap.** In the Session 1 technical-debt audit
(`TECH_DEBT_AUDIT_2026-05-30.md`), the **PED** (Pedigree Construction & Recoding)
and **GV** (Genetic Value Analysis & Reporting) clusters returned **0 findings each
because their auditor sub-agents failed** — those two functional areas were *not
examined*, not *clean*. This document re-runs both audits and supersedes the
"0 / 0 / 0" rows for PED and GV in the Session 1 Cluster Overview.

- **Date:** 2026-05-30
- **Branch:** `add-methodology`
- **Scope:** read-only. No source files were modified.
- **Type:** technical-debt / refactoring-viability audit (complexity, duplication,
  extensibility) plus correctness hazards surfaced during the read.

---

## Method

Three independent evidence streams, then reconciled:

1. **Multi-agent re-audit (workflow `wf_8077a831-96f`).** Four independent auditors
   ran in parallel — two GV auditors (one complexity/duplication lens, one
   extensibility/magic-number/error-convention lens), one fresh PED cross-check, and
   one deep-dive critic on the highest-complexity files. Auditors were given the
   **real file list from `ls R/`** (no phantom filenames) and required to confirm
   every file with a direct read before citing it.
2. **Adversarial per-finding verification.** Every candidate finding (53 fresh from
   the auditors + 11 PED seed findings carried in from an earlier PED auditor pass)
   was handed to a separate verifier agent that re-read the actual source and was
   instructed to **default to "refuted" if it could not confirm the claim**. Only
   verifier-confirmed findings are reported here.
   - **Result: 63 candidate findings → 61 confirmed, 2 refuted** (67 agents total).
   - The 61 confirmed contain substantial overlap (4 auditors independently
     re-reported the same root causes), so they reduce to the **~24 distinct issues**
     enumerated below.
3. **Author's independent full read.** To guard against a repeat of Session 1's
   silent-agent-failure, the author independently read **all 24 GV-cluster source
   files end-to-end**. Every GV citation in this report was verified directly from
   that read; line numbers are authoritative as of this commit.

**Honesty note on tooling:** as in Session 1, several agents reported transient
empty-output tool failures and had to retry; all *cited* file contents were
genuinely read (the verifiers and the author re-read the source). The two refuted
findings are recorded in the run artifact at
`…/tasks/w9oz3tkdf.output`.

---

## PED — Pedigree Construction & Recoding

Verdict: **largely clean and well-factored.** Functions are small (median ~40 lines),
single-purpose, and mostly side-effect-free. No high-severity rot. The themes are a
pervasive duplicated "founders" idiom, scattered hardcoded sex codes, and
inconsistent error/return conventions.

| ID | Sev | Category | Location | Issue |
|----|-----|----------|----------|-------|
| PED-1 | medium | duplication | `findPedigreeNumber.R:35`, `removeUninformativeFounders.R:40` (+15 sites pkg-wide) | The founders predicate `is.na(ped$sire) & is.na(ped$dam)` is copy-pasted 15+ times — the single most-repeated logic concept in the package. (Same root cause as Session 1 **KIN-2**.) |
| PED-2 | medium | extensibility | `correctParentSex.R:71,73,90,91`; `addParents.R:50,58`; `getPotentialSires.R:22`; `createPedOne.R:19`; `createPedSix.R:46` | Sex codes `"M"/"F"/"U"/"H"` hardcoded as bare literals with no shared constant/vocabulary. (Feeds Session 1 **XARCH-4** species-profile.) |
| PED-3 | medium | duplication / complexity | `getProbandPedigree.R:25-36`; `getPedDirectRelatives.R:48-59`; `getAncestors.R:43-66` | Three independent "walk the pedigree to a fixed point" traversals; the proband walk is a special case of the direct-relatives walk. |
| PED-4 | medium | complexity / extensibility | `getPotentialParents.R:24-117` (loop `50-110`) | 117-line multi-responsibility function with a manual `j` counter to skip NULLs and magic day constants `dYear <- 365L` (ignores leap years), `dYear/2L`, `dYear*1.5`; author's own `# TODO … a bit of a hack` at 92-93. Highest cognitive load in the cluster; marked `experimental`. |
| PED-5 | medium | extensibility (API) | `removeDuplicates.R:31,35,44`; `correctParentSex.R:68,84-87`; `getPotentialParents.R:32,115`; `getPedDirectRelatives.R:30,34,38,42`; `rbindFill.R:34` | Same family of functions variously `stop()`, return `NULL`, or return a structured error list — caller cannot predict the failure mode. (Same theme as Session 1 summary point (e).) |
| PED-6 | medium | complexity | `correctParentSex.R:57-94` (branch at 70) | `reportErrors` flag changes the **return type**: a sex vector when `FALSE` (line 92), a named error list when `TRUE` (84-87). Forces caller-side type dispatch. |
| PED-7 | low | extensibility | `addParents.R:47-61` | Synthesized parents hardcode sex by column: sire→`"M"` (50), dam→`"F"` (58); no unknown option. (Ties to PED-2.) |
| PED-8 | low | complexity (silent partial result) | `findGeneration.R:36-56` (break at 46) | Documented precondition (parents must exist as egos) is **not enforced**: a missing parent-as-ego leaves `gen = NA` with no error/warning; the test only covers the happy path. |
| PED-9 | low | extensibility (magic) | `addUIds.R:42,49` | Placeholder IDs use `sprintf("%04d", …)` — a silent 9999-per-column ceiling that widens without warning beyond it. |
| PED-10 | low | complexity / extensibility | `createPedOne.R:31-38`; `createPedSix.R:61-79` | Example/fixture builders mix construction with filesystem `save()`/`message()` side effects and a hardcoded 7-element display-name vector + magic `dyears(20L)`. (Low impact — `@noRd` fixtures.) |
| PED-11 | low | complexity (minor) | `getRecordStatusIndex.R:14` | `any("recordStatus" %in% names(ped))` wraps an already-length-1 logical — dead defensiveness. |

**PED test gaps** (no dedicated `test_<fn>.R`): `getPotentialSires`, `getAncestors`,
`getIdsWithOneParent`, `hasBothParents`, `findOffspring`, `rbindFill`,
`getDateErrorsAndConvertDatesInPed`, `setPopulation` (only `resetPopulation` tested).
`getPotentialSires` (PED-2) and `getAncestors` (PED-3) are the riskiest untested
files to touch.

**PED genuinely clean (no action):** `getParents`, `getOffspring`, `hasBothParents`,
`getIdsWithOneParent`, `removeUnknownAnimals`, `setPopulation`, `getGVPopulation`,
`createPedTree`, `addAnimalsWithNoRelative`, `addBackSecondParents`, `addIdRecords`,
`trimPedigree` (clean orchestrator over the four helpers).

---

## GV — Genetic Value Analysis & Reporting

Verdict: **well-factored into small named helpers with broad test coverage, but
carrying two real maintainability targets, several inline policy constants, and a
small cluster of correctness/dead-code items** that a thorough read surfaces.

| ID | Sev | Category | Location | Issue |
|----|-----|----------|----------|-------|
| GV-1 | medium | duplication | `calcFE.R:42-79`, `calcFG.R:54-93`, `calcFEFG.R:44-83` | **Verbatim triplication.** The entire founder-contribution matrix algorithm — founders idiom, `d` matrix build, the double `for` loop `d[ego,] <- (d[sire,]+d[dam,])/2L`, `p <- colMeans(d)` — is identical across all three files, **including the same commented-out dead `UID.founders` block and the same factor-warning comment**. `reportGV.R:133` uses **only** `calcFEFG`; `calcFE`/`calcFG` are redundant exported duplicates of code already inside `calcFEFG`. |
| GV-2 | medium | complexity + extensibility (Shiny-in-core) | `reportGV.R:66-160` | ~95-line orchestrator interleaving population setup (72), kinship (81-84), gene-drop (92-96), GU (106), offspring (117), demographics (119-123), FE/FG (133), founder extraction (136-142), wrapped around four `updateProgress()` Shiny-progress side-effect calls (92-96, 98-103, 109-114, 125-130). (Overlaps/extends Session 1 **XARCH-3**.) |
| GV-3 | medium | duplication | `reportGV.R:136`, `orderReport.R:29`, `calcFE.R:44`, `calcFG.R:56`, `calcFEFG.R:46`, `calcRetention.R:26` | The founders idiom again, inside the GV cluster (cross-ref **PED-1 / KIN-2**). |
| GV-4 | medium | extensibility (magic) + doc bug | `orderReport.R:58,60,63,66` | The genetic-value **ranking policy is hardcoded as bare literals**: `gu > 10L` (10% genome-uniqueness cutoff) and `zScores <= 0.25` / `> 0.25` (mean-kinship z-score cutoff). No named constant. The param doc (line 16) says "mean kinship less than 0.25" but the code thresholds the **z-score** — a doc/code mismatch. |
| GV-5 | low | extensibility + robustness | `getProportionLow.R:16-27` | Color-band thresholds `0.5`/`0.3` and strings `"red"/"yellow"/"green"` hardcoded; matches literal `"Low"`. Robustness gap: an empty input yields `proportion = NaN`, which fails all three branches, leaving `color`/`colorIndex` **unassigned → error**. |
| GV-6 | low-med | duplication / extensibility | `makeGeneticSummaryTable.R:57-91`; `makeFounderStatsTable.R:67-88` | Two near-identical hand-assembled Bootstrap HTML tables built via long `paste0` literal-tag chains (same scaffold pattern). `makeGeneticSummaryTable` also reads already-renamed columns `meanKinship`/`genomeUniqueness` (35,43) — coupling to the consumer-side rename (ties to Session 1 **XARCH-2**). Neither has a test. |
| GV-7 | low | **dead code** | `makeGeneticDiversityDashboard.R:12-57` | The **entire function body is commented out** (`##`); the file defines no function. Its test (`test_makeGeneticDiversityDashboard.R`) is also fully commented. Delete or implement. |
| GV-8 | medium | **correctness** + efficiency | `summarizeKinshipValues.R:99-113` | `tukeys <- fivenum(numbers)` then `min = tukeys[1L]` **and** `secondQuartile = tukeys[1L]` (line 106) — the second-quartile column is assigned the **minimum** instead of the lower hinge `tukeys[2L]`. `median = tukeys[3L]`/`thirdQuartile = tukeys[4L]` are correct, so `secondQuartile` silently duplicates `min`. Also `rbind` inside the loop (100-113) is quadratic. *Verify whether the `secondQuartile` column is consumed downstream before deciding severity.* |
| GV-9 | low-med | complexity + possible correctness | `countKinshipValues.R:80-142` (esp. 131-134) | Deeply nested accumulation. In the multi-batch branch, `countDiffs <- integer(length(valueDiffs))` is then written as `countDiffs[index] <- …` using the **outer** loop variable `index` rather than a per-value position — a latent indexing bug reached only when accumulating across simulation batches with differing value sets. |
| GV-10 | low | extensibility (magic) | `calcGU.R:91,94` | `gu <- rowSums(rare) / (2L * iterations)` (diploid factor `2L`) and `gu * 100L` (percent) as bare literals. Otherwise `calcGU` is a clean 17-line delegator to `calcA()`. |
| GV-11 | low | duplication | `createSimKinships.R:50-62`; `cumulateSimKinships.R:44-67` | Both repeat the population-setup + simulate-then-kinship loop (`makeSimPed` → `kinship`). Minor divergence: `createSimKinships` calls `setDT(ped)` (50), `cumulateSimKinships` does not. (Same root as Session 1 **KIN-4**; `cumulate`'s running sum/sum-of-squares variance is intentionally memory-efficient and good.) |
| GV-12 | low | extensibility (stringly-typed) | `rankSubjects.R:35,37,36,38,40` | Couples to `orderReport`'s list names via hardcoded `"lowVal"`/`"noParentage"` and emits hardcoded labels `"Low Value"/"Undetermined"/"High Value"`. |
| GV-13 | low | duplication | `orderReport.R:31-42` vs `44-54` | The imports block and noParentage block repeat the same `if ("age" %in% …) order(age) else order(id)` branch. |

**GV test gaps** (no dedicated test file — raise regression risk for any refactor):
`getAnimalsWithHighKinship`, `makeGeneticSummaryTable`, `makeFounderStatsTable`,
`makeRelationClassesTable`, `kinshipMatrixToKValues`, `addKinshipValueCount`,
`getGVGenotype`, `getBoxWhiskerDescription`.

**GV genuinely clean (no action):** `meanKinship` (colMeans wrapper), `getMaxAx`
(one-liner), `filterReport` (one-liner), `filterThreshold` (clean; default `0.015625`
= 1/64 is a documented kinship threshold), `kinMatrix2LongForm`,
`kinshipMatrixToKValues` (well-contained triangle→long-form), `addKinshipValueCount`,
`getGVGenotype`, `getBoxWhiskerDescription`, `makeSimPed`, `geneDrop` (appropriately
structured simulation), `getGVGenotype`.

---

## Distinct underlying issues (deduped) & cross-cluster overlaps

After collapsing the 61 confirmed candidate findings (4 auditors re-reported many of
the same root causes) the distinct issues are:

1. **Founders idiom duplication** — PED-1, GV-3 (+ Session 1 KIN-2). Package-wide;
   the canonical quick-win is a `getFounders(ped)` / `isFounder(ped)` helper.
   ⚠ Do **not** naively unify the adjacent `descendants` lines — `calcRetention.R:27`
   filters by `ped$population`; the `calc*` copies do not (Session 1 KIN-2 trap).
2. **calcFE / calcFG / calcFEFG triplication** — GV-1. Strongest GV target; only
   `calcFEFG` is used by `reportGV`.
3. **`reportGV` length + Shiny-progress coupling** — GV-2 (+ XARCH-3).
4. **Hardcoded sex codes M/F/U/H** — PED-2, PED-7 (+ XARCH-4 species profile).
5. **Inconsistent error/return conventions** — PED-5, PED-6.
6. **Duplicated graph-walk traversals** — PED-3.
7. **`getPotentialParents` complexity + leap-year/day magic** — PED-4.
8. **Inline genetic-value ranking policy constants** — GV-4 (gu>10, z≤0.25).
9. **HTML table-builder duplication + column-rename coupling** — GV-6 (+ XARCH-2).
10. **Sim-kinship loop duplication** — GV-11 (+ KIN-4).
11. **Correctness / dead-code cluster** — see next section.

---

## Correctness & dead-code items (highest-value to act on)

These are not mere style debt:

- **GV-7 — `makeGeneticDiversityDashboard.R` is a fully dead file** (body commented
  out; no function defined). Safe deletion candidate (verify no `::` reference first).
- **GV-8 — `summarizeKinshipValues.R:106` second-quartile = minimum** (should be
  `tukeys[2L]`). Probable defect; confirm downstream use of the column.
- **GV-9 — `countKinshipValues.R:133` outer-loop index** in the cross-batch
  accumulation path. Latent; add a test that accumulates differing value sets.
- **GV-5 — `getProportionLow` undefined `color` on empty input.** Add a default.
- **PED-8 — `findGeneration` silent `NA`** when a parent id is missing as an ego.
  Validate-or-warn.

Each, if pursued, is a separate strictly-TDD session (write the failing test first).

---

## Verification & coverage

- **Adversarial verification:** 63 candidate findings → **61 confirmed, 2 refuted**
  by independent source-reading verifiers (default-refute on uncertainty). The
  per-finding verdict JSON is in the run artifact
  (`…/tasks/w9oz3tkdf.output`); the two refuted candidates were over-broad
  restatements that did not survive a second read.
- **Author independent read:** all 24 GV files read end-to-end; every GV citation
  above verified directly.
- **PED files read:** 28+ (full list in the PED auditor pass). **GV files read:** 24.
- **Out of scope (other clusters):** pedigree loaders `getFocalAnimalPed`,
  `getPedigree`, `getLkDirect*` (loader cluster); core kinship math `kinship.R`,
  `calcA.R` (read for context, owned by KIN); genotype I/O (GENO).

### Updated Cluster Overview rows (supersede the Session 1 "0/0/0" rows)

| Code | Name | Distinct issues | Severity mix |
|------|------|----------------:|--------------|
| PED | Pedigree Construction & Recoding | 11 | 6 medium, 5 low |
| GV | Genetic Value Analysis & Reporting | 13 | 5 medium, 8 low (1 medium = correctness: GV-8) |

---

## Recommendations / sequencing

Honoring strict TDD and one-deliverable-per-session:

1. **Quick wins first (low risk, tested):** `getFounders()` helper (PED-1/GV-3/KIN-2,
   minding the population-filter trap); GV-7 dead-file deletion; GV-4 named ranking
   constants + doc fix.
2. **Correctness pass:** GV-8, then GV-5, GV-9, PED-8 — each test-first.
3. **Duplication consolidation:** GV-1 (`calcFE`/`calcFG` delegate to `calcFEFG`
   or extract `founderContributionMatrix()`), GV-11/KIN-4 shared sim helper.
4. **Decouple Shiny from core:** GV-2 / XARCH-3 (generic `progress` hook).
5. **Larger overhauls (own planning sessions):** PED-4, PED-5/6 (error contract),
   XARCH-2/4 column-schema & species-profile, which several of the above feed.

*This is an audit only. Implementing any target is a separate, strictly
test-driven (RED→GREEN→REFACTOR), one-deliverable-per-session effort.*
