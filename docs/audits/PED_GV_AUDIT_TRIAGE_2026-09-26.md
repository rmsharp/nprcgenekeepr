# PED + GV Audit Triage (Session 781)

> **Status as of 2026-10-02 (S870):** Findings F1-F4 are fixed (S782, S783, S797 with S808-S811, S798), so Recommendation 1 would redo finished work; `BACKLOG.md` (the PED_GV item) holds what is open. The table's PRESENT verdict is also out of date for NEW-14, PED-11, NEW-56, NEW-63 and PED-10/NEW-43, fixed in S795 (`926cc907b`), which `BACKLOG.md` does not list; NEW-62 is still present. The body below is the dated record as written; it was not edited.

**Question answered:** of the findings in `PED_GV_AUDIT_2026-05-30.md` that the ledger does not
record as fixed, which are still present in today's code, which were fixed under another name,
and which never were defects? "Ledger-absent" is not "unresolved" (Learning 791), so each id was
judged against the source, never against the audit's 2026-05-30 line numbers.

- **Date:** 2026-09-26 · **HEAD when read:** `40b9be61` (docs-only commits since the last code
  change, so this is the code as shipped) · **Audit-time base:** `2066f73a` (2026-05-30).
- **Type:** read-only triage. **No source, test or data file was modified.** No fix is proposed
  as done; every "fix" below is a recommendation for a later strict-TDD session.
- **Scope:** **43 ids** — the 41 that `BACKLOG.md` listed, plus **NEW-29 and NEW-47**, which the
  boundary check (see "Ledger boundary") found were counted as recorded without any fix record.

## Audit Summary

