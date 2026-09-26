# PED + GV Audit Triage (Session 781)

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
```

## Verification

A script extracted every `file.R:line` citation (122 distinct lines) and printed the cited line
from the file at HEAD; each was then compared by eye with the claim it supports. Two citations
pointed at roxygen instead of code (`createSimKinships.R`, `rankSubjects.R`) and were corrected.
The verdicts were counted mechanically from the table: 43 rows, 43 distinct ids, 35 PRESENT +
2 FIXED + 4 MOOT + 2 REFUTED.
