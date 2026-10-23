## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Retrospective Snapshot Backfill Plan -- earlier Genetic-Health Trends points from studbook dates

**Session:** S1036 (2026-10-22) · **Workstream:** `methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
(the S756 plan for the same feature family used it; `DESIGN_WORKSTREAM.md` is for UI layout) ·
**Type:** design document, **zero `R/`, `tests/` or `man/` changes this session.**

This is the "fresh Pre-RED design gate" that the issue #167 plan left open as its optional Slice 5
(`docs/planning/issue167-longitudinal-monitoring-plan.md` §3 D5, §5 Slice 5; `BACKLOG.md:33`).
Issue #167 is closed, so implementation needed a **new GitHub issue**: filed as **#170** in S1037
(2026-10-22, with the owner's word; Appendix C is the text posted). Each slice in §5 is a separate strict-TDD session.

**What the owner ruled this session (S1036, at the scope question, 2026-10-22):** build **an
exported R function plus an app button** that calls it. Everything else below is a
recommendation, written so the slice sessions do not re-derive it; each judgment call is marked
and is put to the owner with `AskUserQuestion` at the slice that first needs it (the S758-S760
pattern).

**Approved by the owner, 2026-10-22, after the S1036 close-out** (the owner's words: "approve
design"). The approval covers this document as written. The three marked judgment calls (B4, B6,
B11) are still put to the owner at the slice that first needs them. The GitHub issue was filed as
#170 in S1037, after the owner said to.

---

## 1. Context

### 1.1 The problem, in plain words

The Genetic-Health Trends tab (shipped in S757-S760) records a dated snapshot only when someone
runs an analysis. A colony manager who starts using it today has one point and must wait seasons
for a trend. The studbook already holds every animal's birth and exit date, so "who was alive on
1 January of each past year, and what did the genetics of that group look like" can be rebuilt.

### 1.2 Decided before this session (do not re-litigate)

All from the #167 plan unless noted:

- A snapshot is one aggregate row of the 27-column schema (`R/snapshotSchemaColumns.R:13`); no
  per-animal rows (D1, D8).
- One user-maintained history CSV; pure functions; the app writes only through a user-initiated
  download (D2).
- `membershipRule` is an **open string**: "no enumeration is enforced, so new rule names are
  additive" (`R/checkSnapshotHistory.R:35-36`). Trend plots and delta tables never compare across
  rules (`R/calcSnapshotDeltas.R:49-79`; `R/plotSnapshotTrends.R:70-92`).
- A mixed-provenance series is flagged, never refused; Monte Carlo uncertainty is always shown
  (D4). `reportGV()` has no seed and gets none (Dragon 1).
- No estimator is forked or changed: `reportGV()`, `meanKinship()`, `calcSkewness()` and
  `calcKurtosis()` are consumed as they are.
- New this session, from the owner: **the app and a script must give identical rows** (the owner
  chose function plus button, so the button calls the exported function and adds nothing of its
  own to the numbers).

### 1.3 Facts read from source this session

| Fact | Where |
|---|---|
| "Living breeder" = no exit date **as the column stands** and named as a sire or dam somewhere in the pedigree handed to the estimator. The only reader of `exit` on the snapshot path. | `R/getLivingBreeders.R:18-29`; called by `R/calcNeSexRatio.R:52` and `R/calcNeVariance.R:57` |
| No stored breeder flag is read anywhere on the snapshot path. | grep of `R/reportGV.R`, `R/createColonySnapshot.R`, `R/calcNe*.R`, `R/getLivingBreeders.R`, `R/correctUnknownParentMeanKinship.R`, `R/calcFEFG.R` |
| The Pedigree tab sets the population before any other tab sees the pedigree: no focal list means `setPopulation(ped, ped$id[isLivingAnimal(ped)])`. `isLivingAnimal()` judges by `status == "ALIVE"` when a status column exists, else by `is.na(exit)`. | `R/modPedigree.R:372-374`; `R/isLivingAnimal.R:22` |
| The Genetic Value tab then trims to the population and its ancestors (`removeUninformative = FALSE`, `addBackParents = FALSE`) and calls `reportGV()`. | `R/modGeneticValue.R:293-312, 326-342` |
| The other tabs get `analysisPedigree`, which **is trimmed to the focal animals when a focal list is entered**; the full pedigree is `processedPedigree`, also returned by the module. | `R/appServer.R:313-314`; `R/modPedigree.R:427-430, 783` |
| `createColonySnapshot()` accepts two rules, `wholePedigree` and `focalPopulation`, and verifies the claim against `ped` and the report. | `R/createColonySnapshot.R:83, 124-143` |
| `appendColonySnapshot()` is a pure, one-row merge and stops on a duplicate (`snapshotDate`, `membershipRule`) pair. | `R/appendColonySnapshot.R:34` |
| Generated stand-in parents are recognised by one predicate, which reads the `placeholder` column when `qcStudbook()` wrote it. | `R/autoIdFormat.R:147` |
| The Trends module takes one input, `snapshotSource`; the app wires it from the Genetic Value tab. | `R/modSnapshotTrends.R:142`; `R/appServer.R:527-528` |
| Module return names are pinned by test. | `tests/testthat/test_moduleContract.R:56-58` |
| The guide already lists "the living animals" as a membership rule. | `vignettes/articles/colony-manager-guide.qmd:1277-1279` |

**Names are free:** `git grep -i` for `backfillColonySnapshots`, `reconstructedLiving`,
`asOfPedigree` finds nothing in `R/`, `NAMESPACE` or `_pkgdown.yml`.

---

## 2. Evidence (measured S1036, scratch scripts, nothing committed to `R/`)

**Fixtures.** `inst/extdata/examples/deidentified_jmac_ped.csv` (2,590 animals) read with blanks as
`NA`, then `qcStudbook(minSireAge = 0, minDamAge = 0)` (the default parent-age check stops this
file): 4,055 rows, of which 1,463 are generated stand-ins and 2,592 real animals. The app's
built-in `ExamplePedigree.csv` gives the same picture (3,694 rows, 1,372 stand-ins, 2,322 real).
Gene-drop runs used `guIter = 20` for the many comparisons and `1000` for timing; the numbers
below that do not involve a gene drop (counts, `neSexRatio`, `neVariance`, mean kinship, `fe`)
do not depend on it.

### 2.1 The dates can be used

| Real animals only | jmac | ExamplePedigree.csv |
|---|---|---|
| Animals | 2,592 | 2,322 |
| Status and exit date agree for every animal | yes (339 ALIVE no exit; 1,886 DECEASED and 365 SHIPPED with exit; 2 UNKNOWN are the parent rows QC added) | yes (332 / 1,625 / 365) |
| Exit before birth | 0 | 0 |
| No birth date | 62 (2.4%) | 60 (2.6%) |
| ...of which a parent of a dated animal | 29 | 27 |

### 2.2 The method reproduces the app, and the simple route does not

"Blanked" = in a copy of the pedigree, every exit date after the chosen date is set to `NA`; the
population is the real animals born on or before the date with no remaining exit date; then the
**same** preparation as the Genetic Value tab. "Simple" = set only the population by dates and
leave the exit column alone (all a script user can do today).

At the studbook's export date, 2018-07-11, blanked and the app's own path give **identical**
numbers: 339 animals (125 male, 214 female), `neSexRatio` 83.9, `neVariance` 86.9, `fe` 112.18,
mean kinship 0.01687.

| Date | Animals | `neSexRatio` simple / blanked | `neVariance` simple / blanked | `fe` | Mean kinship |
|---|---|---|---|---|---|
| 1990-01-01 | 201 | 0.0 / 3.9 | NA / 54.1 | 142.60 both | 0.00827 both |
| 2000-01-01 | 230 | 0.0 / 62.0 | Inf / 68.0 | 113.56 both | 0.01149 both |
| 2010-01-01 | 369 | 30.9 / 136.6 | 39.6 / 92.5 | 103.50 both | 0.01447 both |

The cause is `getLivingBreeders()` reading today's exit dates (§1.3). An animal alive in 1990 has
almost always left since, so the simple route finds no living breeders.

**Cutting the pedigree back to animals born by the date is unnecessary.** The trim to the
population's ancestors already drops them: blanking alone gave the same 3.9 / 54.1, 62.0 / 68.0
and 136.6 / 92.5 and the same analysed row counts (524, 496, 679).

### 2.3 Animals with no birth date

A parent with no birth date was born before its first dated offspring, so it was alive on any
later date until its exit (rule B4). Effect on who is counted, jmac, 1 January:

| Year | 1970 | 1975 | 1980 | 1985 | 1990 | 2000 | 2010 |
|---|---|---|---|---|---|---|---|
| Alive, dated animals | 44 | 132 | 281 | 238 | 201 | 230 | 369 |
| Added by the offspring rule | 21 | 20 | 14 | 6 | 3 | 1 | 1 |
| Could also be alive (33 animals with no birth date and no dated offspring, exit after the date) | 20 | 18 | 13 | 4 | 0 | 0 | 0 |
| Share of the upper bound that is uncertain | 23.5% | 10.6% | 4.2% | 1.6% | 0% | 0% | 0% |

At 1990, 2000 and 2010 the rule moves no effective size and moves mean kinship by at most 0.0001
(0.00827 to 0.00830, 0.01149 to 0.01140, 0.01447 to 0.01440). The 33 all have an exit
date, between 1965-04-27 and 1989-03-15, so they matter only for early dates.

### 2.4 Parentage is thin in early years, which drives the sex-ratio number

| Date | Alive | Sire recorded | Dam recorded | Alive and a parent of another animal alive that day |
|---|---|---|---|---|
| 1990-01-01 | 201 | **1** | 194 | 41 |
| 2000-01-01 | 230 | 90 | 210 | 81 |
| 2010-01-01 | 369 | 302 | 362 | 150 |

The 3.9 for 1990 is the app's current definition applied to a year with one recorded sire. It
is not a count of breeding males. The reconstruction therefore reports this next to every date
(B5) and the documentation says so in plain words.

### 2.5 Cost

About **4 seconds per date** at 1,000 iterations (4.1 s for the 679-row analysis of 2010-01-01,
4.0 s for the 772-row analysis of 2018-07-11). 0.2 to 1.5 s at 20 iterations. Estimate, not
measured: 54 yearly dates from 1965 would take about 4 minutes. **Not measured on a larger
colony**; kinship grows roughly with the square of the analysed rows.

### 2.6 A trap for the implementer (a probe error, withdrawn as a defect)

Handing the QC'd pedigree straight to the Genetic Value step, **without** the Pedigree tab's
`setPopulation()` call, falls back to `is.na(exit)` (`R/modGeneticValue.R:293-298`) and counts the
generated stand-in rows as animals: 1,804 against 339 (jmac), 1,704 against 332
(ExamplePedigree.csv). The app never takes that path, so this is not an app defect; but a
backfill written by copying the module's fallback instead of the Pedigree tab's rule would
inherit it. The closure test in §5 Slice 1 is what catches it.

---

## 3. Design decisions

| # | Decision | Status |
|---|---|---|
| B1 | Scope: an exported function **and** an app button that calls it. | **Ruled by the owner, S1036** |
| B2 | Method: blank later exits, set the population, same preparation as the app. | Evidence-determined (§2.2) |
| B3 | Own rule name `reconstructedLiving`; never mixed with recorded rows. | Recommended |
| B4 | Animals with no birth date: placed by their first dated offspring, else left out. | **Decided by the owner, S1038: "From first offspring"; an animal the studbook does not list as living (status UNKNOWN) never counts** (§5.2) |
| B5 | Every date comes with a support report; no hidden floor. | Built S1038 (§5.2) |
| B6 | Date grid and start date. | **Decided by the owner, S1038: the first 1 January with at least `minAnimals` (2) living animals** (§5.2) |
| B7 | Dates already in the history are skipped and reported, never overwritten. | Built S1038 (§5.2) |
| B8 | A failing date is reported, never silent and never fatal to the others. | Built S1038 (§5.2) |
| B9 | `guIter` and `guThresh` are required, no defaults. | Follows S758 |
| B10 | The app panel: full pedigree, the last analysis's settings, a preview before the run. | Recommended; wording is the owner's |
| B11 | One shared helper for "prepare the analysis pedigree". | Recommended; ratify at Slice 1 REFACTOR |
| B12 | Known limits stated, not engineered around. | Recommended |

**B1.** See the status line. It also fixes the order of work: the function first, the button
second, so the app can never do anything the script cannot (parity promise).

**B2. Method, per date `T`.**
1. Copy the pedigree; set `exit` to `NA` where `exit > T`.
2. Population = real animals (not `isGeneratedUnknownId(id, ped = ped)`) with a birth date
   `<= T` and no exit date left, plus the B4 animals.
3. Trim to the population and its ancestors (`removeUninformative = FALSE`,
   `addBackParents = FALSE`), then `reportGV(guIter, guThresh, ...)`, then the row.

The stand-in parents stay in the pedigree (children still name them) and never enter the
population. **Closure invariant** (becomes the Slice 1 RED test): a reconstruction for the date
a pedigree was exported equals the snapshot the app records from that pedigree, exactly for every
field that does not come from the gene drop, and within the reported standard errors for the
ones that do. A reference prototype is in Appendix A.

**B3. The label.** The new rule `reconstructedLiving` is added to `createColonySnapshot()`'s known
rules (`R/createColonySnapshot.R:83`) and verified like `focalPopulation` (a `population` column
whose rows equal the report). Because rules are never compared with each other, a reconstructed
series is its own line on the trend chart and its own choice in the delta selector, with no new
code in `calcSnapshotDeltas()`. It must not reuse `focalPopulation`: the recorded rows of that
rule use whatever population the user chose and today's records, so mixing the two would pass the
validator and be wrong. Slice 3 draws the reconstructed line dashed and adds a one-line caption;
the wording is the owner's.

**B4. No birth date.** A real animal with no birth date and a first dated offspring on or before
`T`, and no exit by `T`, is counted alive (it must have been born before that offspring). One
with no dated offspring cannot be placed on any date and is left out of the population; the
support report (B5) states how many of them could have been alive. Judgment call: leave them out
by default (recommended; they are a known undercount, not a guess), or let the user add them
all. Needs the owner's call at Slice 2.

**B5. Support report.** The function returns, per date, `nLiving`, `nBoundByOffspring`,
`nPossiblyAlive` (the unplaceable animals with an exit after the date), `pctSireKnown` and
`pctDamKnown` among the living animals (§2.3, §2.4). No threshold refuses a date; the numbers
are shown beside the trend so the reader can judge. This is "flag, don't refuse" (D4) applied to
the reconstruction's own weak spots. A cut-off would be an invented scientific threshold (D6).

**B6. Dates.** Either an explicit `dates` vector or `from`, `to` and `by = "year"` (1 January of
each year). Default `from`: the first 1 January with at least `minAnimals` living animals
(`minAnimals` defaults to 2, the floor `reportGV()` already enforces); default `to`: the last
1 January on or before the latest date in the data. The app panel shows the support report for
the whole grid **before** the run (counts only, no gene drop, fast), so the user picks the start
year knowingly. Judgment call: whether the default start should be later than the floor.

**B7. Duplicates.** The function takes `existingHistory`; a (date, `reconstructedLiving`) pair
already there is skipped and listed in `skipped` with the reason. To rebuild after correcting
the studbook the user removes those rows from their own file. A `replace` option is deferred.

**B8. Failures.** Each date is computed independently inside a `tryCatch`; a failure goes to
`skipped` with the condition message verbatim, and the run continues. A run that produces no row
at all stops with a plain message. Required columns (`id`, `sire`, `dam`, `sex`, `gen`, `birth`,
`exit`) are checked first with `assertRequiredColsPresent()`, naming every missing one.

**B9. Provenance.** `guIter` and `guThresh` have no default, for the S758 reason: a default
could record settings the run did not use. The app panel pre-fills them from the last analysis.

**B10. The app panel.** On the Genetic-Health Trends tab, a section "Build earlier snapshots":
start year (from B6), `Build` button, a progress bar (one step per date) and the support table.
Wiring (Slice 3):
- The **full** pedigree is `pedigreeResults$processedPedigree()`, not `analysisPedigree`, because
  a focal-animal trim would drop animals that were alive on a past date.
- The settings (`guIter`, `guThresh`, species tables, kinship overrides, twin relations) come from
  the last Genetic Value analysis, captured with it the way `snapshotSource` already is
  (the #150 pattern, S760), so the rows match the analysis the user just ran. The panel is
  unavailable until an analysis has run, like Generate Snapshot.
- `modSnapshotTrendsServer(id, snapshotSource, fullPedigree)`: the new parameter must be read
  (module-contract rule 6), and `test_moduleContract.R:56-58` / the `snapshotSource` tests grow
  with it.
- The panel calls `backfillColonySnapshots()` and appends its `history`; the existing download
  offers the result. Nothing is written without the user's click.
- A date count and a cost line before the run ("about 4 seconds each for a colony this size" is
  the measured figure of §2.5, labelled as an estimate).

**B11. One shared helper.** Population, trim and generation number are done inline in
`modGeneticValue.R:293-312`. The backfill must do the same thing; two copies drift (§2.6). Slice
1's REFACTOR extracts an internal `@noRd` helper used by both, pinned by the existing module tests
and the closure test. The owner has taken the shared helper every time the question was put; it
is listed here so SAFEGUARDS' "refactoring needs plan approval" is met by the owner approving
this document, and is confirmed again when Slice 1 reaches GREEN.

**B12. Limits that stay, and are stated in the help and the guide.**
1. **Today's parentage is used for every date.** A parent identified later is treated as known
   earlier; the reconstructed past looks more complete than the records then.
2. **Today's genotypes are used** when the pedigree has them (`first`/`second` columns).
3. **Only animals with a birth date, or a dated offspring, are placed** (B4, B5).
4. **The effective sizes reflect the definition in §1.3** (a living animal with a recorded
   offspring in the analysed pedigree), so they read low where sires were not recorded (§2.4).
5. **Sampling noise** is as in any snapshot (Dragon 1); two close dates may differ only by it.

---

## 4. Interface catalog (proposed; the slices fix the final names in their RED phase)

| Interface | Kind | Input | Output | Error | Consumers |
|---|---|---|---|---|---|
| `backfillColonySnapshots(ped, dates = NULL, from = NULL, to = NULL, by = "year", guIter, guThresh, existingHistory = NULL, minAnimals = 2L, updateProgress = NULL, ...)` | New `@export`ed function (B1, B2) | a QC'd pedigree; the date grid; required `guIter`, `guThresh`; optional existing history; `...` goes to `reportGV()` (species tables, `kinshipOverrides`, `twinRelations`) | a list: `history` (existing rows plus the new ones, date-ordered, passes `checkSnapshotHistory()`), `support` (B5), `skipped` (date and reason) | `stop()` naming missing columns, an empty grid, or no row at all; per-date failures go to `skipped` | Slice 3 panel, script users |
| `createColonySnapshot(..., membershipRule = "reconstructedLiving")` | Existing export, one more known rule (B3) | as today | as today | an unknown rule still stops; the new rule is verified like `focalPopulation` | the function above |
| `modSnapshotTrendsServer(id, snapshotSource, fullPedigree)` | Existing module, one more parameter (B10) | the full pedigree reactive | as today, plus the panel | `req()` for upstream absence | `R/appServer.R` |
| internal analysis-pedigree helper (B11) | New `@noRd` | a pedigree with a `population` column | the trimmed pedigree with `gen` | as the code it replaces | `modGeneticValueServer`, the function above |

`appendColonySnapshot()` keeps its one-row contract; the function merges internally.
**Declined: exporting the as-of pedigree itself.** It is only half of the safe path (the user
would still choose the rule label) and the owner's scope ruling made the function the unit.

---

## 5. Slices (each one session; strict TDD; `AskUserQuestion` at every phase gate)

Vertical per FM #25: something works at the end of every slice. Verification commands are the
ones in `CLAUDE.md` "Build / Test / Verify" (fast single-file test, clean regression read,
`lintr::lint_package()` with the package loaded, `devtools::check()`).

**Slice 1: the core, for explicit dates (script only).** Adds the `reconstructedLiving` rule and
`backfillColonySnapshots(ped, dates, guIter, guThresh, ...)` returning `history`. RED: (a) a
hand-built 10-animal pedigree whose answers are computed by hand
(`neSexRatio = 4 * M * F / (M + F)` on named living breeders) at two dates, against a "simple"
run that must differ; (b) the closure test on the shipped jmac example at 2018-07-11; (c) pins of
§2.2 (3.9 / 54.1, 62.0 / 68.0, 136.6 / 92.5 at the three dates; deterministic fields exact); (d)
a pedigree missing `exit` or `birth` stops naming it; (e) the new rule is rejected for a
`population` column that does not match the report. REFACTOR: B11. **Done =** those pass, the
full suite and lint are clean, and `R CMD check` is 0/0/0. **Surface:** local R session on the
shipped fixtures; it cannot show how long a much larger colony takes (§2.5) and says nothing
about the app.

**Slice 2: grid, support report, skips (script only).** `from`/`to`/`by`, `minAnimals`, the B5
`support` table, B6 defaults, B7 `existingHistory` skips, B8 per-date failures, `updateProgress`.
Owner calls via `AskUserQuestion`: the B4 default and the B6 start. RED pins §2.3 and §2.4 (the
44 / 21 / 20 line, the 1 / 194 line). **Done =** the function is complete for a script user;
help page and examples with `guIter = 10L` to keep them fast. **Surface and limit:** as Slice 1.
**Built in S1038:** see §5.2.

**Slice 3: the app button.** The panel, the `fullPedigree` parameter, the captured settings, the
dashed line and caption (B3), the module-contract and `snapshotSource` tests. RED includes a
**parity test**: the rows the panel appends equal the function's rows for the same inputs, and a
focal-list pedigree still reconstructs the whole living population (the `processedPedigree`
point). **Done =** tests pass, plus the browser tier: `shinytest2` headless Chrome with the
recipe in `SESSION_NOTES.md` ("browser tier needs `R CMD INSTALL --no-docs --library=<scratch>`,
`R_LIBS=...`, `RENV_CONFIG_AUTOLOADER_ENABLED=false`, `NOT_CRAN=true`, `NPRC_RUN_E2E=true`"), and
a picture of the finished panel opened for the owner before the long tests. A new `test-e2e-*.R`
file needs its line in `.github/workflows/shinytest2.yaml`. **Surface limit:** headless Chrome;
it cannot show how the panel feels on a slow multi-minute build.

**Slice 4: documentation and close-out.** Colony Manager Guide section (`colony-manager-guide.qmd`
near `:1264`), the B12 limits in plain words, `NEWS.Rmd` (release-state wording), the
`_pkgdown.yml` reference entry, the citation checklist (expected N/A: no new displayed statistic,
recorded not assumed), `a2interactive.Rmd` left for its dedicated pass, and the issue closed.
Wording is written as one proposed sentence per place for the owner to edit.

### 5.1 Corrections found building Slice 1 (S1037)

1. **B4 and the exact-match claim (§2.2, Appendix A).** The measured equality with the app at
   2018-07-11 (339 animals, 25 of 25 fields) holds for a population of dated animals only.
   Appendix A's prototype also applies B4, and at the export date that adds two real animals,
   `2NTIGG` and `4R3TIJ` (status UNKNOWN, no exit date, no birth date, one dated offspring each):
   341 against the app's 339. Slice 1 uses dated animals only, so its closure test passes;
   Slice 2 decides B4 and the closure test together.
2. **The `_pkgdown.yml` reference entry belongs in Slice 1, not Slice 4.** The coverage guard
   (`test_pkgdown_reference_config.R`) fails as soon as the function is exported; the spelling
   guard (`test_wordlist_coverage.R`) also reads the new help page. `NEWS.Rmd`, the guide and the
   `a2interactive.Rmd` pass stay in Slice 4 (the owner approved deferring the NEWS entry at the
   RED to GREEN gate; no test guards it).
3. **`guIter` for the closure test is 20.** At 10 the example gives NA for `fg`, `fgSE` and
   `neGD`, which would make "equal on every field" vacuous. With the same seed all 25 fields
   are identical at 20.
4. **Slice 1 returns `list(history = ...)`** so Slice 2 can add `support` and `skipped`
   without changing the shape. Built in S1037 (issue #170): RED `e4b832abd`, GREEN `559e260d7`
   and `9f863265d`, REFACTOR `a20fc3c32` (B11 done, owner approved).

### 5.2 Decided and found building Slice 2 (S1038)

Built in S1038 (issue #170): claim `387771996`, RED `b8d9bfa80`, GREEN `308cf7b0c`, REFACTOR
`1c9e5f28a`; the owner approved every gate and made the two calls below with `AskUserQuestion`.

1. **B4 and the exact-match claim are settled together.** An animal with no birth date counts from
   the day its first dated offspring was born until its exit date ("From first offspring"). An
   animal with no exit date counts only when `isLivingAnimal()` says so (status `ALIVE`, or no exit
   date when the pedigree has no `status` column), so a status-UNKNOWN animal never counts. The two
   UNKNOWN dams of the example (`2NTIGG`, `4R3TIJ`: named once each as a dam, never listed in the
   file, added by the quality check) are out, the rebuilt export date is 339 animals, equal to the
   app's, and the closure test passes unchanged. The rule is the app's own predicate, not a copy
   of it, and it holds for animals with a birth date too (no shipped example has one with status
   UNKNOWN and no exit date). Animals counted under the three rules the owner saw (leave them out /
   from first offspring / also count UNKNOWN), example studbook: 1970 44 / 65 / 65, 1990
   201 / 204 / 204, 2000 230 / 230 / 231, export date 339 / 339 / 341. `neSexRatio`, `neVariance`
   and `fe` were identical under all three on all 102 dates tested (both example studbooks); mean
   kinship differs between the first two on 80 of the 102, by at most 0.0002 from 1990 on and by
   0.015 in 1967.
2. **B6 is the first 1 January with at least `minAnimals` living animals** (default 2): 1966-01-01
   on the example (two animals, one with a birth date and one parent placed by its offspring), 53
   yearly points to 2018-01-01 (the last 1 January on or before the latest date in the data). It
   would be 1967 (7 animals) if undated parents were left out, which is why B4 came first.
   `minAnimals` moves only the default start; a date named in `dates` or `from` is never refused.
3. **The "could also be alive" count of §2.3 was 20 on 1970-01-01 and should have been 24.** It
   left out undated parents whose first dated offspring came after the date (4 that year, two of
   them the UNKNOWN dams). `nPossiblyAlive` counts every animal that is not counted, is not known
   to have been born after the date and had not left by it, which also holds the UNKNOWN-status
   animals: 24 in 1970, 2 in 1990, 2 in 2000, and 57 on 1966-01-01 against 2 living, so the first
   points rest on very little.
4. **Names and shapes, fixed in RED.** The support columns are `snapshotDate`, `nLiving`,
   `nPlacedByOffspring` (the design's `nBoundByOffspring`), `nPossiblyAlive`, `pctSireKnown` and
   `pctDamKnown` (percent of the living animals with a recorded sire or dam, neither blank nor a
   generated stand-in; `NA` when nobody was alive); `skipped` has `snapshotDate` and `reason`; the
   result is `list(history, support, skipped)`; `support` covers every date in the run, skipped and
   failed ones included.
5. **B7 and B8 as built.** Rows of `existingHistory` are kept exactly as given, extra columns
   included (a zero-row history is the same as none); only a (date, `reconstructedLiving`) pair is
   skipped, and the same date under another rule is not. A failing date goes to `skipped` with the
   error message verbatim and one warning says how many; the run stops, naming the dates, only when
   no date at all could be built; dates already there plus failures return the existing history
   with the warning. `updateProgress(n = dates in the run, value = how many are done, detail = the
   date as text)` is called once per date and is not passed on to `reportGV()`.
6. **Argument order.** `backfillColonySnapshots(ped, dates = NULL, guIter, guThresh, from = NULL,
   to = NULL, by = "year", existingHistory = NULL, minAnimals = 2L, updateProgress = NULL, ...)`:
   Slice 1's first four, then the new ones; `dates` cannot be combined with `from`, `to` or `by`.
   `function_argument_linter` objects to required arguments after `dates = NULL`; the design's
   interface table has the same shape and a test pins it, so two argument lines carry a `nolint`.
   The owner kept it at the GREEN to REFACTOR gate (reordering was offered).
7. **Cost.** The default series on the example (53 dates) takes 8.2 s at `guIter = 10` and all 53
   are built; a second call with that result as `existingHistory` skips all 53 in 0.1 s. At
   `guIter = 10` `reportGV()` warns on 52 of the 53 dates that founder genome equivalents are
   undefined, so a panel has to catch those warnings. The 4 s a date at 1,000 iterations of §2.5
   (about 3.5 minutes for 53 dates) is still an estimate, and a larger colony is still unmeasured.
8. **Open for Slice 3: the support preview has no script-callable twin.** B10 shows the support
   table for the whole grid before the run (counts only, no gene drop). Today those counts exist
   only inside `backfillColonySnapshots()` (internal `describeBackfillColony()`,
   `supportOnDate()` and `buildBackfillDates()`), so a panel preview would do something no script
   can, against B1's promise that the app never does more than the function. Slice 3's PRE-RED
   puts it to the owner: export a small preview function, or accept an app-only preview. Also for
   Slice 4's B12 sentence: an UNKNOWN-fate ancestor with no exit date still counts as a living
   breeder inside the estimators, which read the exit column as the app does, although it is not
   counted in `nAnimals`.

---

## 6. Impact analysis

| System | Impact | Action |
|---|---|---|
| `reportGV()` and the estimators | **Unchanged**, consumed (§1.2). | None. |
| `createColonySnapshot()` | One more known rule. | Slice 1 tests the old two rules still behave. |
| `modGeneticValueServer` | Population/trim code moves to a helper (B11); `snapshotSource` gains settings fields (B10). | Existing tests pin behavior. |
| `modSnapshotTrendsServer`, `appServer.R:527` | One more parameter and a panel. | Slice 3. |
| Recorded snapshot histories and the shipped example history | **Unchanged**; schema stays version 1. | None. |
| `plotSnapshotTrends()`, `calcSnapshotDeltas()` | Style only (B3); no logic change. | Slice 3. |
| `DESCRIPTION` | Unchanged. | Re-confirm at each close-out. |
| CRAN write policy | No new write path. | Reviewers check. |
| `NEWS.Rmd`, guide, `_pkgdown.yml` | New entries. | Slice 4. |

---

## 7. Here be dragons

1. **Two copies of the population rule drift** (§2.6). B11 and the closure test are the guard.
2. **The focal-trim hazard.** Feeding `analysisPedigree` to the backfill silently shrinks every
   past population. Slice 3's parity test names it.
3. **Time-dependent definitions look like trends.** `neSexRatio` for 1990 is low because one sire
   was recorded (§2.4). The support report and the guide sentence exist so a manager does not read
   the data gap as a collapse.
4. **Cost on a large colony is unmeasured** (§2.5). Slice 3 shows the date count first and
   Slice 1 records a timing on the shipped examples; a bigger fixture is the owner's to supply.
5. **A date with fewer than two living animals** stops `reportGV()`; B8 reports it.
6. **Hand editing.** A reconstructed row edited by hand is indistinguishable from a computed one;
   the guide's existing warning against editing metric columns applies.
7. **Excel round-trip precision** is as in D2 / Dragon 5.

---

## 8. Alternatives considered

| Alternative | Pros | Cons | Why not |
|---|---|---|---|
| Export only an "as-of pedigree" helper plus a guide recipe | Smallest; no schema or rule change | The user picks the label and can mix reconstructed with recorded rows in one line, the risk D3/D4 exist to prevent | Owner chose function plus button (B1) |
| Reuse the `focalPopulation` label | No `createColonySnapshot()` change | Passes the validator and mixes two different populations and two kinds of record | B3 |
| Simple route (set only the population) | One line for a script user | Wrong effective sizes (§2.2) | The reason this design exists |
| Cut the pedigree back by birth date as well as blanking | Reads as more careful | No change in any number (§2.2) and more code | B2 |
| Refuse dates with thin data | Safer-looking | An invented cut-off (D6) and loses the early history | B5 |
| Count animals with no birth date as alive for all dates before their exit | No undercount | Invents presence; overstates early years by up to the 33 | B4 |
| Per-animal detail rows | Richer | Needs the #150 gate (D8) | Declined in D1 |
| Do not build | Nothing to maintain | Trends take seasons to appear; the simple route stays available and wrong | The owner chose to build |

---

## 9. Close-out checklist mapping

This session changes no `R/`, `tests/` or `man/` file, so lint, `R CMD check`, `NEWS.Rmd`,
`_pkgdown.yml`, the citation checklist and the `a2interactive.Rmd` checklist are **not owed
this session**; they are owed at the slices as listed in §5. The `BACKLOG.md` block is rewritten
(not removed; implementation remains) and the GitHub issue was filed later, as #170 in S1037.

---

## 10. Provenance

Read in full or in the cited part: the S756 plan above; `R/reportGV.R`; `R/createColonySnapshot.R`;
`R/snapshotSchemaColumns.R`; `R/getLivingBreeders.R`; `R/getGVPopulation.R`; `R/isLivingAnimal.R`;
`R/autoIdFormat.R:120-175`; `R/modGeneticValue.R:270-385`; `R/modPedigree.R:360-430, 770-800`;
`R/appServer.R:300-345, 436-470`; `R/modSnapshotTrends.R` (outline); `R/plotSnapshotTrends.R:42-135`;
`R/checkSnapshotHistory.R`; `R/appendColonySnapshot.R`; `inst/extdata/examples/example_snapshot_history.csv`;
`tests/testthat/helper-jmacExample.R`; `tests/testthat/test_jmacExampleData.R`;
`colony-manager-guide.qmd:1264-1300`; `NEWS.Rmd:387-406`. Measured with `pkgload::load_all()`
scripts in the session scratch directory (not committed); Appendix B says how to repeat them.

---

## Appendix A. Reference prototype (not shipped code)

This is the method that produced §2.2 and §2.3. The final function belongs to Slice 1.

```r
## ped: qcStudbook() output with id, sire, dam, sex, gen, birth, exit (Date columns)
asOfPedigree <- function(ped, asOf) {
  standIn <- isGeneratedUnknownId(ped$id, ped = ped)
  kids <- ped[!standIn & !is.na(ped$birth), ]
  firstKid <- as.Date(
    tapply(c(kids$birth, kids$birth), c(kids$sire, kids$dam), min),
    origin = "1970-01-01"
  )[ped$id]                                     # earliest dated offspring per animal
  ped$exit[!is.na(ped$exit) & ped$exit > asOf] <- NA   # B2 step 1
  dated   <- !standIn & !is.na(ped$birth) & ped$birth <= asOf & is.na(ped$exit)
  bounded <- !standIn & is.na(ped$birth) & !is.na(firstKid) &
    firstKid <= asOf & is.na(ped$exit)                 # B4
  ped$population <- dated | bounded
  ped
}

