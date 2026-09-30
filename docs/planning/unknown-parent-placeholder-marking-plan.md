## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Plan — Mark unknown-parent placeholder ids when they are made

**Session:** S806 (2026-09-28) · **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
(planning session, `SESSION_RUNNER.md` §Planning Sessions) · **Type:** plan — **zero `R/`,
`tests/`, `man/` or data changes this session.** Each §5 slice is its own strict-TDD session,
gated on the §11 decisions.

**Backlog item:** `BACKLOG.md` "Real animal ids that start with the placeholder prefix (`"Uma"`,
`"U123"`) are treated as stand-ins for unknown parents -- the other half of PED_GV F2 / NEW-38".
**Audit source:** `docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md` NEW-38 row and §F2.

---

## 1. Context

### 1.1 The problem, in plain words

When a pedigree has an animal with only one known parent, the package makes up an id for the
missing parent (`U0001`, `U0002`, ...) and adds a row for it. Later, many parts of the package
need to tell these made-up animals apart from real ones. Today they do it by looking at the id
alone: **any id that starts with the prefix (default `"U"`) is treated as made up**
(`R/autoIdFormat.R:109-111`). So a real animal whose id starts with `U` is:

- left out of the founder counts (`reportGV()`),
- dropped from the Potential Parents search (`removeAutoGenIds()`),
- hidden when "Display Unknown IDs" is unticked (Pedigree Browser),
- skipped as a breeder in the effective-size estimates (`getLivingBreeders()`),
- and its offspring are labelled as having an unknown parent (`classifyParentage()`,
  `correctUnknownParentMeanKinship()`).

This already happens in shipped data: `U1` in `inst/extdata/examples/example_ancestry_pedigree.csv`
is a real founder female (row 9, blank ancestry), and today the example reports **3** female
founders instead of **4** (§1.3, M3).

### 1.2 Already decided (do not re-litigate)

- **S797:** `addUIds()` already skips any candidate id that is already in the pedigree (the
  collision half of F2, shipped). The "remainder must be exactly 4 digits" rule was tried and
  withdrawn: it broke 24 tests and caused 1 error in 7 files, because the shipped data's placeholders look like
  `U05X3C` (`obfuscateId()` output), not `U0001` (`git show a01e13af` has the withdrawn tests).
- **S806, owner (AskUserQuestion):** of the four options in the backlog item, **"Mark ids when
  they are made"**: record which ids the package made, instead of guessing from an id's shape.
  The owner chose it knowing it is the biggest change and that the shipped example files hold
  their placeholders as plain values.
- **S806, owner (AskUserQuestion):** this session writes the plan; building starts in a later
  session, one tested slice at a time.

### 1.3 Measured this session (S806)

Scratch scripts, not committed. Every number below was printed by a run in this session.

| # | Measurement | Result |
|---|---|---|
| M1 | Shape of every `U`-leading id in every shipped dataset with an `id` column (5 of them hold `U` ids) and the 8 pedigree example files that hold `U` ids (`inst/extdata/examples/`) | 1,470 distinct ids (4,312 counted per source). All but one are **`U` + 4 or 5 capital letters/digits**: `U0001`-style in `ped1Alleles` (43); `U05X3C`-style in `examplePedigree`/`ExamplePedigree.csv`/`.txt` (1,372), `qcPed`/`pedWithGenotype` (43), `rhesusPedigree` and the 5 `obfuscated_rhesus_mhc_ped*`/`rhesusPedigree_fromCenter` files (11 each). The exception is the real `U1` (M3). |
| M2 | A **tighter rule** — `U` followed by at least as many capital letters/digits as the format makes (4 for `"U%04d"`) — over the same ids | Changes the verdict for exactly **one** id, `U1`. Full-suite trial with the rule patched in (namespace swap, `NOT_CRAN=true`): 357 files, 2,790 tests, **3 tests moved** — `test_autoIdFormat.R` (pins `"U123"` as a placeholder), `test_modPedigree.R` "filters unknown IDs correctly" (uses `"U1"`/`"U2"` as placeholders), `test_obfuscateId.R` "only uppercase-U ids get U-aliases" (errors on `"U123"`: its alias can no longer be made to match) — plus the known local-only `test_pkgdown_reference_config.R` failure. |
| M3 | Today's behaviour on real `U` ids | Ancestry example after `qcStudbook()`: `removeAutoGenIds()` drops `U1`; `reportGV()` female founders `C2 I2 J2` (3; `U1` missing); `obfuscateId()` gives `U1` a `U`-shaped alias. Hand-built pedigree (real `Uma` F, `U123` M; `K1` = `U123` x `Uma`; `K3` = `R1` x `Uma`): `classifyParentage()` says `K1` "both unknown", `K3` "one unknown parent"; `getLivingBreeders()` returns `R1 R2` only; `reportGV()` founders F `R2`, M `R1`. |
| M4 | Can `recordStatus` carry the mark? | **No.** `addParents()` rebuilds it on every run (`R/addParents.R:43-44`): a placeholder row is `"added"` after one `qcStudbook()`, `"original"` after a second. Uploading `ExamplePedigree.csv` gives its 1,372 `U` rows `"original"`, and 0 new ids are made (the file already holds them as rows). |
| M5 | Can an R attribute carry the mark? | **No.** A data-frame attribute survives row subsetting, a new column and `rbind()`, but is lost by `merge()` and by a CSV save and reload. |
| M6 | Can a column carry the mark? | **Yes.** A logical column survives `write.csv()` → `getPedigree()` (read back as logical) → `qcStudbook()` (kept as a novel column, `R/qcStudbook.R:324-325`), `trimPedigree()` and `obfuscatePed()`. `fixColumnNames()` lowercases names and strips `_`/`.`, so `unknownId` and `unknown_id` both arrive as `unknownid`; a lowercase name (`placeholder`) arrives unchanged. `bindPedigreeRows()` (cross-center merge) fills the column with `NA` for rows from a file that lacks it. |
| M7 | Which pedigree do downstream modules get? | The Pedigree Browser's **filtered** one (`R/appServer.R:312`, `shared$currentPedigree <- pedigreeResults$pedigree()`), passed to Genetic Value (`:330-332`), Potential Parents (`:500-502`) and the rest. With "Display Unknown IDs" unticked, placeholder rows are removed but children still name them as sire/dam: on `qcPed`, 280 → 237 rows, 43 children name a removed placeholder. |
| M8 | What does the filtered state do today? | `calcNeVariance()` is unchanged (26.41, the value-based rule still works); **`reportGV()` stops** with "sire and dam must have had alleles assigned: logic error", also after the Genetic Value module's own steps (`population <- is.na(exit)`, `trimPedigree(..., removeUninformative = FALSE, addBackParents = FALSE)`: 236 rows, 43 naming a removed row); ticked, the same steps run. A pre-existing defect, not in scope: §10 and its own `BACKLOG.md` item. |
| M9 | `obfuscatePed()` on a real `U` id | `Uma`'s alias is `U`-shaped (`UJU2UX`), so after de-identification the id-shape rule would still misread it. |
| M10 | Adding a `placeholder` column to every `qcStudbook()` result, alone (trial) | **1 test moves** (§1.4). |
| M11 | Does `addUIds()` avoid every id already in use? | **No.** `existingIds <- ped$id` (`R/addUIds.R:46`) leaves out sire/dam values that have no row. Pedigree `K1` (sire `U0001`, no `U0001` row), `K2` (no sire), dam `D1` for both: `addUIds()` gives `K2` the sire `U0001` too, and `qcStudbook()` then shows `K1` and `K2` as paternal half-sibs through one made-up sire. |

