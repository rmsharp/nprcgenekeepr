# Issue #127 Plan — Surface `correctUnknownParentMeanKinship()`'s silently-dropped `flagged` list

**Tracks:** GitHub issue **[#127](https://github.com/rmsharp/nprcgenekeepr/issues/127)**
(filed S422, 2026-07-29, from
`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md` Dimension 4 /
Recommendation #4). Sibling of issues #126 (DONE, S429), #129, #130 from the
same audit — owner-ratified sequencing (S428, reconfirmed S429): #126 shipped
first; **planning + implementing #127 and #129 are next, either order**;
planning #130 follows both (see `BACKLOG.md`).

**Authored:** Session 430 (2026-07-29), **planning session**. TDD phases
(RED/GREEN/REFACTOR) are inapplicable to this document — it is a plan, per
this project's own S423/S426/S428 precedent. The implementation below is its
own strict-TDD session (RED -> GREEN -> REFACTOR).

**Evidence base:** a parallel research fan-out this session (4 agents) plus
firsthand verification of every load-bearing claim before publication:
firsthand reads of `R/correctUnknownParentMeanKinship.R` (entire),
`R/reportGV.R` (entire), `R/gvaConvergence.R` (lines 148-160),
`R/orderReport.R` (entire), `R/rankSubjects.R` (entire),
`R/classifyParentage.R`, `R/modGeneticValue.R` (call site, DT render, both
CSV download handlers), `tests/testthat/test_correctUnknownParentMeanKinship.R`
(entire), `tests/testthat/test_reportGV.R` (column-contract and
bundled-report-regression sections); a repo-wide grep for every
`reportGV(`/`correctUnknownParentMeanKinship(`/`formatStyle|styleEqual`/
`showNotification` hit; the verbatim Dimension 4 text of the audit document;
and two hand-verified computations on real data (§4) — the bundled
`examplePedigree` (327 probands) and a purpose-built 14-row synthetic
pedigree run through the **full** `reportGV()` pipeline, both confirmed live
via `Rscript`, not estimated.

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `man/`,
> `NAMESPACE`, or `data/` content is changed by writing it.**

> **RATIFIED this session (2026-07-29), via `AskUserQuestion`.** See §5 for
> the record. Decisions are documented directly below as ratified, not as
> open recommendations, since ratification happened before this document was
> written.

---

## 1. Context

### What issue #127 says

> `R/correctUnknownParentMeanKinship()` raises a one-unknown-parent animal's
> mean kinship toward a contemporaneous breeding-age peer-cohort mean,
> directly counteracting the bias the 2015 NHP Genetics and Genomics Working
> Group PDF describes (an unknown/missing parent artificially lowers mean
> kinship).
>
> **Gap:** when no peer cohort exists for an animal, the function returns a
> `flagged` list of uncorrected ids — but nothing in the codebase reads or
> surfaces that flag to the user. Those animals are silently left uncorrected
> with no indication in any report or warning.
>
> **Scope note:** the audit frames this as a small, low-risk fix — surface
> the `flagged` (uncorrected-animal) output somewhere user-visible (a report
> column, or a warning). Acceptance criteria: any animal left uncorrected for
> lack of a peer cohort is visibly flagged in at least one user-facing
> surface (e.g. the genetic-value report or a Shiny warning), with a test
> asserting the flag reaches that surface.

The audit's own Dimension 4 table (verbatim) frames this identically:

> | Handling of the PDF's stated bias (an unknown/missing parent artificially
> lowers mean kinship) | **Implemented** |
> `R/correctUnknownParentMeanKinship.R` raises a one-unknown-parent animal's
> mean kinship toward a contemporaneous breeding-age peer-cohort mean —
> directly counteracts the bias the PDF describes. **Gap noted:** when no
> peer cohort exists, the function returns a `flagged` list of uncorrected
> ids, but nothing in the codebase reads or surfaces that flag to the user —
> those animals are silently left uncorrected |

This session's research confirms the issue's own framing is accurate — there
is no drift to correct here (unlike #126's citation-drift finding). The gap
is exactly as described, and this session found and hand-verified a **real,
non-hypothetical instance of it** (§4), not just a theoretical edge case.

### What this session's research found

- **Two independent callers, both discard `$flagged` identically:**
  `R/reportGV.R:180-186` and `R/gvaConvergence.R:152-157` both chain
  `...)$indivMeanKin` straight off the call, so `$flagged` is discarded at
  the call site itself — there is no local variable anywhere in either
  function that ever holds the flagged ids.
- **`reportGV()`'s `$report` is the only report table rendered to a live
  user.** A repo-wide grep for `reportGV(` finds exactly one call site
  outside tests/examples: `R/modGeneticValue.R:302`
  (`eventReactive(input$runAnalysis, ...)`). From there:
  - `output$rankingsTable <- DT::renderDT({...})` (`R/modGeneticValue.R:379-384`)
    is the primary interactive table shown in the Genetic Value tab.
  - `output$downloadRankings` (`:491-494`) exports the **full** report via
    `write.csv(gvResults(), file, row.names = FALSE)`.
  - `output$downloadGVASubset` (`:496-501`) exports the (optionally
    id-filtered) subset via `write.csv(gvaView(), file, na = "", row.names = FALSE)`.
  - `gvaConvergence()` is exported but **not** wired into the live Shiny app
    (only named in a help-text string, `R/modGeneticValue.R:91`) — a
    script-user-facing diagnostic function, not a UI surface.
- **A precedented, zero-new-plumbing insertion point exists.** The existing
  `parentage` column (`R/classifyParentage.R`, values `"known"` /
  `"one unknown parent"` / `"both unknown"`) is added via a plain `cbind()`
  in `R/reportGV.R:293` and survives `orderReport()`/`rankSubjects()`
  untouched (confirmed by reading both functions in full — `orderReport()`
  only splits/reorders **rows** into ranking tiers and `rbind()`s them back
  together; `rankSubjects()` only **adds** `value`/`rank` columns; neither
  ever subsets or drops columns). Any column added at the `cbind()` stage
  therefore reaches the DT table and both CSV downloads automatically, with
  no new plumbing in `modGeneticValue.R` — exactly like `parentage` does
  today.
- **No conditional-styling precedent exists anywhere in the package.** A
  repo-wide grep for `formatStyle|styleEqual|styleInterval|styleColorBar`
  returns zero hits. `output$rankingsTable` passes a bare data.frame to
  `DT::renderDT` with no `DT::datatable()` wrapper. A row-highlight feature
  would be genuinely new UI code, not an extension of prior art.
- **A notification precedent does exist**, for a different purpose: after QC
  runs, `R/appServer.R:177-207` computes an aggregate error/warning
  condition and fires a three-way `showNotification()` + tab-switch
  (error/warning/message, branching starts at `:182`). This is the closest
  reusable pattern *if* a notification were wanted, but the ratified
  decision (§5) is column-only.
- **No existing test asserts `$flagged` reaches any downstream surface.**
  `tests/testthat/test_correctUnknownParentMeanKinship.R` has 4 tests
  directly asserting `res$flagged` on the function's **own** return value in
  isolation (lines 137, 171, 187, 314) — none of them call `reportGV()` or
  `gvaConvergence()`, so the acceptance criteria's "a test asserting the flag
  reaches that surface" is currently unmet anywhere in the suite.

---

## 2. Scope (ratified, §5)

**In scope:** add a new boolean column to `reportGV()`'s `$report`,
populated from `correctUnknownParentMeanKinship()`'s `$flagged`, via the same
`cbind()` mechanism `parentage` already uses. This reaches the live DT table
(`R/modGeneticValue.R:379-384`) and both CSV exports (`:491-494`, `:496-501`)
with no other code change required. A test exercises the full `reportGV()`
pipeline (not just the correction function in isolation) and asserts the
flag reaches `$report`, satisfying the issue's own acceptance criteria.

**Out of scope (deferred, ratified):**
- **`R/gvaConvergence.R:152-157`** — an independent second caller of
  `correctUnknownParentMeanKinship()` that discards `$flagged` the identical
  way, but is a script-facing diagnostic function, not wired into the live
  Shiny UI. The issue's acceptance criterion ("at least one user-facing
  surface") is fully satisfied by `reportGV()` alone. Recorded as a
  deliberate deferral via a comment on issue #127 at Pre-RED (mirroring the
  #126 `summarizeKinshipValues()` deferral precedent), not silently left as
  an apparent oversight.
- **A Shiny notification banner.** The report column alone satisfies
  visibility; no new notification/tab-switch UI code is added.
- **Row-highlighting / conditional DT styling.** No precedent exists to
  extend (§1); the plain boolean column, sortable/filterable in the DT
  table like any other column, is the minimal fix matching the issue's own
  "small, low-risk fix" framing.

---

## 3. The mechanism (design — verified against source)

### 3.1 Call-site change (`R/reportGV.R:180-186`)

Today:
```r
indivMeanKin <-
  correctUnknownParentMeanKinship(indivMeanKin, ped,
    gestationTable = gestationTable,
    breedingTable = breedingTable,
    breedingAgeDefault = breedingAgeDefault,
    gestationDefault = gestationDefault
  )$indivMeanKin
```

Changes to capture the full return value, then derive a `probands`-aligned
boolean vector:
```r
mkCorrection <-
  correctUnknownParentMeanKinship(indivMeanKin, ped,
    gestationTable = gestationTable,
    breedingTable = breedingTable,
    breedingAgeDefault = breedingAgeDefault,
    gestationDefault = gestationDefault
  )
indivMeanKin <- mkCorrection$indivMeanKin
flagged <- probands %in% mkCorrection$flagged
```

**`probands` is already in scope** at this point in `reportGV()` (defined
`R/reportGV.R:149`, and `indivMeanKin` is itself re-ordered to `probands`
order earlier, at `:172`). Building `flagged` from `probands %in%
mkCorrection$flagged` — **not** the reverse — is load-bearing: it guarantees
`flagged` is a plain `logical` vector in `probands` order, ready to `cbind()`
alongside `indivMeanKin`/`zScores`/`gu`/etc. without any name-alignment step.
Getting this backwards (e.g. subsetting `mkCorrection$flagged` itself, which
is a bare unordered character vector of only the flagged subset) would
silently misalign the column against the wrong rows — see Dragon P1.

### 3.2 Report assembly (`R/reportGV.R:293`)

Today:
```r
finalData <- cbind(
  demographics, indivMeanKin, zScores, gu, guSE, offspring, parentage
)
```
Becomes:
```r
finalData <- cbind(
  demographics, indivMeanKin, zScores, gu, guSE, offspring, parentage, flagged
)
```
Appending at the end (after `parentage`, before nothing else exists yet)
keeps the change purely additive — no existing column is reordered.

### 3.3 Propagation (verified, no code changes needed here)

- `orderReport()` (called from `R/reportGV.R:297`) splits `finalData` into
  five ranking tiers by row and `rbind()`s them back — `flagged` rides along
  on every row exactly like `parentage` does (confirmed by reading the full
  function; the only column-name-aware logic in it, `bothUnknown <- ...`
  and `origin <- ...`, only **reads** `parentage`/`origin`, never drops
  columns).
- `rankSubjects()` (`R/rankSubjects.R`) only **adds** `value` and `rank` to
  each tier's data.frame — confirmed by reading the full function.
- `modGeneticValue.R`'s DT render (`:379-384`) and both CSV download
  handlers (`:491-494`, `:496-501`) pass the report data.frame through with
  no explicit column list — the new column appears automatically.

### 3.4 Roxygen

`reportGV()`'s `@return` documentation (`R/reportGV.R:65-93`) documents the
semantics of every report column already present (`gu`/`guSE`'s
de-inflation policy, etc.). Add one clause for `flagged`: `TRUE` for a
one-unknown-parent animal left uncorrected for lack of an eligible
breeding-age peer cohort (or a missing birth date); `FALSE` for every other
animal, including one-unknown-parent animals that *were* successfully
corrected and all fully-known/both-unknown animals (which are never
candidates for this correction at all).

---

## 4. Worked example (concrete, on real and hand-built data)

### 4.1 A real, non-hypothetical case (bundled `examplePedigree`)

Running the full pre-correction pipeline against the bundled
`nprcgenekeepr::examplePedigree` (327 probands after the standard
`qcStudbook()` -> `setPopulation()` -> `trimPedigree()` sequence from
`reportGV()`'s own `@examples` block) finds **4 animals silently left
uncorrected today**, confirmed live via `Rscript`:

| id | sire | dam | birth | sex | parentage (today's report) |
|---|---|---|---|---|---|
| `5IAFMK` | `U4YSS5` | `WVE6Y4` | 1987-06-24 | F | "one unknown parent" |
| `BCJJKN` | `UA379T` | `JPVAT3` | 1987-04-18 | F | "one unknown parent" |
| `GCBYDW` | `UTKZCG` | `XJ3G42` | 1990-06-26 | F | "one unknown parent" |
| `KZM9RB` | `UWTJQ0` | `BLLUWW` | 1989-05-03 | M | "one unknown parent" |

A colony manager reading today's report sees `"one unknown parent"` for all
four and has no way to know the mean-kinship correction was actually skipped
for them (too few contemporaneous breeding-age peers at their early
1987-1990 birth dates) — exactly the silent gap issue #127 describes. Post-fix,
`$report$flagged` is `TRUE` for these 4 ids and `FALSE` for the other 323.

**Degenerate companion case (worth noting, not fixing):** the two package
data-generating pedigrees (`nprcgenekeepr::qcPed`, 280 probands, and
`nprcgenekeepr::pedWithGenotype`, 280 probands) — used to build the bundled
pre-computed `qcPedGvReport`/`pedWithGenotypeReport` objects (§7 Dragon P2) —
both confirmed live to have **zero** flagged animals. The regenerated bundled
objects' `flagged` column will be all-`FALSE`, a real but uninteresting case;
it is not a substitute for a positive-case test (§4.2).

### 4.2 A hand-verified positive-case fixture for the RED test

`test_correctUnknownParentMeanKinship.R`'s own "flags (not NA) an
empty-cohort animal" fixture (`foc_empty`/`too_young`/`dk2`, lines 156-172)
exercises the correction function in isolation, but **cannot be reused
as-is** to test that the flag reaches `reportGV()`'s report — `reportGV()`'s
full pipeline (via `calcFEFG()`) requires an explicit auto-generated U-id
for a missing parent, not a bare `NA` (§7 Dragon P3), and a 3-row pedigree
has too few founders for `calcFEFG()`'s founder-contribution matrix (§7
Dragon P4).

This session hand-built and verified (via `Rscript`, not estimated) a
14-row fixture that survives the full `reportGV()` pipeline and produces
exactly one flagged animal:

```r
flagPed <- data.frame(
  id    = c("U0001","U0002","M1","F1","M2","F2","P1","O1","O2","O3",
            "too_young_male","dam_known","U0003","Q1"),
  sire  = c(NA,NA,NA,NA,NA,NA,"U0001","M1","M2","M1",
            NA,NA,NA,"U0003"),
  dam   = c(NA,NA,NA,NA,NA,NA,"U0002","F1","F2","F2",
            NA,NA,NA,"dam_known"),
  sex   = c("M","F","M","F","M","F","M","F","M","F",
            "M","F","M","F"),
  origin= c(NA,NA,NA,NA,"CHINA","CHINA",NA,NA,NA,NA,
            NA,NA,NA,NA),
  birth = as.Date(c("2000-01-01","2000-01-01","2000-01-01","2000-01-01",
            "2000-01-01","2000-01-01",NA,"2010-01-01","2010-01-01","2010-01-01",
            "2009-06-01","1995-01-01",NA,"2000-06-01")),
  stringsAsFactors = FALSE
)
flagPed$gen <- findGeneration(flagPed$id, flagPed$sire, flagPed$dam)
```

`Q1` (sire `U0003` unknown, dam `dam_known` known, born 2000-06-01) is the
only one-unknown-parent animal with **no eligible male peer**: the two
candidate founder males (`M1`/`M2`, born 2000-01-01) are not 2+ years older
than `Q1` (the default minimum breeding age), `too_young_male` (born
2009-06-01) postdates her entirely, and `U0001`/`U0003` have no birth date
(excluded by `getBreedingPeerCohort()`'s `!is.na(birth)` filter). `P1`
(both-unknown parentage) is correctly never a candidate for this correction
at all (`xor(sireMiss, damMiss)` is `FALSE` for both-unknown animals).

Confirmed live with `reportGV(flagPed, guIter = 5L)` (small `guIter` for
test speed — the flagging computation itself is deterministic, no gene-drop
involved):
- `nMaleFounders = 3`, `nFemaleFounders = 3` — the pipeline runs cleanly
  (no `calcFEFG()`/founder-contribution degeneracy).
- `mkCorrection$flagged` (via the same code path §3.1 introduces) is
  exactly `c("Q1")`.
- `Q1`'s `indivMeanKin` is `0.07142857` in both the corrected and
  uncorrected vectors (unchanged, confirming it was genuinely skipped, not
  coincidentally equal).
- Every other id (`U0001`, `U0002`, `M1`, `F1`, `M2`, `F2`, `P1`, `O1`, `O2`,
  `O3`, `too_young_male`, `dam_known`, `U0003`) must have `flagged == FALSE`.

---

## 5. Decisions (ratified this session, via `AskUserQuestion`)

| # | Decision | Ratified | Rationale |
|---|---|---|---|
| D1 | Column value format | **Boolean (`TRUE`/`FALSE`)** | Sorts/filters cleanly in the DT table; unambiguous machine-readable semantics. (The recommended alternative — a human-readable label string, matching `parentage`/`value`'s style — was presented and declined.) |
| D2 | `gvaConvergence()` scope | **Deferred** | Not wired into the live Shiny UI; `reportGV()` alone satisfies "at least one user-facing surface." Recorded as an issue #127 comment at Pre-RED, mirroring the #126 `summarizeKinshipValues()` precedent. |
| D3 | Additional Shiny notification | **Column only — no notification** | Matches the issue's own "small, low-risk fix" framing; avoids new UI code with no existing conditional-styling/notification-on-completion precedent to extend for this specific case. |
| D4 | Column name | **`flagged`** (author-proposed, not separately polled) | Direct terminological parity with `correctUnknownParentMeanKinship()`'s own return-list field of the same name (§3.1) — a script user reading that function's roxygen sees the identical word in the report. Subject to the plan's own overall ratification below. |

---

## 6. Implementation plan — one vertical slice

### Pre-RED

- Re-read `R/reportGV.R`, `R/correctUnknownParentMeanKinship.R`,
  `R/orderReport.R`, `R/rankSubjects.R`, and
  `tests/testthat/test_reportGV.R` firsthand — confirm every line number
  cited in §1/§3 still matches live source (vertical-slice
  contract-reverification gate).
- Post the D2 (`gvaConvergence()` deferral) decision as a comment on issue
  #127 itself, per §5.

### RED (tests only)

1. **New `test_that()` in `tests/testthat/test_reportGV.R`**, using the §4.2
   `flagPed` fixture: `gv <- reportGV(flagPed, guIter = 5L)`; assert
   `"flagged" %in% names(gv$report)`; assert
   `gv$report$flagged[gv$report$id == "Q1"]` is `TRUE`; assert every other
   row's `flagged` is `FALSE` (e.g.
   `expect_false(any(gv$report$flagged[gv$report$id != "Q1"]))`). This is
   the test the issue's acceptance criteria names — the flag reaching
   `reportGV()`'s report, not just the correction function's own return
   value (already covered by 4 pre-existing tests in
   `test_correctUnknownParentMeanKinship.R`, left untouched).
2. **Extend both existing golden `expect_named()` assertions**
   (`test_reportGV.R:7-18` and `:32-43`) — append `"flagged"` to the
   expected column vector **immediately after `"parentage"` and before
   `"value"`**, matching the `cbind()` order in §3.2:
   ```r
   c("id", "sex", "age", "birth", "exit", "population", "sire", "dam",
     "indivMeanKin", "zScores", "gu", "guSE", "totalOffspring",
     "livingOffspring", "parentage", "flagged", "value", "rank")
   ```
3. **Extend the bundled-report regression test**
   (`test_reportGV.R:557-564`, `"bundled GV reports are regenerated to the
   current reportGV structure (issue #86)"`) — add `"flagged"` to the
   `all(c("guSE", "parentage") %in% names(rpt$report))` check for both
   `qcPedGvReport` and `pedWithGenotypeReport`. This will fail until both
   bundled objects are regenerated (GREEN, §7 Dragon P2) — confirm it fails
   for that reason (missing column), not a typo.
4. All new/extended assertions must fail for the correct reason (missing
   column / function not yet returning it); every pre-existing assertion in
   every touched file must stay green.

### GREEN

- `R/reportGV.R`: apply the §3.1 call-site change and §3.2 `cbind()`
  addition exactly.
- `R/reportGV.R`: add the `flagged` clause to the `@return` roxygen (§3.4);
  regenerate `man/reportGV.Rd`.
- Regenerate both bundled report objects per their own documented
  regeneration recipe (`R/data.R:264-280`'s `@source` tag for
  `pedWithGenotypeReport`; `R/data.R:311-324`'s equivalent prose recipe —
  not an `@source` tag — for `qcPedGvReport`) — re-run `reportGV(...)` on
  the same source pedigree with the same documented `guIter`/seed and
  re-`save()` — so they carry the new `flagged` column (§7 Dragon P2).
  Confirm the regenerated `fg`/`fe`/`guSE` values are byte-identical to
  today's (same seed, same inputs) — only the new column should differ.
- `R/gvaConvergence.R:152-157`: leave the discard exactly as-is, but add a
  one-line comment noting the deferral and pointing at issue #127's comment
  (D2) — so a future reader sees a deliberate, documented decision, not an
  apparent oversight matching the very bug this issue fixes elsewhere.

### REFACTOR

Assess once GREEN is committed — this is a small, additive, single-file
core change; likely "skip, already clean" per the S424/S425/S427/S429
precedent for similarly small slices, but the call is the implementing
session's per its own gate.

### DONE looks like

- `reportGV()`'s `$report` (and thus the live Genetic Value DT table and
  both CSV downloads) carries a `flagged` column: `TRUE` for any
  one-unknown-parent animal left uncorrected for lack of an eligible peer
  cohort, `FALSE` otherwise.
- Both bundled `qcPedGvReport`/`pedWithGenotypeReport` objects carry the new
  column (all-`FALSE`, per §4.1's degenerate-case confirmation) with every
  other value byte-identical to today.
- `gvaConvergence()`'s identical discard is untouched but now explicitly
  documented as a deliberate, recorded (issue-commented) deferral.
- A test exercises the **full `reportGV()` pipeline** (not just
  `correctUnknownParentMeanKinship()` in isolation) and asserts the flag
  reaches `$report` — satisfying the issue's own acceptance criteria for
  the first time.

### Verify

- Targeted test files: `test_reportGV.R`,
  `test_correctUnknownParentMeanKinship.R` (confirm untouched, still green),
  `test_modGeneticValue.R` (confirm the new column doesn't break any
  existing `%in% names(...)` presence check — none of them are exhaustive
  per this session's grep, §1).
- Clean regression read (`CLAUDE.md` "Clean regression read" recipe) against
  the current environment baseline (S429 established ~3246 passed on the
  unchanged prior commit + this session's own net new/changed test count).
- `devtools::check()`: 0 errors/0 warnings, and confirm the pre-existing
  `deduplicated`/`selectable` spelling NOTE is the only one (tracked since
  S415, unrelated to this change).
- Citation checklist (`CLAUDE.md` "Additional close-out checks"): this issue
  adds no new *statistic* (it surfaces an existing correction's own
  bookkeeping), so `inst/extdata/ui_guidance/population_genetics_terms.html`
  likely needs no new entry — confirm this reading against the actual page
  content before skipping it, rather than assuming.
- Phase 3E runtime smoke test: drive Input -> Genetic Value Analysis ->
  confirm the `flagged` column renders in the live DT table on a fixture
  that actually has flagged animals — **do not use `examplePedigree`
  end-to-end for the live smoke test** (327-animal gene-drop at a
  reasonable `nIterations` may be slow); the fastest verified path is
  grepping the committed E2E suite for the working
  `obfuscated_rhesus_mhc_ped.csv` + `nIterations = 100` pattern (Learning
  400) and confirming whether that bundled fixture has any flagged animals
  first — if it does not, use the §4.2 hand-built fixture (or a script-only
  confirmation against `examplePedigree`, per §4.1) as the smoke-test data
  instead.

### Session boundary

STOP. This slice closes issue #127 for `reportGV()`; `gvaConvergence()`
remains deliberately open per D2.

---

## 7. Here be dragons

| # | Dragon | Mitigation |
|---|---|---|
| **P1** | **Vector-alignment inversion.** Building the new column from `mkCorrection$flagged %in% probands` (or any form that indexes off the flagged-subset vector rather than the full `probands` vector) would silently misalign the boolean against the wrong rows — `mkCorrection$flagged` is an unordered character vector of only the flagged ids, with no positional relationship to `probands`' row order. | Build strictly as `probands %in% mkCorrection$flagged` (§3.1) — `probands` is the vector already in `cbind()`-order use everywhere else in `reportGV()`. The RED test's per-row assertion (§6 RED step 1) catches an inversion immediately (every row's flag would be reversed). |
| **P2** | **The bundled `qcPedGvReport`/`pedWithGenotypeReport` objects are pre-computed and saved, not regenerated on load** (`R/data.R:264-280`, `:311-324`) — adding a column to `reportGV()`'s live output does **not** retroactively update these `.RData` objects. Both source pedigrees (`qcPed`, `pedWithGenotype`) were independently confirmed this session to have **zero** flagged animals, so the regenerated objects' `flagged` column is a real but degenerate all-`FALSE` case — do not mistake "the bundled report has a `flagged` column that's all FALSE" for "the feature doesn't work"; it means these two colonies simply have no such animals. | GREEN must explicitly regenerate both objects per their documented regeneration recipe (§6 GREEN) — the RED-phase test extension at `test_reportGV.R:557-564` (§6 RED step 3) fails until this happens, by design. |
| **P3** | **`reportGV()`'s full pipeline requires an explicit auto-generated U-id for a missing parent, not a bare `NA`.** `correctUnknownParentMeanKinship()` itself treats `NA` and a U-id identically (`isU()`), but `calcFEFG()` (called earlier in `reportGV()`) throws `"calcFEFG requires complete parentage... id(s) with exactly one known parent"` on a bare `NA` parent — confirmed live this session. | Any RED fixture for the full-pipeline test must give every missing parent an explicit `U`-prefixed placeholder id **with its own row** in the pedigree (matching `makeOriginTestPed()`'s existing convention in the same test file), never a bare `NA`. The §4.2 fixture already does this (`Q1`'s sire is `"U0003"`, itself a row). |
| **P4** | **Too few founders collapses `calcFounderContributions()`.** A first attempt at a minimal 3-4 row fixture failed with `'x' must be an array of at least two dimensions` inside `calcFounderContributions()`/`colMeans()` — confirmed live this session — because the founder-contribution matrix degenerates to a bare vector below some founder-count threshold. | Build any full-pipeline RED fixture with a founder pool comparable in size to the §4.2 fixture (9 founders) rather than the smallest fixture that seems logically sufficient; verify it runs via `Rscript` before trusting it in a test (this plan already did — §4.2's fixture is confirmed working, not theoretical). |
| **P5** | **`gvaConvergence.R:152-157`'s identical discard, left untouched (D2), could read as an oversight** to a future session that finds it independently (exactly how issue #127 itself was found) and re-opens the same investigation. | The GREEN-phase comment (§6 GREEN) plus the issue #127 Pre-RED comment (§5 D2) are the two durable records of the deliberate deferral — both are load-bearing, not optional documentation. |

---

## 8. References

- Issue #127: <https://github.com/rmsharp/nprcgenekeepr/issues/127>
- `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`, Dimension
  4 (verbatim quoted §1) and "Recommendations" item 4.
- `R/correctUnknownParentMeanKinship.R` (the function whose `$flagged` is
  surfaced), `R/reportGV.R` (the caller and insertion point),
  `R/gvaConvergence.R` (the deferred second caller), `R/orderReport.R` /
  `R/rankSubjects.R` (confirmed non-dropping propagation path),
  `R/modGeneticValue.R` (the live rendering/export surfaces),
  `R/classifyParentage.R` (the `parentage` column precedent this design
  follows).
- `docs/planning/issue126-distribution-shape-stats-plan.md` — the immediate
  sibling plan this document's structure and RED/GREEN/DONE-looks-like
  conventions follow.