| | Count |
|---|---:|
| Ids triaged | **43 of 43** (no id skipped) |
| **PRESENT** (still true in today's source) | **35** |
| **FIXED** since the audit (commit cited) | **2** — PED-8, PED-9 |
| **MOOT** (immaterial, by design, or unreachable) | **4** — NEW-27, NEW-33, NEW-44, NEW-47 |
| **REFUTED** (the audit's claim does not hold) | **2** — NEW-58, NEW-60 |

Of the 35 present, only **5 ids in 4 groups are correctness hazards** (F1-F4 below). The rest are
duplication, extensibility and documentation debt; 1 is already tracked (NEW-24 → open issue #123).

## Method

1. Read today's source for every function the audit named (43 ids, about 40 files); read the
   audit's own text for each claim first.
2. **Ran R probes** (`pkgload::load_all()`, scratch scripts, nothing committed) for every claim a
   probe could settle — 9 probes (P1-P9), transcript at the end. Rows settled by a probe: PED-8,
   PED-9, NEW-14, 31, 32, 35, 38, 41, 44, 59. Every other row rests on reading the cited lines
   and, for the FIXED, MOOT and REFUTED rows, on git history.
3. **History:** `git log -S<token> -- <file>` for the fixing commit of each FIXED/MOOT row;
   `git show 2066f73a:<file>` for the audit-time code where the claim depends on it; the ledger
   and every `docs/archive/CHANGELOG-*.md` searched by id AND by function name.
4. **Independent id check:** `git log --all --extended-regexp --grep` for each of the 43 ids.
   A control confirmed the search works (it finds NEW-45 and NEW-53). **Zero of the 43 ids appear
   in any commit message** — see Structural Observation 1.
5. Every `path:line` below was checked mechanically against the file at HEAD (see "Verification").

**Verdict definitions.** PRESENT = the defect or debt exists in today's source. FIXED = it existed
and a commit removed it (cited). MOOT = true but immaterial, an intentional contract, or
unreachable from any caller. REFUTED = the claim did not hold against the source (today or at audit
time). "Disposition" is my recommendation only: **TDD** = a strict-TDD fix slice; **DOC** =
documentation-only; **BUNDLE** = a trivial cleanup for one small session; **DECIDE** = the owner
must choose direction first; **TRACKED** = already an open issue; **CLOSE** = recommend closing.

## Triage table (43 rows)

| id | audit claim (short) | verdict | evidence today (path:line) and history | disposition |
|---|---|---|---|---|
| PED-2 | sex codes hardcoded, no shared constant | **PRESENT** (partial) | `sexCodes.R:13` now exists (S367: `3a02990a`, `b64c4481`; adopted in 6 files, e.g. `getPotentialSires.R:22`). Bare literals remain at `correctParentSex.R:85,86,89,91`, `getPotentialParents.R:151,158,198` and **28 comparison lines in 10 files** in all. S367's ledger entry left them "for a future item"; `BACKLOG.md` has none | DECIDE (finish adoption?) |
| PED-3 | duplicated ancestor/relative walk loops | **PRESENT** | `getProbandPedigree.R:24-40` and `getPedDirectRelatives.R:47-60` each hand-roll the fixed-point loop; only the latter uses `getParents`/`getOffspring` | DECIDE (low value) |
| PED-4 | 117-line multi-purpose `getPotentialParents` | **PRESENT** | `getPotentialParents.R:64-213` is one 150-line function (the audit cited `:24-117`); it grew with species-keyed floors (#46) and gestation windows (#31) | DECIDE (one slice with NEW-35/54/55/56) |
| PED-5 | inconsistent error/return conventions | **PRESENT** | `stop` vs `NULL` vs list: `correctParentSex.R:78,102-105`, `removeDuplicates.R:36,47`, `getPotentialParents.R:90,211`, `getPedDirectRelatives.R:31,39`, `rbindFill.R:35`. Same theme as XARCH-6, whose narrow remainder (qcStudbook call de-dup) shipped S368; the contract redesign never did | DECIDE (overhaul) |
| PED-6 | `correctParentSex` return type depends on `reportErrors` | **PRESENT** | `correctParentSex.R:87` returns a vector, `:102-105` a list; now at least documented (`:26-31`) | DECIDE (with NEW-36) |
| PED-7 | `addParents` hardcodes sire→M, dam→F | **PRESENT** (accepted design) | `addParents.R:50,58`; a sire is male by role, so this is only a constant-adoption question | CLOSE (or fold into PED-2) |
| PED-8 | `findGeneration` silent `NA` generations | **FIXED** | `findGeneration.R:59-75` warns naming the unplaced ids; commit `ea5d28fa` (2026-05-30, "NEW-40"). Same defect as NEW-40, which the S1-9 campaign entry records. Probe P9: a 2-cycle returns `NA,NA,0` plus a warning naming the unplaced ids | CLOSE (cross-reference NEW-40) |
| PED-9 | fixed 4-digit width, silent 9999 ceiling | **FIXED** | width is now configurable: `autoIdFormat.R:20-22,42-77`, `addUIds.R:41-58`; commit `14c8e84d` (#44/#38, S71). The **ceiling half was never real**: audit-time code was `paste0("U", sprintf("%04d", ...))` and `%04d` widens. Probe P3: 10,001 dam-only animals gave 10,001 unique ids, last `U10001` | CLOSE |
| PED-10 | `createPed*` mix construction and file writes | **PRESENT** | `createPedOne.R:13,31-38`, `createPedSix.R:13,74-80`: `savePed = TRUE` writes to `tempdir()/data` (since 2020, `31eef7cf`); roxygen `:6-7` still says "packages data directory". `@noRd`, no `R/` caller, one test file each | DOC (or CLOSE as internal) |
| PED-11 | `any()` on a length-1 `%in%` | **PRESENT** | `getRecordStatusIndex.R:14`; behavior-neutral | BUNDLE (same file as F1) |
| NEW-14 | first-flag accumulator instead of `lapply` | **PRESENT** | `kinshipMatricesToKValues.R:97,99`. Probe P7: `kinshipMatricesToKValues(list())` stops with "object 'kValues' not found" | BUNDLE |
| NEW-18 | hand-built HTML literals, repeated null guards | **PRESENT** | `makeGeneticSummaryTable.R:69` builds two near-identical rows by hand; `makeFounderStatsTable.R:39-60` repeats a five-way `is.null` guard | DECIDE (low value) |
| NEW-19 | `relationClass` vector duplicated from the domain | **PRESENT** | `makeRelationClassesTable.R:35` (11 names); the same strings are assigned in `convertRelationships.R:59` etc.; no shared constant | DECIDE |
| NEW-21 | proportion thresholds scattered | **PRESENT** | `getProportionLow.R:23,26,29` (0.5 / 0.3 inline); `filterThreshold.R:28` (0.015625 default) | DECIDE (with NEW-26) |
| NEW-24 | stringly-typed column vocabulary, no schema | **PRESENT** | `reportGV.R:248` still intersects `getIncludeColumns()` with `names(ped)`. **Tracked: open issue #123 (XARCH-5)**; Phase 1 landed S386 (`assertRequiredColsPresent`, `reportGV.R:281`) | TRACKED (#123) |
| NEW-26 | scattered thresholds and rounding constants | **PRESENT** | as NEW-21, plus the `digits = 4L` formatter `makeGeneticSummaryTable.R:56` | DECIDE (with NEW-21) |
| NEW-27 | positive: Shiny progress injected as a callback | **MOOT** (positive) | still true: `reportGV.R:219,238,257` call the injected `updateProgress`; S358 re-audit (`XARCH3_SHINY_PROGRESS_HOOK_AUDIT_2026-07-11.md`) confirmed | CLOSE (nothing to fix) |
| NEW-28 | `kinship()` validates, others fail bare | **PRESENT** (partial) | `kinship.R:109,119,165` validate; explicit `stop()` now also in `geneDrop.R`, `summarizeKinshipValues.R`, `countKinshipValues.R`, `cumulateSimKinships.R:51`, `getProportionLow.R:17`; none in `reportGV.R`, `calcGU.R`, `calcRetention.R`, `rankSubjects.R`, `filterReport.R`, `orderReport.R` | DECIDE (with PED-5) |
| **NEW-31** | `getRecordStatusIndex` returns `integer(0)` when `recordStatus` is absent | **PRESENT** | `getRecordStatusIndex.R:14-18`, `removeUnknownAnimals.R:22`. **Probe P1: `smallPed` (17 rows, no `recordStatus`) → `removeUnknownAnimals()` returns 0 rows, no message.** Exported; no `R/` caller; the test covers only the with-`recordStatus` case. The other caller (`getDateErrorsAndConvertDatesInPed.R:39`) asks for `"added"`, where empty is correct, so the defect is only in the `"original"` use | **TDD (F1)** |
| **NEW-32** | same, seen from `removeUnknownAnimals` | **PRESENT** | same code and probe as NEW-31 | **TDD (F1)** |
| NEW-33 | 365-day year; 182 vs 547.5-day windows; leap years | **MOOT** (after #31) | the half-year exclusion window was replaced by the gestation-derived one (`getPotentialParents.R:167-169,190`; `0eeee3f6` #31, species-keyed by `5980e44d` #46). The ±0.5-1.5-year proven-breeder window (`:171-182`) still uses `dYear <- 365L` (`:130`, also at audit time); a one-day leap-year error on a heuristic window is immaterial | CLOSE |
| **NEW-35** | dam exclude→intersect→replace re-admits excluded dams | **PRESENT** | `getPotentialParents.R:190-199`: the fallback at `:196-199` rebuilds the dam set from `ba`, discarding the `:190` exclusion. **Probe P5: a female who delivered another animal 59 days after the focal birth is still returned as its dam (`dams=[F1]`).** The comment at `:194-195` shows the fallback is deliberate, so intent needs the owner | **DECIDE then TDD (F3)** |
| NEW-36 | flag-controlled dual return type | **PRESENT** | same as PED-6 | DECIDE (with PED-6) |
| **NEW-38** | `U`-prefix collision / wrongful strip | **PRESENT** (mitigated) | `removeAutoGenIds.R:22-27` + `autoIdFormat.R:109-111` treat any id that *starts with* the prefix (default `"U"`) as generated; `addUIds.R:49,56` never checks minted ids against existing ones. **Probe P3: real ids `Uma` and `U123` are dropped by `removeAutoGenIds()`, and `addUIds()` minted `U0001` for a pedigree that already had a real `U0001` (duplicate id).** Mitigation: the prefix is configurable (#44/#38). Reach: `removeAutoGenIds` is called by `getPotentialParents.R:93`; `addUIds` by `qcStudbook.R:228` (every QC run) | **TDD (F2)** after a design choice |
| NEW-39 | hardcoded M/F by column (= PED-7) | **PRESENT** | `addParents.R:50,58` | CLOSE with PED-7 |
| **NEW-41** | `getAncestors` recursion: no cycle guard, no dedup | **PRESENT** (cycle half) | `getAncestors.R:44-67`. **Probe P2: a 2-cycle → "evaluation nested too deeply: infinite recursion"; a diamond → `S,G,D,G`.** The repeats are pinned by `test_getAncestors.R:28` ("with repeats"), so dedup is by design; there is no cycle test. `qcStudbook`'s error list has no cycle category (P8); `findGeneration` warns (`:59-75`). Callers: `countLoops.R:50`, `makesLoop.R:29-30` | **TDD (F4)** |
| NEW-42 | near-duplicate walk helpers, inconsistent argument order | **PRESENT** | `getParents.R:18`, `getOffspring.R:19` take `(pedSourceDf, ids)`; `findOffspring.R:32`, `getProbandPedigree.R:24`, `getPedDirectRelatives.R:29` take `(ids or probands, ped)`. **All five are exported**, so reordering is an API change | DECIDE (with PED-3) |
| NEW-43 | file writes on by default (= PED-10) | **PRESENT** | same as PED-10 | DOC (or CLOSE) |
| NEW-44 | `rbindFill` stops on factor/list/complex columns | **MOOT** | `rbindFill.R:25-36`. Probe P4: factor and POSIXct columns pass (`mode()` is `"numeric"`), so the audit's "factor" claim was wrong; list and complex do stop, but the only caller is `addParents.R` on pedigree frames. No test file | CLOSE |
| NEW-50 | duplicated, diverging sim driver | **PRESENT** (partial) | `createSimKinships.R:49,52,59` have `verbose` and `as.data.table`; `cumulateSimKinships.R:48-77` has neither and repeats the loop | DECIDE |
| NEW-51 | positional matrix accumulation, no dimname check | **PRESENT** (latent) | `cumulateSimKinships.R:74-77` (read; no evidence of a wrong result: `makeSimPed` keeps row order) | DECIDE (with NEW-50) |
| NEW-54 | data.table NSE mixed with `$` indexing | **PRESENT** | `getPotentialParents.R:87,111,143-144,167-169` | BUNDLE (with PED-4) |
| NEW-55 | dam heuristic collapses confidence tiers | **PRESENT** | `getPotentialParents.R:190-205` returns `dams` without saying whether they came from the proven-breeder or the all-eligible set | DECIDE (with NEW-35) |
| NEW-56 | `pUnknown$id[i][1L]` on a scalar | **PRESENT** | `getPotentialParents.R:202`; trivial | BUNDLE |
| NEW-57 | `rankSubjects` coupled to list-name strings | **PRESENT** | `rankSubjects.R:41,43,49` compare `names(rpt[i])` to `"lowVal"` and `"noParentage"` | DECIDE (low value) |
| NEW-58 | `tapply` drops animals with no qualifying partner | **REFUTED** (by design) | `getAnimalsWithHighKinship.R:57`. The companion `addAnimalsWithNoRelative.R:49` (2018, `7a6deeb5`) re-adds them as `NA` and its roxygen says why; `groupAddAssign.R:234` calls it. Tested through five consumer test files | CLOSE (optionally cross-reference in roxygen) |
| NEW-59 | unnamed `rep(NA, 6)` fallback indexed by name | **PRESENT** (harmless) | `makeGeneticSummaryTable.R:44,52`, guarded by `fmt()` at `:56`. Probe P6: a frame with no `indivMeanKin` or `gu` returns a table of `N/A`, no error | CLOSE (or a one-line `setNames`) |
| NEW-60 | `reportGV` positional `cbind` | **REFUTED** | the audit's own Appendix (`PED_GV_AUDIT_2026-05-30.md:259`): `findOffspring` orders by `probands`. It was never a finding, so it was never in the ledger and should not be in the count | CLOSE (drop from the list) |
| NEW-61 | `reportGV` and `calcFEFG` define "founder" differently | **PRESENT** (decision) | `reportGV.R:282-286` excludes generated-unknown ids from the *known* founders it reports; `calcFounderContributions.R:35` uses every both-parents-unknown row. The ledger has only S17's "out of scope" mention (2026-06-01). Plausibly intended ("Known Founders" vs the FE/FG founder set) | DECIDE (document or unify) |
| NEW-62 | `updateProgress` null-check boilerplate ×4 | **PRESENT** | 3 blocks now: `reportGV.R:219,238,257` | BUNDLE (or CLOSE) |
| NEW-63 | `getMaxAx` doc says negative counts | **PRESENT** (doc only) | `getMaxAx.R:6,16` say "negative (males)" and `bins` "integer vector"; the code (`:18-20`) and `test_getMaxAx.R:5` take a list of non-negative counts | DOC |
| NEW-29 | hardcoded sex/status codes and `^U` in founder logic | **PRESENT** (partial) | the `^U` half is resolved (dead block dropped S18; predicate `isGeneratedUnknownId` at `reportGV.R:284,286`); sex literals remain at `reportGV.R:283,285`. The ledger holds only S17's "out of scope" mention | DECIDE (fold into PED-2) |
| NEW-47 | `calcGU` divisor from the input column set | **MOOT** | `calcGU.R:98-99`: `iterations` counts the same non-id/parent columns `calcA.R` iterates with `apply(alleles, 2L, ...)`, so they agree by construction; unchanged since audit. The ledger's "NEW-47" is a NEWS label for `getDescendantPedigree` (id collision) | CLOSE |

## Findings worth acting on

Ranked by how unconditional and how silent each is. **None is fixed here.**

**F1 — `removeUnknownAnimals()` silently returns 0 rows when `recordStatus` is absent (NEW-31/32).**
Exported, so a script user can hit it; the app never calls it. Probe P1: 17 rows in, 0 out, no
message. *Fix:* return `ped` unchanged when nothing can be "added" (matches the function's meaning:
remove the added rows) — or `stop()` with a clear message; the owner picks. Fix it in
`removeUnknownAnimals()`, **not** in `getRecordStatusIndex()`, whose `"added"` use is correct.
*RED test:* a pedigree without `recordStatus` round-trips unchanged; the existing test covers only
the with-column case. *Effort S.*

**F2 — `U`-prefix scheme: collision at generation, wrongful strip at detection (NEW-38).**
`addUIds()` runs in every `qcStudbook()`; if a colony's real ids can look like `U0001`, it mints a
duplicate. `removeAutoGenIds()` (used by the Potential Parents feature) drops any real id that
starts with the prefix. Impact depends on the centers' id schemes, which the owner knows.
*Needs a design choice first:* stricter detection (prefix plus digits derived from the format)
changes what an exported function strips; collision avoidance changes what `addUIds()` mints.
*RED tests:* real `U`-prefixed ids survive; a minted id never equals an existing id. *Effort M.*

**F3 — an excluded dam is re-admitted by the fallback (NEW-35, with NEW-55).**
Probe P5. The fallback at `getPotentialParents.R:196-199` is documented as intentional, so this is
first a *decision*: fall back to the exclusion-filtered set, return no dam, or keep it and label
the tier (NEW-55). *Effort S after the decision.*

**F4 — `getAncestors()` on a cyclic pedigree recurses until R aborts (NEW-41).**
Rare (a cycle is a data error) and reported by `findGeneration()` already, but nothing upstream
rejects it. *Fix:* carry a visited set, keep the documented repeats, stop with a clear message on a
cycle. *RED test:* a 2-cycle. *Effort S.*

## Recommendations

1. **Take F1 first** (unconditional, silent, small), then F2 (after the owner's design choice),
   F3 (after the decision), F4. One TDD slice each, with the phase gates.
2. **One small "BUNDLE/DOC" session** for the trivial items: PED-11, NEW-56, NEW-63, the PED-10 /
   NEW-43 roxygen, NEW-14 (with its empty-list edge), and optionally NEW-62. None changes behavior.
3. **Owner decisions** on the overhaul roots, none urgent: sex-code adoption (PED-2, NEW-29,
   PED-7/39); the error/return contract (PED-5, PED-6, NEW-28, NEW-36); splitting
   `getPotentialParents` (PED-4, NEW-54, NEW-55); the walk-helper family (PED-3, NEW-42 — exported
   API); the sim driver (NEW-50, NEW-51); constants and HTML builders (NEW-18, 19, 21, 26, 57);
   the founder definition (NEW-61).
4. **Close 11 ids** as fixed, moot or refuted once the owner agrees: PED-7, NEW-39, PED-8, PED-9,
   NEW-27, NEW-33, NEW-44, NEW-47, NEW-58, NEW-59, NEW-60. No new ledger entry is owed for the
   fixed ones: PED-8 is recorded under NEW-40 and PED-9 under #44/#38.
5. **Leave NEW-24 to issue #123.**

## Closure record (owner-ratified 2026-09-30, S818)

The owner agreed to Recommendation 4: these **11 ids are closed**. Closing records a decision; it
changes no code, and the table above is left as the frozen S781 reading.

| id | closed because |
|---|---|
| PED-8 | FIXED: `findGeneration` warns naming unplaced ids (`ea5d28fa`, recorded under NEW-40) |
| PED-9 | FIXED: id width is configurable, and the 9999 ceiling was never real (`14c8e84d`, #44/#38) |
| NEW-27 | MOOT: a positive finding, nothing to fix |
| NEW-33 | MOOT: the half-year window was replaced by the gestation-derived one (#31, #46) |
| NEW-44 | MOOT: factor and POSIXct columns pass; the only caller is `addParents.R` |
| NEW-47 | MOOT: `calcGU` and `calcA` count the same columns by construction |
| NEW-58 | REFUTED: `addAnimalsWithNoRelative.R` re-adds the dropped animals by design |
| NEW-60 | REFUTED: `findOffspring` orders by `probands`; never a finding |
| PED-7 | accepted design: a sire is male by role; any constant-adoption question folds into PED-2 |
| NEW-39 | same as PED-7 |
| NEW-59 | harmless: guarded by `fmt()`, a frame with no `indivMeanKin` or `gu` gives a table of `N/A` |

Open after closure: 43 - 11 = **32 ids**, of which NEW-24 is issue #123 and the rest are the
overhaul roots and small no-behavior-change items in Recommendations 2 and 3.

### Closure record 2 (owner decision 2026-10-02, S871)

| id | closed because |
|---|---|
| NEW-61 | INTENDED: known founders and unknown founders are different things (an unknown founder may be a known founder, another animal in the population, or an animal outside it). `reportGV` lists only known founders; `calcFEFG` counts every both-parents-unknown animal as a separate, unrelated founder. Both stay; the difference is now documented in the roxygen of `calcFEFG()` and `reportGV()` (`5f6ba3c0b`), including that the unrelated-founder assumption can overstate FE and FG when placeholders are common. |

Open after this closure: **31 ids**.

### Decision record 3 (owner decision 2026-10-02, S872) -- not a closure

| id | decided |
|---|---|
| PED-2, NEW-29, PED-7 | ADOPT EVERYWHERE: every direct `"M"`/`"F"`/`"U"`/`"H"` comparison or assignment in `R/` should go through `sexCodes`. Work not started; the ids stay open until it ships. S872 measured 40 comparison lines in 16 files (a grep of `==`, `!=`, `%in%` against a quoted letter, comment lines excluded; assignments like `addParents.R:54,62` and `identical(sexOf[[p]], "M")` in `makePedigreeDiagramData.R` are extra). |

Still **31 ids** open.

### Closure record 4 (S879, 2026-10-03) -- decision record 3 shipped

| id | closed because |
|---|---|
| PED-2 | SHIPPED: every direct sex letter in `R/` goes through `sexCodes` (stages 1-6, S874-S879). `tests/testthat/test_sexCodes.R` scans every `R/*.R`; exempt are `convertSexCodes.R`, `createPedOne.R`, `createPedSix.R` (whole files) and six lines by exact text (four non-sex uses, the owner-kept `groupAddAssign()` default). |
| NEW-29 | SHIPPED with PED-2; the `reportGV.R` sex literals now use `sexCodes` (S876). The `^U` half was resolved earlier. |
| PED-7 | SHIPPED with PED-2 (`addParents.R`, S877). It was already counted closed in the S818 record (with NEW-39); decision record 3 only held it open for this work, so it does not lower the count again. |

Open after this closure: **29 ids** (31 minus PED-2 and NEW-29).

### Decision record 5 (owner decision 2026-10-03, S880)

| id | decided |
|---|---|
| NEW-55 | CLOSED, SHIPPED: each `getPotentialParents()` entry now carries `damBasis` (`"provenBreeder"`, `"eligibleFemale"`, or `NA` when `dams` is empty); `id`, `sires`, `dams` unchanged (tests in `test_getPotentialParents.R`, GREEN `ed344a83a`). |
| PED-4, NEW-54 | STAY OPEN: the owner chose to split the 150-line function in its own later session (plan-mode approval first). |

NEW-56's `pUnknown$id[i][1L]` is no longer in the file (verified S880), but it was not recounted.
Open after this closure: **28 ids** (29 minus NEW-55).

### Closure record 6 (S881, 2026-10-03) -- decision record 5's split shipped

| id | closed because |
|---|---|
| PED-4 | SHIPPED: `getPotentialParents()` now delegates to five internal helpers in `R/getPotentialParentsHelpers.R` (`resolveMinParentAges`, `gestationWindows`, `selectPotentialSires`, `selectPotentialDams`, `buildParentEntry`); output pinned unchanged by `test_getPotentialParentsHelpers.R` (RED `b446143ac`, `8509d4b7d`; GREEN `5d9dbbfa9`; REFACTOR `8add079bb`). |
| NEW-54 | SHIPPED with PED-4: the sire and dam selection now use bare column names inside the data.table calls (`is.na(exit)`), not `ba$exit` beside `exit`. |

Open after this closure: **26 ids** (28 minus PED-4 and NEW-54).

### Closure record 7 (owner decision 2026-10-03, S885) -- ids already fixed in code

The owner agreed to close these **11 ids**. Each was checked against today's code and its pinned tests, not the
ledger alone. Closing changes no code, and the table above stays the frozen S781 reading. These ids stayed open
only because the fixes travelled under session and issue names, not audit ids (Structural Observation 1).

| id | closed because |
|---|---|
| NEW-31, NEW-32 | FIXED (F1, S782 `3aae4b9cb`): `removeUnknownAnimals()` returns a pedigree with no `recordStatus` column unchanged. S885: `smallPed` 17 rows in, 17 out (was 17 to 0); `test_removeUnknownAnimals.R` passes. |
| NEW-41 | FIXED (F4, S783 `c0ef7bc6a`): `getAncestors()` stops with a message naming the cycle and keeps the documented diamond repeats. S885: a 2-cycle gives "...A -> B -> A"; `test_getAncestors.R` passes. The absent-id and depth-limit findings are their own BACKLOG item and stay open. |
| NEW-35 | FIXED (F3, S798, RED `4bbcb071d`, GREEN `174be7f5e`): the dam fallback no longer re-admits a female ruled out by the gestation window. Pinned at `test_getPotentialParents.R:316,329,341` (the first is named for probe P5); the file passes S885. |
| NEW-38 | FIXED, both halves: `addUIds()` never mints a duplicate of an existing id, including an id used only as a sire or dam (S797 `cf956da81`, S808 `bac494e0c`; `test_addUIds.R:39,68`); a real id that merely starts with the prefix is kept by the `placeholder` mark (S808-S811, e.g. `410273d54`, `665e9c475`; `test_removeAutoGenIds.R:61,95,116`). Both files pass S885. |
| NEW-14 | FIXED (S795 GREEN `a2fe3443a`, restyle `926cc907b`): the first-flag accumulator is gone, and an empty list stops with "kinshipMatrices must contain at least one kinship matrix" (was "object 'kValues' not found"). `test_kinshipMatricesToKValues.R` passes. |
| PED-11 | FIXED (S795 `926cc907b`): `getRecordStatusIndex()` no longer wraps `%in%` in `any()`. |
| NEW-63 | FIXED (S795 `926cc907b`): the `getMaxAx()` roxygen now says non-negative integer `male` and `female` counts. |
| PED-10, NEW-43 | DOC FIXED (S795 `926cc907b`): the `createPedOne()` and `createPedSix()` roxygen say the `data` subdirectory of `tempdir()`. `savePed = TRUE` still writes there by default; the triage accepted that for these `@noRd` internals. |
| NEW-56 | GONE: `pUnknown$id[i][1L]` is not in `R/getPotentialParents*.R` (S880 and S885 both checked). |

Open after this closure: **15 ids** (26 minus 11). The `BACKLOG.md` item said 28 after S881, when this report's own
count was 26. The 15 are NEW-24 (issue #123, tracked) and 14 owner decisions: the error/return contract (PED-5,
PED-6, NEW-28, NEW-36), the walk helpers (PED-3, NEW-42; exported), the sim driver (NEW-50, NEW-51), constants and
HTML builders (NEW-18, NEW-19, NEW-21, NEW-26, NEW-57) and the repeated `updateProgress` null checks (NEW-62; 3
blocks, `reportGV.R:229,248,267`).

### Decision record 8 (owner decision 2026-10-03, S886) -- sim driver

The owner chose "Share the 6-line step" over "Leave both as they are" and "Share it and add a safety check". The
table above stays the frozen S781 reading.

| id | decided |
|---|---|
| NEW-50 | SHARE THE STEP, STAYS OPEN until it ships: an internal helper does one simulation (`makeSimPed()` then `kinship()`, `createSimKinships.R:60-65` and `cumulateSimKinships.R:63-68`) and both exported functions call it. Each keeps its own loop, so `cumulateSimKinships()` still holds 4 running matrices and not `n`. No change for users. Work not started; strict TDD, with the owner's approval of the refactor given at its own scope gate. |
| NEW-51 | CLOSED, ACCEPTED, no guard: the owner declined the dimnames check. S886 measured the audit's reason on `smallPed` (`pop = LETTERS[1:7]`, seed 42): 200 simulated matrices, row and column order identical in all 200 and equal to `ped$id`; and `cumulateSimKinships()`'s mean equalled the mean of `createSimKinships()`'s matrices under the same seed. One small fixture: no wrong result today, not a proof. |

What S886 measured, for whoever picks up the work:

- The two functions differ on purpose in memory: `createSimKinships()` returns all `n` matrices, `cumulateSimKinships()`
  keeps 4. By arithmetic (not run), one 3,000-animal matrix is 72 MB, so 1,000 simulations kept as a list would be about
  72 GB against about 288 MB. Building the summary on top of `createSimKinships()` would lose that, so it is not the plan.
- `createSimKinships()` converts the pedigree to a data.table and takes `verbose`; `cumulateSimKinships()` does neither.
  The helper must take an already-prepared pedigree. The same-seed match above suggests the result does not depend on the
  class, on that one fixture. Whether `cumulateSimKinships()` gains `verbose` was not asked; it stays without.
- Existing tests pin seeded numbers for each function (`test_createSimKinships.R:70`, `test_cumulateSimKinships.R:63`),
  the `twinRelations` values and the `n < 2` handling, but nothing ties the two functions together. The first RED test
  should: same seed, `cumulateSimKinships()`'s mean equals the mean of `createSimKinships()`'s matrices.
- Only one behavior change ever had to edit both files: `twinRelations` (`99796a655`). No function in `R/` calls either.

Open after this decision: **14 ids** (15 minus NEW-51); NEW-50 is decided and waits on the work.

### Closure record 9 (S887, 2026-10-03) -- decision record 8's shared step shipped

| id | closed because |
|---|---|
| NEW-50 | SHIPPED: `createSimKinships()` and `cumulateSimKinships()` call one internal `.simulateKinship()` (`R/simulateKinship.R`), which runs `makeSimPed()` then `kinship()` in that order, so seeded results did not move. Each keeps its own loop, so `cumulateSimKinships()` still holds 4 running matrices and not `n`. No change for users; `cumulateSimKinships()` did not gain `verbose`. Pinned by `test_simulateKinship.R` (RED `b96bbb45f`; GREEN `de45c8928`; REFACTOR `38c3f713c`): the helper equals `makeSimPed()` then `kinship()` under one seed, passes `twinRelations` and `verbose`, leaves the caller's pedigree alone; each function calls it once per simulation and never at `n = 0`; and under one seed the mean, min and max of `cumulateSimKinships()` equal those of `createSimKinships()`'s matrices. |

Open after this closure: **13 ids** (14 minus NEW-50): NEW-24 (issue #123, tracked) and 12 owner decisions, the
error/return contract (PED-5, PED-6, NEW-28, NEW-36), the walk helpers (PED-3, NEW-42; exported), constants and HTML
builders (NEW-18, NEW-19, NEW-21, NEW-26, NEW-57) and the repeated `updateProgress` null checks (NEW-62; 3 blocks).

### Decision record 10 (owner decision 2026-10-03, S888) -- error behavior

The owner chose "Keep it" for the `reportErrors` two-mode pattern (over "Change only `correctParentSex()`" and "Replace it
in all six") and "Clear message in `reportGV()` only" for bad input outside QC (over "Leave it" and "`reportGV()` and the
others"). The table above stays the frozen S781 reading.

| id | decided |
|---|---|
| PED-6 | CLOSED, ACCEPTED: `correctParentSex()` returns the corrected sex codes when `reportErrors = FALSE` and the error list when `TRUE` (`R/correctParentSex.R:38-43`, the branches at `:95-103` and `:122-125`). That is the QC family's one pattern, below, not a quirk of this function. |
| NEW-36 | CLOSED, ACCEPTED: same as PED-6. |
| PED-5 | CLOSED, ACCEPTED as the umbrella for the two decisions in this record: no package-wide error or return contract. Of the sites the S781 row cites, `getPotentialParents()` returns `NULL` when no animal has an unknown parent with a candidate or `ped` has no `fromCenter` column (its `@return` says so, `R/getPotentialParents.R:59-61`) and `getPedDirectRelatives()` returns `NULL` for a `NULL` pedigree (its roxygen says so); `rbindFill()` is internal (`@noRd`). |
| NEW-28 | DECIDED, STAYS OPEN until it ships: `reportGV()` names its missing required columns up front, before the kinship step. No other function changes. Work not started; strict TDD, with the owner's approval of the scope at its own gate. New READY item in `BACKLOG.md`. |

What S888 measured, for whoever picks up the work (all by running the code, except where it says "read"):

- **The pattern.** Six exported functions take `reportErrors`: `qcStudbook()`, `correctParentSex()`, `removeDuplicates()`,
  `checkParentAge()`, `checkRequiredCols()` and `convertDate()`. `FALSE` stops at the first problem, or returns the cleaned
  data; `TRUE` returns the problems (`NULL` when none). Run in both modes on clean and bad input: `correctParentSex`,
  `removeDuplicates`, `checkRequiredCols`, `qcStudbook`, each returning what its help page says. Read, not run: `checkParentAge`
  and `convertDate`. The app depends on it: `runQcStudbook()` calls `qcStudbook()` with `reportErrors = TRUE`, then `FALSE`
  (`R/runQcStudbook.R:125,212`).
- **Bad input outside QC** (a missing column or `NULL`), run: a clear message from `getGeneticDiversityStats()` ("requires at
  least one group"); a base-R message from `reportGV()` ("result would be too long a vector"), `calcGU()` ("dim(X) must have
  a positive length") and `calcRetention()` ("undefined columns selected"); silent from `filterReport()` (a table with no
  `id` column gives an empty vector) and `rankSubjects(NULL)` (`NULL`). Read, not run: `cumulateSimKinships()` (stops when
  `n < 1`) and `getPedDirectRelatives()` (stops on a missing `ids` or `ped`) give clear messages, and
  `checkParentAge(reportErrors = FALSE)` returns its input unchanged when `sire` or `dam` is missing (`R/checkParentAge.R:92`,
  the early `return(sb)`).
- **The NEW-28 row's "none in `reportGV`" is out of date.** `reportGV()` checks `id` and `sex` at `R/reportGV.R:291` (issue
  #123, S386), but after `kinship()` (`:179`) and `geneDrop()` (`:223`) have run, so a missing `id`, `sire`, `dam` or `gen`
  never reaches it.
- **Per-column probe** on the `reportGV()` example pipeline (`examplePedigree` through `qcStudbook()`, `setPopulation()` and
  `trimPedigree()`; 704 rows; `guIter = 10L`, `guThresh = 3`): the unmodified fixture runs. Without `id`: "'dimnames' applied
  to non-array". Without `sire` or `dam`: "arguments imply differing number of rows: 704, 0". Without `gen`: "result would
  be too long a vector". Without `sex`: the clear named message of the `:291` check. Without `birth`, `exit`, `age` or
  `population`: no error.
- **A column check alone is not enough for a raw pedigree.** `smallPed` (all six columns present, no QC run) stopped with
  "sire and dam must have had alleles assigned: logic error" at `guIter = 10L`; it is not a usable "good input" fixture.
- The first RED test for the follow-up: a fixture without `gen` stops with a message naming `gen`, and the unmodified fixture's
  result is identical. Two points for its scope gate: whether the new check replaces the `:291` one or sits before it, and
  whether "clear message" means missing columns only.

Open after this decision: **10 ids** (13 minus PED-5, PED-6, NEW-36; by script over this report's table: 43 ids, 33 closed,
the same script gives 13 on the S887 report): NEW-24 (issue #123, tracked), NEW-28 (decided, waits on the work) and 8 owner
decisions, the walk helpers (PED-3, NEW-42; exported), constants and HTML builders (NEW-18, NEW-19, NEW-21, NEW-26, NEW-57)
and the repeated `updateProgress` null checks (NEW-62; 3 blocks).

### Closure record 11 (S889, 2026-10-03) -- decision record 10's NEW-28 shipped

| id | closed because |
|---|---|
| NEW-28 | SHIPPED: `reportGV()` checks `id`, `sire`, `dam`, `gen` and `sex` as its first statement (one `assertRequiredColsPresent()` call in `R/reportGV.R`) and names every missing one in one message, before `kinship()`; the late `sex`-only check is deleted. Missing columns only, as decided: a pedigree with every column but nothing the gene drop needs (`smallPed`) still stops with "sire and dam must have had alleles assigned". RED `22cc2f63f` and `e86e68b4e`, GREEN `7f6216876`, REFACTOR `67b8afd21`. |

One consequence the owner chose on purpose (S889): a pedigree missing `sex` that also has an animal with one known parent
now gets the missing-column message, not `calcFEFG()`'s partial-parentage one. `test_calcFEFG.R` gives its pedigree a `sex`
column for that reason (`lacy1989Ped` has none).

Open after this closure: **9 ids** (10 minus NEW-28; by a counting script rebuilt S889 and validated first on the unchanged
report, where it gave 43 ids, 33 closed, 10 open, the same open set as Decision record 10): NEW-24 (issue #123, tracked) and
8 owner decisions, the walk helpers (PED-3, NEW-42; exported), constants and HTML builders (NEW-18, NEW-19, NEW-21, NEW-26,
NEW-57) and the repeated `updateProgress` null checks (NEW-62; 3 blocks).

### Decision record 12 (owner decision 2026-10-05, S911) -- progress-callback checks

The owner chose "One shared helper for all 7" (over "Leave as is, close it" and "Only the 3 in reportGV") for NEW-62. S911
wrote it down and changed no code. The table above stays the frozen S781 reading.

| id | decided |
|---|---|
| NEW-62 | DECIDED, STAYS OPEN until it ships: one internal (not exported) helper replaces the seven "if a progress function was given, call it" blocks in four files; no change for users. Work not started; strict TDD, with the owner's approval of the scope at its own gate. New READY item in `BACKLOG.md`. |

What S911 measured, for whoever picks up the work (by reading today's code and grepping `tests/`; nothing was run):

- **The row is out of date twice.** It cites 3 blocks at `reportGV.R:219,238,257`; they are at `:246,265,284` (S889's
  `assertRequiredColsPresent()` call moved them), and the same pattern has four more copies outside `reportGV.R`.
- **The seven sites** (33 lines in all; the `reportGV.R` three differ only in the message text):

  | Site | What it sends | Lines |
  |---|---|---|
  | `reportGV.R:246` | `detail = "Calculating Genome Uniqueness", value = 1L, reset = TRUE` | 6 |
  | `reportGV.R:265` | `detail = "Calculating Numbers of Offspring"`, same two arguments | 6 |
  | `reportGV.R:284` | `detail = "Calculating Founder Equivalents"`, same two arguments | 6 |
  | `geneDrop.R:124` | `detail = "Performing Gene-drop Simulation", value = 0L, reset = TRUE` | 6 |
  | `geneDrop.R:147` | `n = nrow(ped)`, inside `for (id in ped$id)` | 3 |
  | `convertRelationships.R:94` | no arguments, inside the per-pair loop | 3 |
  | `groupAddAssign.R:308` | no arguments, inside the iteration loop | 3 |

- **The callback the app passes** is `function(n = 1L, detail = NULL, value = 0L, reset = FALSE)` (`R/modGeneticValue.R:284`,
  `R/modBreedingGroups.R:625`). `reportGV()` hands its callback to `geneDrop()` (`:243`) and `gvaConvergence()` hands its own to
  `geneDrop()` (`R/gvaConvergence.R:199`); those two are pass-throughs with no null check, so they are not blocks.
- **What the tests pin about the calls to the callback: nothing.** `test_reportGV.R:24-26` passes a stub that returns `"stub"` and
  checks only the report's shape; `test_convertRelationships.R:8` passes `function() {}`; all 10 `updateProgress` mentions in
  `test_geneDrop.R` pass `NULL` (so `geneDrop()`'s own tests never reach its two callback branches; `reportGV()`'s test does);
  no `test_groupAddAssign*` file passes a callback. No test records which messages are sent or in what order, so the first RED
  is a recording test for each function (a stub that saves its calls), written and run at the current commit before any block moves.
- **Estimate, not a measurement:** the 33 lines of blocks become about 11 lines of calls, plus a helper of roughly 10 lines and a
  new test file.
- **Points for the pickup's scope gate:** (a) keep the `!is.null(updateProgress)` test, so a non-function still fails as it
  does today, or switch to `is.function()` (a small behaviour change); (b) the helper's name and file; (c) three sites sit in
  per-item loops (`geneDrop.R:147`, `convertRelationships.R:94`, `groupAddAssign.R:308`), so time each function before and after
  on a large pedigree (not timed here); (d) whether `reportGV()`'s own checks stay inline.

Open after this decision: **9 ids** (no id closed; NEW-62 is decided and waits on the work, as NEW-28 and NEW-50 did):
NEW-24 (issue #123, tracked), NEW-62 (decided) and 7 owner decisions, the walk helpers (PED-3, NEW-42; exported) and constants
and HTML builders (NEW-18, NEW-19, NEW-21, NEW-26, NEW-57).

### Decision record 13 (owner decision 2026-10-05, S912) -- the walk helpers

The owner took the walk helpers at the Phase 0 scope question (the other group was the constants and HTML builders) and chose:

- **PED-3:** "Merge all four" (over "Fix only the LabKey function" and "Leave all four, close it").
- **NEW-42:** "Leave as is, document it" (over "Ids first, in the 3.0.0 release").

S912 wrote it down and changed no code. The table above stays the frozen S781 reading.

| id | decided |
|---|---|
| PED-3 | DECIDED, STAYS OPEN until it ships: one internal (not exported) function replaces the four hand-written "collect parents or offspring until nothing new turns up" loops; no change for users on normal data; `getLkDirectAncestors()` will stop on circular data (today it never does). Work not started; strict TDD, with the owner's approval of the scope at its own gate. New READY item in `BACKLOG.md`. |
| NEW-42 | DECIDED, STAYS OPEN until it ships: the argument order of `getParents()` and `getOffspring()` (pedigree first) stays, and the help page of each says so. No API change. A small READY item in `BACKLOG.md` (help text only). |

What S912 measured, for whoever picks up the work (by reading today's code, one bounded R probe (P12 below) and greps of `R/`
and `tests/`; no test suite was run):

- **The PED-3 row names 2 loops; there are 4** (42 lines in all):

  | Site | Walks | Lines |
  |---|---|---|
  | `getProbandPedigree.R:26-37` | up (ancestors), with its own inline parent lookup | 12 |
  | `getDescendantPedigree.R:27-34` | down (descendants), through `getOffspring()` | 8 |
  | `getPedDirectRelatives.R:54-65` | both ways, through `getParents()` and `getOffspring()` | 12 |
  | `getLkDirectAncestors.R:69-78` | up, over the LabKey demographics table, one generation at a time | 10 |

  The fourth is the odd one out. It widens only the newest generation (it passes the last result back in), not the whole set
  found so far, and it has no "nothing new was added" test. It also returns rows generation by generation with the first
  occurrence of an id kept, while the other three return rows in the pedigree's own order.
- **Circular data** (P12: A's sire is B and B's sire is A): `getProbandPedigree()`, `getDescendantPedigree()` and
  `getPedDirectRelatives()` each returned the 2 animals in under 0.1 s; `getLkDirectAncestors()` ran until the probe's 5-second
  limit stopped it. Only `tests/testthat/test_getDescendantPedigree.R:57` tests circular data; the other three have no such
  test. `getLkDirectAncestors()` is exported but has no caller in `R/` or the app; its tests stub `getDemographics()` with
  `mockery` (`test_getLkDirectAncestors.R:36-51`).
- **Who calls the walkers:** the app calls `getDescendantPedigree()` (`R/modPedigree.R:392`); `trimPedigree()` calls
  `getProbandPedigree()` (`R/trimPedigree.R:60`); `getLkDirectRelatives.R:39` and `getFileDirectRelatives.R:52` call
  `getPedDirectRelatives()`; `getParents()` is also called at `getLkDirectAncestors.R:70` and `getOffspring()` at
  `getDescendantPedigree.R:28`. All five functions the NEW-42 row names are exported, as are `getDescendantPedigree()` and
  `getLkDirectAncestors()`.
- **NEW-42, the argument-order count:** of the 18 exported functions that take both a pedigree and animal ids (matched by
  argument name; the Shiny module servers excluded, because their `id` is the module id), 11 put the ids first
  (`addSexAndAgeToGroup`, `calculateSexRatio`, `findOffspring`, `getDescendantPedigree`, `getPedDirectRelatives`,
  `getPotentialSires`, `getProbandPedigree`, `hasBothParents`, `offspringCounts`, `removePotentialSires`, `trimPedigree`) and
  7 put the pedigree first (`convertRelationships`, `countFirstOrder`, `getOffspring`, `getParents`,
  `markerParentageLikelihood`, `markerRealizedRelatednessVariance`, `setPopulation`). Reordering `getParents()` and
  `getOffspring()` would have lined up 2 of the 7; the other 5 would have stayed. A call in the swapped order stops with "$
  operator is invalid for atomic vectors" from both (tested), so a script passing them by position would have failed loudly, not
  silently. Callers in `R/`: 2 each; tests: `test_getParents.R` (4 mentions), `test_getOffspring.R` (4) and
  `test_getDescendantPedigree.R` (1).
- **Points for PED-3's pickup scope gate:** (a) the walker's name and file; (b) when `getLkDirectAncestors()` stops on circular
  data, whether it returns the animals found, as the other three do, or stops with a message; (c) the exported signatures stay
  as they are; (d) the first RED is a recording test per function (rows and row order of each, including the LabKey
  generation order and first-occurrence de-duplication, and today's handling of `NA` ids), then a circular-data test for each
  of the three that lack one, which is RED for the LabKey function; (e) time `getDescendantPedigree()` and `trimPedigree()`
  before and after on a large pedigree (not timed here).
- **Measured for the remaining group, no decision taken** (these backed the scope question; today's code): the 11
  relationship-class names are all in `makeRelationClassesTable.R:35` and `convertRelationships.R`, and 3 of them
  (`Parent-Offspring`, `Full-Siblings`, `Half-Siblings`) are also in `markerRealizedRelatednessVariance.R` (S912's option text
  said "listed in 3 files", which overstated it); the `0.015625` default is typed in 3 places (`filterThreshold.R:28`,
  `getKinshipWithMaleStatus.R:40`, `groupAddAssign.R:179`); the `0.5` and `0.3` cut-offs are inside one function
  (`getProportionLow.R`, internal, one caller at `getGeneticDiversityStats.R:95`); `digits = 4L` is once in
  `makeGeneticSummaryTable.R:57` (the `DT::formatRound(..., digits = 4L)` at `modMarkerGenetics.R:1192` is a different
  formatter); `makeFounderStatsTable.R` now has 6 "if present, else default" blocks (the row says five; `fgSE` was added by
  issue #82 Slice 3); `"lowVal"` and `"noParentage"` are compared by text at `rankSubjects.R:51,53,59` and listed again at
  `orderReport.R:131,139`.

Open after this decision: **9 ids** (no id closed; PED-3 and NEW-42 are decided and wait on the work, as NEW-62, NEW-28 and
NEW-50 did): NEW-24 (issue #123, tracked), NEW-62, PED-3 and NEW-42 (decided), and the 5 undecided constants and HTML builders
ids (NEW-18, NEW-19, NEW-21, NEW-26, NEW-57).

### Closure record 14 (S913, 2026-10-05) -- decision record 13's NEW-42 shipped

| id | closed because |
|---|---|
| NEW-42 | SHIPPED: the help pages of `getParents()` and `getOffspring()` say the pedigree is the first argument, unlike `getProbandPedigree()`, `getDescendantPedigree()`, `getPedDirectRelatives()` and `findOffspring()`, which take the animal ids first. The sentence is in `@param pedSourceDf` of `R/getParents.R:6-10`; `getOffspring()` already inherited `ids` from `getParents()` and now inherits `pedSourceDf` too, so it is written once and both man pages carry it. The argument order is unchanged (record 13) and the parsed R code of both files is identical to before. Pinned by `test_getParentsOffspringHelp.R` (RED `dd5396ddc`; GREEN `5b87d8819`; REFACTOR `0645d57f4`): the `pedSourceDf` entry of each man page says "first" and names the four functions, and the argument order of all six functions is what the sentence says (green before the edit; a lock against a later reorder). |

Open after this closure: **8 ids** (9 minus NEW-42; recounted S913: the table has 43 ids and the 9 named in record 13 are all
among them, so 35 are closed): NEW-24 (issue #123, tracked), NEW-62 and PED-3 (decided, wait on the work), and the 5 undecided
constants and HTML builders ids (NEW-18, NEW-19, NEW-21, NEW-26, NEW-57).

### Closure record 15 (S914, 2026-10-05) -- decision record 12's NEW-62 shipped

| id | closed because |
|---|---|
| NEW-62 | SHIPPED: one internal helper, `notifyProgress(updateProgress, ...)` in `R/notifyProgress.R` (`@noRd`, not exported, a 6-line function), replaces the seven `if (!is.null(updateProgress))` blocks at `R/reportGV.R:246,263,280`, `R/geneDrop.R:124,145`, `R/convertRelationships.R:94` and `R/groupAddAssign.R:308`; the 33 lines of blocks became 19 lines of calls. The two pass-throughs (`reportGV.R:243`, `gvaConvergence.R:199`) are untouched. At the Pre-RED gate the owner kept the `!is.null()` test (a non-function still stops with `could not find function "updateProgress"`, measured for `geneDrop()` and `convertRelationships()` before the change; the helper's parameter is named `updateProgress` so that message is unchanged) and chose the name `notifyProgress`, no leading dot. Pinned by `test_notifyProgress.R` (RED `66c9e61cf`; GREEN `a2a0c9bb7`; REFACTOR `3d521d0c9`), 14 tests and 34 expectations: the helper itself; one recording test per function of the calls it sends, measured at the unchanged commit (`geneDrop()`: one start call, then one `n = nrow(ped)` per animal; `reportGV()`: those, then three step messages; `convertRelationships()`: one argument-free call per pair; `groupAddAssign()`: one per iteration; green before any block moved); and one test per function that it goes through the helper (red until the blocks moved; with the pre-change `R/` files back in place exactly these four fail again, 11 expectations). Timing, old and new code alternating in one R process (7 repetitions): +0.3 to +0.8% on five of six rows and +3.8% for `groupAddAssign()` with no callback, inside a 0.26-0.40 s run-to-run range; a per-call microbenchmark gives +0.4 to +0.6 microseconds, about 2 ms on the 3,694-animal `examplePedigree` run. |

Open after this closure: **7 ids** (8 minus NEW-62; recounted S914: the table has 43 ids, all unique, and the 7 open ones are all
among them, so 36 are closed): NEW-24 (issue #123, tracked), PED-3 (decided, waits on the work), and the 5 undecided constants and
HTML builders ids (NEW-18, NEW-19, NEW-21, NEW-26, NEW-57).

### Closure record 16 (S915, 2026-10-05) -- decision record 13's PED-3 shipped

| id | closed because |
|---|---|
| PED-3 | SHIPPED: one unexported `walkPedigree(ids, ped, direction)` in `R/walkPedigree.R` (`@noRd`, 51 lines; `direction` is `"ancestors"`, `"descendants"` or `"both"`; it returns a list of id vectors, one per generation, each id once) replaces the four hand-written loops (42 lines) in `R/getProbandPedigree.R`, `R/getDescendantPedigree.R`, `R/getPedDirectRelatives.R` and `R/getLkDirectAncestors.R`; the four exported signatures, help pages and callers are unchanged. At the Pre-RED gate the owner chose the name and file (`walkPedigree`, `R/walkPedigree.R`) and that `getLkDirectAncestors()` stops and returns the animals found. **Two side effects, both on invalid data:** `getLkDirectAncestors()` stops on circular data (before: it ran into the 5-second limit on two animals that are each other's sire and on one that is its own sire); and `getPedDirectRelatives()` stops when a row of the pedigree has a missing id (a new finding of S915, not in record 13: it ran into the 5-second limit for `ids = "A"`, `NA` and `c("F", NA)`, because each pass found the missing-id row as an offspring, dropped it from `ids`, and found it again); it now returns the family with that row, as `getDescendantPedigree()` already did. Pinned by `test_walkPedigree.R` (11 tests) and additions to the four existing test files (RED `710677332` and `a29e3a643`; GREEN `302a0cdb8`; a gap test `75832de41` and its fix `a3c8f584f`; REFACTOR `af402927e`): 38 new tests, 64 tests and 137 expectations in the five files; the 19 recording tests, written at the unchanged commit, pin today's rows and row order (including the LabKey function's generation-by-generation order and its first-row-per-id rule); with the four pre-change `R/` files in a scratch copy exactly 7 of the 64 fail (5 delegation tests and the 2 never-stops tests). **Measured, old and new code in one R process, 400 random pedigrees (dangling parents, repeated id rows, shuffled table order, `NA`, absent and repeated ids):** the three set-returning walkers 0 differences (row names included); `getPedDirectRelatives(unrelatedParents = TRUE)` differed in the order of the placeholder records in 259 of 400 (the old loop left `ids` farthest generation first), so the owner chose to keep today's order (a test at `75832de41`, the fix reads the generations in reverse) and the difference is then 0; `getLkDirectAncestors()` 0 differences in values or row order and 679 of 1,200 (3 seeds) in row labels only (the old code re-added already-found ancestors and `rbind()` relabelled rows, for example `112` for the row `11`; the new rows keep the table's labels). Timing, alternating old and new (median of 9): the 3,694-animal `examplePedigree`, 1-2 ms before and after for `getDescendantPedigree()`, `trimPedigree()`, `getProbandPedigree()` and `getPedDirectRelatives()`; a 2,000-generation chain 0.44-0.65 times the old time. |

Open after this closure: **6 ids** (7 minus PED-3; recounted S915: the table has 43 ids, all unique, and the 6 open ones are all
among them, so 37 are closed): NEW-24 (issue #123, tracked) and the 5 undecided constants and HTML builders ids (NEW-18, NEW-19,
NEW-21, NEW-26, NEW-57).

### Decision record 17 (owner decision 2026-10-05, S916) -- the constants, the HTML builders and NEW-24's leftovers

The owner took what was left of the audit at the Phase 0 picker ("PED_GV leftovers") and answered four questions put in plain
words, each with the measurements below, and chose:

- **NEW-21 and NEW-26 (the cut-off numbers):** "Leave, close both" (over "One internal list" and "Document for users").
- **NEW-19 (the relationship names):** "Share one list" (over "Add the check only" and "Leave, close").
- **NEW-18 and NEW-57 (the low-value items):** "Name value labels" (over "Leave, close both" and "Tidy table makers").
- **NEW-24's two leftovers:** "Shared check only" (over "Check and print" and "Leave both").

S916 wrote it down and changed no `R/` file, test or `man/` page. The table above stays the frozen S781 reading.

| id | decided |
|---|---|
| NEW-21 | CLOSED, ACCEPTED, no change: the heat-map cut-off numbers and the `0.015625` kinship default stay where they are. |
| NEW-26 | CLOSED, ACCEPTED, no change: same as NEW-21 (the `digits = 4L` formatter, once, in `makeGeneticSummaryTable()`, stays). |
| NEW-18 | CLOSED, ACCEPTED, no change: the two exported HTML table makers keep their hand-built rows and their "if present, else default" blocks (the app calls neither). |
| NEW-57 | CLOSED, ACCEPTED, no change: `rankSubjects()` and the internal ordering function keep comparing and listing the tier names (`lowVal`, `noParentage`, ...) as text. The owner chose instead to name the three value labels once; that is a new S916 finding, not an audit id (new READY item in `BACKLOG.md`). |
| NEW-19 | DECIDED, STAYS OPEN until it ships: `convertRelationships()` and `makeRelationClassesTable()` read the 11 relationship names from one internal list, with a new test that every name `convertRelationships()` can give appears in the table; no output changes; `markerRealizedRelatednessVariance()` keeps its own 3 names. Work not started; strict TDD, with the owner's approval of the scope at its own gate. New READY item in `BACKLOG.md`. |
| NEW-24 | DECIDED IN PART, STAYS OPEN (issue #123): leftover (1), `getGeneticDiversityStats()` keeping its own `requiredPed` and `requiredGv` checks, switches to the shared `assertRequiredColsPresent()` (the error wording changes); leftover (2), the missing `print` method for genetic-value results, stays open on issue #123 as low priority (the owner did not choose to build it). New READY item in `BACKLOG.md` for (1). |

**Correction to the question text.** S916's first question said each heat-map number is "typed once". Today's code is more
exact: each function holds its own numbers and nothing else repeats them, but within a function some appear twice, in its two
comparisons (below). The answer does not turn on it (no number is typed in two functions), but the record states it as measured.

What S916 measured, for whoever picks up the work (today's code at `c75cfc2aa`, by reading it, greps of `R/`, `tests/`, `inst/`
and `vignettes/`, and the three bounded R probes P13 to P15 below; no test suite was run):

- **Heat-map cut-offs (NEW-21, NEW-26):** four internal functions colour the cells. `R/getProportionLow.R:23,26,29` (Value: over
  0.5 low-value is red, 0.3 to 0.5 yellow, under 0.3 green; 0.5 and 0.3 each appear twice, one caller at
  `R/getGeneticDiversityStats.R:95`), `R/getKinshipWithMaleStatus.R:66,69` (Inbreeding: under 0.6 red, up to 0.9 yellow, over 0.9
  green; stated in its comment `:11-12`), `R/getProductionStatus.R:108-114` (shelter pens 0.63 and 0.6) and `:122-128` (corral 0.53
  and 0.5; each appears twice; stated in its comment `:20-28`) and `R/getIndianOriginStatus.R:36-43` (Origin: counts, no numbers:
  Chinese plus hybrid at least 1 is red, borderline at least 1 yellow). `getProportionLow()` has no comment that states its numbers.
  **No guide, article or vignette gives any of them:** a grep of `inst/extdata/ui_guidance`, `vignettes/*.Rmd`,
  `vignettes/articles/*.qmd` and `vignettes/manual_components` for 30, 50, 60, 63, 90 and 53 with a percent sign or word beside
  heat-map words found nothing, and `vignettes/articles/colony-manager-guide.qmd:676-690` says only "cut-offs that depend on the
  selected Housing type".
- **The `0.015625` kinship default (second cousins, 1/64):** the default in `R/filterThreshold.R:28` and `R/groupAddAssign.R:179`
  (both exported) and `R/getKinshipWithMaleStatus.R:40` (internal; `R/getGeneticDiversityStats.R:103` passes no threshold, so the
  Inbreeding cell uses this default); also written in the help text of two of them (`getKinshipWithMaleStatus.R:31`,
  `groupAddAssign.R:32`), in 3 roxygen examples, and in 6 hand-written guide, article and vignette files
  (`inst/extdata/ui_guidance/group_formation.html:26,76` and `gvAndBgDesc.html:137`, `vignettes/a2interactive.Rmd:887`,
  `vignettes/articles/breeding-group-formation.qmd:112,176`, `vignettes/manual_components/_breeding_group_algorithm.Rmd:52` and
  `_breeding_group_formation.Rmd:167`). `tests/testthat/test_sexCodes.R:75` pins the text of `groupAddAssign()`'s heading line
  `threshold = 0.015625, ignore = list(c("F", "F")),`. A shared constant in an exported heading would, by how roxygen writes usage, put the constant's name where
  `man/filterThreshold.Rd:7` and `man/groupAddAssign.Rd:12` print the number (reasoned from those two lines; not run) and would
  still leave the 6 prose files typing the number. The application's own
  default Max kinship threshold is 0.25 (`_breeding_group_algorithm.Rmd:52`), a different setting.
- **Relationship names (NEW-19):** `R/convertRelationships.R:51,53,56,59,63,69,75,81,85,87,89` assign the 11 names (`Self`,
  `Full-Siblings`, `Parent-Offspring`, `Half-Siblings`, `Grandparent-Grandchild`, `Full-Cousins`, `Cousin - Other`,
  `Full-Avuncular`, `Avuncular - Other`, `Other`, `No Relation`); `R/makeRelationClassesTable.R:38-43` lists the same 11 in display
  order (the app calls it at `R/modSummaryStats.R:432`); `R/markerRealizedRelatednessVariance.R:33-35` uses 3 of them as the names
  of a list of formulas. **P13: a pair named `Full-Sibling` (one letter short) is left out of the table silently** (5 pairs that are
  not `Self` in, 4 in the table): the table keeps only names that are in its own list, so an unlisted name is dropped whatever the
  reason.
  Tests: only `test_convertRelationships.R` names all 11; `test_makeRelationsClasses.R` has 1 test; no test checks that the two
  lists match.
- **HTML builders (NEW-18):** `R/makeGeneticSummaryTable.R` (exported; header plus two near-identical rows by hand, `fmt()` with
  `digits = 4L` at `:57`) and `R/makeFounderStatsTable.R` (exported; 6 "if present, else default" blocks). Neither is called from
  `R/` or the app (issue #37's table says "Not on the app's call path" for both). Tests: `test_makeGeneticSummaryTable.R` (8),
  `test_makeFounderStatsTable.R` (3), `test_modFounderStats.R` (14).
- **Tier names (NEW-57):** `R/rankSubjects.R:51,53,59` compare the list name to `"lowVal"` and `"noParentage"`;
  `R/orderReport.R:131,139` list the five tier names in order; `orderReport()` is internal (callers `R/reportGV.R:336`,
  `R/gvaConvergence.R:215`).
- **Value labels (the new finding):** `"Low Value"`, `"High Value"` and `"Undetermined"` are typed as text in 5 files, 8 lines:
  `R/rankSubjects.R:52,54,56` (assigns them), `R/getGeneticDiversityStats.R:91`, `R/modBreedingGroups.R:548`,
  `R/modGeneticValue.R:385` and `R/summary.nprcgenekeeprErr.R:262,267` (compare them). A ninth site is a substring match:
  `R/getProportionLow.R:21` counts values containing `"Low"`, not the whole label. No file in `inst/` names them. Not measured: what
  the app does when one file's label drifts (no probe was run).
- **NEW-24's leftovers:** `R/getGeneticDiversityStats.R:58-67` keeps two hand-written checks (`requiredPed`, 5 columns, message
  `ped is missing required column(s): dam`; `requiredGv`, 2 columns) while `assertRequiredColsPresent()` (`R/assertRequiredColsPresent.R:19`)
  is used at `R/reportGV.R:181`, `R/qcStudbook.R:373`, `R/gvaConvergence.R:176` and `R/reportMatePairs.R:175`; its message is
  `nprcgenekeepr: required column(s) missing in <where>: <cols>.` with `call. = FALSE`. The only test, `test_getGeneticDiversityStats.R:194-201`,
  matches the column name `dam` and nothing else; none covers a missing `geneticValues` column. **P14:** a list given the class
  `c("list", "nprcgenekeeprGV")` the way `R/reportGV.R:365` does prints in full with an `attr(,"class")` line; the package has
  `summary` and `print.summary` methods for the class but no `print` method.
- **Points for each build's Pre-RED gate:** (NEW-19) the list's name and file; whether `convertRelationships()` takes each name
  from the list by element name or keeps its literals and the new test alone guards the two (the owner chose to share the list);
  keep the exported signatures; the bundled `smallPed` gives all 11 names (P15: 17 `Self`, 19 `Parent-Offspring`, 13 `Grandparent-Grandchild`, 10 `Avuncular - Other`, 7
  `Half-Siblings`, 6 `Full-Avuncular`, 4 `Full-Siblings`, 4 `Other`, 3 `Cousin - Other`, 2 `Full-Cousins`, 68 `No Relation`), so it
  serves as the fixture for the new test. (Value
  labels) the list's name and file (a new file makes 6 files with the 5 edits: two GREEN commits for the 5-file cap); whether
  `getProportionLow()`'s `"Low"` substring match moves to the exact label (a behaviour question, since other `Low...` values would
  stop matching); the first RED is a recording test per file of today's labels and counts. (NEW-24 first leftover) the exported
  function's error wording changes (and the call is no longer in the message); a NEWS line is decided at the gate; the first RED
  records today's two messages and adds a test for a missing `geneticValues` column.

Open after this decision: **2 ids** (4 closed: NEW-18, NEW-21, NEW-26, NEW-57; recounted S916: the table has 43 ids, all unique,
and the 6 open ones before this record are all among them, so 41 are closed): NEW-19 (decided, waits on its build) and NEW-24
(issue #123: its first leftover decided and waiting on a build, its print-method leftover open, low priority).

### Closure record 18 (S918, 2026-10-05) -- decision record 17's NEW-19 shipped

| id | closed because |
|---|---|
| NEW-19 | SHIPPED: one internal list, `relationClassNames` in `R/relationClassNames.R` (`@noRd`, not exported; 11 named elements `self`, `parentOffspring`, `fullSiblings`, `halfSiblings`, `grandparentGrandchild`, `fullCousins`, `cousinOther`, `fullAvuncular`, `avuncularOther`, `other`, `noRelation`, in the table's display order, written like `sexCodes`), is read by `convertRelationships()` (its 11 assignments at `R/convertRelationships.R:51-89` now take each name by element name) and by `makeRelationClassesTable()` (its typed vector of 11 became `unname(relationClassNames)` and its `"Self"` test reads the list too). No output changed: both functions' results were identical to a baseline saved from the unchanged commit, for the bundled `smallPed`, the full `qcPed`, 12-id subsets of each, and both empty-table errors (6 of 6; two baseline runs at the old commit were identical first). `markerRealizedRelatednessVariance()` keeps its own 3 names, as decided. No signature, help page, `NAMESPACE`, `man/` or `NEWS` change. Tests: 4 new in `tests/testthat/test_relationClassNames.R` (the list, its two uses, both functions following a swapped list), 3 recordings added to `test_makeRelationsClasses.R` and 1 to `test_convertRelationships.R`. At RED all 4 new tests errored (no list); with the list present and unread, the two "reads the list" tests failed on assertions (checked in a scratch clone); putting either function back to typed names fails only its own test. Full suite at GREEN: 373 files, 3,081 tests, 0 failed, 0 errors, 187 skipped. S918 found two edge cases it left alone (`BACKLOG.md`): `convertRelationships()` given exactly one id returns a nonsense row (`filterKinMatrix()` has no `drop = FALSE`), and `makeRelationClassesTable()` stops when no non-Self pair is left (recorded as today's behaviour in a test). |

Open after this closure: **1 id** (2 minus NEW-19; recounted S918: the table has 43 ids, all unique, and the 1 open one is among
them, so 42 are closed): NEW-24 (issue #123: its first leftover decided and waiting on a build, its print-method leftover open,
low priority).

### Closure record 19 (S919, 2026-10-06) -- decision record 17's NEW-24 first leftover shipped

| id | closed because |
|---|---|
| NEW-24, first leftover | SHIPPED: `getGeneticDiversityStats()` (`R/getGeneticDiversityStats.R:58-65`) makes its two column checks with the shared `assertRequiredColsPresent()`, in place of its hand-written `requiredPed` and `requiredGv` checks: `names(ped)` against `id`, `dam`, `sex`, `birth`, `exit`, labelled `getGeneticDiversityStats(ped)`, then `names(geneticValues)` against `id`, `value`, labelled `getGeneticDiversityStats(geneticValues)`; the ped is still checked first. The only change for a caller is the wording of the error, from `ped is missing required column(s): dam` to `nprcgenekeepr: required column(s) missing in getGeneticDiversityStats(ped): dam.`, which no longer shows the call; the function stops under exactly the same conditions as before. No signature, help page, `NAMESPACE` or `man/` change; no `NEWS` line (the owner's answer at the REFACTOR gate: `reportGV()`, `qcStudbook()`, `gvaConvergence()` and `reportMatePairs()` moved to the shared check with none). Tests: 6 new in `tests/testthat/test_getGeneticDiversityStats.R` (the shared wording for the ped and for the genetic-value frame, no call on the error, the ped reported before the genetic-value frame, and one recorder test per check that `assertRequiredColsPresent()` is called with the names, the required columns and the label), 16 existing, still green. At RED all 6 failed; after REFACTOR (the file builds its two one-column-short frames once instead of 4 and 4 times, so two existing tests only lost a local copy of one) putting the pre-GREEN function back fails exactly those 6 (11 failed expectations) and passes the 16. Full suite: 373 files, 3,087 tests, 0 errors, 187 skipped, and 2 failed: the wall-clock benchmarks `markerKinship` and `markerParentageLikelihood` while another project's parallel `quarto render` jobs held the machine at a load average of 455; neither file nor the two functions it times mention `getGeneticDiversityStats()` or `assertRequiredColsPresent()`, and both files pass alone (5 and 25 tests) once no render job was left. |

NEW-24 itself **stays open**, as Decision record 17 says: its second leftover, the missing `print` method for genetic-value
results (`reportGV.R:365` appends the class last; there is no bare `print.nprcgenekeeprGV`), stays on issue #123 as low priority,
the owner chose not to build it, and the owner closes the issue. No build waits on it.

Open after this closure: **1 id** (unchanged: leftover (1) shipped, the id stays open; recounted S919: the table, lines 55-99,
has 43 rows and 43 distinct ids, and the 1 open one is among them, so 42 are closed): NEW-24 (issue #123: its first leftover
shipped, its print-method leftover open, low priority, tracked on the issue only). S918's handoff predicted "open count 1 to 0"
for this build; Decision record 17's "STAYS OPEN (issue #123)" and every earlier count (NEW-24 listed as "tracked") say it stays 1.

## Ledger boundary — what the "ledger-absent" list gets wrong both ways

`BACKLOG.md` said the ledger records 22 of the audit's 63 ids, leaving 41. Checking each of the 22
by reading the entry, not just counting hits:

- **19 have a real fix or resolution record:** NEW-12 (S358), 13, 15, 16, 17, 20 (S15 "won't
  delete"; the file was later removed by `5667f9c8`, #112), 22, 23, 25, 30, 34, 37, 40, 45, 46,
  48, 52, 53 (backfilled S779), PED-1.
- **3 do not:** NEW-29 (only an "out of scope" mention), **NEW-47 and NEW-49 (id collision)** —
  the S68, S71, S74 and S80 entries use "NEW-47/48/49" as **NEWS.md entry labels**
  (`getDescendantPedigree`, `setAutoIdFormat`, the gestation window), not the audit's ids. NEW-49 is
  the audit's own refuted candidate, so it needs no action; NEW-29 and NEW-47 are the last two rows
  of the table.
- NEW-61 was on the 41-id list already but is *mentioned* in the ledger (S17, "out of scope").

So an id grep both **under-counts** (Learning 791: NEW-53) and **over-counts** (NEW-47/49 above).

## Structural Observations

1. **The audit's ids never entered the project's commit vocabulary.** 0 of 43 appear in any commit
   message. Fixes travelled under issue numbers and tracker names: PED-9 and NEW-38's mitigation →
   #44/#38; NEW-33 → #31; NEW-20 → #112 slice S1; NEW-24 → #123 (XARCH-5); PED-2 (and NEW-29's
   sex-code part) → XARCH-4's sex-code half (S367); PED-5 and NEW-28 → the same theme as XARCH-6.
   Any reconcile keyed on the audit id misses them; only code plus `git log -S` finds them.
2. **"Confirmed" in the audit is not "correct".** Four of the 43 misdescribed a contract: PED-9's
   ceiling (`sprintf` widens), NEW-44's factor case (`mode()`), NEW-58 (a companion function
   exists by design) and NEW-41's dedup (a test pins the repeats). Each was settled by reading the
   design contract — a callee, a test, a language rule — before calling the shape a defect.
3. **The overhaul roots mostly persist, and one grew.** `getPotentialParents` is 150 lines
   (`:64-213`); the error contract, sex-code adoption and the walk-helper family are unchanged in
   kind. Debt that was not converted into a tracked item did not shrink on its own.
4. **What is app-reachable.** `addUIds` (every QC run) and `removeAutoGenIds` (Potential Parents)
   are; `removeUnknownAnimals` and `cumulateSimKinships` have no internal caller, so their hazards
   reach only script users.
5. **Test gaps:** `rbindFill` has no test file; `getAncestors` has no cycle test;
   `getAnimalsWithHighKinship` is tested only through its five consumers.

## Limits

- **No suite or `devtools::check()` run:** no code changed and every changed file is build-ignored.
- Severity and effort labels are my estimates; F2's real impact depends on the colonies' id schemes.
- Rows without a probe (listed under Method) are structural claims visible in the cited lines;
  NEW-51 ("latent") is a judgment from reading, with no failing input found.
- App reachability was traced by caller grep, not by driving the app.

## Probe transcript (scratch scripts; rerun with `pkgload::load_all()`)

```r
# P1  NEW-31/32
p <- nprcgenekeepr::smallPed                  # 17 rows, no recordStatus column
nrow(removeUnknownAnimals(p))                 # 0
# P2  NEW-41
diamond <- list(A = list(sire = "S", dam = "D"), S = list(sire = "G", dam = NA_character_),
                D = list(sire = "G", dam = NA_character_), G = list(sire = NA_character_, dam = NA_character_))
getAncestors("A", diamond)                    # "S" "G" "D" "G"
cyc <- list(A = list(sire = "B", dam = NA_character_), B = list(sire = "A", dam = NA_character_))
getAncestors("A", cyc)                        # Error: evaluation nested too deeply: infinite recursion
# P3  NEW-38 / PED-9
removeAutoGenIds(data.frame(id = c("Uma","U123","real1","kid1"), sire = NA, dam = c(NA,NA,NA,"real1"),
                            sex = "M", stringsAsFactors = FALSE))$id       # "real1" "kid1"
# a pedigree with a real "U0001" and kid1 (dam known, sire unknown): addUIds gives kid1 sire "U0001"
# 10001 dam-only animals through addUIds: first "U0001", last "U10001", 10001 unique
# P4  NEW-44   mode(factor("a")) "numeric"; mode(list(1)) "list"; rbindFill(list column) -> "list : unknown column type"
# P5  NEW-35   F1 (F, born 2000), M1, K1 (born 2010-01-01, unknown parents), K2 (born 2010-03-01, dam F1)
#      getPotentialParents(ped, 2, 2, maxGestationalPeriod = 210L)  -> K1: sires [M1], dams [F1]
# P6  NEW-59   makeGeneticSummaryTable(data.frame(id = c("a","b")))   -> a table of "N/A" cells
# P7  NEW-14   kinshipMatricesToKValues(list())                       -> Error: object 'kValues' not found
# P8  cycles   qcStudbook(a 2-cycle, reportErrors = TRUE) error list has no cycle category
# P9  PED-8    cyc <- data.frame(id = c("A","B","C"), sire = c("B","A",NA), dam = NA_character_)
#              findGeneration(cyc$id, cyc$sire, cyc$dam)   # NA NA 0, warning naming "A, B"
# P10 PED-5/6, NEW-28/36 (S888): bad input outside QC, then the QC family in both modes
reportGV(data.frame(id = "a"))                              # Error: result would be too long a vector
calcGU(data.frame(x = 1))                                   # Error: dim(X) must have a positive length
calcRetention(data.frame(id = "a"), data.frame(id = "a"))   # Error: undefined columns selected
filterReport("a", data.frame(x = 1))                        # numeric(0), no message
rankSubjects(NULL)                                          # NULL
getGeneticDiversityStats(NULL, NULL, NULL, NULL)            # Error: getGeneticDiversityStats() requires at least one group.
qcStudbook(data.frame(id = "a"), reportErrors = FALSE)      # Error: Required field(s) missing: sire, dam, sex, birth.
qcStudbook(data.frame(id = "a"), reportErrors = TRUE)       # a list of 11 (failedDatabaseConnection, missingColumns, ... changedCols)
checkRequiredCols(c("id","sire","dam","sex"), FALSE)        # Error: Required field(s) missing: birth.
checkRequiredCols(c("id","sire","dam","sex"), TRUE)         # a character(1)
# P11 NEW-28 (S888): reportGV(p, guIter = 10L, guThresh = 3) with each column removed in turn, on the example pipeline
#     (examplePedigree -> qcStudbook(minSireAge = 2, minDamAge = 2) -> setPopulation(focal) -> trimPedigree(probands,
#     removeUninformative = FALSE, addBackParents = FALSE); 704 rows)
#     unmodified: runs. without id: "'dimnames' applied to non-array". without sire or dam: "arguments imply differing number
#     of rows: 704, 0". without gen: "result would be too long a vector". without sex: "nprcgenekeepr: required column(s)
#     missing in reportGV(ped): sex." without birth, exit, age or population: runs.
#     smallPed unmodified, reportGV(smallPed, guIter = 10L): Error: sire and dam must have had alleles assigned: logic error
# P12 PED-3 / NEW-42 (S912): circular data, each call run under setTimeLimit(elapsed = 5)
cyc <- data.frame(id = c("A","B","C"), sire = c("B","A",NA), dam = NA_character_, stringsAsFactors = FALSE)
getProbandPedigree("A", cyc)$id; getDescendantPedigree("A", cyc)$id; getPedDirectRelatives("A", cyc)$id   # "A" "B" each, under 0.1 s
# getLkDirectAncestors(ids = "A") with mockery::stub(f, "getDemographics", function(...) <the 7-column table of cyc>)
#     -> no return: "reached elapsed time limit" at 5.0 s
getParents("C", cyc); getOffspring("C", cyc)    # swapped order: Error: $ operator is invalid for atomic vectors (both)
# P13 NEW-19 (S916): a misspelt relation name is dropped from the table
kin <- data.frame(id1 = letters[1:6], id2 = letters[7:12], kinship = 0.1, stringsAsFactors = FALSE,
                  relation = c("Parent-Offspring", "Full-Siblings", "Full-Siblings", "Full-Sibling", "Self", "No Relation"))
makeRelationClassesTable(kin)    # Parent-Offspring 1, Full-Siblings 2, No Relation 1: 4 rows of the 5 that are not Self
# P14 NEW-24 (S916): the class reportGV() gives, printed
x <- list(report = data.frame(id = "a", value = "High Value"), k = 1); class(x) <- append(class(x), "nprcgenekeeprGV")
class(x)   # "list" "nprcgenekeeprGV"; print(x) shows both list elements and an attr(,"class") line (no print method)
# P15 NEW-19 (S916): which names the bundled smallPed gives
rel <- convertRelationships(kinship(smallPed$id, smallPed$sire, smallPed$dam, smallPed$gen, sparse = FALSE), smallPed)
table(rel$relation)   # all 11 names appear (counts in Decision record 17); setdiff(<the 11>, unique(rel$relation)) is character(0)
```

## Verification

A script extracted every `file.R:line` citation (122 distinct lines) and printed the cited line
from the file at HEAD; each was then compared by eye with the claim it supports. Two citations
pointed at roxygen instead of code (`createSimKinships.R`, `rankSubjects.R`) and were corrected.
The verdicts were counted mechanically from the table: 43 rows, 43 distinct ids, 35 PRESENT +
2 FIXED + 4 MOOT + 2 REFUTED.