### 1.4 M10 — what adding the column alone moves

Trial: `qcStudbook()` wrapped so that its result gains a last column `placeholder` (set by today's
prefix rule), swapped into the namespace and the attached package environment, then the full suite
(`NOT_CRAN=true`): 357 files, 2,790 tests, 3 failed, 0 errors.

- **Real move (1):** `tests/testthat/test_qcStudbook.R:105` "qcStudbook corrects column names" pins
  the output columns with `expect_named()`; Slice 2 adds `placeholder` to that pin.
- **Trial artifact (1):** `test_qcStudbook.R:443` ("line-316 guard fires on a contrived internal
  fault") uses `mockery::stub(qcStudbook, "removeDuplicates", ...)`, which stubbed the wrapper, not
  the real function, so the fault was never injected. It will not move in Slice 2.
- **Known local-only failure (1):** `test_pkgdown_reference_config.R` (the owner's untracked
  `vignettes/suggested_NEWS_entry.Rmd`).

So the column alone is cheap: no module test, no shipped-data pin and no e2e test compares the
full column set of a QC'd pedigree. The trial does not cover Slice 2's other changes (reading the
mark, validation).

---

## 2. Evidence-based inventory

Commands (run from the repo root; re-run them at the start of each slice, since line numbers
drift):

```sh
grep -rn 'isGeneratedUnknownId\|getAutoIdPrefix' R/
grep -rn 'addUIds(\|addParents(' R/
grep -rn 'removeAutoGenIds(\|classifyParentage(\|getLivingBreeders(\|correctUnknownParentMeanKinship(\|obfuscateId(\|obfuscatePed(' R/
grep -n 'downloadHandler' R/*.R
grep -rniE 'unknown ids?|U0001|placeholder id|setAutoIdFormat|removeAutoGenIds' inst/extdata/ui_guidance vignettes NEWS.Rmd
grep -lE 'isGeneratedUnknownId|removeAutoGenIds|classifyParentage|getLivingBreeders|correctUnknownParentMeanKinship|obfuscateId\(|obfuscatePed\(|addUIds\(|displayUnknownIds|setAutoIdFormat|getAutoIdFormat' tests/testthat/*.R
```

### 2.1 Where ids are made and rows added

| File:line | Role | Exported | Change |
|---|---|---|---|
| `R/qcStudbook.R:231` | `sb <- addUIds(sb)` — the only production call | yes | Slice 2: note the ids made here |
| `R/qcStudbook.R:232` | `sb <- addParents(sb)` — adds rows for every parent without one | yes | Slice 2: write the mark after this |
| `R/qcStudbook.R:324-325` | keeps novel columns after the known ones | — | none (M6) |
| `R/addUIds.R:43-63`, `:79-92` | fills missing sire/dam with made-up ids; skips existing ids | yes | none (its return value is unchanged, D2) |
| `R/addParents.R:43-61` | rebuilds `recordStatus` from scratch | yes | none (D9) |
| `R/fixColumnNames.R:60-61` | the `recordstatus` → `recordStatus` mapping line | — | only if D1 picks a camelCase name |
| `R/columnSchema.R:19-23` | `possible` column list (pinned exactly by `test_getPossibleCols.R`) | — | D1: decide whether the new column joins it |
| `R/headerDisplayNames.R:54` | table header names (`recordStatus = "Original/ Added"`) | — | Slice 4: a display name for the new column |

### 2.2 Where ids are read (the 7 files that call the predicate, and their callers)

| File:line | What it does with a placeholder | Has the pedigree? | Upstream callers |
|---|---|---|---|
| `R/autoIdFormat.R:90`, `:109-111` | `getAutoIdPrefix()`, `isGeneratedUnknownId()` — the single rule | — | all below |
| `R/removeAutoGenIds.R:22-25` | drops placeholder rows, blanks placeholder sire/dam (exported) | yes | `R/getPotentialParents.R:98` |
| `R/getLivingBreeders.R:18`, `:26` | excludes placeholder parents from breeders | yes | `R/calcNeSexRatio.R:52`, `R/calcNeVariance.R:57` |
| `R/reportGV.R:283-286` | excludes placeholders from male/female founders | yes | Genetic Value module |
| `R/classifyParentage.R:20-21` | placeholder or `NA` parent = unknown | **no — sire/dam vectors only** | `R/reportGV.R:292`, `R/gvaConvergence.R:175` (both have `ped`; `demographics <- ped[probands, ...]` at `R/reportGV.R:255`, `R/gvaConvergence.R:174`) |
| `R/correctUnknownParentMeanKinship.R:134`, `:155` | one-unknown-parent correction | yes | `R/reportGV.R:196`, `R/gvaConvergence.R:163` |
| `R/obfuscateId.R:28`, `:34-56` | placeholders get prefix-shaped aliases; real ids must not (exported) | **no — ids only** | `R/obfuscatePed.R:43` |
| `R/modPedigree.R:359-361` | "Display Unknown IDs" filter | yes | the filtered result feeds every downstream module (M7) |

No other production code tests an id's first letter (`grep -rnE 'startsWith\([^)]*"U"|\^U' R/` finds
none).

