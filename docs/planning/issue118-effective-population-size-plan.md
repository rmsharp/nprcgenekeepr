# Issue #118 -- Effective population size (Ne) estimates

**Status:** PLAN (Session 309, 2026-07-07). Owner scope decisions were gathered
*this* session (Section 5.1) via `AskUserQuestion`; a small set of sub-decisions
(Section 5.2) remain to ratify at the Slice-1 gate. The deliverable of a planning
session is this document; implementation is separate sessions, one estimator each,
per `SESSION_RUNNER.md` (FM #18, no planning-to-implementation bleed).

**Issue:** [#118](https://github.com/rmsharp/nprcgenekeepr/issues/118) -- "Add the
effective population size estimate". Body in full: *"place to locate output has not
been determined."* Triaged Session 308
(`docs/audits/ISSUE_118_EFFECTIVE_POPULATION_SIZE_TRIAGE_2026-07-07.md`) -- that
triage is the seed of this plan's inventory.

**How this plan was built:** the S308 triage + a firsthand evidence sweep this
session (read `reportGV.R`, `makeFounderStatsTable.R`, `findOffspring.R`,
`offspringCounts.R`, `modGeneticValue.R`, `modSummaryStats.R`; an `Explore`-agent
wiring/test map; and a **worked numeric Ne computed on the bundled example
pedigree**, Section 4). Confidence: high on the machinery and the population
definition; the open items are display labeling and the exact E3 variance-formula
variant (Section 5.2 / Section 8).

**Scope note (E4 deferred).** The owner chose to implement **E1 + E2 + E3** now and
**defer E4** (rate-of-coancestry Ne). E4's avenues (compute generation length from
the data + a user slider; a cross-generation coancestry-rate estimate) are recorded
as a comment on issue #118 for future work -- see Section 11. This plan does **not**
implement E4.

---

## 1. Context

### Problem

Issue #118 asks for "*the* effective population size," as if Ne were one quantity.
It is not: **Ne names a family of estimators** (triage Section 2), each answering a
different management question. The owner has resolved the ambiguity by selecting a
labeled set of three, each surfaced as its own clearly-named metric rather than one
ambiguous "Ne":

- **E1 -- gene diversity from FG** (`GD = 1 - 1/(2*FG)`): how much founding-gene-pool
  diversity survives. Nearly free -- FG is already computed.
- **E2 -- demographic sex-ratio Ne** (`4*Nm*Nf/(Nm+Nf)`): diversity loss from an
  unequal breeding sex ratio.
- **E3 -- variance effective size** (`~ (4N-4)/(Vk+2)`): diversity loss from unequal
  family sizes (the dominant Ne-reducer in a harem colony).

### Constraints (hard)

- **Strict TDD** for every code slice (RED -> GREEN -> REFACTOR, gated; declare the
  phase every response).
- **Additive / golden-master:** existing values (`fe`, `fg`, `fgSE`, founder counts,
  the `reportGV` bundle names, the `$report` columns) must NOT change. Each Ne scalar
  rides additively into the bundle and the display, exactly as `fgSE` did beside `fg`
  (issue #82 Slice 3).
- **Build-equivalent:** `devtools::check()` = 0 errors / 0 warnings / 0 notes; full
  test suite green; `spelling::spell_check_package(".")` = 0 (a 0/0/0 check does NOT
  imply spelling-clean -- Learning 175).
- **Determinism:** E2/E3 are deterministic pure functions of the pedigree (no RNG),
  so their tests need no seed. E1's `GD` is a pure function of the existing `fg`
  scalar. Tests should assert exact closed-form values on a small crafted or bundled
  pedigree.
- **Documentation:** the estimator and its idealizing assumptions must be explained
  in user-facing documentation where the estimate is displayed (the #82 D6 / #2 D5
  "explain the estimate where it appears" precedent).

### Interactions

- E1 is a pure function of `fg` (already in the bundle) -- it introduces **no new
  population machinery**. It is the natural tracer-bullet first slice.
- E2 and E3 both need the **current-living-breeder set** (Section 3). The first of
  them to be implemented builds a shared helper; the second reuses it.
- None of E1/E2/E3 touch QC, candidate finding, or breeding-group formation. Blast
  radius is low: a new scalar in the `reportGV` bundle and a new labeled cell/row in
  the founder-stats display surface, per estimator.

---

## 2. The three estimators (definitions -- verified against the sources)

| # | Metric (display name) | Formula | Inputs | Population | Degeneracy -> value |
|---|---|---|---|---|---|
| E1 | Gene diversity (GD) | `GD = 1 - 1/(2*FG)` | `fg` scalar (already in bundle) | same as FG (the analysis/proband set) | `fg` is `NA` (existing zero-retention degeneracy) -> `GD = NA` |
| E2 | Effective size, sex ratio (Ne_sr) | `4*Nm*Nf/(Nm+Nf)` | counts of living **breeding** males `Nm` and females `Nf` | current living breeders | `Nm==0` or `Nf==0` -> `Ne_sr = 0` (or `NA` -- Section 5.2 D-c) |
| E3 | Effective size, variance (Ne_v) | `~ (4N-4)/(Vk+2)` (stable-pop form; see Dragon D-7 for the mean-adjusted form) | `N` = number of living breeders; `Vk` = variance of lifetime offspring counts among them | current living breeders | `N < 2` -> `Ne_v = NA`; `Vk` undefined for `<2` breeders |

**These are not interchangeable** and, importantly, **E1 and E2/E3 are computed over
different populations** (E1 over the FG/analysis set; E2/E3 over living breeders).
That mismatch is real and defensible -- GD is about the founding gene pool retained
in the whole analyzed pedigree; the demographic Ne's are about the *current breeding*
subset -- but it MUST be made explicit in the display or it misleads (Dragon D-1 /
decision D-a).

**E1 note.** `GD` is gene diversity (expected heterozygosity retained), the
FG-based reading of "effective." The owner selected it as the near-free member of the
labeled set; the plan reports `GD` beside `FG` and labels `FG` as the effective
number of founder genomes. `GD` is not literally an "Ne count," so its label must say
"gene diversity," not "effective population size."

**E2/E3 assumptions to document (Dragon D-6).** Both idealize a Wright-Fisher
population (constant `N`, discrete generations, defined sex ratio) that a managed
colony violates. Each reported number needs a one-line "what this assumes" note, the
same discipline #82 applied to the FG sampling SE.

---

## 3. The population: "current living breeders" (exact, evidence-based)

The owner chose **current living breeders** as the population for E2/E3. Every
predicate below is a confirmed package convention (firsthand + the `Explore` map):

- **Living** -- `is.na(ped$exit)`. `exit` is guaranteed present after `qcStudbook()`
  (`R/setExit.R:44-66`, wired at `R/qcStudbook.R:272`); `NA` means "still living."
  This exact idiom is repeated across `reportGV.R:80-82`, `findOffspring.R:25-27`,
  `offspringCounts.R:29-31`, `setPopulation.R:26`, `trimPedigree.R:42`,
  `fillBins.R:19-20`.
- **Breeder** -- id appears as a `sire` or a `dam`. Reuse `findOffspring()`
  (`R/findOffspring.R:32-43`): a breeder is a proband whose offspring count `> 0`.
  `tapply(ped$id, as.factor(ped$sire), length)` drops `NA` parents automatically.
- **Exclude generated-unknown (U-id) parents** -- `!isGeneratedUnknownId(id)`
  (`R/autoIdFormat.R:109-111`, default prefix `"U"`), the same exclusion
  `reportGV.R:229-232` already applies to founder counts.
- **Known sex only, for E2's Nm/Nf** -- `sex == "M"` / `sex == "F"`. The `sex` column
  is a factor with levels `c("F","M","H","U")` (`R/convertSexCodes.R:37-52`);
  `convertSexCodes` maps `NA -> "U"` and (default `ignoreHerm=TRUE`) hermaphrodite
  `-> "U"`, so realistic values are `M`/`F`/`U`. `sex == "M"` / `sex == "F"` cleanly
  excludes `U`/`H` (Dragon D-2).

**Reference filter (living breeders):**

```r
living      <- is.na(ped$exit)
parentIds   <- c(ped$sire, ped$dam)
parentIds   <- parentIds[!is.na(parentIds)]
parentIds   <- parentIds[!isGeneratedUnknownId(parentIds)]
isBreeder   <- ped$id %in% unique(parentIds)
livingBreeder <- living & isBreeder            # the E2/E3 population
Nm <- sum(ped$sex[livingBreeder] == "M")       # known-sex breeding males
Nf <- sum(ped$sex[livingBreeder] == "F")       # known-sex breeding females
```

**Decision surfaced (D-b):** the living-breeder set is derived from the `ped`
data.frame, *independent of* the `reportGV` proband/`population` selection (which is
the analysis set for kinship/FG). The two can differ. The recommendation is to
compute Ne over living breeders **within the analyzed pedigree** and to label the
population explicitly; ratify at the Slice-1 gate.

---

## 4. Worked example (concrete, on the bundled example pedigree)

Computed this session on `nprcgenekeepr::examplePedigree` after `qcStudbook()`
(analysis only; no package code changed). This makes the "cheap to compute now"
claim concrete rather than asserted (addresses the S308 self-assessment gap):

| Quantity | Value |
|---|---|
| animals (post-QC) | 3694 |
| living (`is.na(exit)`) | 1704 |
| distinct breeders (appear as sire/dam) | 554 |
| **living breeders** | **156** |
| living-breeder sex counts | `Nm = 35`, `Nf = 121` (0 `H`/`U`) |
| **E2** `= 4*35*121/(35+121)` | **108.59** |
| living-breeder `N`, mean offspring, `Vk` | `N = 156`, `kbar = 5.28`, `Vk = 16.54` |
| **E3** `~ (4*156-4)/(16.54+2)` | **33.45** (simple stable-pop form) |
| **E1** `GD = 1 - 1/(2*FG)` | e.g. `FG = 20 -> GD = 0.975` (uses the run's `fg`) |

**Takeaway for the plan:** E2 (108.6) is ~3.2x E3 (33.5). Reproductive skew drags
the effective size far below the sex-ratio figure -- exactly the harem-colony effect
the triage predicted, and a strong argument for reporting E2 and E3 *together and
distinctly* (owner's labeled-set choice). Note `kbar = 5.28 != 2`: the colony is not
at simple replacement, which is precisely why the E3 variant matters (Dragon D-7).

*(The example used the now-deprecated `minParentAge=2`; qcStudbook now warns and
prefers `minSireAge`/`minDamAge` -- the QC result and these counts are unaffected.
Slice fixtures should use `minSireAge`/`minDamAge` per S307.)*

---

## 5. Decisions

### 5.1 Gathered this session (owner, via AskUserQuestion)

- **Estimators: E1 + E2 + E3**, as a labeled multi-metric block (triage Option 5).
  Each is its own TDD slice.
- **Population: current living breeders** (for E2/E3), with a documented "breeder"
  definition (Section 3).
- **Display home: the GVA founder-stats surface** (beside FE/FG).
- **E4: deferred**, its avenues saved as an issue comment (Section 11).
- **E4 generation-length insight (owner):** in a controlled colony generation length
  is arbitrary; it could be (a) computed from the data (mean parent age at offspring
  birth) as a principled default and/or (b) user-set via a slider for sensitivity.
  Recorded for the future E4 effort; not implemented here.

### 5.2 Remaining sub-decisions to ratify at the Slice-1 gate (AskUserQuestion)

| # | Decision | Recommendation | Why it matters |
|---|----------|----------------|----------------|
| **D-a** | Display: one founder-stats table with Ne cells appended, OR a **separate labeled "Effective Population Size" block** in the same Summary-Statistics panel. | **Separate labeled block** (same `renderUI`, same tab), each row named with estimator + population. | The founder table's FE/FG are over the analysis set; E2/E3 are over living breeders. Appending them as unlabeled columns of a "Founders" table conflates two populations (Dragon D-1). A separate block keeps the story honest and still lives "in the founder-stats surface." |
| **D-b** | Population source: living breeders within the analyzed pedigree, independent of the proband/`population` selection. | **Yes** -- compute over living animals in `ped`; label the population. | The analysis set (probands) and the current-breeder set differ; the label must say which (Section 3). |
| **D-c** | E2 degeneracy when `Nm==0` or `Nf==0`. | `Ne_sr = 0` with the cell shown as `0` (a colony with one breeding sex has ~no effective diversity contribution from sex balance). Alternative: `NA`. | Small/founding colonies can have one sex only; pick a sentinel and mirror the `makeFounderStatsTable` `N/A` pattern. |
| **D-d** | E3 formula variant. | Start with the **mean-adjusted Crow-Kimura form** (Dragon D-7), NOT the bare `(4N-4)/(Vk+2)` used in the Section-4 illustration, because `kbar != 2` here. Document the exact formula and its assumptions. | The simple form assumes replacement (`kbar ~ 2`); the colony grows, so it overstates Ne. This is the single most consequential correctness choice in the campaign. |
| **D-e** | Function API + names. | New exported pure functions mirroring the `calc*` idiom: `calcGeneDiversity(fg)`, `calcNeSexRatio(ped)`, `calcNeVariance(ped)`; a shared `@noRd` helper `getLivingBreeders(ped)`. `reportGV()` calls them and adds `neGD`/`neSexRatio`/`neVariance` to the bundle. | Matches `calcFE`/`calcFG`/`calcFGSE` (exported, standalone, also called by `reportGV`). Final names are the owner's to bikeshed. |
| **D-f** | Optional `GD` sampling SE. | **Defer / optional.** `GD` is a monotone function of `fg`, so `Var(GD) ~ (1/(2*FG^2))^2 * Var(FG)` gives `gdSE = fgSE/(2*FG^2)` for free from the existing `fgSE`. Nice-to-have, not required for E1. | Keeps E1 a true tracer bullet; can be added later without rework. |

A single scope/approach `AskUserQuestion` poses D-a..D-f before the executor declares
RED on Slice 1 (mirrors the #82 Section 5 ratification gate).

---

## 6. Evidence-based inventory (firsthand + Explore map)

### 6.1 Compute chain (what Ne reuses)

| File:lines | Role |
|---|---|
| `R/calcFEFG.R:54-74` / `R/calcFG.R:64-82` | FG scalar (`$FG`; `NA` on zero-retention degeneracy). E1's `GD = 1 - 1/(2*FG)` reads this. |
| `R/reportGV.R:217` | `feFg <- calcFEFG(ped, alleles)`; `fg = feFg$FG` at `:269`. E1 computed here. |
| `R/findOffspring.R:32-43` | Per-proband offspring counts; breeder = count `> 0`; the `Vk` source for E3. |
| `R/offspringCounts.R:36-46` | Wraps `findOffspring`; `reportGV.R:198` already calls it with `considerPop=TRUE`. |
| `R/isFounder.R:29-31`, `R/autoIdFormat.R:109-111` | Founder / generated-unknown-id predicates (population filtering). |
| `R/convertSexCodes.R:37-52` | `sex` factor `c("F","M","H","U")`; `NA->"U"`; Nm/Nf via `=="M"`/`=="F"`. |
| `R/setExit.R:44-66`, `R/qcStudbook.R:272` | Guarantees `exit`; `is.na(exit)` = living. |

### 6.2 Display surfaces (where Ne appears)

| File:lines | Role | Ne change |
|---|---|---|
| `R/reportGV.R:264-276` | The `nprcgenekeeprGV` bundle (`fe/fg/fgSE/nMale.../total`). | **Add `neGD`, `neSexRatio`, `neVariance` scalars.** Document in `@return` (`reportGV.R:52-69`). |
| `R/modGeneticValue.R:467-478` | Builds the `founderStats` reactive from `fr`. | **Add `ne*` fields** from `fr$ne*`. |
| `R/modGeneticValue.R:394-404` | GV-tab `Metric`/`Value` summary rows (FE/FG). | Add Ne rows (parity with the live founder table). |
| `R/appServer.R:296` | Threads `founderStats = gvResults$founderStats` into `modSummaryStatsServer`. | No change (Ne rides in the list). |
| `R/modSummaryStats.R:623-651` | **Live** founder table (`tags$th`/`tags$td`); the `FG +/- SE` inline pattern at `:641-649`. | **Add the Ne block/cells** here (D-a decides table-cell vs separate block). |
| `R/makeFounderStatsTable.R:37-101` | Exported HTML-string helper; **no runtime caller** (tests only). | Keep in sync for script users (add Ne column) -- but the live surface is `modSummaryStats`. Dragon D-5. |
| user docs (see D6-style set) | Explain each estimate where shown. | Add plain-language Ne notes (Section 8, Slice 4). |

### 6.3 Tests to mirror

| File | What it anchors | Use for |
|---|---|---|
| `tests/testthat/test_reportGV.R:7-22` | `expect_named(bundle, c(...))` + founder-count values. | **Extend** the bundle-name assertion with `neGD/neSexRatio/neVariance`; add value checks. |
| `tests/testthat/test_makeFounderStatsTable.R:18-33` | `grepl("22.30 +/- 0.40", html)`; `N/A`/NULL handling. | Template for an Ne HTML cell test. |
| `tests/testthat/test_modFounderStats.R:45-74` | `makeFounderStatsTable` counts/FE/FG render. | Helper render template. |
| `tests/testthat/test_modSummaryStats.R:286-317` | Module founder-table render; `grepl("52.76 +/- 0.05", html)`. | **Module-render template for the Ne cell/block.** |
| `tests/testthat/test_modSummaryStats_parity.R:161-163` | Asserts header strings ("Founder Equivalents", ...). | Template for asserting a new "Effective Population Size (Ne)" header. |
| `tests/testthat/test_calcFG.R` / `test_calcFEFG.R` / `test_calcFGSE.R` | Exact-value + degeneracy + name-alignment for the `calc*` family. | Structure template for `test_calcNeSexRatio.R` / `test_calcNeVariance.R` / `test_calcGeneDiversity.R`. |

**Test gaps:** no dedicated `findOffspring`/`offspringCounts` test file exists (only
`test_getOffspring.R`, a different function). The Ne slices add the first offspring-
variance coverage. Craft tiny deterministic pedigrees (one-breeding-sex for E2=0;
`N<2` for E3=NA; a skewed-family-size case for E3) rather than leaning on the large
`examplePedigree`.

---

## 7. Key findings (firsthand -- corrections to the triage)

| # | Finding | Evidence | Consequence |
|---|---------|----------|-------------|
| F1 | **The triage's display home is a dead helper.** `makeFounderStatsTable()` has NO runtime caller. | `grep` + Explore map; only a `@seealso` in `makeGeneticSummaryTable.R:17`. | Target the LIVE surface: `modSummaryStats.R:623-651` (+ the `modGeneticValue.R` alt table). Keep the helper in sync for script users, but it is not "the" home. |
| F2 | **`sex` has four levels `{F,M,H,U}`, not just M/F.** `NA->"U"`; hermaphrodite `->"U"` by default. | `R/convertSexCodes.R:37-52`. | E2 counts only `sex=="M"`/`sex=="F"`; `U`/`H` breeders are an explicit edge case (Dragon D-2). |
| F3 | **E1 and E2/E3 use different populations.** GD is over the FG/analysis set; E2/E3 over living breeders. | Section 3; `reportGV` FG is over probands. | Labeling is load-bearing (Dragon D-1 / D-a). A separate labeled block is recommended. |
| F4 | **`kbar != 2` on the real colony** (5.28). | Section 4. | The bare `(4N-4)/(Vk+2)` overstates Ne; use the mean-adjusted form (Dragon D-7 / D-d). |
| F5 | **All E2/E3 inputs are guaranteed at `reportGV` time**; only E4's generation length is absent. | Explore Q7: `id/sire/dam/sex/gen/birth/exit/age/...` all present post-QC. | E1/E2/E3 are implementable now; E4's deferral is the only data-driven gap. |
| F6 | **`GD` and `Ne` are genuinely new.** No `1 - 1/(2*FG)` anywhere. `getGeneticDiversityStats()` is unrelated (age-structure demographics). | Explore Q6. | No resurrection; net-new metric with net-new tests. |

---

## 8. Implementation plan -- vertical slices (one session each)

Each slice is one session under strict TDD; "if I stop here, something works" holds
for each (FM #25). Expect **4 sessions** (E1 + E2 + E3 + a publish/docs session),
plus this planning session.

### Slice 1 = E1 gene diversity (the tracer bullet)

- **Pre-RED:** ratify D-a, D-e, D-f. Read `R/calcFG.R`, `R/calcFEFG.R`,
  `R/reportGV.R`, `test_reportGV.R` firsthand.
- **RED (tests only):** `tests/testthat/test_calcGeneDiversity.R` -- exact value
  `calcGeneDiversity(20) == 0.975`; `calcGeneDiversity(NA) == NA`; monotone in `fg`.
  Extend `test_reportGV.R` bundle-name assertion to include `neGD`; assert
  `bundle$neGD == 1 - 1/(2*bundle$fg)` on `qcPed`. A display test (D-a) asserting the
  GD value/label renders. All fail for the right reason; `fe/fg/fgSE`/counts
  golden-master UNCHANGED.
- **GREEN:** `R/calcGeneDiversity.R` (`@export`, `NAMESPACE`, `man/`, `_pkgdown.yml`);
  `reportGV.R:269`-area adds `neGD = calcGeneDiversity(feFg$FG)` to the bundle
  (`:264-276`) and `@return`; `modGeneticValue.R:467-478` reactive + `:394-404` row +
  `modSummaryStats.R:623-651` cell/block (per D-a). Optional `gdSE` only if D-f = yes.
- **DONE:** GD reported beside FG wherever founder stats show; additive; nothing else
  changes. **Verify:** `devtools::check()` 0/0/0; suite green; spell 0; Phase-3E app
  smoke (GD renders in the Summary-Statistics tab).
- **Session boundary:** STOP.

### Slice 2 = E2 demographic sex-ratio Ne (builds the living-breeder helper)

- **Pre-RED:** ratify D-b, D-c. Read `R/findOffspring.R`, `R/convertSexCodes.R`,
  `R/isFounder.R`, `R/autoIdFormat.R` firsthand.
- **RED:** `tests/testthat/test_calcNeSexRatio.R` on crafted tiny peds --
  balanced (`Nm=Nf=k -> Ne=2k`); skewed harem (`Nm=1,Nf=9 -> 3.6`); one-sex
  degeneracy (`Nf=0 -> 0` per D-c); excludes dead animals, non-breeders, and U-id
  parents; excludes `sex=="U"`/`"H"` from Nm/Nf (F2). A `getLivingBreeders(ped)`
  helper test. Extend `test_reportGV.R` for `neSexRatio`. Display test for the E2
  cell/row. All RED for the right reason.
- **GREEN:** `R/getLivingBreeders.R` (`@noRd` helper: `is.na(exit) & isBreeder &
  !U-id`); `R/calcNeSexRatio.R` (`@export` + docs + pkgdown); wire into the bundle +
  display. Document the sex-ratio idealization (Dragon D-6).
- **DONE:** E2 reported over living breeders, labeled with its population; degeneracy
  sentinel per D-c. **Verify:** as Slice 1 + the app smoke shows E2.
- **Session boundary:** STOP. Here be dragons: F2 (sex codes), D-1 (population label).

### Slice 3 = E3 variance effective size (reuses the helper)

- **Pre-RED:** ratify D-d (the formula variant -- the load-bearing choice). Read
  `R/findOffspring.R`, `R/offspringCounts.R`.
- **RED:** `tests/testthat/test_calcNeVariance.R` -- exact value on a crafted ped with
  known `N`, `kbar`, `Vk` against the RATIFIED formula (D-d); `N<2 -> NA`; equal
  family sizes (`Vk=0`) give the max Ne for that form; a skewed case gives a lower Ne;
  reuses `getLivingBreeders`. Extend `test_reportGV.R` for `neVariance`. Display test.
- **GREEN:** `R/calcNeVariance.R` (`@export` + docs + pkgdown) implementing the
  ratified variant; wire into bundle + display. Document the stable-population /
  mean-family-size assumption prominently (Dragon D-6, D-7).
- **DONE:** the three-metric labeled block complete; E2 vs E3 visibly differ on the
  example colony (Section 4). **Verify:** as Slice 1 + app smoke shows all three.
- **Session boundary:** STOP. Here be dragons: D-7 (formula variant), D-6 (caveats).

### Slice 4 = publish / user documentation

- **Deliverable:** plain-language notes for each metric where it displays (the #82 D6
  precedent -- reconcile the parallel doc surfaces: `genetic_value.html`,
  `population_genetics_terms.html`, `summary_stats.html`,
  `manual_components/_summary_statistics.Rmd`, and the GVA vignette; the executor
  confirms exact paths), the WORDLIST additions (`Ne`, gene-diversity terms), a NEWS
  bullet, and the E4 forward-pointer. Migrate any fixtures off deprecated
  `minParentAge` (S307).
- **DONE:** each Ne is explained where shown, with its assumptions; docs render; spell
  clean. **Verify:** `devtools::check()` 0/0/0; vignettes render; Phase-3E app smoke.
- **Session boundary:** STOP. This slice closes #118 (E1-E3 scope).

---

## 9. Cross-slice notes

- **Additive golden-master:** pin `fe/fg/fgSE`/founder counts and the `$report`
  columns before vs after each slice; they must not move.
- **Reuse, don't recompute:** E1 reads the `fg` already in the bundle (do not
  gene-drop again); E2/E3 share one `getLivingBreeders(ped)` helper.
- **Determinism:** E2/E3 are RNG-free -- assert exact closed-form values on tiny
  crafted peds; no seeds.
- **Labeling over cleverness:** the biggest risk is not the arithmetic (trivial) but
  presenting three different-population metrics without saying which population each
  covers (Dragon D-1). The display work is where care is spent.

---

## 10. Here be dragons (consolidated)

| # | Dragon | Guard |
|---|--------|-------|
| **D-1** | **Ne is not one number, and E1 vs E2/E3 use different populations.** Unlabeled cells mislead. | Label each metric with estimator + population; prefer a separate "Effective Population Size" block (D-a). |
| **D-2** | **`sex` is `{F,M,H,U}`, `NA->"U"`.** Counting `sex != "F"` as male (or vice-versa) miscounts Nm/Nf. | Count only `sex=="M"` / `sex=="F"`; treat `U`/`H` breeders as excluded; test it (F2). |
| **D-3** | **"Breeder" definition is load-bearing.** Living / current / whole-studbook give materially different Ne. | Fix and document the living-breeder definition (Section 3); it is an owner decision (D-b). |
| **D-4** | **Degeneracy.** `Nm==0`/`Nf==0` (E2); `N<2` (E3); `fg==NA` (E1). | Decide sentinels (D-c): E2 -> 0, E3/E1 -> `NA`; mirror the `makeFounderStatsTable` `N/A` cell pattern; test each branch. |
| **D-5** | **`makeFounderStatsTable()` has no runtime caller.** Editing only it changes nothing users see. | Edit the LIVE surface (`modSummaryStats.R`, `modGeneticValue.R`); update the helper only for script-user parity (F1). |
| **D-6** | **Idealized-model caveats.** E2/E3 assume constant N, defined sex ratio, discrete generations. | One-line "what this assumes" beside each number (Slice 4 docs), the #82 discipline. |
| **D-7** | **E3 formula variant.** The bare `(4N-4)/(Vk+2)` assumes replacement (`kbar~2`); the colony has `kbar=5.28`, so it overstates Ne. | Ratify the mean-adjusted Crow-Kimura form (D-d) and document the exact formula; the Section-4 `33.45` is the simple-form illustration, not the shipped formula. |
| **D-8** | **Population source ambiguity.** `reportGV` probands (analysis set) != living breeders. | Compute Ne over living animals in `ped`, independent of the proband selection; label the population (D-b). |

---

## 11. E4 deferral -- future-work record

E4 (rate-of-coancestry Ne, `Ne = 1/(2*dCbar)`) is **out of scope** for this plan.
Its avenues are recorded as a comment on issue #118 (posted Session 309) so nothing
is lost:

- **Generation length** (owner's insight -- arbitrary in a managed colony): compute
  it from the data as the mean age of parents at offspring birth (`birth` + sire/dam
  links are present, so no new bundled constant is needed), used as a default, and/or
  expose a **Shiny slider** (and an R parameter) to override it and watch Ne respond
  (sensitivity analysis).
- **The rate `dCbar`** (the second, harder ingredient): estimate the per-generation
  increase in mean kinship **cross-generationally** from the single pedigree, using
  `findGeneration()`'s per-animal generation numbers to form per-generation mean-
  coancestry cohorts -- feasible today. (A longitudinal mean-kinship series is not
  stored, so the cross-generation route is the tractable one.) Generation-length-in-
  years then only converts the result to a per-year figure.

E4 becomes its own planning/implementation effort after E1-E3 land.

---

## 12. References

- Issue [#118](https://github.com/rmsharp/nprcgenekeepr/issues/118); triage
  `docs/audits/ISSUE_118_EFFECTIVE_POPULATION_SIZE_TRIAGE_2026-07-07.md`.
- Model plan (structure + slice discipline):
  `docs/planning/issue82-fg-se-plan.md` (the FG sampling-SE slices this mirrors).
- Code: `R/reportGV.R`, `R/calcFEFG.R`, `R/calcFG.R`, `R/findOffspring.R`,
  `R/offspringCounts.R`, `R/convertSexCodes.R`, `R/setExit.R`, `R/autoIdFormat.R`,
  `R/isFounder.R`, `R/modGeneticValue.R`, `R/modSummaryStats.R`,
  `R/makeFounderStatsTable.R`, `R/appServer.R`.
- Tests: `test_reportGV.R`, `test_makeFounderStatsTable.R`, `test_modFounderStats.R`,
  `test_modSummaryStats.R`, `test_modSummaryStats_parity.R`, `test_calcFG.R`,
  `test_calcFEFG.R`, `test_calcFGSE.R`.
- Genetics: Lacy, R.C. (1989) *Zoo Biology* 8:111-123 (FE/FG, the E1/GD basis);
  Crow & Kimura (1970) *An Introduction to Population Genetics Theory* (variance and
  sex-ratio effective size, E2/E3); Vinson & Raboin (2015) *JAALAS* 54(6):700-707
  (the colony-management framing the package already advertises).
