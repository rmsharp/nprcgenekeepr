# PED + GV Cluster Audit (Session 2)

**Closing the Session 1 coverage gap.** In the Session 1 technical-debt audit
(`TECH_DEBT_AUDIT_2026-05-30.md`), the **PED** (Pedigree Construction & Recoding)
and **GV** (Genetic Value Analysis & Reporting) clusters returned **0 findings each
because their auditor sub-agents failed** — those two functional areas were *not
examined*, not *clean*. This document re-runs both audits and **supersedes the
"0 / 0 / 0" rows for PED and GV** in the Session 1 Cluster Overview.

- **Date:** 2026-05-30 · **Branch:** `add-methodology`
- **Scope:** read-only. **No source files were modified.**
- **Type:** technical-debt / refactoring-viability audit (complexity, duplication,
  extensibility) **plus correctness hazards** surfaced during the read.

---

## Method

Three independent evidence streams, then reconciled:

1. **Multi-agent re-audit (workflow `wf_8077a831-96f`).** Four independent auditors in
   parallel — two GV auditors (complexity/duplication lens; extensibility/magic-number/
   error-convention lens), one fresh PED cross-check, one deep-dive critic on the
   highest-complexity files — each given the **real `ls R/` file list** (no phantoms)
   and required to confirm every file with a direct read before citing it.
2. **Adversarial per-finding verification.** Every candidate (53 fresh + 11 PED seed)
   was handed to a separate verifier that re-read the actual source and was instructed
   to **default to "refuted" on any uncertainty**. Only verifier-confirmed findings
   are reported here. **Result: 63 candidates → 61 confirmed, 2 refuted** (67 agents).
3. **Author independent full read.** To avoid repeating Session 1's silent-agent
   failure, the author independently read **all 24 GV-cluster files end-to-end**;
   every GV citation here was verified directly. The author's reads corroborate the
   verifiers on every spot-checked item (founders idiom, calcFE/FG/FEFG triplication,
   `summarizeKinshipValues` quartile mislabel, dead `makeGeneticDiversityDashboard`,
   `countKinshipValues` index, `makeSimPed` in-place mutation, `cumulateSimKinships`
   n=1 sd, `geneDrop` period-in-id).

**Confirmed-finding distribution:** severity **1 high · 12 medium · 48 low**;
fix type **38 quick-win · 23 overhaul**; tests **57 have a test · 4 do not**
(NEW-20, NEW-41, NEW-44, NEW-58); regression risk 38 low / 22 medium / 1 high.

The 61 confirmed contain heavy overlap (4 auditors independently re-reported the same
roots); they collapse to the **~24 distinct issues** in §"Deduped issues" below.
Per-finding verdict JSON (incl. the 2 refuted) is archived in the run artifact
`…/18efd281-…/tasks/w9oz3tkdf.output`.

---

## Headline

- **PED is largely clean** (mostly small, single-purpose functions). Its debt is
  duplication (founders idiom, walk helpers), scattered hardcoded sex codes, and
  inconsistent error/return conventions — but it also hides **two real correctness
  hazards**: a crash (`getPotentialParents` unbound `j`, NEW-34) and silent `NA`
  generations (`findGeneration`, NEW-40).
- **GV is well-factored with broad test coverage**, but carries the audit's **only
  high-severity bug** (`countKinshipValues` indexing, NEW-15), a verbatim
  `calcFE`/`calcFG`/`calcFEFG` triplication (NEW-13/23), `reportGV` length + Shiny
  coupling (NEW-12), inline ranking-policy constants, an **entirely dead file**
  (NEW-20), and a cluster of latent correctness items in the simulation/gene-drop path.

---

## Correctness & dead-code findings (act on these first)