### 2.3 Where a pedigree is saved (the mark must survive these)

| File:line | Export | Source |
|---|---|---|
| `R/modInput.R:671-675` | "cleaned studbook" CSV | `qcResults()$cleaned` |
| `R/modPedigree.R:843-850` | Pedigree Browser export | `pedigreeData()` (filtered) |
| `R/modDeidentifiedExport.R:294-300` | de-identified pedigree | `obfuscatePed()` result |
| `R/modCrossCenterIdentity.R:380-384` | merged pedigree | `resolveCrossCenterIds()` → `bindPedigreeRows()` (`R/resolveCrossCenterIds.R:17-26`, NA-fills missing columns) |

### 2.4 Shipped data (M1)

Datasets: `examplePedigree` (has `recordStatus`), `qcPed`, `pedWithGenotype`, `rhesusPedigree`,
`ped1Alleles` (an allele table with an `id` column, not a pedigree). Example files:
`ExamplePedigree.csv`/`.txt`, `obfuscated_rhesus_mhc_ped.csv` (+ `_affected`, `_name`,
`_twins`), `rhesusPedigree_fromCenter.csv`, `example_ancestry_pedigree.csv` (the real `U1`).
Builders: `data-raw/examplePedigree.R`, `data-raw/ExamplePedigree_txt.R`,
`data-raw/rhesusPedigree.R`, `data-raw/obfuscated_rhesus_mhc_ped_{affected,name}.R`; `qcPed`
and `pedWithGenotype` have no builder script. The base rhesus CSV is read by about 20 test files
(`data-raw/obfuscated_rhesus_mhc_ped_affected.R:28`).

### 2.5 Documentation that describes the rule

`R/modPedigree.R:110-112` (app help text: "by default beginning with a capital U");
`vignettes/manual_components/_pedigree_browser.Rmd:38`;
`vignettes/articles/colony-manager-guide.qmd:254-266`;
`vignettes/articles/studbook-quality-control.qmd:109`;
`inst/extdata/ui_guidance/summary_stats.html:10-11`; the roxygen of `addUIds()`,
`removeAutoGenIds()`, `getAutoIdFormat()`, `setAutoIdFormat()`, `isGeneratedUnknownId()`,
`classifyParentage()`, `obfuscateId()`; `NEWS.Rmd:498` (the existing stand-in-id entry).

### 2.6 Tests that touch the rule (27 files)

