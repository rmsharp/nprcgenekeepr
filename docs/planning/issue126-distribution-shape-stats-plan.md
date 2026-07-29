# Issue #126 Plan — Kinship/genome-uniqueness distribution-shape statistics

**Tracks:** GitHub issue **[#126](https://github.com/rmsharp/nprcgenekeepr/issues/126)**
(filed S422, 2026-07-29, from
`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md` Dimension 3 /
Recommendation #2). Sibling of issues #127, #129, #130 from the same audit —
owner-directed sequencing: **planning + implementing #127 and #129 follow #126's
implementation; planning #130 follows all three** (see `BACKLOG.md`).

**Authored:** Session 428 (2026-07-29), **planning session**. TDD phases (RED/
GREEN/REFACTOR) are inapplicable to this document — it is a plan, per this
project's own S423/S426 precedent (issue #125/#128 plans). The implementation
below is its own strict-TDD session (RED -> GREEN -> REFACTOR).

**Evidence base:** firsthand reads this session of `R/summarizeKinshipValues.R`
(entire), `R/makeGeneticSummaryTable.R` (entire), `R/modSummaryStats.R` (lines
560-739, 890-928), `tests/testthat/test_summarizeKinshipValues.R` (entire),
`tests/testthat/test_makeGeneticSummaryTable.R` (entire),
`tests/testthat/test_modSummaryStats_parity.R` (lines 95-141),
`tests/testthat/test_moduleContract.R` (lines 39-47),
`docs/architecture/module-contract.md`, `R/calcNeSexRatio.R` (roxygen style
template), `inst/extdata/ui_guidance/population_genetics_terms.html` (lines
130-187), `NEWS.Rmd` (head), `inst/WORDLIST`; a repo-wide grep for every
`makeGeneticSummaryTable`/`summarizeKinshipValues`/`skew`/`kurtosis` hit; and a
worked computation on the bundled `qcPedGvReport` dataset (Section 4).

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `man/`,
> `NAMESPACE`, or `data/` content is changed by writing it.**

> **RATIFIED this session (2026-07-29), via `AskUserQuestion`.** See §5 for the
> record. Decisions are documented directly below as ratified, not as open
> recommendations, since ratification happened before this document was
> written.

---

## 1. Context

### What issue #126 says

> The 2015 NHP Genetics and Genomics Working Group PDF recommends reporting
> kinship-distribution and genome-uniqueness-distribution shape statistics
> (skewness, kurtosis) as part of colony-level genetic health reporting.
> Currently: `R/summarizeKinshipValues.R` reports only min/quartiles/mean/
> median/max/sd -- no third or fourth moment. `R/makeGeneticSummaryTable.R:
> 47-53` reports genome-uniqueness mean but not its distribution shape.
>
> **Scope note:** the audit frames this as a comparatively small, well-scoped
> addition to `R/makeGeneticSummaryTable.R` / `R/summarizeKinshipValues.R` if
> wanted -- acceptance criteria could plausibly be made explicit enough for a
> `ready-for-agent`-equivalent implementation session (add skewness/kurtosis
> columns to both summary paths, with tests).

### What this session's research found and corrected about the picture

The issue's own citations turned out to point at the **wrong surfaces** — the
same class of drift issue #118's planning session found in
`makeFounderStatsTable()` (its own Dragon F1). Two independent problems:

- **`makeGeneticSummaryTable()` has no runtime caller.** A repo-wide grep for
  every call site outside its own definition file finds exactly two hits:
  `R/makeFounderStatsTable.R:23` (an `@seealso` doc cross-reference) and
  `R/normalizeGvReport.R:7` (a roxygen mention). No Shiny module calls it. It
  is exported and tested (`tests/testthat/test_makeGeneticSummaryTable.R`,
  five `test_that()` blocks) as a **script-user-facing HTML-table helper**,
  not something a user of the live app ever sees.
- **`summarizeKinshipValues()` is a different function on a different
  population.** Its input is `countedKValues` — pairwise **simulated**
  kinship values from the Monte Carlo parentage-uncertainty workflow
  (`createSimKinships()` / `kinshipMatricesToKValues()` /
  `countKinshipValues()`), consumed only by
  `vignettes/simulatedKValues.Rmd`/`.R`, a standalone offline vignette about
  simulating kinship under **unknown-parentage uncertainty** — not the
  colony-wide per-animal mean-kinship distribution the PDF's Dimension 3
  ("Colony/Population Genetic Health Reporting Metrics") actually asks about.

**The actual live surface** — where a user of the running app sees a
mean-kinship/genome-uniqueness distribution table today — is
`R/modSummaryStats.R:590-714`:

- `mkSummaryData <- reactive({ summary(geneticValues()$indivMeanKin) })`
  (`:592-595`) and `guSummaryData <- reactive({ summary(geneticValues()$gu)
  })` (`:597-600`) — **base `summary()`, not `summarizeKinshipValues()` or
  `makeGeneticSummaryTable()`, and not a call to either of the issue's cited
  functions at all.**
- `quartileRow(label, s)` (`:602-613`) renders one HTML table row
  (Min/1st Qu./Mean/Median/3rd Qu./Max) per metric.
- `distTbl` (`:698-714`) assembles the two rows ("Mean Kinship", "Genome
  Uniqueness") into the live table, embedded in the `output$summaryStats`
  `renderUI` (`:616-730`) alongside the founder-stats and Ne blocks (issue
  #118 precedent).
- The server's return list (`:896-928`) already exposes `mkSummary =
  mkSummaryData` and `guSummary = guSummaryData` (`:909-910`) — declared,
  tested API surface with **no internal consumer**
  (`tests/testthat/test_moduleContract.R:44` enumerates them by name; no
  other module reads them via `appServer.R`). This is the established
  precedent this plan's ratified API decision (§5) follows for the new
  shape-statistic reactives.

This re-targets the plan onto the surface that actually matters for the PDF's
own ask (colony-wide reporting, seen by every user of the app), while still
satisfying the issue's literal `makeGeneticSummaryTable.R` citation (same
`indivMeanKin`/`gu` data, same script-user-parity role as
`makeFounderStatsTable()`'s relationship to the live founder table).

---

## 2. Scope (ratified, §5-Q1)

**In scope:**

1. **The live surface** — `R/modSummaryStats.R`'s `distTbl` (`:698-714`) and
   its two reactives `mkSummaryData`/`guSummaryData` (`:592-600`).
2. **`R/makeGeneticSummaryTable.R`** — the exported script-user-parity helper
   the issue names, extended in step with the live surface so it doesn't
   silently fall further out of sync (the same discipline issue #118's Slice
   1-3 applied when it kept `makeFounderStatsTable()` current for script
   users even though it targeted the live surface as primary).

**Out of scope, recorded for a future, separate decision:**

- **`R/summarizeKinshipValues.R`** — a different population (simulated
  pairwise kinship values under parentage uncertainty), a different use case
  (offline vignette exploration, not colony health reporting), and not
  something a running-app user ever sees. Adding skewness/kurtosis here
  would technically close the issue's literal citation but would not serve
  the PDF's actual Dimension-3 ask. If a future session wants this too, it
  is a small, independent addition (same `calcSkewness()`/`calcKurtosis()`
  helpers, §3) — **not implemented by this plan.** Comment this scope
  decision on issue #126 at the start of the implementing session, mirroring
  issue #118's E4-deferral record (§6).

---

## 3. The statistics (definitions — verified against a named source)

**Ratified (§5-Q2): the adjusted Fisher-Pearson standardized moment
coefficients** — the bias-corrected sample skewness (`G1`) and excess
kurtosis (`G2`), following Joanes, D.N. and Gill, C.A. (1998) "Comparing
measures of sample skewness and kurtosis," *Journal of the Royal Statistical
Society: Series D (The Statistician)*, 47(1), 183-189 — their "Method 2",
which is what SPSS, SAS, and Excel report by default, and the same
convention the `moments`/`e1071` CRAN packages call `type = 2`. **No new
package dependency is added** — both formulas are three lines of base-R
arithmetic; pulling in `moments` or `e1071` for two closed-form scalar
formulas would be disproportionate (consistent with how `calcNeSexRatio.R`/
`calcNeVariance.R`/`calcGeneDiversity.R` hand-implement their own formulas
rather than importing a stats package).

For a numeric vector `x` with `n = length(x)` (after removing `NA` when
`na.rm = TRUE`), let `m2 = mean((x - mean(x))^2)`, `m3 = mean((x -
mean(x))^3)`, `m4 = mean((x - mean(x))^4)`:

| Statistic | Formula | Degeneracy |
|---|---|---|
| Skewness (`G1`) | `g1 <- m3 / m2^1.5`; `G1 <- g1 * sqrt(n*(n-1)) / (n-2)` | `n <= 2` -> `NA`; `m2 == 0` (zero-variance / all-identical values) -> `NA` |
| Excess kurtosis (`G2`) | `g2 <- m4 / m2^2 - 3`; `G2 <- ((n+1)*g2 + 6) * (n-1) / ((n-2)*(n-3))` | `n <= 3` -> `NA`; `m2 == 0` -> `NA` |

`G2` is reported as **excess** kurtosis (kurtosis minus 3, so a normal
distribution reads `0`), matching every common statistics package's default
and avoiding a "kurtosis of a normal distribution is 3" surprise in the UI.

**New helper functions** (mirroring the `calc*` exported-function idiom —
`calcFE`/`calcFG`/`calcNeSexRatio`/`calcGeneDiversity`):

```r
calcSkewness(x, na.rm = TRUE)
calcKurtosis(x, na.rm = TRUE)  # excess kurtosis
```

Both `@export`ed, each its own `R/calcSkewness.R` / `R/calcKurtosis.R` file
with a roxygen `@references` citing Joanes & Gill (1998) — satisfying this
project's citation-checklist convention (`CLAUDE.md` "Additional close-out
checks," issue #120) in the same session that ships the feature, not
deferred. Both are pure functions of a numeric vector — no pedigree, no
population-selection logic — so they carry no data-shape assumptions beyond
"a numeric vector," and are trivially reusable by any future caller (see §2's
out-of-scope note on `summarizeKinshipValues()`).

---

## 4. Worked example (concrete, on bundled data)

Computed this session on `nprcgenekeepr::qcPedGvReport$report` (a bundled,
pre-computed `reportGV()` result — no gene-drop re-run, no package code
changed):

| Quantity | `n` | Min | Mean | Max | SD | Skewness (`G1`) | Excess kurtosis (`G2`) |
|---|---|---|---|---|---|---|---|
| `indivMeanKin` (Mean Kinship) | 280 | 0.0027 | 0.0072 | 0.0170 | 0.0035 | **0.3756** | **-0.9982** |
| `gu` (Genome Uniqueness) | 280 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | **NA** | **NA** |

**Takeaways for the plan:**

- **Mean kinship is genuinely informative here.** A mild positive skew
  (0.38, a longer right tail — a minority of animals are noticeably more
  related than the bulk of the colony) and negative excess kurtosis (-1.00,
  flatter/more spread-out than normal, fewer extreme outliers than a bell
  curve would predict) — exactly the kind of shape detail the PDF's
  Dimension-3 ask wants, invisible in the existing min/quartile/mean/median/
  max/sd table alone.
- **The `gu == 0` degeneracy is real, not hypothetical.** This bundled
  dataset's genome-uniqueness values are uniformly `0` (`sd = 0`), so `G1`/
  `G2`'s `m2 == 0` branch fires on live, shipped data — the `NA`-on-
  zero-variance guard (§3) is load-bearing, not a defensive-only edge case.
  This is a strong, real fixture for the degeneracy test (§6 Slice, RED).

---

## 5. Decisions (ratified this session, via `AskUserQuestion`)

| # | Decision | Ratified |
|---|---|---|
| **Q1 — Scope** | Which surfaces get skewness/kurtosis. | **Live surface (`modSummaryStats.R`) + `makeGeneticSummaryTable()`.** `summarizeKinshipValues()` deferred (§2). |
| **Q2 — Formula** | Which skewness/kurtosis variant. | **Bias-adjusted `G1`/`G2`** (Joanes & Gill 1998, "type 2" — §3). |
| **Q3 — Layout** | Where the new stats appear in the live table. | **Extend the existing `distTbl`** with two new columns (Skewness, Kurtosis) rather than a separate block — same MK/GU population already shown there, unlike issue #118's Ne block which needed separation because it covered a *different* population (living breeders vs. the analysis set). |
| **Q4 — API** | Whether to return the new reactives from `modSummaryStatsServer`. | **Yes** — add `mkShape`/`guShape` to the return list, matching the existing `mkSummary`/`guSummary` precedent (`:909-910`) with no internal consumer required, same as those two already have. |

---

## 6. Implementation plan — one vertical slice

The issue's own scope note ("acceptance criteria could plausibly be made
explicit enough for a `ready-for-agent`-equivalent implementation session")
and this session's evidence agree: unlike issue #118 (three architecturally
distinct estimators over two different populations, genuinely requiring
separate sessions), skewness and kurtosis are **the same statistical
transform** applied uniformly to two already-computed vectors
(`indivMeanKin`, `gu`) across two files that both already consume those
exact vectors. This is **one session, one vertical slice** — "if I stop
here, something works" holds after this single slice (FM #25): the live UI
shows the new columns, the script-user helper matches, tests cover both.

### Pre-RED

- Comment the §2 scope decision (defer `summarizeKinshipValues()`) on issue
  #126 itself, so the deferral is visible to anyone reading the issue later
  (the issue #118 E4-deferral precedent).
- Re-read `R/modSummaryStats.R:560-739`, `R/makeGeneticSummaryTable.R`
  (entire), `tests/testthat/test_modSummaryStats_parity.R:95-141`, and
  `tests/testthat/test_moduleContract.R:39-47` firsthand — confirm this
  plan's cited line numbers still match live source (vertical-slice
  contract-reverification gate, `SESSION_RUNNER.md` §Vertical Slice
  Sessions gate (a)).

### RED (tests only)

- `tests/testthat/test_calcSkewness.R` / `test_calcKurtosis.R` — new files,
  mirroring `test_calcFG.R`'s structure (exact-value + degeneracy + `na.rm`
  handling): a known closed-form value on a small crafted vector (e.g. `c(1,
  2, 3, 4, 100)` computed by hand against the `G1`/`G2` formulas in §3);
  `n <= 2` (skewness) / `n <= 3` (kurtosis) -> `NA`; a zero-variance vector
  (`rep(5, 10)`) -> `NA` for both; `NA` handling with `na.rm = TRUE`/`FALSE`.
- Extend `tests/testthat/test_makeGeneticSummaryTable.R` — new
  `test_that()` blocks asserting the HTML table gains Skewness/Kurtosis
  columns/cells with correct values on the existing fixture data.frames, and
  that the zero-variance/NA case renders `"N/A"` via the existing `fmt()`
  helper (`R/makeGeneticSummaryTable.R:56-59` — already `NA`-aware, no
  change needed there).
- Extend `tests/testthat/test_modSummaryStats_parity.R` (the "Item 2: MK /
  GU quartile distribution tables" section, `:98-141`) — assert
  `result$mkShape()`/`result$guShape()` exist and equal
  `list(skewness = calcSkewness(gv$indivMeanKin), kurtosis =
  calcKurtosis(gv$indivMeanKin))` (and the GU equivalent); assert the
  rendered `output$summaryStats` HTML contains `"Skewness"` and `"Kurtosis"`
  header text alongside the existing `"Quartile"`/`"Mean Kinship"`/`"Genome
  Uniqueness"` assertions.
- Extend `tests/testthat/test_moduleContract.R:44` — add `"mkShape"`,
  `"guShape"` to `modSummaryStats`'s declared `names` vector (Q4).
- A degenerate-input test using the §4 worked-example shape (a
  `gu`-equivalent all-identical-value vector) — the real, non-hypothetical
  `m2 == 0` case found this session.
- All new/extended tests fail for the correct reason (functions/columns
  don't exist yet); every pre-existing test in each touched file stays
  green, unmodified.

### GREEN

- `R/calcSkewness.R`, `R/calcKurtosis.R` — `@export`ed pure functions per
  §3, each with a roxygen `@references` citing Joanes & Gill (1998) and an
  `@examples` block using a small crafted vector (matching the `calcFE`/
  `calcNeSexRatio` style). `NAMESPACE`/`man/` regenerated via
  `devtools::document()`.
- `R/makeGeneticSummaryTable.R` — add Skewness/Kurtosis columns to the HTML
  table (both the header row `:62-73` and the two data rows `:76-93`),
  computed via the new `calcSkewness()`/`calcKurtosis()` on `mk`/`gu`
  (`:40,48`), formatted through the existing `fmt()` helper (already
  `NA`-safe).
- `R/modSummaryStats.R` — new `mkShapeData`/`guShapeData` reactives beside
  `mkSummaryData`/`guSummaryData` (`:592-600`); extend `quartileRow()` (or
  add a parallel row-building path) so `distTbl` (`:698-714`) gains
  Skewness/Kurtosis columns in its header (`:701-709`) and both data rows
  (`:711-712`); add `mkShape = mkShapeData`, `guShape = guShapeData` to the
  return list (`:909-910` area, per Q4).
- All new tests pass; every pre-existing test in every touched file stays
  green (golden-master: existing Min/1st Qu./Mean/Median/3rd Qu./Max values
  and HTML must not change, only gain two new columns).

### REFACTOR

- Owner gate per the Development Process Contract (`AskUserQuestion`,
  `GREEN->REFACTOR`) — likely skip if the GREEN implementation is already
  clean, matching S424/S425/S427 precedent for similarly small slices.

### DONE looks like

- The live Genetic Value Analysis Summary Statistics tab's distribution
  table shows Skewness and Kurtosis columns for both Mean Kinship and Genome
  Uniqueness, alongside the existing Min/1st Qu./Mean/Median/3rd Qu./Max.
- `makeGeneticSummaryTable()` (script-user path) shows the same two new
  columns.
- `modSummaryStatsServer()`'s return list exposes `mkShape`/`guShape`,
  enumerated in `test_moduleContract.R`.
- `summarizeKinshipValues()` is unchanged; its deferral is recorded on issue
  #126 as a comment.

### Verify (this session's Build/Test/Verify + Phase 3E)

- Targeted test files green (`test_calcSkewness.R`, `test_calcKurtosis.R`,
  `test_makeGeneticSummaryTable.R`, `test_modSummaryStats_parity.R`,
  `test_moduleContract.R`).
- Clean regression read: 0 failed/0 error/0 warning, count at or above the
  S427 baseline (3928 passed).
- `devtools::check()`: 0 errors/0 warnings/0 notes.
- **`spelling::spell_check_package(".")`** — add `skewness`, `kurtosis`,
  `Pearson`, and `Joanes` to `inst/WORDLIST` in their case-insensitive-
  collation position (none of the four are present today, confirmed this
  session by grep) **before** running the check, hand-added per the S230/
  S421 convention (never `spelling::update_wordlist()`).
- **Citation checklist (issue #120):** update
  `inst/extdata/ui_guidance/population_genetics_terms.html`'s existing
  "Genome Uniqueness (GU)" and "Mean Kinship (MK)" entries (`:130-187`) with
  a short skewness/kurtosis explanation, in the same session — not deferred.
- **NEWS.Rmd**: a new dev-version bullet (matching the issue #125/#128
  bullet style at the file's head), rendered to `NEWS.md` via
  `rmarkdown::render`.
- Phase 3E runtime smoke test: drive the live app via `shinytest2::AppDriver`
  through Input -> Genetic Value Analysis -> Summary Statistics tab;
  confirm the Skewness/Kurtosis columns render with real (non-`N/A`) values
  for Mean Kinship on a synthetic pedigree sized to avoid the §4 GU
  degeneracy (or confirm `"N/A"` renders cleanly if GU is degenerate on the
  chosen fixture — either is an acceptable, informative smoke result).

### Session boundary

STOP. This slice closes issue #126.

---

## 7. Here be dragons

| # | Dragon | Guard |
|---|--------|-------|
| **P1** | **The issue's own citations point at the wrong surfaces** (§1) — `makeGeneticSummaryTable()` has no runtime caller; `summarizeKinshipValues()` is a different population entirely. | Target `R/modSummaryStats.R`'s live `distTbl` as primary (§2); keep `makeGeneticSummaryTable()` in sync for script-user parity; defer `summarizeKinshipValues()` explicitly, recorded on the issue (§2, §6 Pre-RED). |
| **P2** | **Zero-variance degeneracy is real, not hypothetical** — the bundled `qcPedGvReport$report$gu` is uniformly `0` today (§4), so `G1`/`G2`'s `m2 == 0` branch fires on shipped data. | `NA` on `m2 == 0` for both statistics (§3); test it with the real bundled shape, not only a contrived fixture (§6 RED). |
| **P3** | **Small-`n` degeneracy** — `G1` needs `n > 2`, `G2` needs `n > 3`; the adjustment terms divide by `(n-2)` / `(n-2)*(n-3)`, which are `0` or negative right at the boundary. | `NA` for `n <= 2` (skewness) / `n <= 3` (kurtosis), tested explicitly (§6 RED). |
| **P4** | **Excess vs. raw kurtosis convention.** Reporting raw kurtosis (`g2 + 3`) instead of excess (`g2`) would silently disagree with every common stats package and confuse a normal-distribution baseline of `3` instead of `0`. | `calcKurtosis()` returns **excess** kurtosis only (§3); name and roxygen say so explicitly; a UI label reading just "Kurtosis" should be read in context of the docs update (§6 Verify) which states the excess convention. |
| **P5** | **Golden-master discipline.** Both touched display functions already have passing tests asserting exact existing HTML/values (`test_makeGeneticSummaryTable.R`, `test_modSummaryStats_parity.R`). Careless column insertion could shift cell ordering and silently break an existing `grepl()`/`expect_equal()` assertion for the wrong reason. | Re-run the full pre-existing test file after each GREEN edit, not just the new assertions; new columns append, they don't reorder existing ones (§6 GREEN). |

---

## 8. References

- Issue [#126](https://github.com/rmsharp/nprcgenekeepr/issues/126); source
  audit `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`
  Dimension 3.
- Model plan (structure + slice discipline, most analogous prior plan — a
  small multi-metric addition to an existing summary surface):
  `docs/planning/issue118-effective-population-size-plan.md`.
- Joanes, D.N. and Gill, C.A. (1998) "Comparing measures of sample skewness
  and kurtosis." *Journal of the Royal Statistical Society: Series D (The
  Statistician)*, 47(1), 183-189. (The `G1`/`G2` "Method 2" formulas, §3.)
- Code: `R/modSummaryStats.R`, `R/makeGeneticSummaryTable.R`,
  `R/summarizeKinshipValues.R` (deferred, §2), `R/calcNeSexRatio.R` (roxygen
  style template), `R/normalizeGvReport.R`.
- Tests: `tests/testthat/test_makeGeneticSummaryTable.R`,
  `tests/testthat/test_modSummaryStats_parity.R`,
  `tests/testthat/test_moduleContract.R`,
  `tests/testthat/test_summarizeKinshipValues.R` (unchanged baseline).
- Data: `nprcgenekeepr::qcPedGvReport` (the §4 worked-example fixture).