### NEW-15 — `countKinshipValues.R:131-134` wrong loop index  ·  **HIGH** · correctness
`countDiffs <- integer(length(valueDiffs))` then `for (value in valueDiffs) {
countDiffs[index] <- kCounts[[index]][kValues[[index]] == value] }`. The vector is
sized to `length(valueDiffs)` and the loop iterates over `valueDiffs`, but the
assignment indexes by the **outer** loop variable `index`, not a per-value position.
Every iteration writes the same slot (all but the last new value are lost); if
`index > length(valueDiffs)` the vector silently grows with leading 0/NA. Correct
form: `for (i in seq_along(valueDiffs)) countDiffs[i] <- kCounts[[index]][kValues[[index]] == valueDiffs[i]]`.
**The test only exercises same-`kValues` runs, so `valueDiffs` is always empty and
this block (l.127-138) is never entered — the defect is untested.** (Independently
confirmed by the author's own read.)

### NEW-34 — `getPotentialParents.R` references `j` outside its block (crash) · medium · correctness
`j <- 0L` is assigned only inside the `if (nrow(pUnknown) > 0L)` block (l.49), but
`if (j > 0L)` (l.112) reads `j` **unconditionally** outside it. When no in-colony
animal has a missing parent (or the birth filter empties the table), R raises
`Error: object 'j' not found` instead of returning `NULL`. One-line fix: hoist
`j <- 0L` above the `if`.

### NEW-37 — `correctParentSex.R` silently rewrites H/U parents to M/F · medium · correctness
Report branch tests `!sex %in% c("H","U","M")` / `c("H","U","F")` (H/U **not**
flagged); the default correction branch tests `sex != "M"` / `sex != "F"` (l.72/80)
and overwrites — so hermaphrodite/unknown parents are silently forced to M/F.
Inconsistent membership rules between branches; untested for H/U.

### NEW-40 — `findGeneration.R:36-56` silent `NA` generations · medium · correctness
`gen <- rep(NA, …)`; ids whose parent never appears as an ego id are never reached
and keep `gen = NA`, with no `stop()`/`warning()`. The roxygen precondition (l.20) is
unenforced; the test covers only the self-contained happy path.

### NEW-45 — `geneDrop.R:122-134` period-in-id corrupts allele assignment · medium · correctness
`strsplit(rownames(alleles), ".", fixed = TRUE)` then `id <- key[1]; parent <- key[2]`.
Rownames are `id.sire`/`id.dam`; an id containing `.` (e.g. `"A.1"` → `"A.1.sire"`)
splits to `c("A","1","sire")` → `id="A"` (truncated), `parent="1"` (wrong). Silent
mis-assignment; no guard. Latent (fixtures use plain ids).

### NEW-48 — `calcFEFG.R:73` NA propagation (no partial-parentage guard) · medium · correctness
`d[ego,] <- (d[sire,] + d[dam,]) / 2L` with character indexing. Roxygen documents
"no partial parentage" but there is **no guard**; an `NA` parent makes `d[NA,]` an
all-NA row that contaminates the ego and every descendant, silently corrupting
`p <- colMeans(d)` and the returned FE/FG.

### NEW-53 — `makeSimPed.R:24-48` mutates the caller's pedigree in place · medium · correctness
The exported `makeSimPed` calls `data.table::setDT(ped)` (by reference) then assigns
sire/dam with no `copy()`, so the caller's `ped` is mutated (class flips to
`data.table`; sire/dam overwritten). `createSimKinships` similarly does an
unconditional `setDT` + adds a population column in place.

### NEW-52 — `cumulateSimKinships.R:70-73` sd divide-by-zero / NaN · low · correctness
`sqrt(((n*squaredKinship) - sumKinship^2)/(n*(n-1)))` — catastrophic-cancellation
form; `n = 1` → 0/0 = NaN; near-constant cells → tiny-negative under the root → NaN.

### NEW-20 — `makeGeneticDiversityDashboard.R` is entirely dead code · low · dead-code · **(no test)**
The whole function body (l.12-57) is commented out; the file defines no function. Its
test (`test_makeGeneticDiversityDashboard.R`) is also fully commented. Delete or
implement (verify no `::` reference first).

### Other confirmed correctness/robustness items
- **NEW-25** `getProportionLow.R:14-28` — empty input → `proportion = NaN`; the
  three-way `if/else-if` has no terminal `else`, so `if (NaN > 0.5)` raises
  *"missing value where TRUE/FALSE needed"* (the empty-input crash holds; the precise
  message differs from the original "object color not found" claim).
- **NEW-31 / NEW-32** `getRecordStatusIndex.R` returns `integer(0)` when `recordStatus`
  is absent; `removeUnknownAnimals` then silently yields a 0-row pedigree.