`test_addUIds.R`, `test_autoIdFormat.R`, `test_calcNeSexRatio.R`, `test_calcNeVariance.R`,
`test_classifyParentage.R`, `test_correctUnknownParentMeanKinship.R`,
`test_examplePedigreeFixtures.R`, `test_getLivingBreeders.R`,
`test_gvaConvergence_kinshipOverrides.R`, `test_mapIdsToObfuscated.R`,
`test_markerParentageLikelihood.R`, `test_modDeidentifiedExport.R`, `test_modMarkerGenetics.R`,
`test_modPedigree.R`, `test_modPedigree_coverage.R`, `test_modPedigree_processing.R`,
`test_modPedigree_twinRelations.R`, `test_obfuscateGenomicROH.R`,
`test_obfuscateGenotypeMatrix.R`, `test_obfuscateId.R`, `test_obfuscateLdBlocks.R`,
`test_obfuscateMhcHaplotypes.R`, `test_obfuscatePed.R`, `test_obfuscateTwinRelations.R`,
`test_removeAutoGenIds.R`, `test_reportGV.R`, `test-e2e-marker-genetics-genomic-roh-module.R`.
Plus the 12 ancestry-example readers (`grep -ln example_ancestry_pedigree tests/testthat/*.R`);
none of them moved in the M2 trial, where `U1` became a real animal.

---

## 3. Design decisions

Each decision states a recommendation. §11 lists the ones that need the owner's answer before
Slice 1.

**D1 — Where the mark lives: a logical column on each pedigree row.** `TRUE` = this row is a
made-up animal standing in for an unknown parent; `FALSE` = a real animal. Not `recordStatus`
(M4), not an attribute (M5). **Name — owner decision.** Recommended: **`placeholder`** —
lowercase, so `fixColumnNames()` passes it through with no new mapping line (M6), and it matches
the roxygen's own word ("Add placeholder IDs for unknown parents"). Alternative: `unknownId`,
which matches the app's "Unknown IDs" label but needs a mapping line like `recordStatus`'s
(`R/fixColumnNames.R:60`). Either name avoids the substrings `fixColumnNames()` rewrites
(`ego`, `egoid`, `sireid`, `damid`, `birthdate`, `deathdate`). Keep it out of `possible`
(`R/columnSchema.R`) unless the owner wants it listed: as a novel column it lands last and no
column-order pin moves.

**D2 — When the mark is written: once, by `qcStudbook()`, for every row.** After
`addUIds()`/`addParents()` (`R/qcStudbook.R:231-232`):

1. a row whose id was made in this run → `TRUE` (the made ids are the sire/dam values
   `addUIds()` introduced — true only once `addUIds()` also skips ids already used as a sire or
   dam, dragon 7; Slice 2 fixes that first);
2. otherwise, a row whose input already had the column with `TRUE`/`FALSE` → keep that value (so
   a saved and re-uploaded file keeps its marks, and a center can mark a real `U1234` as
   `FALSE` in its own file);
3. otherwise (column absent, or `NA`) → the fallback rule's verdict (D3).

So every pedigree that has been through `qcStudbook()` has a complete column (no `NA`), and
everything downstream can trust it. `addUIds()` keeps its return value (it cannot mark rows that
do not exist yet, and `addParents()` would reset anything it wrote into `recordStatus`); a
script that calls `addUIds()`/`addParents()` directly gets no column, and consumers use the
fallback.

**D3 — The fallback rule, for pedigrees without the mark — owner decision.** It is used (a) by
`qcStudbook()` for input rows with no mark (D2 step 3), which covers every shipped example file
and every file saved by an earlier version, and (b) by consumers given a pedigree that never went
through `qcStudbook()`, or a sire/dam that has no row (D4). Options:

- **(a) Today's rule** — anything starting with the prefix. No shipped result changes; `U1` in the
  ancestry example stays misread unless that one file gets a `placeholder` column (D6 (c)).
- **(b) The tighter rule (recommended)** — the prefix followed by at least *W* capital letters or
  digits, *W* = the width the format makes (`nchar(sprintf(format, 1L)) - nchar(prefix)`, 4 for
  `"U%04d"`). `U1`, `U123`, `Uma` read as real; a real id shaped like `U1234` or `UAB12` is still
  misread unless the center marks it `FALSE`. Measured: only `U1` changes in the shipped data, 3
  tests move (M2). It is also the smallest useful change on its own, so it can ship first
  (Slice 1).

A custom format with a suffix (e.g. `"U%04d-x"`) is allowed by `setAutoIdFormat()`; rule (b) must
still recognize everything `addUIds()` makes. Slice 1 pins that with a test.

**D4 — How consumers read the mark: one predicate that is given the pedigree.**
`isGeneratedUnknownId(id, format = getAutoIdFormat(), ped = NULL)` (internal): when `ped` has the
column, an id that has a row in `ped` answers with that row's mark; an id with no row (a sire/dam
whose placeholder row was filtered away, M7) or an `NA` mark answers with the fallback rule; `NA`
id → `NA`, as now. Every consumer that has the pedigree passes it. `classifyParentage()` gains an
optional `ped` argument (internal function, so no API change); `obfuscateId()` gains an optional
`placeholder` logical vector (exported, additive, `NULL` = fallback), which `obfuscatePed()`
fills from the column.

**D5 — Bad values in a user's column — owner decision.** Recommended: `TRUE`/`FALSE` (as
`getPedigree()` reads them, M6) and blank/`NA` are accepted; anything else stops QC with a
message naming the rows, reported the same way as invalid ids and dates (a new `errorLst` entry
in the QC report). Alternative: treat anything else as blank and fall back silently.

