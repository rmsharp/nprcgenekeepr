# Issue #123 (XARCH-5) — String-column-keyed pipeline: architecture plan

**Status:** PLAN (not implemented). Written Session 385, 2026-07-15, HEAD `b534e08d`.
**Issue:** https://github.com/rmsharp/nprcgenekeepr/issues/123
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
**Predecessor:** `docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md` (Session 365) re-verified
`TECH_DEBT_AUDIT_2026-05-30.md`'s XARCH-5 finding against current source and filed it as this issue.
**Sibling:** `docs/planning/issue122-module-contract-plan.md` (issue #122/XARCH-2 — same audit origin,
already implemented Phases 1-5; §2.6 below covers what it does and does not constrain here).

> **The plan is the deliverable.** Implementation is a separate session (or sessions). Do not
> implement any phase in the session that produced this document (FM #18).

**Method:** a 35-agent background research pass (6 independent inventory readers, 24 adversarial
re-verifiers, 4 independent alternative-design agents, 1 judge), all re-deriving claims from current
source rather than trusting the issue text or the 2026-07-11 audit's prose. 0 agent errors, 479 tool
calls. Where this plan cites a claim as "confirmed," it means an agent read the cited file/line
directly this session, not that it copied the issue's wording.

---

## 1. Executive summary — what the research changed

| | Issue #123 says | What the research found |
|---|---|---|
| **Severity** | "a silently-dropped required column fails downstream with no clear error at the point of loss" (framed generally) | **Reproduced by execution, not inference** (§2.3): `reportGV()` called on a pedigree missing `sex` returns *successfully*, with no error and no warning, but silently omits the `sex` column from the report **and** corrupts `nMaleFounders`/`nFemaleFounders`/`total` from the correct `3`/`17`/`20` to `0`/`0`/`0`. |
| **Scope** | "each stage" implicitly assumes the prior stage's exact columns | Of the 8 `@export`ed pipeline-adjacent functions traced end to end, only **3 explicit, named-column existence checks with a clear diagnostic** exist anywhere in the whole chain. Every other function surveyed — `setPopulation`, `createPedTree`, `kinship`, `calcA`, `calcFounderContributions`, `calcNeSexRatio`/`calcNeVariance`, `filterPairs`, `filterAge`, `getPotentialSires`, `calculateSexRatio`, and `reportGV`'s own `demographics` line — accesses its assumed columns unconditionally (§2.2). |
| **The 3 lists** | `getRequiredCols()`/`getPossibleCols()`/`getIncludeColumns()` "must be kept in sync by hand" | Confirmed — **and an additional 9 independently hand-maintained column-name-vector duplicates** exist elsewhere in `R/`, outside the 3 named getters (§2.4). The issue's own inventory understates how scattered the pattern already is. |
| **The recommendation** | "Define a lightweight S3 `pedigree`/`gvReport` class... each stage accepts and returns it" | **Does not survive contact with source as literally scoped.** Only 3 of the 7 implied pipeline functions (`qcStudbook` exit, `setPopulation`, `trimPedigree`) actually round-trip a pedigree-shaped data.frame at all; `createPedTree`/`kinship`/`calcA`/`groupAddAssign` never accept-and-return one (§4.1, §5 Alternative A). **All 8 pipeline functions and all 3 column-getters are `@export`ed** — confirmed by grep, not assumed — so during a mid-CRAN-resubmission window (v2.0.0), changing any of their contracts is exactly the risk category the sibling XARCH-2 plan's Dragon 5 was written to avoid. |
| **Effort** | `BACKLOG.md` tags this **Effort L** | That estimate reflects the issue's literal (rejected, §4.1) recommendation. The right-sized fix — consolidate the 3 lists into one internal schema, add an explicit validator at the known silent-drop sites — is judged to fit **one ordinary TDD session** (§7), not a multi-session architecture campaign. |
| **Test risk** | (not mentioned) | **Zero** Dragon-2-style `deparse()`-source-text tests target this pipeline (confirmed absent — a genuine, checked negative, unlike XARCH-2's ~40). But 2 hard `expect_identical` exact-vector pins exist on the getters themselves, plus an order-sensitive `expect_named` pin on `reportGV()$report`'s full column vector, plus a formatted-error-string pin whose exact wording depends on `getRequiredCols()`'s element order (§8.2). |

**Net:** the defect is real, and now reproduced rather than inferred. The issue's literal fix is
disproportionate given every touched function is exported mid-resubmission. §4 proposes a narrower
alternative — consolidate the 3 lists, validate explicitly at the 3 sites (2 named by the issue, 1
found during research) that can silently drop a required column — which fixes the reproduced bug,
fixes the "kept in sync by hand" complaint for the 3 named getters, breaks no exported contract, and
fits one session. It leaves "wrap the whole pipeline in a class" explicitly open (§10) rather than
foreclosing it.

> **⚠ Read §6 (Dragons) before implementing any part of this plan.**

---

## 2. Context — current state, verified firsthand

### 2.1 The three hardcoded column lists (the issue's named complaint)

| Function | Contents (current HEAD) | Callers (production + test) |
|---|---|---|
| `getRequiredCols()` — `R/getRequiredCols.R:25` | `c("id", "sire", "dam", "sex", "birth")` (5) | `getSiteInfo.R:62,94`; `summary.nprcgenekeeprErr.R:36`; `checkRequiredCols.R:34`; `test_checkRequiredCols.R:4`; `test_getSiteInfo.R:22,38` |
| `getPossibleCols()` — `R/getPossibleCols.R:53-58` | `c("id","sire","dam","sex","species","gen","birth","exit","death","age","ancestry","population","origin","status","condition","departure","spf","vasxOvx","pedNum","first","second","first_name","second_name","recordStatus")` (**24**, not 23 — the initial research pass miscounted and a verifier caught it) | `getSiteInfo.R:63,95`; `qcStudbook.R:316`; `test_getSiteInfo.R:23,39`; `test_species_first_class.R:26,77`; `test_getPossibleCols.R:18` |
| `getIncludeColumns()` — `R/getIncludeColumns.R:16-19` | `c("id","sex","age","birth","exit","population","condition","origin","first_name","second_name")` (10) | `getSiteInfo.R:64,96`; `gvaConvergence.R:161`; `reportGV.R:211`; `test_getIncludeColumns.R:4`; `test_getSiteInfo.R:24,40` |

No hits under `vignettes/` for any of the three. `getPossibleCols()` and `getIncludeColumns()`
disagree on the relative order of shared columns (e.g. `birth` before `age` in one, `age` before
`birth` in the other) — both orders are load-bearing, since `intersect(x, y)` returns `x`'s order,
which becomes output column order in report data frames pinned by `expect_identical`/`expect_named`
tests (§8.2).

### 2.2 The full pipeline: column dependencies, stage by stage

Traced `qcStudbook → setPopulation/trimPedigree → createPedTree → kinship/calcA → reportGV →
groupAddAssign` by reading every named function's actual body (not the issue's paraphrase).

| Stage | Assumes on input | Produces / renames | Existence-checked before use? |
|---|---|---|---|
| `qcStudbook` (`R/qcStudbook.R`) | Arbitrary raw column names | Normalizes via `fixColumnNames()` (`R/fixColumnNames.R:19-70`, synonym remap: `egoid→id`, `sireid→sire`, `damid→dam`, `birthdate→birth`, …), **then** `checkRequiredCols()` (`R/checkRequiredCols.R:33-54`) verifies `id/sire/dam/sex/birth` present — `stop()`s with a named-column message (`reportErrors=FALSE`) or returns the missing list (`reportErrors=TRUE`) | **Yes** — the one gate in the whole chain that is both explicit and unconditional |
| …rest of `qcStudbook` body | `sb$id/$sire/$dam/$sex` (guaranteed present by the gate above); `sb$status/$ancestry/$fromCenter/$species` only if present (`any("status" %in% cols)` guards) | `recordStatus` (`addParents.R:43-44`); `U%04d` unknown-parent ids (`addUIds.R:41-61`); `sex` → 4-level factor; `status`/`ancestry` → factors; `exit` (`setExit.R`); `age` (conditionally, via `calcAge`); `gen` (unconditionally, `findGeneration`) | Partial — 4 columns silently skipped if absent by design |
| `removeDuplicates` (in `qcStudbook`, `R/removeDuplicates.R:35-37`) | `id`, `recordStatus` | — | **Yes** — explicit `stop()` naming both columns if either is missing |
| `qcStudbook.R:316` reorder | `getPossibleCols()` vs `colnames(sb)` | Reorders only — `cols`+`novelCols` together cover every existing column; **nothing is dropped here** (confirmed by reading the two lines together, contrary to a naive reading of "intersect") | No explicit check, but `checkRequiredCols()` (line ~210) already guaranteed the 5 required columns ~100 lines earlier |
| `setPopulation` (`R/setPopulation.R`) | `ped$id` only | Overwrites `ped$population` (logical) | **No** — `ped$id %in% ids` silently evaluates against `NULL` if `id` is absent |
| `trimPedigree` → `getProbandPedigree` | `ped$sire/$dam/$id` | Row-filtered subset, no renames | No |
| `trimPedigree` → `removeUninformativeFounders` (`R/removeUninformativeFounders.R:31-37`) | `id/sire/dam` | Row removal, NA-ing of `sire`/`dam` | **Yes** — explicit `stop()` naming missing columns |
| `trimPedigree` → `addBackSecondParents` | `sire/id/dam` | — | No |
| `createPedTree` (`R/createPedTree.R`) | `ped$id/$sire/$dam` | Plain list keyed by `id` (not a data.frame) | No — and unlike `kinship()`, tolerates **duplicate** `id` values silently (later occurrence wins, no warning) |
| `kinship()` (`R/kinship.R`) | Plain vectors `id, father.id, mother.id, pdepth` (not a data.frame — no column-name dependency of its own) | Square matrix, `dimnames = list(id, id)` | Only checks `anyDuplicated(id)`; father/mother ids not found in `id` are silently mapped to a placeholder row, not an error |
| `calcA()` (`R/calcA.R`) | An `alleles` matrix with `id`/`parent` columns — a **different object** (gene-drop output), not the studbook `ped` | Bare matrix | No |
| `reportGV()` (`R/reportGV.R`) | `ped$id`, `ped$sire/$dam`, `ped$gen`; conditional `ped$population` (soft-fallback via `getGVPopulation`); `includeCols <- intersect(getIncludeColumns(), names(ped))` (line 211) then `ped[probands, c(includeCols, "sire","dam")]` (line 218) | `demographics` + computed columns (`indivMeanKin`, `zScores`, `gu`, `guSE`, `offspring`, `parentage`) | **`sire`/`dam` are hardcoded into the subset with no guard** — if absent, an unlabeled R subscript error. Everything in `includeCols` is silently dropped if absent — **no diagnostic** (this is the reproduced bug, §2.3) |
| `groupAddAssign()` (`R/groupAddAssign.R`) | No direct `ped$`/`ped[` access in its own body — pushed into `filterPairs` (`id`,`sex`), `filterAge` (`id`,`age`), `getPotentialSires` (`birth`,`id`,`sex`), `calculateSexRatio` (`sex`,`id`) | Group id-lists, score, optional `groupKin` — no pedigree columns | No — each helper accesses its columns unconditionally |

**Across the entire traced chain, exactly 3 functions perform an explicit, named-column existence
check with a clear diagnostic**: `checkRequiredCols()` (inside `qcStudbook`), `removeDuplicates()`
(inside `qcStudbook`), and `removeUninformativeFounders()` (inside `trimPedigree`).
`correctUnknownParentMeanKinship()` (called from `reportGV`) also checks, but silently no-ops rather
than erroring (§2.4). Everything else either silently produces a wrong-shaped/wrong-valued result
(most common) or throws an opaque, unlabeled built-in R error ("undefined columns selected",
subscript out of bounds).

### 2.3 Reproduced: the silent-failure bug (not inferred — executed)

Built the standard example pipeline (`qcStudbook → setPopulation → trimPedigree`, from the package's
own roxygen examples) against the bundled `examplePedigree`. Baseline `reportGV()` call gives
`nMaleFounders=3`, `nFemaleFounders=17`, `total=20`, and a report with a `sex` column, as expected.

Then: `ped2 <- ped; ped2$sex <- NULL; reportGV(ped2, guIter=20, guThresh=3, byID=TRUE,
updateProgress=NULL)` — called directly, no `tryCatch`, no suppression.

**Observed:** the call returns normally. No error, no warning, anywhere in captured output.
`names(gv$report)` is missing `sex`. `gv$nMaleFounders == 0`, `gv$nFemaleFounders == 0`,
`gv$total == 0`. `gv$maleFounders`/`gv$femaleFounders` are valid, syntactically correct, **empty**
(0-row) data frames — no crash, no diagnostic, just silently wrong numbers, even though 202 real
founder rows exist in the input before the sex-based split discards all of them.

**Mechanism, isolated further:** `founders$sex` on the sex-less frame is `NULL`; `NULL == "M"`
evaluates to `logical(0)`; `logical(0) & <any vector>` recycles to `logical(0)`; and
`data.frame[logical(0), ]` silently returns a valid 0-row frame with no exception. Three silent `NULL`
propagations compound into a confidently-wrong headline statistic with zero diagnostic signal — the
exact failure mode the issue describes, now demonstrated end to end rather than argued from reading
the source.

**By contrast**, `qcStudbook()` called on the same `examplePedigree` with `sex` removed does **not**
hit this defect — it throws `ERROR CAUGHT: message: Required field(s) missing: sex. call:
checkRequiredCols(cols, reportErrors)` immediately, well before line 316's `intersect`. The bug is
specific to `reportGV()` being independently callable (and documented for scripting use) on any
pedigree-shaped data.frame, not only one that has been through `qcStudbook()` first.

### 2.4 Beyond the issue's inventory: 9 more hardcoded column-name-vector duplicates

Searched `R/*.R` for any additional hand-maintained column-name vectors beyond the 3 named getters.
Found 9 more genuine duplicates (plus several roxygen-example/false-positive hits, listed for
completeness so no future session re-discovers them as "new"):

| Site | Vector | Purpose |
|---|---|---|
| `R/headerDisplayNames.R:17-55` | `nameConversion` — ~30 internal names → display labels | UI label lookup |
| `R/defaultSiteParams.R:34` | `mapPedColumns = c("id","sex","birth","death","exit","dam","sire")` | LabKey→internal rename target |
| `R/getFocalAnimalPed.R:55` | `names(ped) <- c("id","sex","birth","death","departure","dam","sire")` | Positional rename of LabKey-sourced frame |
| `R/getPyramidAgeDist.R:36-38` | `colNames <- c("id","sire","dam","sex","birth","exit_date")` | Positional rename + subset |
| `R/getGeneticDiversityStats.R:58,98` | `requiredPed <- c("id","dam","sex","birth","exit")` | Narrower required-set duplicate (drops `sire`, adds `exit`) |
| `R/getProductionStatus.R:74` | `expectedCols <- c("id","dam","sex","age")` | Distinct narrower required-set duplicate |
| `R/correctUnknownParentMeanKinship.R:141` | `c("id","sire","dam","sex","birth")` | **Exact duplicate of `getRequiredCols()`'s content, inlined rather than calling it** |
| `R/removeUninformativeFounders.R:31` | `required <- c("id","sire","dam")` | Narrower inline duplicate (subset of `getRequiredCols()`) |
| `R/checkParentAge.R:79` | `c("id","sire","dam")` | Same narrower inline duplicate pattern |
| `R/getPedigreeSource.R:43` | `c("id","sire","dam")` | Same pattern again |
| `R/modBreedingGroups.R:434-435` | `c("id","sex","birth","sire","dam")` | Display-column selection for a Shiny `DT` table (reordered `getRequiredCols()`) |
| `R/toCharacter.R:24` | default param `headers = c("id","sire","dam")` | Coercion helper default |

**False positives, checked and ruled out** (so a future session doesn't re-flag them): `R/data.R:337`
and `R/getTokenList.R:25,29` are roxygen-comment/`@examples` text, not executable code;
`R/findGeneration.R:37` and `R/countLoops.R:44` subset an existing built-in dataset for
illustration; `R/getParents.R:16`, `R/getOffspring.R:17`, `R/hasBothParents.R:14`, `R/toCharacter.R:20`
each build a throwaway example pedigree inside `@examples`; `R/defaultSiteParams.R:30-33`'s
`lkPedColumns` is LabKey's *external* field-naming convention, not a duplicate of the internal
schema; `R/qcStudbook.R:217,323`, `R/calcFounderContributions.R:27`, `R/geneDrop.R:109` all call
`toCharacter(x, headers = c("id","sire","dam"))` explicitly restating an existing default, not an
independent definition.

**Scope decision this plan makes explicit (§9):** consolidating all 12 of these would be a
different, much larger undertaking than issue #123 asks for. **This plan's schema consolidation
touches only the 3 getters the issue names** (`getRequiredCols`/`getPossibleCols`/`getIncludeColumns`)
**plus the 3 silent-drop validator sites** (§4.2). The other 9 are recorded here as a checked
inventory so a future session doesn't have to re-discover them, not as in-scope work for this plan.

### 2.5 No existing schema/class abstraction

Confirmed absent, not assumed: no `setClass`/`R6Class`/`new_class`/`UseMethod` anywhere in `R/`; the
only S3 classes that exist (`nprcgenekeeprFileErr`, `nprcgenekeeprGV`, `nprcgenekeeprGVConv`,
`summary.nprcgenekeeprErr`/`summary.nprcgenekeeprGV`) are for error/report **print dispatch**, not
column-schema representation; `checkRequiredCols()` is the package's only genuine schema-adjacent
validator, and it correctly delegates to `getRequiredCols()` rather than duplicating it. The
package's real column-schema source of truth today is exactly the 3 plain-vector getters the issue
names, plus the 9 uncoordinated duplicates in §2.4.

One notable half-built piece: `reportGV.R:303` already does
`class(finalData) <- append(class(finalData), "nprcgenekeeprGV")`, and a real, tested
`summary.nprcgenekeeprGV`/`print.summary.nprcgenekeeprGV` pair already exists and is registered in
`NAMESPACE`. But `append(..., "nprcgenekeeprGV")` puts the specific class **last**
(`c("list","nprcgenekeeprGV")`), and there is no bare `print.nprcgenekeeprGV` — printing a raw GV
report at the console dumps an unreadable nested list. This is a real, if currently latent, wrinkle
independent of the schema-validation question; noted in §10 as a small, separately-decidable item,
not folded into this plan's core scope.

### 2.6 Relationship to XARCH-2 (issue #122) — no overlap, one inherited constraint

`docs/architecture/module-contract.md` (the ratified output of XARCH-2) says exactly one thing
relevant here — Rule 3: *"Data-frame columns use the canonical vocabulary (see `reportGV()`'s
`indivMeanKin`/`gu`) — never a per-consumer rename."* That is this plan's one inherited constraint:
any schema this plan defines must use `indivMeanKin`/`gu` as canonical, not `meanKinship`/
`genomeUniqueness`. XARCH-2's own Alternatives table (§5, row F) rejected a *different*, more narrowly
scoped idea — a formal class for the Shiny **module-contract return shape** — as "astronaut
architecture... not proportional." That rejection does not pre-decide this plan's question (an S3
class on the pedigree/report **data** flowing through `qcStudbook → kinship → reportGV`, which is
what issue #123's body actually asks for) — the two are different objects, and this plan should not
be read as re-litigating an already-settled XARCH-2 decision.

**Confirmed zero code overlap:** none of XARCH-2's 11 implementation commits (Phases 1-5, S372-S377)
touch `R/getRequiredCols.R`, `R/getPossibleCols.R`, `R/getIncludeColumns.R`, `R/reportGV.R`, or
`R/qcStudbook.R` (verified via `git log --name-only` across the full commit range). The exact
`intersect()` lines this plan is about are byte-for-byte unchanged since well before XARCH-2 began.

---

## 3. Issue claim re-verification (re-derived at HEAD `b534e08d`, not copied from the issue)

| # | Claim | Verdict | Current refs |
|---|---|---|---|
| 1 | 3 hand-maintained column-name vectors that must be kept in sync by hand | **CONFIRMED, and understated** | §2.1 (the 3 named) + §2.4 (9 more found) |
| 2 | `reportGV.R:211/218`'s `intersect` has no check that a required column survived | **CONFIRMED, and reproduced by execution** | §2.3 — silent `sex`-column loss corrupts founder counts to `0/0/0` |
| 3 | `qcStudbook.R:316`'s analogous `intersect` | **CONFIRMED but lower-stakes than it reads** — this specific line reorders, it does not drop any column (`cols`+`novelCols` cover all of `colnames(sb)`), and `checkRequiredCols()` already guarantees the 5 required columns ~100 lines earlier in the same function | §2.2 |
| 4 | No S3 `pedigree`/`gvReport` class, `columnMap`, or consolidated schema exists | **CONFIRMED** | §2.5 |
| 5 | Recommendation: a lightweight S3 class, each stage accepts/returns it | **DOES NOT SURVIVE AS LITERALLY SCOPED** — only 3 of 7 implied functions round-trip a pedigree-shaped frame; all 8 pipeline functions + all 3 getters are `@export`ed, raising CRAN-timing risk the sibling plan's Dragon 5 already flagged for a differently-scoped but analogous change | §4.1, §5 Alternative A |
| 6 | *(not in the issue; found this session)* a third, byte-identical unguarded `intersect(getIncludeColumns(), names(ped))` site | **NEW FINDING** — `R/gvaConvergence.R:161` carries the same pattern as `reportGV.R:211`, unnamed by the issue, structurally identical, also unguarded | §2.1, §4.2 |
| 7 | *(not in the issue; found this session)* `mergeReportColumns` (cited in the original 2026-05-30 audit text) never existed in this repo's history | **CONFIRMED as a labeling artifact**, already noted by the 2026-07-11 tracker audit — the underlying pattern it described is real regardless | (carried forward from the tracker audit, re-confirmed here) |

---

## 4. Decision — the proposed design

Four independently-generated alternatives were adversarially designed and judged against this
package's actual constraints (all touched functions `@export`ed; mid-CRAN-resubmission; the sibling
plan's precedent for weighing exported-contract risk). Full write-ups in §5.

### 4.1 Rejected: the issue's literal recommendation — a full S3 class (Alternative A)

**Why rejected, not merely "not chosen":**

- **Scope collapse on contact with source.** Of the 7 functions the issue implicitly covers
  (`qcStudbook`, `setPopulation`, `trimPedigree`, `createPedTree`, `kinship`, `calcA`,
  `groupAddAssign`), only 3 (`qcStudbook` exit, `setPopulation`, `trimPedigree`) actually accept and
  return a pedigree-shaped data.frame that a class could wrap end to end. `createPedTree` returns a
  plain list; `kinship` takes 4 plain vectors and returns a bare matrix; `calcA` operates on a
  gene-drop allele matrix, a different object entirely, two stages downstream; `groupAddAssign`
  operates on ID lists and a kinship matrix. "Each stage accepting and returning it" is true for 3
  functions, half-true for 2 more (accept-only, via an additive S3 generic), and false for 2.
- **Every touched function is `@export`ed.** Confirmed by `grep -n "@export"` across all 8 pipeline
  functions and all 3 column-getters — none is internal-only. During v2.0.0's CRAN-resubmission
  window, a documented `@return` contract change on any of them is exactly the risk category the
  sibling XARCH-2 plan's Dragon 5 says must not land before the resubmission completes — that plan's
  own Alternative A (rename at source) and Alternative F (a formal S3 class for the *module contract*)
  were both rejected on this same basis.
- **`qcStudbook()`'s polymorphic return defeats a uniform "validate and wrap" story.** With
  `reportErrors=FALSE` it returns a data.frame; with `reportErrors=TRUE` it returns a plain
  `errorLst`/change-report list, and can short-circuit early on missing required columns. A class
  wrapper would need a branch, and entry-side validation is nearly vacuous for this function by
  design — accepting raw, not-yet-canonical input *is* `qcStudbook`'s job.
- **Class preservation through existing internal helpers is not free.** Empirically verified:
  `cbind()` and `merge()` always drop a custom S3 class; `rbind()` preserves it only when the
  class-carrying object is passed first. This reopens, for a brand-new class, the exact silent-class-
  loss hazard 3 existing regression tests (tagged "NEW-53") were written to catch for
  `data.table::setDT()` — a real, non-hypothetical failure mode, not a theoretical objection.

**Verdict:** correctly identifies the seam, but its own most rigorous write-up concludes it needs to
go back through a `DECISION NEEDED` gate before any code is written — i.e., even taken on its own
terms, it is not this session's answer.

### 4.2 Adopted: consolidated schema + explicit validator at 3 sites (Alternative B, extended)

**One internal schema, three getters become pass-throughs:**

```r
# R/columnSchema.R (new, @noRd, not exported)
## Internal column schema -- single source of truth for
## getRequiredCols()/getPossibleCols()/getIncludeColumns(). A named list, not
## a data.frame: the three roles have independently load-bearing element
## orders (callers rely on intersect()'s x-order to fix output column
## order; see test_reportGV.R's exact-name pin, test_getPossibleCols.R,
## test_getIncludeColumns.R) -- a single row-per-column table can only
## preserve one role's order for free.
.nprcColumnSchema <- list(
  required = c("id", "sire", "dam", "sex", "birth"),
  include  = c("id", "sex", "age", "birth", "exit", "population",
               "condition", "origin", "first_name", "second_name"),
  possible = c("id", "sire", "dam", "sex", "species", "gen", "birth",
               "exit", "death", "age", "ancestry", "population", "origin",
               "status", "condition", "departure", "spf", "vasxOvx",
               "pedNum", "first", "second", "first_name", "second_name",
               "recordStatus")
)
```

`getRequiredCols()`/`getPossibleCols()`/`getIncludeColumns()` become one-line pass-throughs
(`.nprcColumnSchema$required`, etc.) — exported names, signatures, and man pages unchanged. The
existing `expect_identical()` pins in `test_getPossibleCols.R`/`test_getIncludeColumns.R` are the
regression guard that nothing about the returned vectors (including order) changed.

**One validator, wired at 3 sites — narrowly scoped per site, not a blanket check:**

```r
# @noRd, co-located with the schema or its own file
assertRequiredColsPresent <- function(availableCols, required, where) {
  missing <- setdiff(required, availableCols)
  if (length(missing) > 0L) {
    stop("nprcgenekeepr: required column(s) missing in ", where, ": ",
         toString(missing), ".", call. = FALSE)
  }
  invisible(NULL)
}
```

1. **`R/reportGV.R:211`** — before `includeCols <- intersect(getIncludeColumns(), names(ped))`, call
   `assertRequiredColsPresent(names(ped), c("id", "sex"), "reportGV(ped)")`. **Scoped to `id`/`sex`
   only, not the full `getIncludeColumns()` list** — `age`/`birth`/`exit`/`condition`/`origin` are
   *documented* optional (`getPossibleCols()`'s own roxygen) and `origin` in particular already has
   an established, deliberate graceful-fallback precedent (S62 audit; `reportGV.R:261`,
   `orderReport.R:44`). Checking the whole list would wrongly `stop()` on every studbook lacking
   `origin`/`condition`. This is the site that earns its keep — the reproduced bug (§2.3) lives here.
2. **`R/qcStudbook.R:316`** — before the reorder, call
   `assertRequiredColsPresent(colnames(sb), getRequiredCols(), "qcStudbook(sb)")`. Lower marginal
   value: `checkRequiredCols()` already guarantees this ~100 lines earlier, and no internal step is
   known to drop a required column in between. This is defense-in-depth against a future internal
   regression, not a fix for an observed-today failure — flagged honestly, not oversold (§6, §8.2).
3. **`R/gvaConvergence.R:161`** — the byte-for-byte identical pattern to site 1, not named by the
   issue, found during research (§3, row 6). Leaving it unguarded ships this deliverable with a known
   third instance of the same bug still open.

**Non-goals, stated up front:** no new class; no signature or return-contract change on any exported
function; no validation added at `setPopulation`/`trimPedigree`/`createPedTree`/`kinship`/`calcA`/
`groupAddAssign`; no change to any of the 9 other hardcoded duplicates in §2.4 (`correctUnknownParent
MeanKinship.R:141`'s inline duplicate is a candidate for a trivial follow-up swap, §10, but changing
its *behavior* — silent skip vs. error — is a separate design decision this plan does not make).

### 4.3 Why not the other two alternatives

- **Alternative C (attribute-based `columnMap`)** — rejected because its own empirical testing shows
  the mechanism doesn't survive the exact operation the issue is about:
  `ped[probands, c(includeCols, "sire","dam")]` supplies a column index, and `[.data.frame` drops any
  custom attribute whenever a column index is supplied at all — even selecting every column in the
  same order. Its own honestly-scoped recommendation degrades into "validate at each stage's own
  formal argument," which is §4.2's approach, plus unused attribute bookkeeping, plus a new failure
  mode (a silently-lost map masking a real bug, indistinguishable from "never set").
- **Alternative D (narrow `setdiff`+`stop()` guard at exactly the 2 issue-named sites, nothing else)**
  — genuinely close, and independently valuable (§5): it reuses an idiom this codebase already trusts
  (`R/checkKinshipOverrides.R:36-42`, tested), and is even smaller than §4.2. Not adopted as the full
  answer because, by its own analysis, it leaves the 3-list duplication — literally half of issue
  #123's own framing — untouched, and its own stated escalation trigger ("a third call site with this
  identical shape turns up") **has already fired**: `gvaConvergence.R:161` (§3, row 6) is that third
  site. §4.2 is Alternative D's insight (the `setdiff`+`stop()` idiom, narrowly scoped per site) folded
  into Alternative B's schema consolidation, rather than a fourth, separate option.

---

## 5. Alternatives considered

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| **A. Full S3 `pedigree`/`gvReport` class, each stage accepts/returns it** (issue's literal text) | Gives the strongest, most general answer; the `gvReport` half is nearly free (half-built already, §2.5) | Only 3 of 7 functions round-trip a pedigree frame; all touched functions `@export`ed mid-CRAN-resubmission; `cbind`/`merge` silently drop custom classes (reopens the "NEW-53" hazard for a new subject); `qcStudbook`'s polymorphic return defeats uniform wrapping | **Rejected** — disproportionate risk for the reproduced defect; its own analysis recommends a further `DECISION NEEDED` gate before coding |
| **B. Consolidated schema + explicit validator at known silent-drop sites** | Fixes both halves of the issue (3-list duplication + silent drop); zero exported-contract risk; existing pinned tests are the regression guard; fits one session; found and folds in a 3rd unguarded site | Leaves every other pipeline stage (`setPopulation`→`groupAddAssign`) exactly as unguarded as today; doesn't touch the other 9 hardcoded duplicates (§2.4) | **ADOPTED** (§4.2) |
| **C. `attr(ped, "columnMap")` set at pipeline entry, validated per stage** | Zero signature/type changes anywhere; cheap to prototype and cheap to abandon | The exact call the issue is about (`ped[probands, c(includeCols,...)]`) is the exact operation that drops the attribute (empirically verified); no enforcement mechanism across ~45 subsetting sites; a lost map is indistinguishable from "never set" | **Rejected** — self-undermining; its safely-scoped version collapses into B minus the schema fix |
| **D. Narrow `setdiff`+`stop()` guard at exactly the 2 issue-named sites** | Smallest possible diff; reuses an already-tested house idiom (`checkKinshipOverrides.R`); zero contract risk | Leaves the 3-list duplication untouched; its own stated escalation trigger (a 3rd identical site) has already fired (`gvaConvergence.R:161`) | **Superseded by B** — B is D's mechanism plus the schema fix, for comparable risk |

---

## 6. Dragons — where this plan is dangerous

> Not all steps are equally risky (`SESSION_RUNNER.md` Learning #3). These are the load-bearing
> assumptions; an implementer who ignores them ships a regression or a spurious break.

**🐉 Dragon 1 — do NOT check the full `getIncludeColumns()` list at the `reportGV.R:211` site.**
`getIncludeColumns()` deliberately mixes a genuinely-required column (`id`) with columns this project
has *already decided* must stay silently-optional (`origin`, per the S62-audit precedent;
`age`/`condition` per `getPossibleCols()`'s own roxygen "(optional)" tags). A naive
`setdiff(getIncludeColumns(), names(ped))` check would `stop()` on every studbook lacking `origin` —
which is most bundled test fixtures (`test_reportGV.R:201-212` explicitly exercises the
no-`origin`-column path as a *passing*, intended behavior, not a bug). **Scope the check to
`c("id", "sex")` only** (§4.2, site 1).

**🐉 Dragon 2 — the `qcStudbook.R:316` check is defense-in-depth, not a fix for a reachable-today
bug; a "faithful" RED test for it requires contriving a fault, not observing one.** `checkRequiredCols()`
already guarantees `id/sire/dam/sex/birth` ~100 lines earlier in the same function, and nothing
between there and line 316 is known to drop a required column. A genuinely faithful RED test would
need to monkey-patch an internal helper to simulate a fault that has no cited history of occurring —
weaker justification than the `reportGV.R` site. Do not let this honesty gap become an excuse to skip
the test entirely (per this project's strict-TDD contract, a RED test is still required); state the
contrivance explicitly in the test's own comment rather than presenting it as an observed-bug repro.

**🐉 Dragon 3 — `getRequiredCols()` vs. `getPossibleCols()`'s own roxygen disagree about whether
`birth` is required.** `getPossibleCols()`'s roxygen entry for `birth` calls it "(optional)"; the
package's actual enforced behavior (via `checkRequiredCols()`, called from `qcStudbook()`) treats it
as required. This is a pre-existing doc/behavior mismatch, not something this plan's consolidation
introduces — but consolidating the 3 lists into one schema object (§4.2) is the natural moment to
either fix the roxygen wording or explicitly decide to leave it (§10, open decision 2). Do not let the
consolidation silently change which columns are enforced — that must stay behavior-identical, checked
via the existing pinned tests.

**🐉 Dragon 4 — zero `deparse()`-source-text tests target this pipeline (a genuine relief, verified,
not assumed).** A `rg -n 'deparse\('` sweep of `tests/testthat/` found 32 hits across 15 files — every
one targets the Shiny module-server layer (`appServer`, `mod*Server`), the XARCH-2 Dragon-2 blast
radius. Zero hits for `deparse(reportGV)`, `deparse(qcStudbook)`, or any of the 3 getters. This
pipeline's blast radius is disjoint from XARCH-2's — **do not** assume Dragon-2-style triage is needed
here; it isn't. What *does* apply: two **hard, exact-vector** pins (`test_getPossibleCols.R:17-19`,
`test_getIncludeColumns.R:5-10`) and one **order-sensitive `expect_named`** pin on `reportGV()$report`
(`test_reportGV.R:6-23,29-49`) — the schema consolidation must preserve these vectors' exact contents
and order, or these tests fail with no behavioral bug.

**🐉 Dragon 5 — a formatted-string test is a hidden order pin on `getRequiredCols()`.**
`test_summary.nprcgenekeeprErr.R:24-30` asserts the exact literal string `"The required columns are:
id, sire, dam, sex, and birth"`, generated by `get_and_or_list(getRequiredCols())`
(`R/summary.nprcgenekeeprErr.R:36`). Any reordering of `getRequiredCols()`'s elements — even one that
preserves the *set* — breaks this test by changing the "and"-joined phrase. The consolidation must
keep `.nprcColumnSchema$required`'s element order identical to today's `getRequiredCols()` return.

**🐉 Dragon 6 — CRAN timing (inherited from the sibling plan, still true here).** v2.0.0 is
mid-resubmission. This plan's adopted design (§4.2) deliberately breaks no exported contract — that is
why Alternative A was rejected, not a coincidence. If a future session reopens the "full class" option,
it must not land before the resubmission completes.

---

## 7. Migration path — one phase, one session

Alternative B (§4.2) was explicitly judged to fit inside one ordinary TDD session — this is not a
multi-session architecture migration like the sibling XARCH-2 plan. One phase, three commits within
it are reasonable (schema consolidation; validator; the gvaConvergence site), but all within the same
session's close-out.

### Phase 1 — Consolidate the 3 getters; add the explicit validator at 3 sites

**Scope:** new `R/columnSchema.R` (`@noRd`); `getRequiredCols()`/`getPossibleCols()`/
`getIncludeColumns()` become pass-throughs over it; new `assertRequiredColsPresent()` (`@noRd`);
wired at `R/reportGV.R:211` (scoped to `id`/`sex`), `R/qcStudbook.R:316` (full `getRequiredCols()`),
and `R/gvaConvergence.R:161` (mirrors the `reportGV.R` site). **No exported signature changes.**

**DONE looks like:**
- `reportGV()` called on a pedigree missing `id` or `sex` `stop()`s with a named-column message
  instead of silently corrupting founder counts (the §2.3 repro, inverted into a RED test).
- `qcStudbook()` and `gvaConvergence()` gain the same defensive check at their respective sites.
- `getRequiredCols()`/`getPossibleCols()`/`getIncludeColumns()` return byte-identical vectors to
  today (existing `expect_identical`/`expect_named` tests are the proof, unmodified).
- `test_reportGV.R`'s `$report` exact-name pin and `test_summary.nprcgenekeeprErr.R`'s formatted-string
  pin both stay green, unmodified (Dragons 4-5).

**Verification:**
```r
# The RED test, before the fix, must currently pass silently (proving the bug):
ped2 <- ped; ped2$sex <- NULL
gv <- reportGV(ped2, guIter = 20, guThresh = 3, byID = TRUE, updateProgress = NULL)
expect_equal(gv$nMaleFounders, 0)   # <- documents today's silent-corruption bug

# After the fix, the same call must instead error clearly:
expect_error(reportGV(ped2, ...), "required column\\(s\\) missing.*sex")
```
```sh
Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_reportGV.R", reporter="summary")'
Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_qcStudbook.R", reporter="summary")'
Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_gvaConvergence.R", reporter="summary")'
Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_getPossibleCols.R", reporter="summary")'
Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_getIncludeColumns.R", reporter="summary")'
Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_summary.nprcgenekeeprErr.R", reporter="summary")'
Rscript -e 'as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))'  # sum(failed)/sum(error)/sum(warning) at baseline
Rscript -e 'lintr::lint_package()'   # no new lints; <=80 cols
```
Plus `devtools::check()` (0 errors/0 warnings/0 notes beyond the known incoming-feasibility note) and
a scripted-use smoke test (this package's stated goal is "use... interactively or in R scripts" —
call the new `reportGV()` guard directly, not only through the Shiny app, since that is the actual
call path the reproduced bug hits).

**Session boundary: this phase is one session. Close out when done.**

---

## 8. Evidence-based inventory (grep-derived, re-verified against current source, not assumed)

### 8.1 Files this plan touches

| File | Change |
|---|---|
| `R/columnSchema.R` (new) | Internal `.nprcColumnSchema` list |
| `R/getRequiredCols.R` | Body replaced with pass-through |
| `R/getPossibleCols.R` | Body replaced with pass-through |
| `R/getIncludeColumns.R` | Body replaced with pass-through |
| `R/reportGV.R:211` | New `assertRequiredColsPresent(names(ped), c("id","sex"), ...)` before the existing `intersect` |
| `R/qcStudbook.R:316` | New `assertRequiredColsPresent(colnames(sb), getRequiredCols(), ...)` before the existing reorder |
| `R/gvaConvergence.R:161` | Same pattern as `reportGV.R:211` |

### 8.2 Tests that must stay green, unmodified (the regression guard)

- `test_getPossibleCols.R:17-19` — **hard** `expect_identical(getPossibleCols(), <24-element literal>)`, order included.
- `test_getIncludeColumns.R:5-10` — **hard** `expect_identical`, 10-element literal, order included.
- `test_getSiteInfo.R:18-24,27-40` — pins that `getSiteInfo()` delegates unchanged to the 3 getters (refactor-safe as long as delegation is preserved).
- `test_checkRequiredCols.R:4-29` — pins `checkRequiredCols()`'s NA-tolerant behavior against `getRequiredCols()`'s value, not the value itself.
- `test_reportGV.R:6-23,29-49` — **hard, ordered** `expect_named` pin on `gvReport$report`'s full column vector.
- `test_reportGV.R:201-212` — behavioral test that a missing `origin` column is gracefully tolerated (proves Dragon 1's scoping is correct).
- `test_summary.nprcgenekeeprErr.R:24-30` — pins the exact formatted string built from `getRequiredCols()`'s order (Dragon 5).
- `test_species_first_class.R:26,29-54,77` — behavioral tests of `qcStudbook()`'s column-ordering algorithm, including a line that re-derives the same `intersect(getPossibleCols(), ...)` expression as `qcStudbook.R:316`.
- `test_gvaConvergence.R:90-92,107,246-254` — no exact column-vector pin on the includeCols/demographics columns; safe to add the new guard.

### 8.3 New tests required (RED before GREEN, per this project's strict-TDD gate)

- `test_columnSchema.R` (or fold into existing getter test files): confirm the 3 getters still return exactly today's vectors post-consolidation.
- `test_assertRequiredColsPresent.R`: happy path, single-missing, multi-missing, order-independence of the `missing` message.
- `test_reportGV.R`: new case — `reportGV()` on a pedigree missing `sex` (or `id`) now errors clearly instead of silently corrupting founder counts (the §2.3 repro, inverted).
- `test_qcStudbook.R`: new case for the `qcStudbook.R:316` guard — Dragon 2 notes this requires a contrived fault, not an observed one; state that in the test's own comment.
- `test_gvaConvergence.R`: mirror of the `reportGV.R` case.

### 8.4 Clean negative, stated so no one goes hunting

Zero `deparse()`-based structural tests target `getRequiredCols`/`getPossibleCols`/`getIncludeColumns`/
`reportGV`/`qcStudbook` (Dragon 4) — confirmed by a full `rg -n 'deparse\('` sweep plus a targeted
follow-up grep for each function name, both returning no hits for this pipeline.

---

## 9. Impact analysis

| Surface | Impact | Action required |
|---|---|---|
| `getRequiredCols()`/`getPossibleCols()`/`getIncludeColumns()` exported contracts | **None** — same names, same signatures, same return values (existing pinned tests re-prove this) | Re-run §8.2's tests after the refactor |
| `reportGV()` exported contract | **Widened, not broken** — a call that previously silently corrupted its output now errors instead; no change to any call that already supplies `id`/`sex` | New RED test (§8.3); update `@return`/`@details` to document the new error condition |
| `qcStudbook()` exported contract | **None observable** — the new check only fires on an internal fault with no cited history | New (contrived) RED test (§8.3, Dragon 2) |
| `gvaConvergence()` exported contract | Same as `reportGV()` — widened, not broken | New RED test (§8.3) |
| CRAN resubmission | **None** — no exported signature or return-shape changes anywhere (§4.1's rejection basis) | Keep it that way |
| The rest of the pipeline (`setPopulation`→`groupAddAssign`) | **None** — explicitly out of scope | Note as future work (§10), do not silently imply it's now protected |
| The 9 other hardcoded duplicates (§2.4) | **None** — explicitly out of scope | Recorded here so a future session doesn't have to re-discover them |

**Explicit scope boundary — what this plan does NOT change:** any exported function's signature or
return type; validation at any pipeline stage other than the 3 named sites; the 9 other hardcoded
column-name duplicates cataloged in §2.4; the half-built `nprcgenekeeprGV` print-method wrinkle noted
in §2.5.

---

## 10. Open decisions for the implementing session

1. **`correctUnknownParentMeanKinship.R:141`'s inline duplicate of `getRequiredCols()`'s content.**
   Swap it to call `getRequiredCols()` instead of inlining the literal — trivial, behavior-identical
   (it already silently no-ops rather than erroring on missing columns, and this plan does not propose
   changing that design choice). Recommend: yes, in the same session, as a cheap consistency win — but
   it is a distinct micro-decision from the core fix, not bundled into it silently.
2. **The `getRequiredCols()`/`getPossibleCols()` "`birth` optional" roxygen wording mismatch**
   (Dragon 3). Recommend fixing the roxygen wording (drop the misleading "(optional)" tag on `birth`
   in `getPossibleCols()`'s docs) in the same session, since the consolidation touches this file
   anyway — but this is a documentation-only change; confirm it does not touch any test's literal
   string expectations before landing it.
3. **Is the `qcStudbook.R:316` defense-in-depth check worth its contrived-RED-test cost** (Dragon 2)?
   Recommend yes — cheap, matches this codebase's existing defensive-programming taste, and the
   sibling `gvaConvergence.R` site makes the pattern consistent across all 3 guarded sites — but flag
   it honestly in the commit/test as insurance, not a fix for an observed bug.
4. **The `nprcgenekeeprGV` print-method wrinkle** (§2.5: specific class appended last, no bare
   `print.nprcgenekeeprGV`). Out of scope for this plan's core deliverable; note as a small, separate,
   easy future fix if a session wants to pick it up.
5. **Future direction, explicitly NOT this session's work:** extending explicit validation to
   `setPopulation`/`trimPedigree`/`createPedTree`/`kinship`/`calcA`/`groupAddAssign`, or consolidating
   the 9 other hardcoded duplicates (§2.4). Per Alternative D's own stated escalation triggers (§4.3),
   revisit the full-class question (Alternative A) only if: (a) a fourth recurrence of this exact
   silent-drop pattern appears outside the 3 sites this plan guards; (b) a new pipeline stage or a
   kinship-backend swap forces re-deriving which of the (now-consolidated) schema roles applies at the
   new joint; or (c) the `birth`-required-vs-optional inconsistency (or a similar list-vs-list drift)
   is ever the confirmed root cause of a real bug report, not just a latent doc mismatch. Until then,
   issue #123 should be updated to reflect **partial, scoped closure** (the 3-list duplication + the 3
   silent-drop sites) — not closed outright, and not escalated to the class rewrite either.