- **NEW-16** `summarizeKinshipValues.R:105-106` — `min` and `secondQuartile` are
  **both** `fivenum()[1]` (the minimum); Q1 should be `[2]`. Plus `rbind`-in-loop O(n²).
- **NEW-38** `addUIds`/`removeAutoGenIds` — the `"U"`-prefix scheme can collide with /
  wrongly strip real `U…` ids.
- **NEW-41** `getAncestors.R:43-66` — recursive walk with **no cycle guard / no dedup**. **(no test)**
- **NEW-46** `geneDrop` parent lookup by rowname with no duplicate-id uniqueness guard.
- **NEW-58** `getAnimalsWithHighKinship.R:45-63` — `tapply` collapse silently drops
  animals with zero qualifying partners. **(no test)**
- **NEW-59** `makeGeneticSummaryTable` — unnamed `rep(NA,6)` fallback indexed by name
  (works only because `fmt()` guards `is.na`).

---

## All confirmed findings (61)

Severity/category are verifier-adjusted where present; `T/F` = has dedicated test.

### PED — Pedigree Construction & Recoding

| ID | sev | category | fix | risk | location | issue |
|----|-----|----------|-----|------|----------|-------|
| PED-1 | medium | duplication | quick-win | low | `findPedigreeNumber.R:35`, `removeUninformativeFounders.R:40` (+16 sites) | founders idiom `is.na(sire)&is.na(dam)` duplicated package-wide |
| PED-2 | low | extensibility | overhaul | medium | `correctParentSex.R`, `addParents.R`, `getPotentialSires.R`, `createPedOne/Six.R` | sex codes M/F/U/H hardcoded, no shared constant |
| PED-3 | low | duplication | overhaul | medium | `getProbandPedigree.R:25-36`, `getPedDirectRelatives.R:48-59` | duplicated ancestor/relative graph-walk loops |
| PED-4 | medium | complexity | overhaul | medium | `getPotentialParents.R:24-117` | 117-line multi-responsibility fn; magic `365L` |
| PED-5 | low | extensibility | overhaul | medium | `removeDuplicates`, `correctParentSex`, `getPotentialParents`, `getPedDirectRelatives`, `rbindFill.R:34` | inconsistent error/return (stop vs NULL vs list) |
| PED-6 | medium | complexity | overhaul | medium | `correctParentSex.R:57-94` | return **type** changes with `reportErrors` flag |
| PED-7 | low | extensibility | quick-win | low | `addParents.R:50,58` | hardcodes sire→M, dam→F |
| PED-8 | low | complexity | quick-win | low | `findGeneration.R:36-56` | (see NEW-40) silent NA generations |
| PED-9 | low | extensibility | quick-win | low | `addUIds.R:42,49` | fixed 4-digit width, silent 9999 ceiling |
| PED-10 | low | complexity | quick-win | low | `createPedOne.R:31-39`, `createPedSix.R:61-79` | data construction mixed with filesystem side effects |
| PED-11 | low | complexity | quick-win | low | `getRecordStatusIndex.R:14` | `any()` on a length-1 `%in%` |
| NEW-33 | low | complexity/magic | quick-win | medium | `getPotentialParents.R:43-103` | magic 365-day year; 182 vs 547.5 asymmetry; ignores leap years |
| NEW-34 | medium | **correctness** | quick-win | low | `getPotentialParents.R:47-116` | unbound `j` → crash when `pUnknown` empty |
| NEW-35 | low | complexity/correctness | overhaul | medium | `getPotentialParents.R:90-103` | dam exclude→intersect→replace re-admits excluded dams (author-flagged) |
| NEW-36 | low | extensibility | overhaul | medium | `correctParentSex.R:70-93` | flag-controlled dual return type |
| NEW-37 | medium | **correctness** | quick-win | medium | `correctParentSex.R:51,59,72-73,80-81` | non-report branch silently rewrites H/U sires/dams to M/F |
| NEW-38 | low | correctness/ext | overhaul | medium | `addUIds.R:42,47-49`, `removeAutoGenIds.R:20-24` | `U`-prefix collision / wrongful strip |
| NEW-39 | low | extensibility/dup | quick-win | low | `addParents.R:50,58` | hardcoded M/F by column (≡ PED-7) |
| NEW-40 | medium | **correctness** | quick-win | medium | `findGeneration.R:36-56` | silent NA generations when pedigree not self-contained |
| NEW-41 | low | correctness | quick-win | medium | `getAncestors.R:43-66` | **(F)** recursive walk, no cycle guard / no dedup |
| NEW-42 | low | duplication/ext | overhaul | medium | `getOffspring`/`getParents`/`findOffspring`/`getPedDirectRelatives`/`getProbandPedigree`/`findPedigreeNumber` | near-duplicate walk helpers, inconsistent arg order |
| NEW-43 | low | complexity/ext | quick-win | low | `createPedOne.R:13`, `createPedSix.R:12` | file-writing side effects ON by default (`savePed=TRUE`) |
| NEW-44 | low | extensibility | quick-win | low | `rbindFill.R:22-36` | **(F)** `stop()`s on factor/list/complex cols instead of degrading |
| NEW-54 | low | complexity | quick-win | low | `getPotentialParents.R:25,39-64` | mixes data.table NSE and `$`-indexing |
| NEW-55 | low | extensibility | overhaul | low | `getPotentialParents.R:90-109` | dam heuristic silently collapses confidence tiers |
| NEW-56 | low | complexity | quick-win | low | `getPotentialParents.R:106` | `id = pUnknown$id[i][1L]` indexes an already-scalar value |