**D6 — Shipped data — owner decision.** Options: **(a) leave it unmarked (recommended)** — D2 step
3 marks the placeholders on upload through the fallback rule, and no fixture, column count or
pinned number moves; (b) add the column to all 5 datasets and 8 files — every placeholder is then
marked, not inferred, but the base rhesus CSV alone is read by about 20 test files, so column-count
pins move; (c) add it only to `example_ancestry_pedigree.csv` (`U1 = FALSE`) — the one file where
the fallback is wrong, needed only if D3 = (a).

**D7 — App display.** The "Display Unknown IDs" filter (`R/modPedigree.R:361`) uses the mark; the
Pedigree Browser shows the column with a display name (`R/headerDisplayNames.R`); the help text
(`R/modPedigree.R:110-112`) and the manual/guide wording (§2.5) say what the mark is and how to
change it. Downstream wiring (`R/appServer.R:312`) is unchanged.

**D8 — Exports.** Every export in §2.3 writes the data frame as is, so the column rides along.
Each slice that touches an export pins the round trip: export → re-upload → `qcStudbook()` → the
same marks. The cross-center merge NA-fills the unmarked side, and D2 step 3 then marks it by the
fallback rule.

**D9 — Unchanged.** `recordStatus`, `addParents()`, `addUIds()`'s return value (apart from the
dragon 7 fix),
`removeAutoGenIds()`'s signature, `getAutoIdFormat()`/`setAutoIdFormat()`, the downstream module
wiring.

---

## 4. Interface catalog (proposed; built by the slices, not this session)

| Interface | Input | Output | Errors |
|---|---|---|---|
| `qcStudbook(sb, ...)` (exported) | as now; an optional `placeholder` column | as now **plus** `placeholder` (logical, no `NA`) | D5: a non-logical `placeholder` value → QC error listing the rows |
| `isGeneratedUnknownId(id, format, ped = NULL)` (internal) | ids; optional pedigree | logical, `NA` for `NA` id | none |
| `.placeholderShape(id, format)` (internal; D3 rule) | ids | logical | none |
| `classifyParentage(sire, dam, ped = NULL)` (internal) | as now + optional pedigree | as now | none |
| `obfuscateId(id, size, existingIds, placeholder = NULL)` (exported, additive) | as now + optional logical vector, length of `id` | as now | `placeholder` of the wrong length → error; under D3 (b), a `size` too short to make a recognizable placeholder alias → the existing "too short" stop, with a clearer message |
| `removeAutoGenIds(ped)`, `getLivingBreeders(ped)`, `reportGV(ped, ...)`, `correctUnknownParentMeanKinship(...)`, `getPotentialParents(ped, ...)` | unchanged | unchanged shape; values follow the mark | unchanged |

---

## 5. Implementation plan — vertical slices (each its own session)

Every slice: strict TDD (RED → GREEN → REFACTOR, each gate an `AskUserQuestion`); the 5-file
per-commit cap; lint on touched `.R` files; the full unfiltered suite (`CLAUDE.md` "Clean regression
read") before close-out; `devtools::check()` where `R/` or `man/` changed. **Surface for every
slice:** local `testthat` with `NOT_CRAN=true`, the real Shiny module servers through
`shiny::testServer()` where a module is named, then GitHub Actions R-CMD-check (5 legs). **What
these surfaces cannot show:** whether any center's real ids look like `U` + 4 capitals/digits (the
owner knows; no data here), and the live LabKey path (no server; the LabKey-sourced pedigree only
reaches the mark through `qcStudbook()`, which is covered locally).

### Slice 1 — The tighter fallback rule (only if D3 = (b))

- **Change:** `isGeneratedUnknownId()` uses the D3 (b) rule (`R/autoIdFormat.R:109-111`); a
  suffix-format test; `obfuscateId()`'s placeholder alias is at least *W* characters long, or
  stops with a message that names the minimum size; the 3 tests of M2 updated.
- **RED tests:** `U1`, `U123`, `Uma` are real; `U0001`, `U05X3C` and a custom format's own ids are
  placeholders; the ancestry example reports 4 female founders and `removeAutoGenIds()` keeps
  `U1`; the hand-built pedigree of M3 gives `K1` "known", `K3` "known", and `getLivingBreeders()`
  includes `Uma` and `U123`.
- **DONE:** those pass; the full suite shows only the M2 moves, updated; `NEWS.Rmd` entry
  (release-state wording, plain language); roxygen of `isGeneratedUnknownId()`/`removeAutoGenIds()`
  and the app help text say what counts as a placeholder.
- **Verify:** `Rscript -e 'Sys.setenv(NOT_CRAN="true"); pkgload::load_all("."); testthat::test_file("tests/testthat/test_autoIdFormat.R")'`,
  then the full suite; `lintr::lint_package()` on touched files.
- **Session boundary:** one session. Close out.
- **DONE S807** (RED `9b8431dd`, `9dd49380`; GREEN `aeccac96`; docs `9e89cd3d`, `32cae6cc`,
  `93640b3f`). Beyond the list above, by the S807 decisions D10/D11 (§11): `getAutoIdWidth()`
  (internal, `R/autoIdFormat.R`) gives *W*; `setAutoIdFormat()` refuses a format whose probe ids
  fail the rule; `obfuscateId()` makes placeholder aliases `max(size, prefix + W)` long. The
  manual's "Display Unknown IDs" line (`_pedigree_browser.Rmd:38`, a §2.5 document) already
  states the new rule; Slice 4 adds the column to it.

