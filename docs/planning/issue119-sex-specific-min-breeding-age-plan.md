# Issue #119 Plan — Replace scalar `minParentAge` with sex-specific, table-backed `minSireAge` / `minDamAge`

**Issue:** #119 — "Use of `minParentAge` seems to conflict with newer sex specific
minimum reproductive ages"
**Type:** Implementation plan (multi-slice, strict TDD). **This document is the
deliverable of the planning session (S302). It is NOT implementation.**
**Seed inventory:** `docs/audits/ISSUE_119_MINPARENTAGE_TRIAGE_2026-07-07.md` (S301).
**Author:** Session 302 (2026-07-07).
**Predecessor context:** issue9 plan §8-D deliberately deferred this unification; #119
is that follow-up.

---

## 0. Ratified decisions (owner, S302)

Two decisions were settled with the owner via `AskUserQuestion` before this plan was
written. They set the plan's shape; do not re-open them without the owner.

| # | Decision | Ratified choice |
|---|----------|-----------------|
| D1 | **Breeding-age model** | **Table-backed sex scalars.** `minSireAge` / `minDamAge` default to `NULL`, meaning "look up the floor per **parent** species+sex via `getSpeciesMinBreedingAge()`"; an explicit number the caller passes overrides that sex's floor. Absent/unknown species falls back to `2` (the existing `getSpeciesMinBreedingAge` default), so data with no `species` column behaves exactly as today. Resolves BOTH halves of #119 (sex AND species) with one source of truth; no third parallel notion of breeding age. |
| D2 | **`minParentAge` back-compat** | **Split by surface.** In the **exported R signatures** (`checkParentAge`, `getPotentialParents`, `qcStudbook`, `runQcStudbook`), keep `minParentAge` as a **deprecated alias** — still accepted, sets BOTH `minSireAge` and `minDamAge`, emits a deprecation warning — so external scripts do not break. In the **Shiny UI** (package-internal; we own every caller), **fully migrate** to `minSireAge` / `minDamAge` now — no deprecated parameter left in the app. |

### Deferred RATIFY points (settle with the owner during the named slice, not now)

- **R1 (Slice 3): the 2-vs-3 default.** `getProductionStatus` uses a dam floor of **3**
  (`getProductionStatus.R:55`; its only caller `getGeneticDiversityStats.R:99` passes
  `3L`), everywhere else the default is **2**. Production status counts breeding-capacity
  females for a *demographic ratio* — the 3 may be an intentional, distinct threshold,
  not the same concept as the QC parent-age floor. **Recommendation:** preserve 3 as an
  explicit `minDamAge = 3L` override at the caller (no golden change); document the
  distinct purpose; do NOT silently unify 2→3 or 3→table. Confirm with the owner in
  Slice 3.