### GV — Genetic Value Analysis & Reporting

| ID | sev | category | fix | risk | location | issue |
|----|-----|----------|-----|------|----------|-------|
| NEW-12 | medium | complexity | overhaul | **high** | `reportGV.R:66-160` | long mixed-responsibility orchestrator; Shiny progress threaded into compute |
| NEW-13 | medium | duplication | overhaul | medium | `calcFEFG.R:45-79`, `calcFE.R:43-77`, `calcFG.R:55-89` | near-verbatim founder-contribution algorithm in 3 files |
| NEW-23 | medium | duplication | overhaul | medium | `calcFE.R:43-79`, `calcFG.R:55-92`, `calcFEFG.R:45-82` | FEFG = 100% of FE+FG; three 80-93-line near-identical fns |
| NEW-14 | low | complexity | quick-win | low | `kinshipMatricesToKValues.R:92-111` | first-flag accumulator instead of `lapply` |
| NEW-15 | **high** | **correctness** | overhaul | medium | `countKinshipValues.R:101-140` (defect l.133) | wrong loop index in value-diff accumulation |
| NEW-16 | low | correctness(mislabel)/perf | quick-win | low | `summarizeKinshipValues.R:81-116` | `secondQuartile` = min; `rbind`-in-loop |
| NEW-17 | low | duplication | quick-win | low | `getGVPopulation.R:28-36` + reportGV/createSim/cumulateSim | repeated population-setup idiom |
| NEW-18 | low | duplication | quick-win | low | `makeGeneticSummaryTable.R:28-94`, `makeFounderStatsTable.R:37-91` | hand-built HTML literals; repeated null-guard scaffolding |
| NEW-19 | low | duplication | quick-win | low | `makeRelationClassesTable.R:34-39` | relationClass magic vector duplicated from domain |
| NEW-20 | low | **dead-code** | quick-win | low | `makeGeneticDiversityDashboard.R:1-56` | **(F)** entirely commented out; no live fn |
| NEW-21 | low | extensibility | quick-win | low | `getProportionLow.R:24-27` (+filter helpers) | threshold primitive mildly scattered |
| NEW-22 | low | duplication/magic | overhaul | medium | `calcFE.R:71`, `calcFG.R:83`, `calcFEFG.R:73`, `kinship.R:98-99` | Mendelian ½ factor hardcoded in 5 places |
| NEW-24 | low | extensibility | overhaul | medium | reportGV; calcGU/A/Retention; geneDrop; calcFE/FG/FEFG; getRequiredCols/getIncludeColumns | column vocabulary stringly-typed, not from a schema |
| NEW-25 | low | error-conv/edge | quick-win | low | `getProportionLow.R:14-28` | NaN (empty input) sets no branch → crash |
| NEW-26 | low | magic/ext | quick-win | low | filterThreshold/getProportionLow/rankSubjects/makeGeneticSummaryTable/reportGV/calcGU | scattered genetic thresholds & rounding constants |
| NEW-27 | low | (positive) | quick-win | low | `reportGV.R`, `geneDrop.R` | Shiny progress handled cleanly via injected `updateProgress` (positive) |
| NEW-28 | low | error-conv | overhaul | low | `kinship.R:71-74` vs other GV fns | `kinship()` uses `stop()`; others rely on bare R failures |
| NEW-29 | low | magic/dup/ext | quick-win | low | `reportGV.R:136-142`; dead `^U` in calcFE/FG/FEFG | hardcoded sex/status codes & `^U` prefix in founder logic |
| NEW-30 | low | dead-code/copy-paste | quick-win | low | `calcFE/FG/FEFG.R` | dead/unused computed variables |
| NEW-45 | medium | **correctness** | overhaul | medium | `geneDrop.R:122-134` | period-in-id `strsplit` mis-assigns alleles |
| NEW-46 | low | correctness | quick-win | low | `geneDrop.R:82-104` | parent lookup by rowname; duplicate ids → wrong values |
| NEW-47 | low | complexity | quick-win | low | `calcGU.R:89-91` | iteration divisor from input column set, not matrix width |
| NEW-48 | medium | **correctness** | overhaul | medium | `calcFEFG.R:73` | unchecked no-partial-parentage precondition → silent NA rows |
| NEW-50 | low | duplication | overhaul | medium | `cumulateSimKinships.R:41-67`, `createSimKinships.R:46-63` | duplicated-and-diverging sim driver (setDT/verbose in one only) |
| NEW-51 | low | correctness | quick-win | low | `cumulateSimKinships.R:47-66` | positional matrix accumulation, no dimname/order assertion |
| NEW-52 | low | **correctness** | quick-win | low | `cumulateSimKinships.R:70-73` | sd divide-by-zero (n=1) / NaN |
| NEW-53 | medium | **correctness** | quick-win | medium | `makeSimPed.R:24-48` | mutates caller's `ped` in place (data.table reference) |
| NEW-57 | low | extensibility | overhaul | low | `rankSubjects.R:30-48` | value/rank policy coupled to magic list-name strings |
| NEW-58 | low | correctness | overhaul | low | `getAnimalsWithHighKinship.R:45-63` | **(F)** `tapply` drops zero-partner animals |
| NEW-59 | low | correctness | quick-win | low | `makeGeneticSummaryTable.R:36-40,73-87` | unnamed `rep(NA,6)` fallback indexed by name |
| NEW-61 | low | duplication | overhaul | low | `reportGV.R:135-142`, `calcFEFG.R:44-52` | reportGV vs calcFEFG define "founder" differently (U-id handling) |
| NEW-62 | low | duplication | quick-win | low | `reportGV.R:98-130` | `updateProgress` null-check boilerplate ×4 |
| NEW-63 | low | complexity(doc) | quick-win | low | `getMaxAx.R:17-19` | doc says "negative (males)" but code takes plain max |