### Slice 2 — QC writes the mark; Potential Parents trusts it

- **Change:** first, `addUIds()` also skips ids used as a sire or dam (M11, `R/addUIds.R:46`); then
  `qcStudbook()` writes `placeholder` (D2) and validates it (D5); the predicate takes `ped` (D4);
  `removeAutoGenIds()` passes it; D1's name mapping if needed.
- **RED tests:** the M11 pedigree gets a new id for `K2`'s sire, not `U0001`; QC of a pedigree
  with one-parent animals marks exactly the made rows `TRUE`;
  re-QC keeps every mark (the M4 trap); a file with a `U1234` row marked `FALSE` keeps it as a real
  animal through QC and `removeAutoGenIds()`; a file with no column (e.g. `ExamplePedigree.csv`)
  gets marks from the fallback rule, and `getPotentialParents()` on `qcStudbook(examplePedigree)` still
  returns 1,587 (`tests/testthat/test_getPotentialParents.R:452`); an invalid value is reported (D5); through `modInputServer` →
  `modPotentialParentsServer` (`testServer`), the real `U1234` is kept.
- **DONE:** those pass; the M10 move (`test_qcStudbook.R:105`, §1.4) updated; full suite clean.
- **Session boundary:** one session. Close out.
- **DONE S808** (RED `98720bf2`, `b6f050a1`, `84382fa1`; GREEN `bac494e0`, `410273d5`, `9a4dee7c`, lint `cd19fbab`; docs `ec2c4d14`, `d830034e`, `34fcc801`, `ef91c4b1`, `904d9ff2`). Beyond the list above, by D12/D13 (§11): `getPotentialParents()` runs `removeAutoGenIds()` before it sets aside animals with no birth date; the column accepts TRUE/FALSE spellings, 1/0 and blank, and any other value stops QC (`errorLst$invalidPlaceholderRows`, the 11th field). Not done, left for Slices 3-4: the other readers (`reportGV()`, `classifyParentage()`, `correctUnknownParentMeanKinship()`, `getLivingBreeders()`, the "Display Unknown IDs" filter) still use the id shape.

### Slice 3 — Genetic value and effective size read the mark

- **Change:** `reportGV()` founders, `classifyParentage(ped =)`, `correctUnknownParentMeanKinship()`,
  `gvaConvergence()`, `getLivingBreeders()` (→ `calcNeSexRatio()`/`calcNeVariance()`) pass `ped`.