snapshotAsOf <- function(ped, asOf, guIter, guThresh) {
  p <- asOfPedigree(ped, asOf)
  p <- trimPedigree(p$id[p$population], p,
                    removeUninformative = FALSE, addBackParents = FALSE)
  gv <- reportGV(p, guIter = guIter, guThresh = guThresh, byID = TRUE)
  createColonySnapshot(p, gv, "focalPopulation",     # becomes "reconstructedLiving" (B3)
                       guIter = guIter, guThresh = guThresh, snapshotDate = asOf)
}
```

## Appendix B. How to repeat the measurements

1. `j <- read.csv(<jmac csv>, na.strings = c("", "NA"), check.names = FALSE)`, then
   `qcStudbook(j, minSireAge = 0, minDamAge = 0, reportChanges = FALSE, reportErrors = FALSE)`.
   (Without `na.strings` the blank cells become `""`, which is "both a sire and a dam"; without
   the two zeros QC stops on low parent age.)
2. For the **app-faithful reference** run `setPopulation(r, r$id[isLivingAnimal(r)])`, then the
   trim and `reportGV()` of `modGeneticValue.R:302-342`, then `createColonySnapshot()`.
3. For each date apply `asOfPedigree()` (§2.2 "blanked") or only set
   `population <- real & birth <= T & (is.na(exit) | exit > T)` and leave `exit` alone ("simple").
4. Timing: repeat with `guIter = 1000L`.

## Appendix C. GitHub issue text (filed as #170, S1037)

**Title:** Build earlier Genetic-Health Trends snapshots from studbook birth and exit dates

**Body:** Today the Genetic-Health Trends tab shows a trend only after snapshots have been
recorded over several seasons. Add an exported `backfillColonySnapshots()` that rebuilds one
snapshot per past date from the birth and exit dates in the pedigree, and a "Build earlier
snapshots" button on the tab that calls it. Rebuilt rows carry their own membership rule
(`reconstructedLiving`), so they form a separate line and never mix with recorded snapshots.
Each date comes with a support report (animals counted, animals that might also have been alive,
share with a recorded sire and dam). Design, measurements and slices:
`docs/planning/retrospective-snapshot-backfill-plan.md`. Follows the optional Slice 5 of #167
(closed). Four slices, strict TDD, each its own session.