---

## Deduped issues (~24 distinct roots)

Tags: PED · GV · X-cut (cross-cutting).

| # | Issue | Contributing IDs | Consensus | Location | Tag |
|---|-------|------------------|-----------|----------|-----|
| 1 | **`getPotentialParents` bundle** (length, magic 365, unbound-`j` crash, dam hack, NSE-mix, scalar index, confidence collapse) | PED-4, NEW-33/34/35/54/55/56 | medium / complexity+correctness | `getPotentialParents.R` | PED |
| 2 | **`reportGV` orchestrator** (length+Shiny, stringly cols, hardcoded codes, founder-def disagreement, boilerplate; +positive Shiny note) | NEW-12/24/27/29/61/62 | medium / complexity | `reportGV.R` | X-cut |
| 3 | **calcFE/FG/FEFG triplication** (verbatim dup, ½ magic, dead UID block, NA propagation) | NEW-13/22/23/30/48 | medium / duplication (+1 correctness) | `calcFE.R`,`calcFG.R`,`calcFEFG.R` | GV |
| 4 | **`correctParentSex` flag/return** (M/F/U/H, dual return type ×2, silent H/U overwrite) | PED-2, PED-6, NEW-36/37 | medium / correctness+complexity | `correctParentSex.R` | PED |
| 5 | **recordStatus handling** (`any()` misuse, silent empty pedigree) | PED-11, NEW-31/32 | low / correctness | `getRecordStatusIndex.R`,`removeUnknownAnimals.R` | PED |
| 6 | **Sim driver dup & mutation** (diverging loop, positional accumulation, n=1 sd, in-place mutation) | NEW-50/51/52/53 | medium / correctness | `createSimKinships.R`,`cumulateSimKinships.R`,`makeSimPed.R` | GV |
| 7 | **`geneDrop` id-parsing** (period-in-id corruption, duplicate-id lookup) | NEW-45/46 | medium / correctness | `geneDrop.R` | GV |
| 8 | **`findGeneration` silent NA** | PED-8, NEW-40 | medium / correctness | `findGeneration.R` | PED |
| 9 | **`addParents` hardcoded sex** | PED-7, NEW-39 | low / extensibility | `addParents.R` | PED |
| 10 | **`U`-prefix scheme** (width ceiling, collision) | PED-9, NEW-38 | low / correctness+ext | `addUIds.R`,`removeAutoGenIds.R` | PED |
| 11 | **`createPed*` side effects** (save-by-default + literals) | PED-10, NEW-43 | low / complexity | `createPedOne.R`,`createPedSix.R` | PED |
| 12 | **`getProportionLow`** (NaN crash + scattered thresholds) | NEW-21/25 | low / error-conv | `getProportionLow.R` | GV |
| 13 | **`makeGeneticSummaryTable`** (HTML dup + unnamed NA fallback) | NEW-18/59 | low | `makeGeneticSummaryTable.R` | GV |
| 14 | **Founders idiom duplication** | PED-1 | medium / duplication | 16+ sites | X-cut |
| 15 | **Walk-helper family duplication** | PED-3, NEW-42 | low / duplication | walk helpers | PED |
| 16 | **`countKinshipValues` indexing bug** | NEW-15 | **high / correctness** | `countKinshipValues.R:133` | GV |
| 17 | **`summarizeKinshipValues`** (Q1=min, rbind-in-loop) | NEW-16 | low / correctness+perf | `summarizeKinshipValues.R` | GV |
| 18 | **Dead `makeGeneticDiversityDashboard`** | NEW-20 | low / dead-code | file | GV |
| 19 | **`getAncestors` no cycle guard** | NEW-41 | low / correctness | `getAncestors.R` | PED |
| 20 | **`getAnimalsWithHighKinship` zero-partner drop** | NEW-58 | low / correctness | file | GV |
| 21 | **Scattered magic constants / Mendelian ½** | NEW-26 (+NEW-22) | low / magic | multiple | X-cut |
| 22 | **Error-convention inconsistency** | PED-5, NEW-28, NEW-44 | low / error-conv | multiple | X-cut |
| 23 | **`rankSubjects` magic list-name coupling** | NEW-57 | low / extensibility | `rankSubjects.R` | GV |
| 24 | **`calcGU` divisor / `kinshipMatricesToKValues` accumulator / `getMaxAx` doc / relationClass vector** | NEW-47/14/63/19 | low | respective files | GV |