- **RED tests:** a marked real `U1234` founder is counted and its offspring are "known"; a sire/dam
  whose placeholder row was removed still counts as unknown (D4, M7); every shipped-data number
  pinned today (e.g. `qcPed`'s `calcNeVariance()` 26.405868, `tests/testthat/test_calcNeVariance.R:146`)
  is unchanged; `modGeneticValueServer`
  (`testServer`) on a marked pedigree.
- **DONE / boundary:** as above; one session.
- **DONE S809** (RED `deb75ec4f`; GREEN `03c455a73`, `4802843c6`). `classifyParentage(sire, dam, ped = NULL)`; `getLivingBreeders()`, `correctUnknownParentMeanKinship()` (whole `ped`, not the proband subset), `reportGV()` (founders, parentage) and `gvaConvergence()` (parentage) pass `ped`. An id with no row in `ped` is read by shape (D4). Tests: `tests/testthat/test_placeholderMarkReaders.R`. Not done, left for Slice 4: the "Display Unknown IDs" filter.

### Slice 4 — App display, exports and help

- **Change:** the "Display Unknown IDs" filter uses the mark; the column's display name; the
  help text and §2.5 documents (tutorial/article checklist: `colony-manager-guide.qmd`,
  `_pedigree_browser.Rmd`); `summary_stats.html`.
- **RED tests:** the filter hides marked rows only (a real `U1` stays); round trips of the
  "cleaned studbook" and Pedigree Browser exports keep the marks (D8).
- **DONE:** those pass; the `NEWS.Rmd` entry updated to its finished state; the shiny_app_use
  screenshots that show the Pedigree Browser table are noted for the documentation audit if the new
  column appears in them.
- **DONE S810** (RED `056bceda4`; GREEN `83dbbee34`). The filter passes `ped`; `headerDisplayNames()` maps `placeholder` to "Generated Unknown ID"; help text, `_pedigree_browser.Rmd`, `colony-manager-guide.qmd` and `NEWS.Rmd` updated. Tests: `tests/testthat/test_placeholderMarkDisplay.R` (5 failing before, 5 guards incl. both export round trips, which already passed because the column rides along). `summary_stats.html` describes founders, not the id rule, so it needed no change. No screenshot shows the new column (the browser table already displayed it raw), noted for the documentation audit.
- **Session boundary:** one session. Close out.

### Slice 5 — De-identification and cross-center merge

- **Change:** `obfuscateId(placeholder =)`; `obfuscatePed()` passes the column, so a real `U` id
  gets a non-placeholder alias (M9) and the column survives de-identification.
- **RED tests:** `obfuscatePed()` of a pedigree with a real `U1234` (marked `FALSE`) gives it an
  alias the fallback rule reads as real, and keeps `placeholder`; the de-identified export round
  trip (`modDeidentifiedExport`); a cross-center merge of one marked and one unmarked file, then
  QC, marks both sides (D8).
- **DONE:** those pass; `BACKLOG.md` item removed and recorded in `CHANGELOG.md`; the PED_GV
  triage F2 / NEW-38 marked done in the backlog's PED_GV item; the `a2interactive` note for the
  new `obfuscateId()` parameter (deferred pass, `CLAUDE.md`).
- **DONE S811** (RED `6de83f4d8`; GREEN `665e9c475`). `obfuscateId(placeholder = NULL)` (a stand-in gets a stand-in-shaped alias, a real animal a real-shaped one, NA/NULL by shape; a non-logical or wrong-length vector stops); `obfuscatePed()` passes the column; `resolveCrossCenterIds()` resolves a linked pair's mark by the owner's S811 rule (real wins, two stand-ins stay one, a mark on one side is kept, no error on disagreement; before, a one-sided mark was blanked and a disagreement stopped the merge). Tests: `tests/testthat/test_placeholderMarkDeidMerge.R` (11 failing before, 7 guards incl. the de-identified export round trip, which already passed because the column rides along). `checkCrossCenterMapping()` reports only sire/dam conflicts and is unchanged. The `a2interactive` note is carried in `BACKLOG.md`'s deferred-pass item.
- **Session boundary:** one session. Close out.

**Order:** 1 → 2 → 3 → 4 → 5. Slice 1 stands alone and fixes the reported cases for every
pedigree, marked or not; Slices 2-5 make the answer exact for QC'd pedigrees. If D3 = (a), skip
Slice 1 and do D6 (c) inside Slice 2.

---

## 6. Impact analysis

| Area | Changes | Does not change |
|---|---|---|
| `qcStudbook()` output | one new logical column (Slice 2) | row count, order, every other column |
| Results on shipped data | under D3 (b): the ancestry example's founder counts (`U1` counted) | every other shipped result (M1, M2) |
| Results on a center's data | a real animal whose id starts with `U` is counted as real (Slice 1 for ids like `U1`/`Uma`; Slices 2-5 for any id the center marks `FALSE`) | results for colonies whose ids never start with the prefix |
| Exported API | `obfuscateId()` gains an optional argument (Slice 5) | every other signature |
| Saved files | new exports carry `placeholder`; old files still load (fallback) | the file formats the app reads |

**Might break:** tests that compare `qcStudbook()` output column names or counts (M10: 1 test); `write.csv` exports that downstream spreadsheets expect to have a fixed set of columns
(the column is appended last).

---

## 7. Here be dragons

1. **`recordStatus` is rebuilt on every QC run** (M4). Never derive the mark from it.
2. **The downstream pedigree is the filtered one** (M7). A mark kept only on placeholder rows is
   lost for children whose placeholder parent was filtered away; D4's "no row → fallback" is
   what keeps them unknown. Do not "fix" this by reading `shared$currentStudbook` in one module
   only; that forks what different tabs see.
   *(S814: no longer true for the "Display Unknown IDs" box. It now filters only the Pedigree
   Browser table, and the other tabs get `modPedigreeServer()`'s `analysisPedigree`, which keeps
   every row; D4's fallback still covers an id with no row.)*
3. **`fixColumnNames()` lowercases and strips `_` and `.`**, and rewrites `ego` → `id` anywhere
   in a name (M6, `R/fixColumnNames.R`). A camelCase name needs a mapping line.
4. **`obfuscateId()` insists** that an alias and its source are both placeholders or both real
   (`R/obfuscateId.R:53-57`); under D3 (b) a short `size` can never satisfy it for a placeholder
   (M2's `test_obfuscateId.R` error).
5. **The negative-subscript trap** from the `isAddedRecord()` backlog item applies to any new
   `ped[-which(mark), ]`: an empty index drops every row. Use logical subsetting.
6. **`classifyParentage()` sees only sire/dam vectors today**; both callers must pass `ped`, or
   the offspring of a marked real `U` parent stay "unknown".
7. **`addUIds()` can reuse a recorded parent's id** (M11) when that parent has no row, merging a
   real parent with a made-up one. D2's "made in this run" set is wrong until this is fixed, so it
   is Slice 2's first change.

---

## 8. Alternatives considered

| Alternative | For | Against | Outcome |
|---|---|---|---|
| Id shape only, exact digits (S797) | no new column | broke 24 tests; shipped placeholders are not digit-only | withdrawn S797 |
| Id shape only, tighter rule (D3 (b)) | 3 tests move; fixes `U1`/`U123`/`Uma` | still guesses; `U1234`-shaped real ids misread | kept as the fallback, Slice 1 |
| Reuse `recordStatus` (new level) | no new column | rebuilt every QC run (M4); `"added"` also means real missing parents | rejected |
| An R attribute | invisible in tables and files | lost by `merge()` and CSV (M5) | rejected |
| Marks on each child (`sirePlaceholder`, `damPlaceholder`) plus the row mark | survives the filter without a fallback | three columns; three to keep consistent | rejected: D4's no-row fallback covers the filter case with one column |
| Regenerate the shipped data with digit-only placeholders | exact shape rule possible | about 20 test files read the base rhesus CSV; many pins move | not chosen (owner, S806) |

---

## 9. Close-out checklist mapping (`CLAUDE.md`)

- **NEWS.Rmd:** Slice 1 (or 2) adds one entry; later slices update it, release-state wording.
- **Tutorial/article:** Slice 4 (`colony-manager-guide.qmd`, `_pedigree_browser.Rmd`).
- **`_pkgdown.yml`:** no new exported function; no change.
- **`a2interactive.Rmd`:** the new `obfuscateId()` argument joins the deferred pass (Slice 5 notes
  it).
- **Lint:** every slice.
- **Citation checklist:** not applicable (no new statistic).
- **GitHub issue:** none exists for this item; the backlog item is closed in `CHANGELOG.md`.

---

## 10. Related findings, not in scope

1. **`reportGV()` stops when "Display Unknown IDs" is unticked** (M8): "sire and dam must have had
   alleles assigned: logic error" on `qcPed` with placeholder rows removed. Pre-existing; recorded
   as its own `BACKLOG.md` item. *(Fixed S814: the box no longer reaches the other tabs.)*
2. **Cross-center merge of two files that both contain made-up ids:** `.checkCrossCenterCollision()`
   (`R/resolveCrossCenterIds.R:193-201`) reports any id found in both files and not in the mapping,
   so two files that both hold `U0001` would be refused until the mapping links them (read from the
   code, not run). With the mark, a later change could rename placeholders instead. Not recorded as
   an item; the owner has not asked.

---

## 11. Ratification status

**Owner decisions needed before Slice 1** (plain words):

- **D1 — column name:** `placeholder` (recommended) or `unknownId`.
- **D3 — rule for files without the column:** today's rule, or the tighter one (recommended,
  and ship it first as Slice 1).
- **D5 — a bad value in the column:** stop QC and list the rows (recommended), or ignore it.
- **D6 — shipped data:** leave it as it is (recommended), mark all of it, or mark only the
  ancestry example.

D2, D4, D7, D8 and D9 follow from the measurements and the owner's S806 choice. A slice session
re-checks §2's line numbers with the §2 commands before its RED phase.

**Ratified S807 (2026-09-28, owner, AskUserQuestion), all as recommended:** D1 = `placeholder`;
D3 = (b), the tighter rule, shipped first as Slice 1; D5 = a bad value stops QC and lists the rows;
D6 = (a), the shipped data stays unmarked. Re-measured S807 before asking: 1,470 distinct
`U`-leading ids in the shipped datasets and example files; the tighter rule changes only `U1`.

**Two more decisions, found and ratified S807 before Slice 1's RED:**

- **D10 — alias length.** The De-identified Export's alias-length box allows 4
  (`R/modDeidentifiedExport.R:104-105`, `min = 4L`). Measured: with the tighter rule patched in,
  `obfuscatePed(qcPed, size = 4L)` stops ("too short to easily avoid duplicates"), because a
  placeholder alias of 4 characters is `U` + 3 and is no longer recognized; today it runs, and at
  sizes 5 and 6 it runs under the new rule. **Owner:** lengthen only the placeholder aliases to the
  shortest recognizable length (prefix + *W*, 5 for `"U%04d"`) when `size` is shorter; real animals
  keep `size`. Rejected: stop with a message and raise the box's minimum to 5 (a typed 4 would still
  end the app session). This replaces the §4 catalog's "too short" stop for `obfuscateId()`.
- **D11 — formats the rule cannot recognize.** `setAutoIdFormat()` accepts formats whose ids fail
  the tighter rule (lowercase hex `"U%04x"` → `U000a`; space-padded `"U%4d"` → `"U   1"`).
  **Owner:** `setAutoIdFormat()` refuses a format whose own ids the rule would not recognize.
  Rejected: allow it and document the limit. The only formats the package and its tests use
  (`"U%04d"`, `"AUTO%05d"`) pass.

**Two more decisions, found and ratified S808 before Slice 2's RED:**

- **D12 — Potential Parents reads the mark before it sets aside animals with no birth date.**
  `getPotentialParents()` drops rows with no birth date (`R/getPotentialParents.R:92`) before it
  calls `removeAutoGenIds()` (`:98`), so a real `U1234` parent marked `FALSE` but with no birth
  date has no row left when the mark is read, falls back to the id-shape rule, and is blanked as a
  parent; its offspring are then searched for a parent that is on record. **Owner:** fix it in
  Slice 2 by reading the mark first. Rejected: leave it for a later slice.
- **D13 — the values the `placeholder` column accepts (D5's detail).** `TRUE`/`FALSE` in R's own
  spellings (`TRUE`, `true`, `True`, `T`, and the same for `FALSE`), `1`/`0`, and blank or `NA`.
  Anything else (`yes`, `2`) stops QC and lists the rows. Measured S808: `getPedigree()` reads a
  column of only such spellings as logical, but a column that mixes them with other text stays
  character (`"yes"`, `"true"`, `"T"`), and a column of `1`/`0` arrives as numbers. **Owner:** also
  accept `1` and `0`. Rejected: TRUE/FALSE spellings only; exact `TRUE`/`FALSE` only.