- **R2 (Slice 4): Shiny two-field UX.** Replace the single "Minimum Parent Age" text
  input with two optional fields ("Minimum Sire Age (years)", "Minimum Dam Age
  (years)"), blank = use the species+sex table default. Confirm labels/help text and
  whether blank-means-table is the desired UX (vs. prefilled numbers).
- **R3 (Slice 1): deprecation version string.** The `lifecycle::deprecate_warn()` "when"
  argument needs the dev version. DESCRIPTION is `1.1.0.9000`; confirm the exact string
  to stamp at implementation time.

---

## 1. Design summary

### The resolver (shared, tested once, reused by every consumer)

Add one small internal helper that turns the two optional override scalars + a
(species, sex) context into a per-row numeric floor vector:

```r
## internal, @noRd
resolveBreedingAge <- function(species, sex,
                               minSireAge = NULL, minDamAge = NULL,
                               breedingTable = NULL, default = 2.0) {
  floor <- getSpeciesMinBreedingAge(species, sex,
                                    breedingTable = breedingTable,
                                    default = default)
  sexKey <- toupper(trimws(as.character(sex)))
  if (!is.null(minSireAge)) floor[sexKey == "M"] <- as.numeric(minSireAge)
  if (!is.null(minDamAge))  floor[sexKey == "F"] <- as.numeric(minDamAge)
  floor
}
```

- When both overrides are `NULL` → pure table lookup (species+sex correct).
- When an override is supplied → it wins for that sex (back-compat; `minParentAge`
  aliases to both).
- Absent/unknown species → `getSpeciesMinBreedingAge` already returns `default` (2).
- Vectorized: one floor per row, keyed on **that row's own sex** (and, for the
  candidate/female consumers, that row's own species).

`getSpeciesMinBreedingAge` (`R/getSpeciesMinBreedingAge.R`) already exists, is exported,
tested (`test_getSpeciesMinBreedingAge.R`, 30+ assertions), supports an injected
`breedingTable` (user overrides via `loadSpeciesOverrides`), and falls back to 2 for
unknown species / non-M/F sex. **Reuse it; do not reinvent the table.**

### The deprecation recipe (mirror `R/runModularApp.R:25`)

`lifecycle` is already a dependency (DESCRIPTION:47) and `lifecycle::deprecate_soft` is
already used. Apply the standard *deprecated-argument* pattern at each exported entry:

```r
checkParentAge <- function(sb,
                           minSireAge = NULL,
                           minDamAge = NULL,
                           minParentAge = lifecycle::deprecated(),
                           reportErrors = FALSE) {
  if (lifecycle::is_present(minParentAge)) {
    lifecycle::deprecate_warn(
      "<dev-version>", "checkParentAge(minParentAge)",
      details = "Use minSireAge and/or minDamAge instead."
    )
    if (is.null(minSireAge)) minSireAge <- minParentAge
    if (is.null(minDamAge))  minDamAge  <- minParentAge
  }
  ...
}
```

- Use `deprecate_warn` (always warns) rather than `deprecate_soft` (quiet inside
  packages) so external scripts get the signal — BUT that means every existing test /
  vignette / internal caller that still passes `minParentAge` will warn. Therefore each
  slice **migrates its own internal callers and tests to the new params** (so the
  package never triggers its own deprecation warning) and adds an explicit test that the
  alias still works AND warns.
- **Internal caller chain must move together.** `qcStudbook` calls `checkParentAge`
  (`qcStudbook.R:251`); `runQcStudbook`/`modInput` call `qcStudbook`. If Slice 1
  migrated only `checkParentAge`, `qcStudbook` would trip the deprecation warning on
  every QC run. So Slice 1 threads the new params through the whole QC vertical
  (`checkParentAge` → `qcStudbook` → `runQcStudbook`) at once.

### Where the floor keys on species (the parent, not the offspring)

- **`checkParentAge`** operates on **offspring** rows with merged `sireBirth`/`damBirth`.
  The floor must key on the **parent's** species+sex, not the offspring's. Add sire/dam
  **species** via the same merge pattern already used for `sireBirth`/`damBirth`
  (`checkParentAge.R:63-84`), defaulting to `NA` (→ fallback 2) when `sb` has no
  `species` column. In a single-species colony parent species == offspring species, so
  behavior is unchanged; the merge makes it *correct* for mixed-species pedigrees.
- **`getPotentialParents`** filters candidate rows (`ba`) that ARE the potential
  parents — species+sex is on their own row. Straightforward; it already guards
  `if ("species" %in% names(...))` (`getPotentialParents.R:77`).
- **`getProductionStatus`** counts females on their own rows — straightforward; only a
  dam floor applies.

---

## 2. Evidence-based inventory (grep-derived, S302)

Command: `git grep -n "minParentAge" -- R/ tests/ man/ vignettes/ inst/`. Grouped by
role. **Decision sites** are where behavior changes; everything else follows.

### Decision sites (behavior changes here)

| Site | Current use of the scalar | Sex context | Default | Slice |
|---|---|---|---|---|
| `R/checkParentAge.R:94-95` | flags `sireAge < minParentAge` OR `damAge < minParentAge` (one number both) | sire vs dam already separated | 2 | **1** |
| `R/getPotentialParents.R:97` | flat cutoff BEFORE the M/F split (`:104` sires, `:112` dams) | split exists just below | caller | **2** |
| `R/getProductionStatus.R:64` | counts `sex=="F" & age >= minParentAge` | females only | **3** | **3** |

### Plumbing / pass-through (signatures thread the value; migrate with their consumer)

| Site | Role | Slice |
|---|---|---|
| `R/qcStudbook.R:177` (sig), `:251` (calls `checkParentAge`) | QC front door | **1** |
| `R/runQcStudbook.R:40` (sig), `:87`, `:173` | wraps `qcStudbook` | **1** |
| `R/getGeneticDiversityStats.R:99` (passes `minParentAge = 3L`) | only caller of `getProductionStatus` | **3** |

### Shiny UI (fully migrate — package-internal, no external callers)

| Site | Role | Slice |
|---|---|---|
| `R/modInput.R:127-129` | `textInput("minParentAge")` field | **4** |
| `R/modInput.R:448-453` | reads input, NA→2.0 | **4** |
| `R/modInput.R:459`, `:472` | passes to `qcStudbook` / `runQcStudbook` | **4** |
| `R/modInput.R:659-660` | exposes `minParentAge` reactive — **NO consumer found in `appServer.R`** (verify + clean) | **4** |
| `R/modPotentialParents.R:223` (sig `minParentAge = 2.0`), `:264` (→ `getPotentialParents`) | module default | **4** |
| `R/appServer.R:345-350` | invokes `modPotentialParentsServer` **without** `minParentAge` (uses hardcoded 2.0; not wired to the Input field) | **4** |

### Tests (migrate to new params + add deprecation-path tests)

`test_checkParentAge.R` (8), `test_qcStudbook.R` (22), `test_runQcStudbook.R` (1),
`test_getPotentialParents.R` (13), `test_getProductionStatus.R` (13),
`test_modInput.R` (60), `test_modInput_qcStudbook.R` (20), `test_modInput_coverage.R`
(6), `test_modPotentialParents.R` (9), `test_modPotentialParents_coverage.R` (3),
`test_summary.nprcgenekeeprErr.R` (2), `test_print.summary.nprcgenekeeprErr.R` (2),
plus the `test-e2e-*` app files (baseline noise per CLAUDE.md; check they still pass).
`test_species_first_class.R` (3) already exercises species-awareness — align with it.

### Docs / examples / data (Slice 5)

`man/*.Rd` (regenerated by roxygen for every changed signature),
`vignettes/a2interactive.Rmd` (`:129`, `:136`, `:138` footnote about 3.5,
`:143`, `:761`, `:789`, `:802`, `:821`),
`vignettes/articles/studbook-quality-control.qmd` (`:34`, `:67`, `:161`, `:179`,
`:214` param table),
`vignettes/articles/breeding-group-formation.qmd:53`,
`vignettes/articles/genetic-value-analysis.qmd:61`,
`vignettes/ColonyManagerTutorial.Rmd:181-185` (**embeds screenshot
`input_minParentAgeSequence.png` — regenerate or re-caption**),
`vignettes/manual_components/_input.Rmd:68`,
`inst/WORDLIST` (add `minSireAge`, `minDamAge`; the doc build wordlist is curated —
hand-edit, do not run `spelling::update_wordlist`), `NEWS.md` / `CHANGELOG.md`.
`inst/extdata/*` (`claude_code.qmd`, `trulyUnknownParents.R`, `meeting_notes.*`) are
example/history — update only where they are live example code, not archived notes.

### Already sex/species-aware (reuse; do not touch beyond wiring)

`R/getSpeciesMinBreedingAge.R`, `R/getSpeciesGestation.R`, `R/loadSpeciesOverrides.R`,
`R/correctUnknownParentMeanKinship.R:54-58`, `data-raw/speciesGestation.R` /
`data/speciesGestation.RData`.

---

## 3. Vertical slices (one session each; strict TDD; close out per slice)

Each slice is an end-to-end path: parameter → decision → output → tests → docs-for-that-
surface, and the package builds & tests clean after it. Apply the test: *"if I stop
here, does something work?"* — yes at every slice boundary. Do NOT bundle slices.

### Slice order & dependencies

```
Slice 1 (QC vertical: checkParentAge + qcStudbook + runQcStudbook + resolver helper)
Slice 2 (getPotentialParents)              ── both feed ──►  Slice 4 (Shiny UI wiring)
Slice 3 (getProductionStatus + caller)     ── independent
Slice 5 (docs/vignettes/screenshot)        ── last; reflects 1–4
```

Slice 1 and Slice 2 are independent of each other. Slice 4 depends on Slice 1 (new
`qcStudbook`/`runQcStudbook` params) **and** Slice 2 (new `getPotentialParents` params).
Slice 3 is independent. Slice 5 comes last.

---

### Slice 1 — QC vertical: `checkParentAge` + `qcStudbook` + `runQcStudbook` (+ resolver)

**Why first:** `checkParentAge` inside `qcStudbook` is the front door for nearly every
workflow — highest value, and building the shared `resolveBreedingAge` helper here
de-risks Slices 2–3.

**RED (tests first):**
- `resolveBreedingAge`: table lookup when both overrides NULL; sire override applies to
  M only; dam override to F only; absent species → 2; vectorized length/order; injected
  `breedingTable`.
- `checkParentAge`, new params, on a **species-bearing fixture** (rhesus): a 3-yr male
  sire is flagged (floor 4) while a 3-yr female dam is not (floor 2.5) — proves sex+
  species correctness.
- `checkParentAge` back-compat: `checkParentAge(qcPed, minParentAge = 6L)` still returns
  `nrow == 6` (qcPed has no species → floor 6 both sexes) AND emits a deprecation
  warning (`expect_warning`/`lifecycle::expect_deprecated`).
- Migrate the existing `test_checkParentAge.R` golden calls (`minParentAge = 2L/3L/5L/
  6L/10L`) to `minSireAge=/minDamAge=` so they do not trip the deprecation warning; the
  golden counts (0,0,1,6,…) must be **unchanged** for the species-less `qcPed`.
- `qcStudbook` / `runQcStudbook`: new params thread through; `suspiciousParents` output
  unchanged for species-less fixtures; deprecation-path test for each.

**GREEN (minimum impl):**
- Add `resolveBreedingAge` (`@noRd`).
- `checkParentAge`: add `minSireAge`, `minDamAge`, `minParentAge = lifecycle::
  deprecated()`; merge sire/dam **species** (mirror the `sireBirth`/`damBirth` merges);
  replace the flat cutoff at `:94-95` with per-parent floors from `resolveBreedingAge`.
- `qcStudbook` (`:177`, `:251`) and `runQcStudbook` (`:40`, `:87`, `:173`): add the two
  new params + deprecated `minParentAge`; thread to `checkParentAge` with the new names
  (no self-deprecation).

**Completion criteria:**
- New + migrated tests pass; `checkParentAge(qcPed, minParentAge=6L)` → `nrow 6` + warns.
- Species-aware fixture proves M/F+species floors.
- Full suite clean (`test_dir`, isolating true offenders per CLAUDE.md), `R CMD check
  --as-cran` from repo root: no ERROR/WARNING/NOTE.
- `man/checkParentAge.Rd`, `man/qcStudbook.Rd`, `man/runQcStudbook.Rd` regenerated.

**Verification:** `Rscript -e 'pkgload::load_all("."); testthat::test_file(
"tests/testthat/test_checkParentAge.R")'`; then `test_qcStudbook.R`,
`test_runQcStudbook.R`; then full `test_dir` + `--as-cran`.

**Session boundary:** one session. Close out when done.

**Dragons:** (1) parent-vs-offspring species merge (§1). (2) `qcPed`/`breederPed`
fixtures have no `species` column → must degrade to 2, never error. (3) migrating
existing goldens vs. adding new ones — keep the species-less goldens numerically
identical; only *add* species-aware assertions.

---

### Slice 2 — `getPotentialParents`

**RED:** candidate filtering uses per-candidate sex+species floors — a 2-yr rhesus male
is NOT proposed as a sire (floor 4) but the current flat-2 behavior is reproduced when
`minParentAge` (alias) or explicit equal overrides are supplied; absent-species →
floor 2 (existing goldens unchanged); deprecation-path test.

**GREEN:** signature adds `minSireAge`/`minDamAge` + `minParentAge = deprecated()`; move
the flat cutoff (`:97`) INTO the sire (`:104`) and dam (`:112`) selections, each gated
by `resolveBreedingAge` for that candidate's species+sex. Keep the gestation logic
(`mgp`, `births`, `births_plus_minus_one`) untouched.

**Completion:** `test_getPotentialParents.R` goldens preserved for species-less input;
new species-aware assertions added; suite + `--as-cran` clean; `man/getPotentialParents.
Rd` regenerated.

**Session boundary:** one session.

**Dragons:** the age cutoff currently pre-filters `ba` before the split — moving it into
each sex branch changes control flow; keep the `if (nrow(ba)==0) next` early-out
correct. Verify no candidate set silently empties (issue9 R3).

---

### Slice 3 — `getProductionStatus` + `getGeneticDiversityStats` caller

**RATIFY R1 first** (2-vs-3). Recommendation: preserve 3 as an explicit `minDamAge`
override; do not auto-switch this consumer to the table default (that would drop the
floor to 2 / 2.5 and change dam counts silently).

**RED:** `getProductionStatus` with `minDamAge` reproduces the current dam count for the
existing fixture at floor 3; deprecation-path test; `getGeneticDiversityStats` passes
`minDamAge = 3L` and production goldens are unchanged.

**GREEN:** rename param to `minDamAge` (+ deprecated `minParentAge`); `sex=="F" & age >=
minDamAge`; update the caller. `getProductionStatus` is `@noRd` — no man page, but keep
its roxygen `@param` accurate.

**Completion:** `test_getProductionStatus.R` + `test_getGeneticDiversityStats*` goldens
unchanged; suite + `--as-cran` clean.

**Session boundary:** one session.

**Dragons:** only a dam floor exists here (no `minSireAge`). Do not add a sire param to a
females-only function. The 3 is load-bearing — changing it moves production ratios.

---

### Slice 4 — Shiny UI migration (`modInput`, `modPotentialParents`, `appServer` wiring)

**RATIFY R2 first** (two-field UX).

**RED:** `testServer(modInputServer, …)` drives two inputs (`minSireAge`, `minDamAge`),
blank → table default, and asserts they reach `qcStudbook`/`runQcStudbook`;
`modPotentialParentsServer` receives and forwards the two floors; app-level tests
(`test_appServer_server.R`, `test-e2e-*`) still pass.

**GREEN:**
- `modInput.R`: replace the single `textInput("minParentAge")` (`:127`) with two fields;
  rewrite `:448-472` to compute `minSireAge`/`minDamAge` (blank/NA → `NULL` → table
  default) and pass the new params; rename/retire the exposed reactive (`:659-660`) —
  **first verify nothing reads `inputResults$minParentAge`** (grep found no consumer in
  `appServer.R`; confirm across `R/` before deleting).
- `modPotentialParents.R`: signature (`:223`) and call (`:264`) take the two floors.
- `appServer.R:345`: wire `modPotentialParentsServer` to the Input-tab floors (today it
  is unwired — decide whether Potential Parents should follow the UI fields or keep its
  own default; owner call, note under R2).

**Completion:** **Phase 3E runtime smoke test is MANDATORY** — launch `runGeneKeepR()`,
confirm the two age fields render, QC and Potential Parents run and honor them, no
console errors. Suite + `--as-cran` clean.

**Session boundary:** one session.

**Dragons:** this changes runtime behavior — build-clean is necessary but NOT sufficient
(FM #24). The unwired `modPotentialParents` (`appServer.R:345`) and the orphan reactive
(`modInput.R:659`) are pre-existing; clean them deliberately, do not expand scope beyond
the migration.

---

### Slice 5 — Docs, vignettes, screenshot, WORDLIST, NEWS

**Scope:** update every user-facing reference so the package renders WITHOUT tripping its
own deprecation warning (a vignette that still calls `minParentAge=` will warn on
rebuild and can fail `R CMD check`).

- Vignette calls → `minSireAge=`/`minDamAge=` (all sites in §2).
- `a2interactive.Rmd:138` footnote (the "3.5 causes an error" note) — re-verify against
  the new floors; update prose.
- `studbook-quality-control.qmd:34,161,179,214` — param-table and prose.
- `ColonyManagerTutorial.Rmd:181-185` — regenerate the input screenshot for the two new
  fields, or re-caption if the screenshot is retired.
- `inst/WORDLIST` — add `minSireAge`, `minDamAge` by hand (curated file; do NOT run
  `spelling::update_wordlist`).
- `NEWS.md` — user-facing changelog entry. **Keep issue numbers / "Slice N" OUT of
  rendered help and vignette prose** (fine in NEWS issue-refs and source comments).

**Completion:** `devtools::check()` clean **including vignette rebuild**; no deprecation
warnings emitted by package-internal doc code; spelling check passes.

**Session boundary:** one session.

---

## 4. Cross-cutting dragons / load-bearing assumptions

1. **Absent `species` column is the norm, not the exception** — `qcPed`, `breederPed`
   carry none. Every new call site builds the species vector defensively and degrades to
   floor 2. A missing column must never error. (issue9 §8-D lines 227-228.)
2. **`qcStudbook` is the front door** — any behavior change in `checkParentAge` ripples
   through the whole app. Strict TDD + full suite + `--as-cran` every slice.
3. **`deprecate_warn` warns inside tests/vignettes** — migrate internal callers and
   goldens to the new params in the SAME slice, or the package trips its own warning.
4. **Species-less goldens must not move** — the override/alias path reproduces today's
   numbers exactly. Only *add* species-aware assertions on a species-bearing fixture.
5. **Parent-vs-offspring species** in `checkParentAge` (§1) — the floor keys on the
   parent; add the sire/dam species merge.
6. **Runtime behavior change in Slice 4** — Phase 3E launch is mandatory; build-clean is
   not verification (FM #24).
7. **Curated files** — `inst/WORDLIST` hand-edited; screenshot re-generated deliberately
   (do not let a doc tool overwrite curation).

---

## 5. Build / verify (every slice)

| Purpose | Command | Pass |
|---|---|---|
| Single file (fast) | `Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_X.R", reporter="summary")'` | pass |
| Clean regression read | `as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))` → check `sum(failed)` AND `sum(error)`, isolate with `!grepl("test-app-\|test-e2e-", file)` | 0 true offenders |
| Full check | `R CMD check --as-cran` from repo root | no ERROR/WARNING/NOTE |
| Coverage (new code) | `NOT_CRAN=true` covr on changed files | >80% new code |
| Runtime (Slice 4 only) | `runGeneKeepR()` + `/verify` | fields render, QC/PP honor them |

---

## 6. Out of scope / follow-ups

- **Breeding-group formation internals** beyond `getPotentialParents` — not touched.
- **Removing the `minParentAge` alias entirely** — a later release once deprecation has
  shipped a cycle; not this campaign.
- **Unifying the 2-vs-3 default into the table for production status** — deliberately
  deferred (R1); production status keeps its distinct floor unless the owner directs
  otherwise.
- **User-configurable per-colony sire/dam overrides in the species CSV** —
  `loadSpeciesOverrides` already carries `minMaleBreedingAge`/`minFemaleBreedingAge`;
  surfacing them as UI defaults is a separate enhancement.

---

## 7. Executor checklist (per slice)

- [ ] Orient (SESSION_RUNNER Phase 0); read this plan + the triage.
- [ ] Declare TDD phase each response; gate PRE-RED→RED→GREEN→REFACTOR via
      `AskUserQuestion`.
- [ ] RED: write failing tests (species-aware + back-compat + deprecation).
- [ ] GREEN: minimum impl; migrate internal callers/goldens in the same slice.
- [ ] Regenerate `man/*.Rd`; keep R lines ≤80 (avoid new lints).
- [ ] Full suite + `--as-cran`; Slice 4 also runtime smoke test (Phase 3E).
- [ ] Close out: evaluate predecessor, self-assess, CHANGELOG + PROJECT_LEARNINGS +
      handoff, commit, push to `origin/master`. ONE slice per session.
