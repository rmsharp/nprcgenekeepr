# Docs audit, part 2: the 46 slice 6e code candidates, re-checked against today's code (2026-10-15, S1003)

Read-only audit. Nothing in the repo was changed except this report and the session records. No fix was made: every
fix below is a code, help-text or app-text change and needs your ruling and its own session.

## Audit summary

- **Scope:** the 46 "code candidates" of docs-audit slice 6e (S842, `DOCS_STALENESS_AUDIT_SLICE6E_2026-10-01.md`, the last
  126 `man/` pages): CE1-CE7, CF1-CF6, CG1-CG5, CH1-CH4, CI1-CI3, CJ1-CJ8, CK1-CK2, CL1-CL11. `BACKLOG.md` has carried them
  as "not re-checked" since S870. **Not covered:** the 26 moderate and 69 minor *wording* findings of the same slice (the RE
  to RL ids); S844 fixed them and they are not re-audited here. Slices 7b and 8 stay open in `BACKLOG.md`.
- **Criterion:** is the behavior slice 6e described still what the code does; can a colony manager reach it through the
  app or only from a script; does the help (or the app's own text) say so; same severity rule as the 6d re-check:
  **moderate** = reachable from the app and shows a wrong result or a stop; **minor** = documented, script-only, cosmetic
  or visible only to the test harness.
- **Method:** read every site in today's `R/` and its callers, then ran a probe for each candidate from scratch scripts
  outside the repo, started from the project root with `pkgload::load_all()` (the source, not the installed package).
  Who calls each function was found by grepping `R/appServer.R`, `R/appUI.R`, `R/mod*.R` and the rest of `R/`. Five of
  the seven findings below were then run **through the module or entry point the app uses**: the Mate Pair, Genetic Value
  and Cross-Center modules with `shiny::testServer()` (N1, CF3, CE4), the Input tab's `qcStudbook()` (CE2), and
  `groupAddAssign()`, the call the Breeding Groups module makes (CJ3). CE5 was run at function level (the Cross-Center
  module calls `resolveCrossCenterIds()` unchanged, `R/modCrossCenterIdentity.R:311`) and CI1 on the shipped config file.
  `git log` dated every file a later session touched.
- **Not done:** no browser click-through; the modules ran headless in `testServer()`, so the notification a user sees was
  read from the code, not watched. CJ3 and CJ4 ran at `groupAddAssign()` / `fillGroupMembersWithSexRatio()` level, not
  through the Breeding Groups module. CI1 was not run against a LabKey server (the function's return for the shipped file
  was). CH4 (`getLkDirectAncestors`) was read, not run: it needs LabKey. Whether a test pins each behavior was not
  checked, except CL10 (a grep of `tests/testthat/` and `R/` finds the typo only at
  `R/print.summary.nprcgenekeeprErr.R:31`, so no test pins it). "No caller" below means no call in `R/`; `tests/`,
  `vignettes/` and `inst/` were not searched for callers.
- **Result: 1 of 46 is closed by a later session, 45 are still true** (CG3 partly changed). Of the 45: **0 critical, 6
  moderate (CE2, CE4, CE5, CF3, CI1, CJ3), 39 minor.** Sixteen of the 45 are already told truthfully by today's help
  (most were reworded by S844, a few were always told; the code did not change), 5 partly, 1 does not apply (CH4), and **23 are told nowhere or told
  wrongly.** **One new moderate finding (N1)**, found while checking CF1: the Mate Pair table pairs animals of unknown
  sex. Two of the slice's own impact claims need correcting (CF1, CG3).

## What changed since slice 6e

| ID | Slice 6e said | Today | Closed by |
|---|---|---|---|
| CF2 | `kmat[rows, cols]` without `drop = FALSE`: a single-id `populationIds` collapses `kmat` and `reportMatePairs()` fails | `R/filterKinMatrix.R:25` has `drop = FALSE`; `filterKinMatrix("a", <2 x 2>)` returns a matrix; its help says "a matrix however many IDs match" | S923 (`19d976b45`, `c43f11c4e`, 2026-10-06) |
| CG3 (part) | `$genotyped` "is then a vector of `NA` names" when the pedigree shrinks to nothing | `named logical(0)` (run: `lacy1989Ped`, all genotyped, `maxBits = 3`: 7 rows to 0). The zero-row result itself is unchanged and the help says so (`R/shrinkPedigree.R:44`) | not traced to a commit |

For the other 44, no later session changed the code the way the candidate describes (CG3 in part, above). S844 (four docs
commits on 2026-10-01: `54c2f64e5`, `ff8f3c941`, `52335a523`, `9c650237f`) reworded the help of many of them; sixteen now
say the behavior (marked "yes" in the table at the end), a few of those were always told.

## Findings: still true

### Finding 1 (CF3, with RF1 and RF2): the app invites an Excel upload that always fails for two of its three tables (moderate; reachable from the app; the app text and the guide say Excel works)

- **Location:** `R/readExcelPOSIXToCharacter.R:16` reads every Excel column as text (`col_types = "text"`);
  `R/modGeneticValue.R:250` runs `checkKinshipOverrides(readKinshipOverrides(path))` and `R/modSnapshotTrends.R:158` runs
  `checkSnapshotHistory(readSnapshotHistory(path))`, neither converting; the UI says "as a CSV or Excel file"
  (`R/modGeneticValue.R:70`) and "(CSV or Excel)" (`R/modSnapshotTrends.R:48`); the guide says the Kinship Overrides panel
  "accepts a CSV or Excel file" (`vignettes/articles/colony-manager-guide.qmd:454`).
- **Evidence:** a table written with `openxlsx::write.xlsx()` and read through each module's own expression. Kinship
  overrides (`id1`, `id2`, `kinship` = 0.25): "Kinship overrides 'kinship' column must be numeric." Snapshot history (the
  shipped example, as `.xlsx`): "Snapshot history 'schemaVersion' column must be numeric." Twin relations (all columns
  text): reads, 3 x 3, so that table works. **Through the Genetic Value module** (`testServer`, the 12-animal override
  fixture, 100 iterations): F1 mean kinship **0.1042 with no file, 0.1042 with the override as an Excel file** (ignored),
  **0.1375 with the same override as a CSV.** The module catches the error and carries on without the override, so the
  only sign is a red notification, "Could not read kinship overrides: ...".
- **Why moderate:** an invitation the app cannot honor, and the message ("must be numeric") reads as the user's mistake
  when the Excel cells are numeric. The readers' own help tells a script user to convert with `as.numeric()`
  (`R/readKinshipOverrides.R:13`); the app's users get no such step. The reader tests use `.xlsx`, so they pin the
  text-only read; none uploads an Excel table through a module.
- **Fix, your ruling:** (a) **recommended:** convert the declared numeric columns when the Excel branch reads, so the checks
  see numbers (the CSV path already does; `R/readKinshipOverrides.R`, `R/readSnapshotHistory.R`); (b) stop offering Excel on
  those two uploads and reword the guide sentence. Strict TDD, Effort S-M.

### Finding 2 (N1, new): the Mate Pair table pairs animals of unknown sex, lists them as sire or dam, and pairs an animal with itself (moderate; reachable from the app; not documented; no test)

- **Location:** `R/reportMatePairs.R:198-201` drops only male-male and female-female pairs; `:211` reads
  `isSire1 <- sex1 == "M"`, so any other sex lands in the dam column; the comment at `:207-209` says "filterPairs() above
  guarantees every surviving row is opposite-sex", which is false for sex `U` (and `H`). `R/modMatePair.R:392-394,431` passes
  every living animal with no sex filter.
- **Evidence (Mate Pair module, `testServer`):** a pedigree of M1, M2, F1, F2 and two living animals of sex `U` gives **15
  pairs: 7 whose "sire" is not male, 7 whose "dam" is not female, and 2 animals paired with themselves** (U1 x U1, U2 x
  U2); U2 x U1 is listed as sire x dam. On `qcPed` (every living animal M or F) there are 0 such rows of 1,890; setting
  two living animals to `U` gives 1,979 pairs, 177 holding a `U` animal, 2 self-pairs. `qcStudbook()` gives an animal of
  unknown sex the code `U` (`R/sexCodes.R:13`), so a living infant not yet sexed is enough. No test in
  `test_reportMatePairs*.R` or `test_modMatePair*.R` uses sex `U`; `BACKLOG.md`, `CHANGELOG.md` and the earlier audits do
  not mention it.
- **How slice 6e's CF1 differs:** CF1 described `NA` sex (a script-only case: `qcStudbook()` never leaves `NA`). Measured
  today, `filterPairs()` with `reportMatePairs()`'s two-rule list drops **every** pair that holds an `NA`-sex animal, one
  unknown included, because each rule's test is `NA` (`R/filterPairs.R:58,65`); only the single female-female default
  keeps a pair with one unknown. The two cases need different fixes.
- **Fix, your ruling:** (a) **recommended:** pair only animals of known sex M and F, and say in one sentence how many
  animals were left out (the `excluded` table's reasons are a closed list, `R/reportMatePairs.R:32-36`, so adding "sex not
  known" to it is a design choice of its own); (b) keep them and label the
  columns "sire or unknown" (a wider change); (c) leave it and document it. Strict TDD, Effort S.

### Finding 3 (CE2): `convertFromCenter()` reads any text holding a y/t as TRUE and any holding an n/f as FALSE, while its help says an unrecognized value stops (moderate; reachable from the Input tab; the help says the opposite)

- **Location:** `R/convertFromCenter.R:34-39` uses an unanchored alternation (`Y`, `YES`, `T`, `TRUE`; `N`, `NO`, `F`,
  `FALSE`) with `ignore.case`; `R/qcStudbook.R:314` feeds it the `fromCenter` column; the help (`:13`) says any value not
  recognized as a yes or a no "stops with an error naming the offending rows".
- **Evidence:** run on its own: "maybe" TRUE, "unknown" FALSE, "nope" FALSE, "yet" TRUE, "true story" TRUE; "center", "1",
  "" and `1L` stop with "ambiguous values in row(s) 1". **Through `qcStudbook()`** on `examplePedigree` with three
  `fromCenter` cells set to "unknown", "N/A" and "maybe": the QC'd studbook holds FALSE, FALSE and TRUE, with no error,
  warning or QC Summary line.
- **Why moderate:** a spreadsheet cell reading "unknown" or "N/A" is ordinary, and the result silently decides who counts as
  a potential parent (`fromCenter` drives Candidate Parent Assignment) and what the Input tab calls colony-born.
- **Fix, your ruling:** (a) **recommended:** match whole values (y, yes, t, true; n, no, f, false), so anything else stops
  naming the rows, as the help already says; an existing file with a value like "unknown" would then stop until corrected;
  (b) keep the matching and reword the help. Strict TDD, Effort S.

### Finding 4 (CJ3, with CJ4): with a sex ratio set, males under the minimum breeding age are placed in groups as if they were not male (moderate; reachable from the app; the help names only unknown-sex animals)

- **Location:** `R/fillGroupMembersWithSexRatio.R:83` builds the "female" pool as every candidate that is not a potential
  sire, and a potential sire needs age at least `minAge` (`R/getPotentialSires.R:20-24`); `calculateSexRatio()` still
  counts them as males. The `sexRatio` help (`R/groupAddAssign.R:56-58`) says "non-males (females and animals of other or
  unknown sex) per male", which covers sex `U` and `H` but not a male under the age floor. Reached from Breeding Groups
  "Sex ratio: Custom" (`R/modBreedingGroups.R:104-117`, `groupAddAssign` at `:451,544`).
- **Evidence:** `groupAddAssign()`, 2 groups, 3 adult males, 3 males aged 0.3 to 0.5 years, 8 females, `sexRatio = 3`,
  `minAge = 1`: **a male under `minAge` was placed in a group in 40 of 40 runs.** At the fill level (10 candidates,
  `sexRatio = 0.5`, 200 runs) each of three young males was placed 36 to 44 times and the unknown-sex animal 50 times.
- **Why moderate:** a colony usually has living infants; the group's realized ratio then counts them as males while the
  fill treated them as the other sex, so the ratio asked for is not the ratio shown.
- **CJ4, same function, minor:** a group stops being filled as soon as its male pool is empty, whatever females remain
  (`R/fillGroupMembersWithSexRatio.R:123-124`). Measured in that function at a ratio the app offers (4 females per male; 3
  groups, 3 males, 12 females; 60 runs): about 2 females per group against 4 asked, 5.7 of the 12 females unused; with 8
  males and 40 females in 2 groups, about 3.7 against 4. The leftover animals show in "Unused animals" (`R/addGroupOfUnusedAnimals.R:30`), but nothing says the target was not reached.
- **Fix, your ruling:** (a) **recommended for CJ3:** leave a male under `minAge` out of both pools; (b) reword the help
  ("non-males" becomes "animals that are not breeding-age males"). CJ4: accept and add one sentence to the help, or add a
  note on the Statistics tab. Strict TDD for (a), Effort S-M.

### Finding 5 (CE4): a Center B id equal to a mapped Center A id passes the "clean" check and gives duplicate ids (moderate; reachable from the Cross-Center tab; the help claims the opposite)

- **Location:** `R/resolveCrossCenterIds.R:190-205` (`.checkCrossCenterCollision`) intersects only the ids **not** in the
  mapping on each side, so an unmapped Center B `T1` against a mapped Center A `T1` is never compared; the help
  (`:359-363`) says an id string present in both pedigrees and not declared in the mapping is an error.
- **Evidence:** Center A `T1`; Center B `X9` and an unrelated `T1`; mapping T1 to X9. **Through the Cross-Center module**
  (`testServer`): "issues rows: 0" (the page would say "Mapping is clean"), then the merged pedigree has **three rows with
  id `T1`, two of them duplicates.**
- **Why moderate:** the feature exists to stop exactly this (the plan's D5, "identity is established only by the explicit
  mapping table"), and the exported file then breaks anything that expects unique ids.
- **Fix, your ruling:** (a) **recommended:** also flag a Center B id equal to a mapped Center A id that is not itself the
  mapped one, and the mirror case; one more row type in the check, shown with the others; (b) leave it and document it.
  Strict TDD, Effort S.

### Finding 6 (CE5): a column recorded by one center only is lost for a mapped animal, and the whole column when every animal is mapped (moderate; reachable from the Cross-Center tab; the help promises the union)

- **Location:** `R/resolveCrossCenterIds.R:484-509` resolves only columns present on **both** sides; a merged row is built
  with `id`, `sire`, `dam` and those, then `bindPedigreeRows()` (`:511`) fills the gaps with `NA`. The help says the output
  covers "the union of `pedA`'s and `pedB`'s columns" (`:382`, written in S446).
- **Evidence:** Center A has `sex` (T1 = M, S1 = F), Center B has no `sex` column (X9, mapped to T1): the merged T1 has
  `sex` `NA` although Center A recorded M. With only one animal in each file, both mapped, **the merged table has no `sex`
  column at all** (`id`, `sire`, `dam`). The module calls this function unchanged (`R/modCrossCenterIdentity.R:311`).
- **Why moderate:** the shared animals are the ones the curator cares about most, and one center's only record of them is
  dropped from the export, silently.
- **Fix, your ruling:** (a) **recommended:** take the one-sided value (the non-`NA` side) for every column, as the shared
  columns already do, and keep a column that any input has; (b) reword the help ("one-sided values of mapped animals are
  not carried"). Strict TDD, Effort S. Findings 5 and 6 can share one session (the same function).

### Finding 7 (CI1): the shipped example config, copied unedited, makes `getConfigApiKey()` return the placeholder text as a live API key (moderate; the LabKey sign-in path; no help line says so)

- **Location:** `R/getConfigApiKey.R:17-24` does not drop `#` comment lines before parsing; its sibling
  `getOptionalConfigToken()` does (`R/getSpeciesOverridesPath.R:23-27`, with a comment saying why). The shipped
  `inst/extdata/examples/example_nprcgenekeepr_config:53` has `# apiKey = "paste-your-labkey-api-key-here"`.
  `R/setLabKeyDefaults.R:47-51` takes the key from the environment, then from this function, and uses it before it looks
  for a netrc file.
- **Evidence:** `getConfigApiKey()` on the shipped file, 0 active `apiKey` lines, 1 commented: returns
  **"paste-your-labkey-api-key-here"**; `getOptionalConfigToken()` on the same file returns `""`.
- **Why moderate:** a LabKey site that copied the example and relies on its netrc file is told, in effect, that it has an
  API key, and the placeholder beats the netrc; the failure then looks like a server or password problem. Not run against
  a LabKey server.
- **Fix, your ruling:** (a) **recommended:** drop comment lines in `getConfigApiKey()` as the sibling does, and test it on
  the shipped file; (b) leave it. Strict TDD, Effort S.

## The remaining 39 minor findings, grouped by what to do

Every minor finding is in exactly one of the five groups (13 + 16 + 2 + 5 + 3 = 39).

- **Small and clearly wrong (13):** CL10 (the printed `summary()` says "suspicous",
  `R/print.summary.nprcgenekeeprErr.R:31`, no test pins it; its reclass line `:37` is a no-op, run: class unchanged), CL6
  (59.6 s prints "60 seconds."; 119.6 s prints "1 minutes and 60 seconds."), CL7 (`withinIntegerRange(3e9, 0, 10)` is 0,
  the minimum, not the maximum), CL2 (`create_wkbk()` into a missing directory returns `TRUE` and writes nothing, while its
  help says other problems signal errors), CL3 (a length-two `fileType` stops "the condition has length > 1"; the `.excel`
  extension is told in the help), CE3 (cryptic `NA` error; a minimum date after `baseDate + maxDelta` never ends; the
  length message names `minDate` for `maxDelta`), CE6 (the check function's error begins "resolveCrossCenterIds():"; the
  Cross-Center tab shows it as "Structural error: ..."), CE7 (an `NA` id stops `obfuscateId()` and `obfuscatePed()`), CK1
  (the default file is always `examplePedigree.csv`, tab-delimited for `"txt"`, an `.xlsx` workbook for `"excel"`), CK2
  (`focalAnimals$id` is a factor, `examplePedigree$id` a character), CL1 (the zero-row and zero-column strings end in a
  backslash and an n, two characters), CL5 (`setExit()` finds `Death` case-insensitively and reads `ped$death`:
  "replacement has 0 rows"), CJ8 (duplicate group labels share one factor level: 3 rows give 2 levels and 6 plot rows).
- **Told truthfully by today's help; accept (16):** CE1, CF5, CG3, CG4, CG5, CH1, CH2, CH3, CI2, CJ1, CJ5, CJ6, CJ7, CL4
  (`R/safeExecute.R:13` says `expr` runs twice on a warning; measured 2 evaluations), CL8, CL11.
- **Partly told, minor (2):** CF4 (the first snapshot is not checked; the help at `R/appendColonySnapshot.R:22` says columns
  are not checked), CJ2 (`NULL` for a missing `fromCenter` column is documented, and the Candidate Parent Assignment tab
  says why since S948; a missing `sex` or `birth` column also gives `NULL` and is not documented).
- **Latent or design, no action proposed (5):** CF1 (script-only `NA` sex; see Finding 2), CF6 (`filterThreshold()` with an
  `NA` kinship returns an `NA` row; callers remove `NA` first), CG1 (father x daughter is not a loop by the page's own
  definition, `R/makesLoop.R:29-31`), CG2 (`countLoops()` is route-weighted: 3 for the test animal against 2 distinct
  looped animals; `getAncestors()` documents the repeats), CH4 (a code-design note: the LabKey fetch and guard are written
  twice, `R/getLkDirectAncestors.R:48` and `R/getPedigreeSource.R:103`; the focal animals in its return are documented).
- **Carried or folded into a finding (3):** CL9 is the open `BACKLOG.md:170` item ("The Changed Columns tab and `summary()`
  skip some rename fields", DECISION NEEDED); re-counted today from the code, `getEmptyErrorLst()$changedCols` has 13
  fields, `summary()` names 10 of them (none for `recordstatusToRecordStatus`, `fromcenterToFromCenter` or
  `geographicoriginToGeographicOrigin`, `R/summary.nprcgenekeeprErr.R`) and `shouldShowChangedColsTab()` checks 12
  (`R/shouldShowChangedColsTab.R:15,46`). CI3 (`getParamDef()` checks keys case-insensitively and selects
  case-sensitively: a config key written `Center` stops "subscript out of bounds", `R/getParamDef.R:19`) goes with Finding 7.
  CJ4 goes with Finding 4.

**No caller in `R/`.** Eight candidates sit in functions that nothing in `R/` calls: CG2 (`countLoops`), CG3
(`shrinkPedigree`), CH4 (`getLkDirectAncestors`), CK1 (`makeExamplePedigreeFile`), CL1 (`dataframe2string`), CL4
(`safeExecute`), CL6 (`get_elapsed_time_str`) and CL8 (`is_valid_date_str`). Open issue #37, "Exported functions not
currently used by app", asks about exactly such exports, so "retire it" is a real option beside "fix it" for these;
this report does not rule on it.

## Structural observations

- **Three candidates classify a value by what it contains or fails to match, not by what it is:** CE1 and CE2 (substring
  and unanchored matches in `convertAncestry()` and `convertFromCenter()`) and CJ3 ("not a potential sire" means
  female). The same habit produced Finding 2: "not M-M and not F-F" was read as "opposite sex".
- **Four candidates are an `NA` that reaches an `if` or a subset with no guard:** CE3, CE7, CF1, CF6. All four are
  script-only today because `qcStudbook()` removes the `NA` first, which is why none shows in the app.
- **A function returns success without checking:** CL2 (`create_wkbk()` returns `TRUE` for a file that was not written)
  and CF4 (the first snapshot skips every check the later ones get).
- **One root cause, two tables:** Finding 1 is a single line (`col_types = "text"`) that three readers share; the twin
  table is spared only because all its columns are text.
- **S844 reworded, it did not fix, and two of its sentences are wrong today.** Sixteen of the 45 are told truthfully now with
  the code as it was, a sound result for the script-only ones. But S844 also wrote the `convertFromCenter()` sentence that
  an unrecognized value stops (`R/convertFromCenter.R:13`, CE2, `54c2f64e5`) and the `create_wkbk()` sentence that other
  problems are signaled as errors (`R/create_wkbk.R:13`, CL2, `9c650237f`); a run contradicts both. The "union of columns"
  sentence behind CE5 is older (S446, `246f2cfff`). A wording pass that checks the sentence and not a run can add a false
  one; the S994 pattern (`test_docsAuditHousekeepingWording.R`) pins a corrected sentence once a fix lands.

## Comparison with the prior audit

| Metric | Slice 6e (S842, 2026-10-01) | Now (S1003) |
|---|---|---|
| Candidates | 46, severity not rated | 46 re-checked, severity rated |
| Closed | none | 1 (CF2) |
| Still true | 46, "not re-checked" | 45 (1 partly changed) |
| Moderate | not rated | 6, plus 1 new (N1) |
| Reachable from the app | not recorded | 18 of the 45 (5 moderate, 13 minor); CI1 only at a LabKey site; N1 also reachable |
| Told truthfully by the help | not recorded | 16 yes, 5 partly |

## Recommendations (your rulings; each is its own session)

1. **Finding 1 (Excel upload):** (a) convert the numeric columns on the Excel path. Effort S-M.
2. **Finding 2 (Mate Pair, unknown sex):** (a) known-sex M and F only, with a one-sentence count of the animals left out. Effort S.
3. **Finding 3 (`fromCenter` text):** (a) match whole values. Effort S.
4. **Finding 4 (sex ratio):** (a) keep males under the age floor out of both pools; accept CJ4 with one help sentence. Effort S-M.
5. **Findings 5 and 6 (Cross-Center):** (a) both, one session. Effort S-M.
6. **Finding 7 (API key placeholder, with CI3):** (a). Effort S.
7. **The 13 small wrong statements:** one housekeeping session in the S994 shape (help or code, one test file); the eight
   in functions nothing calls could instead be retired under issue #37 if you prefer.
8. **Everything else (16 told, 5 partly, 4 latent, CL9, CH4):** no action; `BACKLOG.md` records them as re-checked.

## Items audited

Reach: **app** = a tab in the running app calls it (tab named), **script** = no app path found. Help: **yes** = today's help
or app text says it, **partly**, **no**, **n/a**.

| ID | Today | Reach | Help | Severity | Evidence (probe run today unless said) |
|---|---|---|---|---|---|
| CE1 | still true | app: Input (`qcStudbook`) | yes (`R/convertAncestry.R:14`) | minor | "Indonesian", "indeterminate" give INDIAN (`:28-34`) |
| CE2 | still true | app: Input | no, help says it stops | **moderate** | Finding 3 |
| CE3 | still true | script (`obfuscatePed` passes no `minDate`, `R/obfuscatePed.R:96`) | no | minor | `NA` min: "missing value where TRUE/FALSE needed"; 2021 min with 2020 base and delta 5: endless (stopped at 3 s); `:37` names `minDate` |
| CE4 | still true | app: Cross-Center | no, help claims the rule | **moderate** | Finding 5 |
| CE5 | still true | app: Cross-Center | no, help promises the union | **moderate** | Finding 6 |
| CE6 | still true | app: Cross-Center (notification) | no | minor | check stops "resolveCrossCenterIds(): 'pedA' must contain ..." (`R/checkCrossCenterMapping.R:58`, `R/modCrossCenterIdentity.R:277`) |
| CE7 | still true | script | no | minor | `obfuscateId(c("A1", NA))` stops (`R/obfuscateId.R:68`) |
| CF1 | still true | script | no | minor | `NA`-sex pair dropped (`R/filterPairs.R:58,65`); see Finding 2 |
| CF2 | **closed** | - | yes | - | S923, `R/filterKinMatrix.R:25` |
| CF3 | still true | app: Genetic Value, Snapshot Trends | partly | **moderate** | Finding 1 |
| CF4 | still true | script (the tab builds its own snapshot) | partly (`R/appendColonySnapshot.R:22`) | minor | `appendColonySnapshot(NULL, <snapshotDate "not a date", schemaVersion 99>)` returns it as given (`:36`) |
| CF5 | still true | app: Snapshot Trends | yes (`R/plotSnapshotTrends.R:15`) | minor | one flag per row (`:75`) against metric-by-metric flags (`R/calcSnapshotDeltas.R:116-145`) |
| CF6 | still true, latent | script | no | minor | `filterThreshold(<NA kinship>, 0.1)` returns an `NA` row (`R/filterThreshold.R:29`) |
| CG1 | still true | script | no | minor | father x daughter: `findLoops` FALSE for the offspring (`R/makesLoop.R:29-31`) |
| CG2 | still true | script, no caller | no | minor | 7 animals: `countLoops` 3, distinct looped animals 2 (`R/countLoops.R:49-52`) |
| CG3 | still true, partly changed | script, no caller | yes (`R/shrinkPedigree.R:44`) | minor | 7 rows to 0; `$genotyped` is `named logical(0)` |
| CG4 | still true | app: Pedigree Browser (QC'd input never absent) | yes (`R/findPedigreeNumber.R:18`) | minor | a cycle gives `NA NA` |
| CG5 | still true | script | yes (`R/trimPedigree.R:26`) | minor | `addBackParents = TRUE` result `identical` to FALSE |
| CH1 | still true | script | yes (`R/offspringCounts.R:17`) | minor | columns: `totalOffspring` only |
| CH2 | still true | script | yes (`R/offspringCounts.R:22`) | minor | duplicated probands give row names 1, 2, 3 |
| CH3 | still true | script | yes (`R/getPedDirectRelatives.R:17`) | minor | "NOPE" gets a founder-looking placeholder row |
| CH4 | still true | script (LabKey), no caller | n/a | minor | fetch and guard repeated: `R/getLkDirectAncestors.R:48`, `R/getPedigreeSource.R:103`; not run |
| CI1 | still true | LabKey sign-in | no | **moderate** | Finding 7 |
| CI2 | still true | app: Pedigree Browser (it handles empty focal ids) | yes (`R/setPopulation.R:14`) | minor | empty `ids` flags everyone TRUE (`:33`) |
| CI3 | still true | LabKey config | no | minor | `getParamDef(<Center key>, "center")`: "subscript out of bounds" (`R/getParamDef.R:19`) |
| CJ1 | still true | app: Breeding Groups (ids come from the pedigree) | yes (`R/addSexAndAgeToGroup.R:15`) | minor | unknown id: "values must be length 1" |
| CJ2 | still true | app: Candidate Parent Assignment | partly | minor | missing `sex`, `birth` or `fromCenter` returns `NULL` (`R/getPotentialParents.R:99-102`) |
| CJ3 | still true | app: Breeding Groups | partly | **moderate** | Finding 4 |
| CJ4 | still true | app: Breeding Groups | no | minor | Finding 4 |
| CJ5 | still true | script | yes (`R/getPyramidAgeDist.R:14`) | minor | a QC'd pedigree: "birth column must be of class ..." |
| CJ6 | still true | app: Age-Sex Pyramid | yes (`R/getPyramidPlot.R:12`) | minor | `qcPed` max age 33.3, living 23.3 |
| CJ7 | still true | app: Breeding Groups (shown as "Unused animals") | yes (`R/groupAddAssign.R:104`) | minor | last element `NA` when nothing is left |
| CJ8 | still true | script (the app's labels are unique) | no | minor | 3 rows, 2 levels, 6 plot rows (`R/makeGeneticDiversityHeatmap.R:56`) |
| CK1 | still true | script, no caller | no | minor | default `examplePedigree.csv` for `"txt"` and `"excel"` (`R/makeExamplePedigreeFile.R:24`) |
| CK2 | still true | data | no | minor | `focalAnimals$id` factor, `examplePedigree$id` character |
| CL1 | still true | script, no caller | no | minor | ends in a backslash and n, two characters (`R/dataframe2string.R:38,41`) |
| CL2 | still true | script | no, help says errors | minor | missing directory: returns TRUE, file absent, one warning |
| CL3 | still true | script | partly (`R/saveDataframesAsFiles.R:7`) | minor | `ex.excel`; `c("csv","txt")` stops (`:43`) |
| CL4 | still true | script, no caller | yes (`R/safeExecute.R:13`) | minor | 2 evaluations |
| CL5 | still true | script (`qcStudbook` fixes headers first) | no | minor | `Birth`/`Death`/`Departure`: "replacement has 0 rows" |
| CL6 | still true, worse | script, no caller | no | minor | 59.6 s "60 seconds."; 119.6 s "1 minutes and 60 seconds." |
| CL7 | still true | app: Breeding Groups (box limits keep it small) | no | minor | `withinIntegerRange(3e9, 0, 10)` is 0 |
| CL8 | still true | script, no caller | yes (`R/is_valid_date_str.R:18`) | minor | numeric input FALSE even with `optional = TRUE`; `format` unused |
| CL9 | still true | app: Changed Columns tab | no | minor | the open `BACKLOG.md:170` item; 10 of 13 and 12 of 13 |
| CL10 | still true | script (console print) | no | minor | "suspicous" (`:31`); reclass a no-op (`:37`) |
| CL11 | still true | app: ORIP tab (config case only) | yes (`R/shouldShowOripTab.R:16`) | minor | "onprc" FALSE (`:35`) |

Coverage: 46 of 46 candidates, each once. A new finding (N1) is Finding 2.