---

## Appendix — Refuted findings (transparency)

Two candidates were **refuted** by verification (causal mechanism did not hold against
source); they are excluded from the findings above.

| ID | Title | File | Why refuted |
|----|-------|------|-------------|
| NEW-49 | calcFEFG/FG divides by retention `r` with `na.rm=TRUE`; calcRetention claimed to return NA for a founder via `tapply(mean)` over empty/NA groups | `calcFEFG.R:81-82`, `calcRetention.R` | Literal code confirmed, but the mechanism is wrong: `rowSums(…, na.rm=TRUE)/ncol` cannot be NA, and `tapply(mean)` over finite values cannot yield NA; a founder absent from `alleles` is *missing* from `r`, not *NA*. The candidate conflated "missing element" with "NA element." (A different, real `p`-vs-`r` length-mismatch hazard exists but is **not** the described tapply-NA bug.) |
| NEW-60 | reportGV final result assembled by positional `cbind`; `offspring` claimed not reindexed to `probands` (alignment hazard) | `reportGV.R:87-144` | Descriptive claims accurate, but `offspringCounts`→`findOffspring` (l.36-39) explicitly orders output by `probands` via `match()` and fills missing with 0, so `offspring` *is* in probands order one frame deeper. A style/locality observation, not a correctness defect. |

---

## Coverage & test gaps

- **GV files read end-to-end (24):** reportGV, calcGU, calcFE, calcFG, calcFEFG,
  calcRetention, geneDrop, rankSubjects, orderReport, filterReport, filterThreshold,
  getProportionLow, getAnimalsWithHighKinship, getGVPopulation, getMaxAx, meanKinship,
  makeGeneticSummaryTable, makeFounderStatsTable, makeRelationClassesTable,
  makeGeneticDiversityDashboard, summarizeKinshipValues, countKinshipValues,
  addKinshipValueCount, kinMatrix2LongForm, kinshipMatricesToKValues,
  kinshipMatrixToKValues, createSimKinships, cumulateSimKinships, makeSimPed,
  getGVGenotype, getBoxWhiskerDescription.
- **PED files read (28+)** by the PED auditor + cross-check.
- **Confirmed findings with NO dedicated test (raise refactor risk):** NEW-20
  (`makeGeneticDiversityDashboard`), NEW-41 (`getAncestors`), NEW-44 (`rbindFill`),
  NEW-58 (`getAnimalsWithHighKinship`). Also no `test_<fn>.R` for
  `makeGeneticSummaryTable`, `makeFounderStatsTable`, `makeRelationClassesTable`,
  `kinshipMatrixToKValues`, `addKinshipValueCount`, `getGVGenotype`,
  `getBoxWhiskerDescription`; PED gaps: `getPotentialSires`, `getIdsWithOneParent`,
  `hasBothParents`, `findOffspring`, `getDateErrorsAndConvertDatesInPed`,
  `setPopulation` (only `resetPopulation` tested).
- **Out of scope (other clusters):** loaders `getFocalAnimalPed`/`getPedigree`/
  `getLkDirect*`; core kinship math `kinship.R`/`calcA.R` (read for context, owned by
  KIN); genotype I/O (GENO).

### Updated Cluster Overview rows (supersede the Session 1 "0/0/0" rows)

| Code | Name | Confirmed | Severity mix |
|------|------|----------:|--------------|
| PED | Pedigree Construction & Recoding | 25 | 0 high · 6 medium · 19 low (incl. 2 correctness: NEW-34, NEW-40) |
| GV | Genetic Value Analysis & Reporting | 36 | **1 high (NEW-15)** · 6 medium · 29 low |

*(PED+GV = 61 confirmed across both clusters; 2 refuted. Counts include cross-cutting
findings that touch both clusters.)*

---

## Recommendations / sequencing

Honoring strict TDD and one-deliverable-per-session:

1. **Fix the high bug first (test-first):** **NEW-15** `countKinshipValues.R:133` —
   add a test that accumulates differing value sets across simulation batches, watch
   it fail, then fix the loop index.
2. **Crash + silent-data correctness pass:** NEW-34 (`getPotentialParents` unbound `j`),
   NEW-40 (`findGeneration` NA), NEW-37 (H/U overwrite), NEW-45 (`geneDrop`
   period-in-id), NEW-48 (`calcFEFG` NA), NEW-53 (`makeSimPed` in-place mutation),
   NEW-52 (sd n=1), NEW-25 (`getProportionLow` empty). Each its own TDD slice.
3. **Dead code:** NEW-20 delete `makeGeneticDiversityDashboard.R` (+ its commented test).
4. **Quick-win duplication:** `getFounders(ped)`/`isFounder(ped)` (PED-1/NEW-17/KIN-2).
   ⚠ Do NOT naively unify the adjacent `descendants` lines — `calcRetention.R:27`
   filters by `ped$population`; the `calc*` copies do not.
5. **Consolidation / overhauls (own sessions):** NEW-13/23 (`calcFE`/`calcFG` delegate
   to `calcFEFG`), NEW-12/XARCH-3 (Shiny progress hook), PED-5/6 error contract,
   XARCH-2/4 column-schema & species-profile.

*This is an audit only. Implementing any target is a separate, strictly test-driven
(RED→GREEN→REFACTOR), one-deliverable-per-session effort. Per-finding verifier
verdicts are archived in `…/tasks/w9oz3tkdf.output`.*
